
data "archive_file" "zip" {
	excludes = [
		"cloudwatch.tf",
		"iam.tf",
		"lambda.tf",
		"locals.tf",
		"outputs.tf",
		"variables.tf",
    local.zip_file,
    "nodejs.zip",
	]
	source_dir = path.module
	type = "zip"

	// Create the .zip file in the same directory as the index.js file
	output_path = "${path.module}/${local.zip_file}"
}

resource "aws_security_group" "allow_outbound_lambda" {
  name        = "allow_outbound_lambda-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Allow lambda outbound traffic"
  vpc_id      = var.VPC_ID

  tags = {
    Name = "allow_lambda_outbound"
  }
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_outbound_lambda.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = "${path.module}/${local.function_layer_zip_file}"
  layer_name = local.function_layer_name

  compatible_runtimes = [local.runtime]
}


resource "aws_lambda_function" "core_activation_worker" {
	// Function parameters 
	function_name = local.function_name
	handler = local.handler
	runtime = local.runtime

	// Upload the .zip file Terraform created to AWS
	filename = "${path.module}/${local.zip_file}"
	source_code_hash = data.archive_file.zip.output_base64sha256
  
  layers = [aws_lambda_layer_version.lambda_layer.arn]

  vpc_config {
    # Every subnet should be able to reach an EFS mount target in the same Availability Zone. Cross-AZ mounts are not permitted.
    subnet_ids         = var.SUBNET_IDS
    security_group_ids = [aws_security_group.allow_outbound_lambda.id,var.DEFAULT_SG_ID]
  }

  timeout = 600

	// Connect our IAM resource to our lambda function in AWS
	role = aws_iam_role.ts_lambda_role.arn

  environment {
    variables = {
      LICENSE_KEY = var.LICENSE_KEY
      APIKEY      = var.APIKEY
      ICAP_PWD    = var.ICAP_PWD
    }
  }

}
