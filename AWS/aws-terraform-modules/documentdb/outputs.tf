output "docdb_secret_arn" {
  description = "The ARN of the DocumentDB secret in Secrets Manager."
  value       = aws_secretsmanager_secret.docdb_secret.arn

}