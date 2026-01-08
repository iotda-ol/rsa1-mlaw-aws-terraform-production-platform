# General Configuration
variable "project_name" {
  description = "Name of the project, used for resource naming"
  type        = string
  default     = "prod-platform"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "ProductionPlatform"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "vpc_flow_logs_retention_days" {
  description = "Number of days to retain VPC flow logs"
  type        = number
  default     = 30
}

# S3 Configuration
variable "s3_logs_retention_days" {
  description = "Number of days to retain S3 access logs"
  type        = number
  default     = 90
}

# EC2 Configuration
variable "ec2_instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "ec2_min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 4
}

variable "ec2_desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 2
}

# ECS Configuration
variable "ecs_container_image" {
  description = "Docker image for ECS tasks"
  type        = string
  default     = "nginx:latest"
}

variable "ecs_container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS tasks"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for ECS tasks in MB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 10
}

variable "ecs_log_retention_days" {
  description = "Number of days to retain ECS logs"
  type        = number
  default     = 30
}

# Lambda Configuration
variable "lambda_schedule_expression" {
  description = "Schedule expression for Lambda automation"
  type        = string
  default     = "rate(5 minutes)"
}

variable "lambda_log_retention_days" {
  description = "Number of days to retain Lambda logs"
  type        = number
  default     = 30
}

# CloudWatch Configuration
variable "create_sns_topic" {
  description = "Create SNS topic for CloudWatch alarms"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = ""
}
