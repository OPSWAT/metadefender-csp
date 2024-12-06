locals {
    // Account ID for passing to IAM policies
    account_id = data.aws_caller_identity.current.account_id


	// The name of our lambda function when is created in AWS
	function_name = "core-worker-lambda"
	function_layer_name = "core-worker-lambda-layer"
	// When our lambda is run / invoked later on, run the "handler"
	// function exported from the "index" file
	handler = "index.handler"
	// Run our lambda in node v20
	runtime = "nodejs20.x"

	// The .zip file we will create and upload to AWS later on
	zip_file = "core-worker-lambda.zip"
	function_layer_zip_file = "nodejs.zip"
} 