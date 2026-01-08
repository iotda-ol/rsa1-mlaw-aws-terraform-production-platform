variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for unique bucket naming"
  type        = string
}

variable "logs_retention_days" {
  description = "Number of days to retain S3 access logs"
  type        = number
  default     = 90
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
