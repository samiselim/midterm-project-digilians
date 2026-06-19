variable "env" {
  description = "The environment name"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "certificate_arn" {
  description = "The ARN of the ACM SSL Certificate. If empty, traffic will be served over HTTP on port 80."
  type        = string
  default     = ""
}
