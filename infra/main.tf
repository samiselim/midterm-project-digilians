# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

# ==========================================
# VPC MODULE (Community)
# ==========================================
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.env}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Single NAT Gateway for Dev to save cost, Multi-AZ NAT for Prod HA
  enable_nat_gateway     = true
  single_nat_gateway     = var.env == "prod" ? false : true
  one_nat_gateway_per_az = var.env == "prod" ? true : false

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = var.env
  }
}

# ==========================================
# ECR REPOSITORIES (Community)
# ==========================================
module "ecr_backend" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name                 = "${var.env}-backend"
  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = var.env
  }
}

module "ecr_frontend" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name                 = "${var.env}-frontend"
  repository_image_tag_mutability = "MUTABLE"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Retain only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = var.env
  }
}

# ==========================================
# ALB MODULE (Community - v9.x)
# ==========================================
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name    = "${var.env}-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "HTTPS web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  security_group_egress_rules = {
    all = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  listeners = merge(
    # HTTP Listener
    {
      http = {
        port     = 80
        protocol = "HTTP"
        redirect = var.certificate_arn != "" ? {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        } : null
        forward = var.certificate_arn == "" ? {
          target_group_key = "frontend"
        } : null
      }
    },
    # HTTPS Listener (conditionally included if certificate_arn is provided)
    var.certificate_arn != "" ? {
      https = {
        port            = 443
        protocol        = "HTTPS"
        certificate_arn = var.certificate_arn
        ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
        forward = {
          target_group_key = "frontend"
        }
      }
    } : {}
  )

  target_groups = {
    frontend = {
      name_prefix = "f-"
      protocol    = "HTTP"
      port        = 80
      target_type = "instance"
      health_check = {
        path                = "/"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-399"
      }
    }
    backend = {
      name_prefix = "b-"
      protocol    = "HTTP"
      port        = 8000
      target_type = "instance"
      health_check = {
        path                = "/health"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 3
        unhealthy_threshold = 3
        matcher             = "200-399"
      }
    }
  }

  tags = {
    Environment = var.env
  }
}

# Native Path-Based Routing Rules for ALB
resource "aws_lb_listener_rule" "api_http" {
  count        = var.certificate_arn == "" ? 1 : 0
  listener_arn = module.alb.listeners["http"].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = module.alb.target_groups["backend"].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "api_https" {
  count        = var.certificate_arn != "" ? 1 : 0
  listener_arn = module.alb.listeners["https"].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = module.alb.target_groups["backend"].arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# ==========================================
# SECURITY GROUPS (EC2 & RDS)
# ==========================================
resource "aws_security_group" "ec2" {
  name        = "${var.env}-ec2-host-sg"
  description = "Security group for EC2 host running Docker containers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  ingress {
    description     = "Allow API port 8000 from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb.security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-ec2-host-sg"
    Environment = var.env
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow PostgreSQL from application instances"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-rds-sg"
    Environment = var.env
  }
}

# ==========================================
# RDS POSTGRESQL MODULE (Community)
# ==========================================
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${var.env}-postgres-db"

  engine               = "postgres"
  engine_version       = "15.7"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100

  db_name  = var.db_name
  username = var.db_user
  password = var.db_password
  port     = "5432"

  # Networking and Security
  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets
  vpc_security_group_ids = [aws_security_group.rds.id]

  # DB Parameter Group is disabled to use engine defaults
  create_db_parameter_group = false
  create_db_option_group    = false

  multi_az = var.db_multi_az

  # dev environment skips final snapshots, prod does not
  skip_final_snapshot       = var.env == "prod" ? false : true
  final_snapshot_identifier_prefix = var.env == "prod" ? "${var.env}-rds-final-" : null

  tags = {
    Environment = var.env
  }
}

# ==========================================
# AUTO SCALING GROUP MODULE (Community)
# ==========================================
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.0"

  name = "${var.env}-asg"

  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  
  target_group_arns = [
    module.alb.target_groups["frontend"].arn,
    module.alb.target_groups["backend"].arn
  ]

  # Launch template configuration
  launch_template_name        = "${var.env}-launch-template"
  launch_template_description = "Launch template for full-stack containers"
  update_default_version      = true

  image_id          = data.aws_ami.al2023.id
  instance_type     = var.instance_type
  ebs_optimized     = true
  enable_monitoring = true

  create_iam_instance_profile = false
  iam_instance_profile_arn    = aws_iam_instance_profile.ec2_profile.arn

  security_groups = [aws_security_group.ec2.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region       = var.aws_region
    ecr_registry_url = split("/", module.ecr_backend.repository_url)[0]
    backend_image    = "${module.ecr_backend.repository_url}:latest"
    frontend_image   = "${module.ecr_frontend.repository_url}:latest"
    db_host          = module.rds.db_instance_address
    db_port          = module.rds.db_instance_port
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    jwt_secret       = var.jwt_secret
    env              = var.env
  }))

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tags = {
    Environment = var.env
  }
}

# ==========================================
# IAM ROLES & PROFILES (Native)
# ==========================================
resource "aws_iam_role" "ec2_role" {
  name = "${var.env}-ec2-container-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.env}-ec2-container-role"
    Environment = var.env
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_policy" "ec2_custom_policy" {
  name        = "${var.env}-ec2-custom-policy"
  description = "Allows logging to CloudWatch and reading database credentials"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_custom_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.env}-ec2-container-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# GitHub OIDC Setup
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_oidc_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}

locals {
  oidc_provider_arn = var.create_oidc_provider ? aws_iam_openid_connect_provider.github[0].arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
}

resource "aws_iam_role" "github_actions" {
  name = "${var.env}-github-actions-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = local.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" : "repo:${var.github_repo}:*"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.env}-github-actions-role"
    Environment = var.env
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.env}-github-actions-policy"
  description = "Allows pushing to ECR and updating ASG / Launch Templates"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:*:*:repository/*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ModifyLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:StartInstanceRefresh",
          "autoscaling:DescribeInstanceRefreshes",
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}
