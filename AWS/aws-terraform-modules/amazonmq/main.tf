# Generate a random password for Amazon MQ
resource "random_password" "mq_password" {
  length  = 16
  special = false
}

# Create secret in AWS Secret Manager
resource "random_pet" "name_suffix" {
  length = 2
}

# Create an Amazon MQ cluster with RabbitMQ
resource "aws_mq_broker" "rabbitmq_cluster" {
  broker_name        = "mdss-amazonmq-${var.ENV_NAME}"
  engine_type        = "RabbitMQ"
  engine_version     = "3.13" 
  host_instance_type = "${var.MDSS_AMAZONMQ_INSTANCE_TYPE}"
  security_groups    = [var.SG_ID]
  subnet_ids         = [var.PRIV_SUBNET_IDS[0]]


  user {
    username = "admin"
    password = random_password.mq_password.result
  }

  publicly_accessible  = false
  apply_immediately    = true
  auto_minor_version_upgrade = true

  encryption_options {
    use_aws_owned_key = true
  }

  logs {
    general = true
  }
}

# Create secret for the MQ URI
resource "aws_secretsmanager_secret" "mq_uri_secret" {
  name        = "${var.ENV_NAME}-amazonmq-uri_${random_pet.name_suffix.id}"
  description = "URI for the Amazon MQ RabbitMQ cluster"
}

# Store the URI in Secrets Manager
resource "aws_secretsmanager_secret_version" "mq_uri_secret_version" {
  secret_id     = aws_secretsmanager_secret.mq_uri_secret.id
  secret_string = jsonencode({
  uri           = "amqps://admin:${random_password.mq_password.result}@${aws_mq_broker.rabbitmq_cluster.id}.mq.${var.MD_REGION}.amazonaws.com:5671"
  })
}