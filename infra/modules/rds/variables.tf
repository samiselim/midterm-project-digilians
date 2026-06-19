variable "env" {
  description = "The environment name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "LeaveTrackDB"
}

variable "db_user" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage size in GB"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "The DB instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type        = bool
  default     = false
}

variable "app_security_group_id" {
  description = "The security group ID of the EC2 instances to allow DB connections from"
  type        = string
}
