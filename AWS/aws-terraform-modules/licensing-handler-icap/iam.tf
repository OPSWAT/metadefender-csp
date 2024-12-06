
######### Detection Services #########

resource "aws_iam_role" "ts_lambda_role" {
  name               = "core-worker-lambda-role-${var.ENV_NAME}-${var.APP_NAME}"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "policy_lambda_complete" {
  name        = "lambda_complete_lifecycle_policy-${var.ENV_NAME}-${var.APP_NAME}"
  path        = "/"
  description = "Lambda comple lifecycle policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:CompleteLifecycleAction"
      ],
      "Resource": "arn:aws:autoscaling:*:${local.account_id}:autoScalingGroup:*:*"
    }
  ]
})
}

resource "aws_iam_policy" "policy_lambda_aws_clients" {
  name        = "lambda_aws_client_policy-${var.ENV_NAME}-${var.APP_NAME}"
  path        = "/"
  description = "Lambda use aws sdk clients"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ssm:*",
      ],
      "Resource": "*"
    }
  ]
})
}



data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}



data "aws_iam_policy" "lambda_logging" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda-complete-attach" {
  role       = aws_iam_role.ts_lambda_role.name
  policy_arn = aws_iam_policy.policy_lambda_complete.arn
}

resource "aws_iam_role_policy_attachment" "lambda-logging-attach" {
  role       = aws_iam_role.ts_lambda_role.name
  policy_arn = data.aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role_policy_attachment" "lambda-aws-clients-attach" {
  role       = aws_iam_role.ts_lambda_role.name
  policy_arn = aws_iam_policy.policy_lambda_aws_clients.arn
}