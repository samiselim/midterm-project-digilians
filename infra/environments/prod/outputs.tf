output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "rds_host" {
  description = "The host address of the RDS database"
  value       = module.rds.db_host
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM Role for GitHub Actions CI/CD to assume"
  value       = module.iam.github_actions_role_arn
}

output "backend_ecr_url" {
  description = "The ECR Repository URL for the backend image"
  value       = module.ecr.backend_repository_url
}

output "frontend_ecr_url" {
  description = "The ECR Repository URL for the frontend image"
  value       = module.ecr.frontend_repository_url
}
