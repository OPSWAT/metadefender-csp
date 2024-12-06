resource "aws_docdb_subnet_group" "service" {
  subnet_ids = var.PRIV_SUBNET_IDS
}

resource "aws_docdb_cluster_instance" "service" {
  count              = 1
  identifier         = "${var.ENV_NAME}-documentdb-${count.index}"
  cluster_identifier = "${aws_docdb_cluster.service.id}"
  instance_class     = "${var.MDSS_DOCUMENTDB_INSTANCE_CLASS}"
}

# Generate random password for documentDB

resource "random_password" "docdb_password" {
  length           = 16 
  special          = false
}

# Create secret in Secrets Manager
resource "random_pet" "name_suffix" {
  length = 2
}

resource "aws_docdb_cluster" "service" {
  skip_final_snapshot     = true
  db_subnet_group_name    = "${aws_docdb_subnet_group.service.name}"
  cluster_identifier      = "mdss-documentdb-${var.ENV_NAME}"
  engine                  = "docdb"
  master_username         = "mdss_${replace(var.ENV_NAME, "-", "_")}_admin"
  master_password         = random_password.docdb_password.result
  db_cluster_parameter_group_name = "${aws_docdb_cluster_parameter_group.service.name}"
  vpc_security_group_ids = [var.SG_ID]
}

resource "aws_docdb_cluster_parameter_group" "service" {
  family = "docdb5.0"
  name = "mdss-documentdb-${var.ENV_NAME}"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

# Store the generated password in a secret and add the MongoDB URI
resource "aws_secretsmanager_secret" "docdb_secret" {
  name        = "${var.ENV_NAME}-docdb-cluster-password_${random_pet.name_suffix.id}"
  description = "Password and URI for the DocumentDB cluster used in Metadefender Storage Security"
}

resource "aws_secretsmanager_secret_version" "docdb_secret_version" {
  secret_id     = aws_secretsmanager_secret.docdb_secret.id
  secret_string = jsonencode({
    username = "mdss_${replace(var.ENV_NAME, "-", "_")}_admin"
    password = random_password.docdb_password.result
    mongo_uri = "mongodb://${"mdss_${replace(var.ENV_NAME, "-", "_")}_admin"}:${random_password.docdb_password.result}@${aws_docdb_cluster.service.endpoint}:27017/MDCS?retryWrites=false&readPreference=primaryPreferred"
  })
}