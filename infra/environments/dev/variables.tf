variable "aws_region" {
  description = "The target AWS Region for resources"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "azs" {
  description = "List of Availability Zones"
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
  description = "The EC2 host instance class"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum count of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum count of instances in ASG"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired count of instances in ASG"
  type        = number
  default     = 1
}

variable "create_oidc_provider" {
  description = "Set to true if OIDC provider for GitHub needs to be created, false if it already exists"
  type        = bool
  default     = true
}
