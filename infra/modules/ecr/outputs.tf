output "backend_repository_url" {
  description = "The URL of the backend repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  description = "The URL of the frontend repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "registry_id" {
  description = "The registry ID where the repositories are created"
  value       = aws_ecr_repository.backend.registry_id
}
