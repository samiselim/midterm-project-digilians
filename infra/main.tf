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

  # Disable lifecycle policy creation.
  create_lifecycle_policy = false

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

  # Disable lifecycle policy creation.
  create_lifecycle_policy = false

  tags = {
    Environment = var.env
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
    description = "Allow HTTP from anywhere"
    # Allow traffic on port 80.
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow API port 8000 from anywhere"
    # Allow traffic on port 8000.
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open for remote workflow deployments
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
  engine_version       = "15.18"
  family               = "postgres15"
  major_engine_version = "15"
  # The computing and memory hardware size allocated to the database (injected via tfvars).
  instance_class = var.db_instance_class

  # Disk space settings.
  allocated_storage = var.db_allocated_storage
  # Enable Auto-Scaling storage limit up to 100GB to accommodate future data growth dynamically.
  max_allocated_storage = 100

  # Admin connection credential parameters.
  db_name                     = var.db_name
  username                    = local.db_creds["username"]
  password                    = local.db_creds["password"]
  port                        = "5432"
  apply_immediately           = true
  manage_master_user_password = false
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
# SINGLE EC2 INSTANCE RESOURCE
# ==========================================
# Provision a single EC2 instance for the full-stack container host.
resource "aws_instance" "web" {
  # Deploy inside the first public subnet.
  subnet_id = module.vpc.public_subnets[0]
  # Specify the latest Amazon Linux 2023 machine image.
  ami           = data.aws_ami.al2023.id
  instance_type = var.instance_type

  # Associate our custom security group rules.
  vpc_security_group_ids = [aws_security_group.ec2.id]

  # Automatically assign a public IP address for internet routing.
  associate_public_ip_address = true

  # Attach an optional SSH key pair name.
  key_name = var.key_name != "" ? var.key_name : null

  # Bootstrap virtual instances using the user_data.sh shell script.
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host          = module.rds.db_instance_address
    db_port          = module.rds.db_instance_port
    db_name          = var.db_name
    db_user          = local.db_creds["username"]
    db_password      = local.db_creds["password"]
    jwt_secret       = local.db_creds["jwt_secret"]
    aws_region       = var.aws_region
    ecr_registry_url = module.ecr_frontend.repository_url
  }))

  tags = {
    Name        = "${var.env}-web-server"
    Environment = var.env
  }
}

# ==========================================
# ROUTE 53 DNS CONFIGURATION
# ==========================================
# 1. Fetch the existing Route 53 Hosted Zone created by your domain registration
data "aws_route53_zone" "main" {
  name         = "digilians.com"
  private_zone = false
}

# 2. Create an A record to route traffic to the EC2 instance
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "digilians.com"
  type    = "A"
  ttl     = 300
  
  # Point directly to the EC2 instance's auto-assigned public IP
  records = [aws_instance.web.public_ip]
}
