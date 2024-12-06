output "mq_secret_arn" {
  value = aws_secretsmanager_secret.mq_uri_secret.arn
}

output "rabbitmq_cluster_endpoint" {
  value = aws_mq_broker.rabbitmq_cluster.instances[0].endpoints[0]
}