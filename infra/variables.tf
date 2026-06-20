# Target geographic region in AWS where resources should be provisioned.
variable "aws_region" {
  description = "The target AWS Region for production resources"
  type        = string
  default     = "us-east-1"
}

# The identifier of the environment tier (e.g., 'dev', 'prod', 'staging'). Used for resource naming prefixes.
variable "env" {
  description = "The environment name"
  type        = string
  default     = "prod"
}

# The main IP range block (CIDR format) allocated to the virtual private cloud.
variable "vpc_cidr" {
  description = "The CIDR block for the production VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# The list of public subnet IP sub-ranges inside the VPC. Public subnets are routed to the Internet Gateway.
variable "public_subnets" {
  description = "List of public subnet CIDRs for production"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

# The list of Availability Zones (AZs) in which subnets are distributed for High Availability.
variable "azs" {
  description = "List of Availability Zones in production"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Name of the primary database schema created inside PostgreSQL.
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "LeaveTrackDB"
}

# Name of the AWS Secrets Manager secret housing our database credentials (username and password in JSON format).
variable "db_credentials_secret_name" {
  description = "The name or ARN of the AWS Secrets Manager secret for database credentials"
  type        = string
  default     = "db-credentials"
}


# EC2 instance class type to use for the Auto Scaling Group compute hosts.
variable "instance_type" {
  description = "The EC2 host instance class for production"
  type        = string
  default     = "t3.small" # Production-grade compute resource
}

# The lower boundary of running EC2 hosts that the Auto Scaling Group must maintain.
variable "min_size" {
  description = "Minimum count of instances in ASG for HA"
  type        = number
  default     = 2
}

# The upper boundary of running EC2 hosts that the Auto Scaling Group can scale out to.
variable "max_size" {
  description = "Maximum count of instances in ASG for scale"
  type        = number
  default     = 4
}

# The desired number of active EC2 hosts to launch initially.
variable "desired_capacity" {
  description = "Desired count of instances in ASG for HA"
  type        = number
  default     = 2
}



# The ACM Certificate ARN needed to enable HTTPS traffic termination at the load balancer.
variable "certificate_arn" {
  description = "The ARN of the ACM SSL Certificate for HTTPS. If empty, routes traffic over HTTP on port 80."
  type        = string
  default     = ""
}

# Allocated database storage size in Gigabytes for the RDS database.
variable "db_allocated_storage" {
  description = "Allocated storage size for RDS database in GB"
  type        = number
  default     = 20
}

# The DB instance class type determining memory and CPU capacity allocated to the RDS database.
variable "db_instance_class" {
  description = "The DB instance class"
  type        = string
  default     = "db.t3.micro"
}

# Boolean flag to toggle RDS synchronous database replication across multiple Availability Zones.
variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

# The name of the SSH key pair to allow SSH access to the EC2 instance.
variable "key_name" {
  description = "The name of the SSH key pair to associate with the EC2 instance"
  type        = string
  default     = ""
}


