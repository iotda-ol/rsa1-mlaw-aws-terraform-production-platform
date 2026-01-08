output "automation_function_name" {
  description = "Name of the automation Lambda function"
  value       = aws_lambda_function.automation.function_name
}

output "automation_function_arn" {
  description = "ARN of the automation Lambda function"
  value       = aws_lambda_function.automation.arn
}

output "s3_processor_function_name" {
  description = "Name of the S3 processor Lambda function"
  value       = aws_lambda_function.s3_processor.function_name
}

output "s3_processor_function_arn" {
  description = "ARN of the S3 processor Lambda function"
  value       = aws_lambda_function.s3_processor.arn
}

output "eventbridge_rule_arn" {
  description = "ARN of the EventBridge rule"
  value       = aws_cloudwatch_event_rule.lambda_schedule.arn
}
