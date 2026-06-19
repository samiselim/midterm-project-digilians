# Fetch latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }
}

# EC2 Host Instance Security Group
resource "aws_security_group" "ec2" {
  name        = "${var.env}-ec2-host-sg"
  description = "Security group for EC2 host running Docker containers"
  vpc_id      = var.vpc_id

  # Inbound traffic from ALB on port 80 (Frontend container)
  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Inbound traffic from ALB on port 8000 (Backend container)
  ingress {
    description     = "Allow API port 8000 from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  # Outbound rules to allow container updates, database query connections, SSM access, and secrets retrieval
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

# EC2 Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "${var.env}-app-launch-template-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region       = var.aws_region
    ecr_registry_url = var.ecr_registry_url
    backend_image    = var.backend_image
    frontend_image   = var.frontend_image
    db_host          = var.db_host
    db_port          = var.db_port
    db_name          = var.db_name
    db_user          = var.db_user
    db_password      = var.db_password
    jwt_secret       = var.jwt_secret
    env              = var.env
  }))

  # Ensures updates to templates prompt dynamic recreation by TF
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.env}-app-instance"
      Environment = var.env
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  name_prefix         = "${var.env}-asg-"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  # Attach target groups to route traffic to both ports on the instances
  target_group_arns = [
    var.target_group_frontend_arn,
    var.target_group_backend_arn
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Zerodowntime Rolling update when Launch Template version is bumped
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }
}
