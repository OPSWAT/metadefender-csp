output "iam_role_arn" {
  description = "The ARN of the IAM role for EC2."
  value       = aws_iam_role.ec2_secrets_manager_role.arn
}

output "instance_profile_arn" {
  description = "The name of the IAM instance profile."
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}
