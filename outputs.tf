# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# S3 Outputs
output "artifacts_bucket_name" {
  description = "Name of the artifacts S3 bucket"
  value       = module.s3.artifacts_bucket_name
}

output "logs_bucket_name" {
  description = "Name of the logs S3 bucket"
  value       = module.s3.logs_bucket_id
}

# EC2 Outputs
output "ec2_autoscaling_group_name" {
  description = "Name of the EC2 Auto Scaling Group"
  value       = module.ec2.autoscaling_group_name
}

output "ec2_security_group_id" {
  description = "ID of the EC2 security group"
  value       = module.ec2.security_group_id
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.cluster_arn
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.service_name
}

# Lambda Outputs
output "lambda_automation_function_name" {
  description = "Name of the Lambda automation function"
  value       = module.lambda.automation_function_name
}

output "lambda_s3_processor_function_name" {
  description = "Name of the Lambda S3 processor function"
  value       = module.lambda.s3_processor_function_name
}

# CloudWatch Outputs
output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = module.cloudwatch.dashboard_name
}

# IAM Outputs
output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = module.iam.ec2_instance_profile_name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = module.iam.ecs_task_execution_role_arn
}

output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.iam.lambda_execution_role_arn
}

# Summary Output
output "deployment_summary" {
  description = "Summary of deployed infrastructure"
  value = {
    project_name         = var.project_name
    region               = var.aws_region
    vpc_cidr             = var.vpc_cidr
    ec2_instances        = "${var.ec2_min_size}-${var.ec2_max_size}"
    ecs_tasks            = "${var.ecs_min_capacity}-${var.ecs_max_capacity}"
    artifacts_bucket     = module.s3.artifacts_bucket_name
    cloudwatch_dashboard = module.cloudwatch.dashboard_name
  }
}
