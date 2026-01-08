variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
}

variable "artifacts_bucket_arn" {
  description = "ARN of the S3 artifacts bucket"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
