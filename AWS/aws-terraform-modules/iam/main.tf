######### IAM Role for EC2 Secrets Manager Access Module #########

# This module creates IAM roles and policies for attaching to an EC2 instance, allowing access to AWS Secrets Manager.

resource "aws_iam_role" "ec2_secrets_manager_role" {
  name = "${var.ENV_NAME}-${var.APP_NAME}-ec2-secrets-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# DocumentDB Policy

resource "aws_iam_policy" "secrets_manager_policy_mdss_docudb" {
  count       = var.DEPLOY_MDSS_DOCUMENTDB ? 1 : 0
  name        = "${var.ENV_NAME}-${var.APP_NAME}-documentdb-secrets-manager-policy"
  description = "Policy granting access to AWS Secrets Manager for MDSS DccumentDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "${var.MDSS_DOCUDB_ARN}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy_mdss_docudb" {
  count      = var.DEPLOY_MDSS_DOCUMENTDB ? 1 : 0
  role       = aws_iam_role.ec2_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy_mdss_docudb[0].arn
}

# AmazonMQ policy

resource "aws_iam_policy" "secrets_manager_policy_mdss_amazonmq" {
  count       = var.DEPLOY_MDSS_AMAZONMQ ? 1 : 0
  name        = "${var.ENV_NAME}-${var.APP_NAME}-amazonmq-secrets-manager-policy"
  description = "Policy granting access to AWS Secrets Manager for MDSS AmazonMQ"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "${var.MDSS_AMAZONMQ_ARN}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy_mdss_amazonmq" {
  count      = var.DEPLOY_MDSS_AMAZONMQ ? 1 : 0
  role       = aws_iam_role.ec2_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy_mdss_amazonmq[0].arn
}

# Elasticache policy

resource "aws_iam_policy" "secrets_manager_policy_mdss_elasticache" {
  count       = var.DEPLOY_MDSS_ELASTICACHE ? 1 : 0
  name        = "${var.ENV_NAME}-${var.APP_NAME}-elasticache-secrets-manager-policy"
  description = "Policy granting access to AWS Secrets Manager for MDSS Elasticache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = "${var.MDSS_ELASTICACHE_ARN}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_manager_policy_mdss_elasticache" {
  count      = var.DEPLOY_MDSS_ELASTICACHE ? 1 : 0
  role       = aws_iam_role.ec2_secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy_mdss_elasticache[0].arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.ENV_NAME}-${var.APP_NAME}-ec2-instance-profile"
  role = aws_iam_role.ec2_secrets_manager_role.name
}