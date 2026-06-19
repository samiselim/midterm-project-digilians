output "db_host" {
  description = "The address of the RDS PostgreSQL instance"
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "The port PostgreSQL listens on"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.postgres.db_name
}

output "db_user" {
  description = "The database master username"
  value       = aws_db_instance.postgres.username
}
