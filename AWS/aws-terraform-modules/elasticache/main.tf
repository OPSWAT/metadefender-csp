# Generate a random password for Amazon MQ
resource "random_password" "redis_auth_token" {
  length  = 32
  special = false
}

# Create secret in AWS Secret Manager

resource "random_pet" "name_suffix" {
  length = 2
}

# Create an ElastiCache for Redis cluster
resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name        = "mdss-elasticache-${var.ENV_NAME}-subnet-group"
  description = "Subnet group for ElastiCache Redis cluster in ${var.ENV_NAME} environment"
  subnet_ids  = var.PRIV_SUBNET_IDS
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  description                   = "Elasticache for Redis used in Metadefender Storage Security"
  replication_group_id          = "mdss-elasticache-${var.ENV_NAME}"
  engine                        = "redis"
  engine_version                = "7.1" 
  node_type                     = "${var.MDSS_ELASTICACHE_NODE_TYPE}"
  num_cache_clusters            = 1
  parameter_group_name          = "default.redis7"
  port                          = 6379
  transit_encryption_enabled    = true

  # Authentication
  auth_token                    = random_password.redis_auth_token.result

  # Availability and failover settings
  automatic_failover_enabled    = false   # Enable for multi-AZ failover
  multi_az_enabled              = false

  # Security settings
  security_group_ids            = [var.SG_ID]
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.name
}

# Create secret in AWS Secrets Manager

resource "aws_secretsmanager_secret" "redis_secret" {
  name        = "${var.ENV_NAME}-elasticache-uri_${random_pet.name_suffix.id}"
  description = "Auth token for the ElastiCache Redis cluster"
}


# Store the Redis authentication token and URI in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "redis_secret_version" {
  secret_id     = aws_secretsmanager_secret.redis_secret.id
  secret_string = jsonencode({
  auth_token    = random_password.redis_auth_token.result
  uri           = "${aws_elasticache_replication_group.redis_cluster.primary_endpoint_address}:${aws_elasticache_replication_group.redis_cluster.port},user=default,password=${random_password.redis_auth_token.result},syncTimeout=10000,ssl=True"
  })
}