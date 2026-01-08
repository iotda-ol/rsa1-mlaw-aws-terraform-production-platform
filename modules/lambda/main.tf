# Lambda Module - Automation and serverless functions

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-automation"
  retention_in_days = var.log_retention_days

  tags = var.common_tags
}

# Lambda function for resource monitoring and automation
resource "aws_lambda_function" "automation" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = "${var.project_name}-automation"
  role             = var.lambda_execution_role_arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 256

  environment {
    variables = {
      PROJECT_NAME     = var.project_name
      ARTIFACTS_BUCKET = var.artifacts_bucket_name
      ECS_CLUSTER_NAME = var.ecs_cluster_name
      ASG_NAME         = var.autoscaling_group_name
    }
  }

  tags = var.common_tags

  depends_on = [aws_cloudwatch_log_group.lambda]
}

# EventBridge rule to trigger Lambda on a schedule
resource "aws_cloudwatch_event_rule" "lambda_schedule" {
  name                = "${var.project_name}-automation-schedule"
  description         = "Trigger Lambda automation function on schedule"
  schedule_expression = var.schedule_expression

  tags = var.common_tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
  target_id = "LambdaFunction"
  arn       = aws_lambda_function.automation.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.automation.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.lambda_schedule.arn
}

# Lambda for S3 event processing
resource "aws_lambda_function" "s3_processor" {
  filename         = "${path.module}/s3_processor.zip"
  function_name    = "${var.project_name}-s3-processor"
  role             = var.lambda_execution_role_arn
  handler          = "s3_processor.handler"
  source_code_hash = filebase64sha256("${path.module}/s3_processor.zip")
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      PROJECT_NAME = var.project_name
    }
  }

  tags = var.common_tags
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.artifacts_bucket_arn
}

# Note: S3 bucket notification is not configured by default to avoid
# circular dependencies. To enable S3 event processing, add the following
# to your S3 bucket configuration:
#
# resource "aws_s3_bucket_notification" "artifacts" {
#   bucket = var.artifacts_bucket_name
#   lambda_function {
#     lambda_function_arn = module.lambda.s3_processor_function_arn
#     events              = ["s3:ObjectCreated:*"]
#   }
# }

# CloudWatch Alarms for Lambda monitoring
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.project_name}-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Alert when Lambda function has errors"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.automation.function_name
  }

  tags = var.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.project_name}-lambda-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Average"
  threshold           = 50000
  alarm_description   = "Alert when Lambda function duration is high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = aws_lambda_function.automation.function_name
  }

  tags = var.common_tags
}
