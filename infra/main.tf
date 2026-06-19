# Query AWS to find the latest Amazon Linux 2023 machine image.
# This prevents hardcoding the AMI ID, which changes regularly and varies across regions.
data "aws_ami" "al2023" {
  # Grab the most recently created image matching our filters.
  most_recent = true
  # Limit search results to official AMIs published directly by Amazon.
  owners = ["amazon"]

  # Define filter criteria to isolate Amazon Linux 2023 x86_64 minimal kernel 6.1 editions.
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

# ==========================================
# VPC MODULE (Community)
# ==========================================
# Instantiate the community VPC module. This manages public subnets, private subnets, routing tables, and gateways automatically.
module "vpc" {
  # Source location of the official VPC module on the HashiCorp Terraform registry.
  source = "terraform-aws-modules/vpc/aws"
  # Lock the version to the v5.x track to avoid breaking api changes.
  version = "~> 5.0"

  # Name of the VPC, dynamically prefixed with our active environment tier.
  name = "${var.env}-vpc"
  # Primary IP allocation pool assigned to the VPC.
  cidr = var.vpc_cidr

  # Availability Zones where subnets will be created to ensure multi-datacenter failover.
  azs = var.azs
  # IP range allocations for external public subnets facing the internet.
  public_subnets = var.public_subnets

  # Automatically assign public IP addresses to instances launched inside the public subnets.
  map_public_ip_on_launch = true

  # Disable NAT Gateways entirely to use only the default Internet Gateway for the VPC.
  enable_nat_gateway = false

  # Enable DNS hostnames inside the VPC network to allow hostname resolution.
  enable_dns_hostnames = true
  # Enable DNS resolution support inside the VPC.
  enable_dns_support = true

  # Resource tags applied to VPC infrastructure assets.
  tags = {
    Environment = var.env
  }
}

# ==========================================
# ECR REPOSITORIES (Community)
# ==========================================
# Instantiate the official community ECR module for our backend application image.
module "ecr_backend" {
  # Source registry path.
  source = "terraform-aws-modules/ecr/aws"
  # Lock version to the v2.x track.
  version = "~> 2.0"

  # Name the repository according to environment prefixes.
  repository_name = "${var.env}-backend"
  # Allow overwriting existing image tags (e.g. latest tag is replaced by new builds).
  repository_image_tag_mutability = "MUTABLE"

  # Apply a lifecycle policy to remove old images, preventing storage costs from accumulating.
  # repository_lifecycle_policy = jsonencode({
  #   rules = [
  #     {
  #       rulePriority = 1
  #       description  = "Retain only the last 10 images"
  #       selection = {
  #         # Target all tags.
  #         tagStatus = "any"
  #         # Select by quantity limit.
  #         countType = "imageCountMoreThan"
  #         # Store a maximum of 10 images before purging oldest.
  #         countNumber = 10
  #       }
  #       action = {
  #         # Expire the matched files.
  #         type = "expire"
  #       }
  #     }
  #   ]
  # })

  # Tag resource for tracking.
  tags = {
    Environment = var.env
  }
}

# Instantiate the ECR module for our frontend static web service.
module "ecr_frontend" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 2.0"

  repository_name                 = "${var.env}-frontend"
  repository_image_tag_mutability = "MUTABLE"

  # Retain only the last 10 builds to save space and minimize storage costs.
  # repository_lifecycle_policy = jsonencode({
  #   rules = [
  #     {
  #       rulePriority = 1
  #       description  = "Retain only the last 10 images"
  #       selection = {
  #         tagStatus   = "any"
  #         countType   = "imageCountMoreThan"
  #         countNumber = 10
  #       }
  #       action = {
  #         type = "expire"
  #       }
  #     }
  #   ]
  # })

  tags = {
    Environment = var.env
  }
}

# ==========================================
# ALB MODULE (Community - v9.x)
# ==========================================
# Instantiate the Application Load Balancer (ALB) module to route incoming client traffic to frontend and backend targets.
module "alb" {
  # Source registry path.
  source = "terraform-aws-modules/alb/aws"
  # Pin to v9.x, which uses modern target group and listener routing definitions.
  version = "~> 9.0"

  # Environment-prefixed name for the ALB.
  name = "${var.env}-alb"
  # Attach the ALB to our VPC.
  vpc_id = module.vpc.vpc_id
  # Deploy the ALB in our public subnets to expose it to the internet.
  subnets = module.vpc.public_subnets

