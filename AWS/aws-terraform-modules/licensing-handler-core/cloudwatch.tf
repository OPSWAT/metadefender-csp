

########### Rule for Initial Hook  ###########
resource "aws_cloudwatch_event_rule" "asg_initial_hook_rule" {
  name        = "capture-asg-initial-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup Initial Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-launch Lifecycle Action" ],
  "detail": {
      "Origin": [ "EC2" ],
      "Destination": [ "AutoScalingGroup" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_initial_hook_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.asg_initial_hook_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_initial_hook" {
    statement_id = "AllowExecutionFromCloudWatchInitialRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.asg_initial_hook_rule.arn
}

########### Rule for initial_warmpool Hook  ###########

resource "aws_cloudwatch_event_rule" "asg_initial_warmpool_rule" {
  name        = "capture-asg-initial-warmpool-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup Initial WarmPool Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-launch Lifecycle Action" ],
  "detail": {
      "Origin": [ "EC2" ],
      "Destination": [ "WarmPool" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_initial_warmpool_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.asg_initial_warmpool_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_lambda_initial_warmpool" {
    statement_id = "AllowExecutionFromCloudWatchInitialWarmPoolRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.asg_initial_warmpool_rule.arn
}

########### Rule for asg_to_warm Hook  ###########
resource "aws_cloudwatch_event_rule" "asg_to_warm_rule" {
  name        = "capture-asg-to-warm-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup ASG To Warm Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-terminate Lifecycle Action" ],
  "detail": {
      "Origin": [ "AutoScalingGroup" ],
      "Destination": [ "WarmPool" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_to_warm_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.asg_to_warm_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_asg_to_warm" {
    statement_id = "AllowExecutionFromCloudWatchAsgToWarmPoolRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.asg_to_warm_rule.arn
}

########### Rule for warm_to_asg Hook  ###########

resource "aws_cloudwatch_event_rule" "warm_to_asg_rule" {
  name        = "capture-warm-to-asg-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup Warm to ASG Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-launch Lifecycle Action" ],
  "detail": {
      "Origin": [ "WarmPool" ],
      "Destination": [ "AutoScalingGroup" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_warm_to_asg_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.warm_to_asg_rule.name
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_warm_to_asg" {
    statement_id = "AllowExecutionFromCloudWatchWarmPoolToAsgRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.warm_to_asg_rule.arn
}


########### Rule for warm_to_terminate Hook  ###########

resource "aws_cloudwatch_event_rule" "warm_to_terminate_rule" {
  name        = "capture-warm-to-terminate-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup Warm to terminate Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-terminate Lifecycle Action" ],
  "detail": {
      "Origin": [ "WarmPool" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_warm_to_terminate_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.warm_to_terminate_rule.name
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_warm_to_terminate" {
    statement_id = "AllowExecutionFromCloudWatchWarmPoolToTermintateRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.warm_to_terminate_rule.arn
}

########### Rule for autoscaling_to_terminate Hook  ###########

resource "aws_cloudwatch_event_rule" "autoscaling_to_terminate_rule" {
  name        = "capture-asg-to-terminate-hook-${var.ENV_NAME}-${var.APP_NAME}"
  description = "Capture autoScalingGroup to terminate Hook"

  event_pattern = jsonencode({
  "source": [ "aws.autoscaling" ],
  "detail-type": [ "EC2 Instance-terminate Lifecycle Action" ],
  "detail": {
      "Origin": [ "AutoScalingGroup" ]
   }
  })
}


resource "aws_cloudwatch_event_target" "asg_autoscaling_to_terminate_event_target" {
    arn = aws_lambda_function.core_activation_worker.arn
    rule = aws_cloudwatch_event_rule.autoscaling_to_terminate_rule.name
}


resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda_asg_to_terminate" {
    statement_id = "AllowExecutionFromCloudWatchASGToTermintateRule"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.core_activation_worker.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.autoscaling_to_terminate_rule.arn
}

