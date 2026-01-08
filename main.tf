# Production-Grade AWS Infrastructure with Terraform
# This configuration demonstrates scalable compute, secure IAM, 
# serverless automation, and comprehensive CloudWatch monitoring

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment for remote state management
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "production/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Data source for available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# S3 Module - Must be created first for IAM policies
module "s3" {
  source = "./modules/s3"

  project_name        = var.project_name
  aws_account_id      = data.aws_caller_identity.current.account_id
  logs_retention_days = var.s3_logs_retention_days
  common_tags         = var.common_tags
}

# VPC Module - Networking foundation
module "vpc" {
  source = "./modules/vpc"

  project_name             = var.project_name
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  enable_nat_gateway       = var.enable_nat_gateway
  enable_flow_logs         = var.enable_vpc_flow_logs
  flow_logs_retention_days = var.vpc_flow_logs_retention_days
  common_tags              = var.common_tags
}

# IAM Module - Least-privilege security design
module "iam" {
  source = "./modules/iam"

  project_name         = var.project_name
  artifacts_bucket_arn = module.s3.artifacts_bucket_arn
  common_tags          = var.common_tags

  depends_on = [module.s3]
}

# EC2 Module - Scalable compute with Auto Scaling
module "ec2" {
  source = "./modules/ec2"

  project_name              = var.project_name
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                  = module.vpc.vpc_cidr
  private_subnet_ids        = module.vpc.private_subnet_ids
  ami_id                    = data.aws_ami.amazon_linux_2.id
  instance_type             = var.ec2_instance_type
  min_size                  = var.ec2_min_size
  max_size                  = var.ec2_max_size
  desired_capacity          = var.ec2_desired_capacity
  iam_instance_profile_name = module.iam.ec2_instance_profile_name
  common_tags               = var.common_tags

  depends_on = [module.vpc, module.iam]
}

# ECS Module - Serverless container orchestration
module "ecs" {
  source = "./modules/ecs"

  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  vpc_cidr                = module.vpc.vpc_cidr
  private_subnet_ids      = module.vpc.private_subnet_ids
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn
  container_image         = var.ecs_container_image
  container_port          = var.ecs_container_port
  task_cpu                = var.ecs_task_cpu
  task_memory             = var.ecs_task_memory
  desired_count           = var.ecs_desired_count
  min_capacity            = var.ecs_min_capacity
  max_capacity            = var.ecs_max_capacity
  log_retention_days      = var.ecs_log_retention_days
  aws_region              = var.aws_region
  common_tags             = var.common_tags

  depends_on = [module.vpc, module.iam]
}

# Lambda Module - Automation and serverless functions
module "lambda" {
  source = "./modules/lambda"

  project_name              = var.project_name
  lambda_execution_role_arn = module.iam.lambda_execution_role_arn
  artifacts_bucket_name     = module.s3.artifacts_bucket_name
  artifacts_bucket_arn      = module.s3.artifacts_bucket_arn
  ecs_cluster_name          = module.ecs.cluster_name
  autoscaling_group_name    = module.ec2.autoscaling_group_name
  schedule_expression       = var.lambda_schedule_expression
  log_retention_days        = var.lambda_log_retention_days
  common_tags               = var.common_tags

  depends_on = [module.iam, module.s3, module.ecs, module.ec2]
}

# CloudWatch Module - Comprehensive monitoring
module "cloudwatch" {
  source = "./modules/cloudwatch"

  project_name          = var.project_name
  aws_region            = var.aws_region
  ecs_cluster_name      = module.ecs.cluster_name
  artifacts_bucket_name = module.s3.artifacts_bucket_name
  create_sns_topic      = var.create_sns_topic
  alarm_email           = var.alarm_email
  common_tags           = var.common_tags

  depends_on = [module.ecs, module.s3]
}
