variable "aws_region" {
  description = "The target AWS Region for production resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "The CIDR block for the production VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs for production"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs for production"
  type        = list(string)
  default     = ["10.1.3.0/24", "10.1.4.0/24"]
}

variable "azs" {
  description = "List of Availability Zones in production"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "LeaveTrackDB"
}

variable "db_user" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret for application validation"
  type        = string
  sensitive   = true
}

variable "github_repo" {
  description = "The target GitHub repository in format 'org/repo' for OIDC trust"
  type        = string
}

variable "instance_type" {
  description = "The EC2 host instance class for production"
  type        = string
  default     = "t3.small" # Production-grade compute resource
}

variable "min_size" {
  description = "Minimum count of instances in ASG for HA"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum count of instances in ASG for scale"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired count of instances in ASG for HA"
  type        = number
  default     = 2
}

variable "create_oidc_provider" {
  description = "Set to true if OIDC provider for GitHub needs to be created, false if it already exists"
  type        = bool
  default     = false # Usually shared/created in dev
}

variable "certificate_arn" {
  description = "The ARN of the ACM SSL Certificate for HTTPS. If empty, routes traffic over HTTP on port 80."
  type        = string
  default     = ""
}

variable "db_allocated_storage" {
  description = "Allocated storage size for RDS database in GB"
  type        = number
  default     = 20
}

variable "db_instance_class" {
  description = "The DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}
