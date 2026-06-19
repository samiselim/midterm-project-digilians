output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

output "rds_host" {
  description = "The host address of the RDS database"
  value       = module.rds.db_instance_address
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM Role for GitHub Actions CI/CD to assume"
  value       = aws_iam_role.github_actions.arn
}

output "backend_ecr_url" {
  description = "The ECR Repository URL for the backend image"
  value       = module.ecr_backend.repository_url
}

output "frontend_ecr_url" {
  description = "The ECR Repository URL for the frontend image"
  value       = module.ecr_frontend.repository_url
}
