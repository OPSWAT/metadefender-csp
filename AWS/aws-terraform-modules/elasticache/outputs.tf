output "elasticache_secret_arn" {
  value = aws_secretsmanager_secret.redis_secret.arn
}