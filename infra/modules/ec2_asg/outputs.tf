output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "ec2_security_group_id" {
  description = "The security group ID of the EC2 instances"
  value       = aws_security_group.ec2.id
}