  # Define internal security group rules for the ALB.
  security_group_ingress_rules = {
    # Accept standard web traffic on HTTP port 80.
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0" # Open to the global internet.
    }
  }
  security_group_egress_rules = {
    # Allow outbound traffic to go anywhere (needed to forward requests to instances in private subnets).
    all = {
      ip_protocol = "-1" # Represents all protocols.
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  # Configure traffic listeners.
  listeners = {
    # HTTP Listener (port 80)
    http = {
      port     = 80
      protocol = "HTTP"
      # Forward HTTP traffic to the frontend target group directly.
      forward = {
        target_group_key = "frontend"
      }
    }
  }

  # Define backend target pools where requests will be balanced.
  target_groups = {
    # Target group for serving static web files.
    frontend = {
      name_prefix       = "f-"
      protocol          = "HTTP"
      port              = 80
      target_type       = "instance" # Target physical EC2 instances.
      create_attachment = false      # Disabled because ASG dynamically attaches instances.
      # Configure health checks to verify that Nginx is running and serving files.
      health_check = {
        path                = "/"       # Home route.
        interval            = 15        # Run check every 15 seconds.
        timeout             = 5         # Wait up to 5 seconds before failing.
        healthy_threshold   = 3         # Require 3 consecutive successes to declare healthy.
        unhealthy_threshold = 3         # Require 3 consecutive failures to declare unhealthy.
        matcher             = "200-399" # Acceptable success response codes.
      }
    }
    # Target group for routing API logic queries.
    backend = {
      name_prefix       = "b-"
      protocol          = "HTTP"
      port              = 8000
      target_type       = "instance" # Target physical EC2 instances.
      create_attachment = false      # Disabled because ASG dynamically attaches instances.
      # Configure health check to query the application API health endpoint.
      health_check = {
        path                = "/health" # Express health check route.
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
# Create a path routing rule for HTTP listener if SSL/HTTPS certificate is disabled.
resource "aws_lb_listener_rule" "api_http" {
  # Attach to the HTTP port 80 listener.
  listener_arn = module.alb.listeners["http"].arn
  # Set priority to 10. Low priority ensures path rule is checked before general default routing.
  priority = 10

  # Action to take when route is matched.
  action {
    type = "forward"
    # Forward matching traffic to the backend target group (Express API server).
    target_group_arn = module.alb.target_groups["backend"].arn
  }

  # Route evaluation trigger criteria.
  condition {
    path_pattern {
      # Match any incoming request path starting with "/api/".
      values = ["/api/*"]
    }
  }
}

# ==========================================
# SECURITY GROUPS (EC2 & RDS)
# ==========================================
# Configure the Security Group (firewall) for the EC2 virtual hosts.
resource "aws_security_group" "ec2" {
  # Name prefix.
  name        = "${var.env}-ec2-host-sg"
  description = "Security group for EC2 host running Docker containers"
  # Associate firewall rules with our custom VPC.
  vpc_id = module.vpc.vpc_id

  # Inbound Rules
  ingress {
    description = "Allow HTTP from ALB"
    # Allow traffic on port 80.
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    # RESTRICTION: Only accept traffic arriving from the Load Balancer security group.
    security_groups = [module.alb.security_group_id]
  }

  ingress {
    description = "Allow API port 8000 from ALB"
    # Allow traffic on port 8000.
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    # RESTRICTION: Only accept traffic arriving from the Load Balancer security group.
    security_groups = [module.alb.security_group_id]
  }

  # Outbound Rules
  egress {
    # Allow EC2 hosts to call out to any destination (required to download packages, pull ECR images).
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols.
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.env}-ec2-host-sg"
    Environment = var.env
  }
}

# Configure the Security Group (firewall) for the RDS database instance.
resource "aws_security_group" "rds" {
  name        = "${var.env}-rds-sg"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow PostgreSQL from application instances"
    # Accept standard PostgreSQL communication port 5432.
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # RESTRICTION: Only accept connection requests coming from EC2 instances in the ec2 security group.
    security_groups = [aws_security_group.ec2.id]
  }

  egress {
    # Allow database to make outbound calls if needed.
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
# AWS SECRETS MANAGER DATABASE CREDENTIALS
# ==========================================
# Query AWS Secrets Manager for metadata on the database credentials secret.
# This secret is stored manually in the AWS console and houses the database username and password.
data "aws_secretsmanager_secret" "db_credentials" {
  # The identifier (name or ARN) of the secret containing database connection details.
  name = var.db_credentials_secret_name
}

# Fetch the version payload (secret string) of the database credentials secret.
data "aws_secretsmanager_secret_version" "db_credentials" {
  # Bind the data lookup to the retrieved database credentials secret ID.
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

# Parse and decode the JSON payload structure of the database credentials secret.
# This assumes the secret is configured with keys "username" and "password".
locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.db_credentials.secret_string)
}

# ==========================================
# RDS POSTGRESQL MODULE (Community)
# ==========================================
# Instantiate community RDS PostgreSQL module to deploy a managed database.
module "rds" {
  # Registry source.
  source = "terraform-aws-modules/rds/aws"
  # Lock RDS module version.
  version = "~> 6.0"

  # Unique RDS resource name prefix.
  identifier = "${var.env}-postgres-db"

  # Specify engine type, version, parameter family, and minor version locks.
  engine               = "postgres"
  engine_version       = "15.7"
  family               = "postgres15"
  major_engine_version = "15"
  # The computing and memory hardware size allocated to the database (injected via tfvars).
  instance_class = var.db_instance_class

  # Disk space settings.
  allocated_storage = var.db_allocated_storage
  # Enable Auto-Scaling storage limit up to 100GB to accommodate future data growth dynamically.
  max_allocated_storage = 100

  # Admin connection credential parameters.
  db_name  = var.db_name
  username = local.db_creds["username"]
  password = local.db_creds["password"]
  port     = "5432"

  # Networking and Security
  # Automatically generate a DB Subnet Group across public subnets since we have no private subnets.
  create_db_subnet_group = true
  # Bind database to public subnets.
  subnet_ids = module.vpc.public_subnets
  # Bind the RDS firewall security group rules.
  vpc_security_group_ids = [aws_security_group.rds.id]

  # DB Parameter Group is disabled to use default database configurations.
  create_db_parameter_group = false
  create_db_option_group    = false

  # High availability replication toggle. Set to true in prod to create synchronous replica in secondary AZ.
  multi_az = var.db_multi_az

  # Dev environment skips database final snapshot on delete to save costs. Prod does not skip.
  skip_final_snapshot = var.env == "prod" ? false : true
  # If in prod, name final backup snapshot to prevent permanent data loss on teardown.
  final_snapshot_identifier_prefix = var.env == "prod" ? "${var.env}-rds-final-" : null

  tags = {
    Environment = var.env
  }
}

# ==========================================
# AUTO SCALING GROUP MODULE (Community)
# ==========================================
# Instantiate the community Auto Scaling Group (ASG) module to manage and scale EC2 compute host instances.
module "asg" {
  # Registry source.
  source = "terraform-aws-modules/autoscaling/aws"
  # Lock to the v7.x version track.
  version = "~> 7.0"

  # Prefix name for ASG resources.
  name = "${var.env}-asg"

  # Set scaling bounds based on active environment variables.
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  # EC2 monitors instance hardware health to determine if an instance needs replacement.
  health_check_type = "EC2"
  # Deploy virtual machines inside public subnets since we have no private subnets.
  vpc_zone_identifier = module.vpc.public_subnets

  # Register EC2 instances with the Application Load Balancer target groups.
  target_group_arns = [
    module.alb.target_groups["frontend"].arn,
    module.alb.target_groups["backend"].arn
  ]

  # Launch template configuration (defines virtual machine boot parameters)
  launch_template_name        = "${var.env}-launch-template"
  launch_template_description = "Launch template for full-stack containers"
  # Set ASG to automatically pick up and boot from the latest launch template version version updates.
  update_default_version = true

  # Set instance properties.
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  # Optimize EBS throughput for improved storage I/O performance.
  ebs_optimized = true
  # Enable CloudWatch detailed monitoring (1-minute intervals).
  enable_monitoring = true

  # Bind the EC2 security group firewall rules.
  security_groups = [aws_security_group.ec2.id]

  # Bootstrap virtual instances using the user_data.sh shell script.
  # We read the file, inject variable placeholders (like ECR urls, database links, secrets, access keys), and base64-encode it.
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = module.rds.db_instance_address
    db_port     = module.rds.db_instance_port
    db_name     = var.db_name
    db_user     = local.db_creds["username"]
    db_password = local.db_creds["password"]
    jwt_secret  = local.db_creds["jwt_secret"]
  }))

  tags = {
    Environment = var.env
  }
}





