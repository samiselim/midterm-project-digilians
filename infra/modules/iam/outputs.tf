output "ec2_instance_profile_name" {
  description = "The name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions CI/CD"
  value       = aws_iam_role.github_actions.arn
}
