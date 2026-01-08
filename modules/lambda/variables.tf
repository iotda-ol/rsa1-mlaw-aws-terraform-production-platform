variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 artifacts bucket"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the S3 artifacts bucket"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "schedule_expression" {
  description = "CloudWatch Events schedule expression for Lambda automation"
  type        = string
  default     = "rate(5 minutes)"
}

variable "log_retention_days" {
  description = "Number of days to retain Lambda logs"
  type        = number
  default     = 30
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
