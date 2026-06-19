# Export the ID of the VPC created by the VPC community module.
output "vpc_id" {
  # Provide a human-readable description explaining what this output represents.
  description = "The ID of the VPC"
  # Fetch the value directly from the output parameters of the instantiated VPC module.
  value = module.vpc.vpc_id
}

# Export the public DNS address of the Application Load Balancer.
output "alb_dns_name" {
  # Expose this as the primary web application entry point URL for user web browsers.
  description = "The public DNS name of the Application Load Balancer"
  # Reference the generated DNS name output by the ALB community module.
  value = module.alb.dns_name
}

# Export the private endpoint address of the RDS PostgreSQL database.
output "rds_host" {
  # This host address is used by backend application containers to locate and connect to the database.
  description = "The host address of the RDS database"
  # Reference the DNS endpoint string exposed by the RDS database module.
  value = module.rds.db_instance_address
}


# Export the repository URL for the backend image registry.
output "backend_ecr_url" {
  # The build pipeline uses this URL to tag and push the compiled Express.js Docker backend image.
  description = "The ECR Repository URL for the backend image"
  # Fetch the repository URL attribute from the backend ECR module.
  value = module.ecr_backend.repository_url
}

# Export the repository URL for the frontend image registry.
output "frontend_ecr_url" {
  # The build pipeline uses this URL to tag and push the compiled Nginx-packaged frontend static image.
  description = "The ECR Repository URL for the frontend image"
  # Fetch the repository URL attribute from the frontend ECR module.
  value = module.ecr_frontend.repository_url
}

