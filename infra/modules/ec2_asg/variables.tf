variable "env" {
  description = "The environment name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the EC2 hosts"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "The name of the IAM instance profile"
  type        = string
}

variable "alb_security_group_id" {
  description = "The security group ID of the ALB to allow inbound traffic from"
  type        = string
}

variable "target_group_frontend_arn" {
  description = "The ARN of the frontend ALB target group"
  type        = string
}

variable "target_group_backend_arn" {
  description = "The ARN of the backend ALB target group"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "aws_region" {
  description = "AWS Region where the resources are deployed"
  type        = string
}

variable "ecr_registry_url" {
  description = "The base ECR registry URL (e.g., account.dkr.ecr.region.amazonaws.com)"
  type        = string
}

variable "backend_image" {
  description = "ECR Image URI for the backend container"
  type        = string
}

variable "frontend_image" {
  description = "ECR Image URI for the frontend container"
  type        = string
}

variable "db_host" {
  description = "The database endpoint address"
  type        = string
}

variable "db_port" {
  description = "The database port"
  type        = string
  default     = "5432"
}

variable "db_name" {
  description = "The database name"
  type        = string
  default     = "LeaveTrackDB"
}

variable "db_user" {
  description = "The database username"
  type        = string
}

variable "db_password" {
  description = "The database password"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT Secret for application authentication"
  type        = string
  sensitive   = true
}
