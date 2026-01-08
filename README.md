# Production-Grade AWS Reference Architecture

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-purple.svg)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Production-grade AWS reference architecture built with Terraform, showcasing scalable compute, secure IAM, serverless automation, and full CloudWatch observability. This repository demonstrates DevOps engineering best practices for real-world production workloads.

## 🏗️ Architecture Overview

This reference architecture implements a comprehensive production-ready AWS infrastructure with the following components:

### Core Infrastructure Components

1. **VPC Networking** - Multi-AZ networking foundation
   - Public and private subnets across multiple availability zones
   - NAT Gateways for secure outbound connectivity from private subnets
   - VPC Flow Logs for network traffic monitoring
   - Internet Gateway for public subnet connectivity

2. **EC2 Compute** - Scalable virtual machines with Auto Scaling
   - Auto Scaling Group with configurable min/max capacity
   - Launch Template with IMDSv2 security hardening
   - CloudWatch agent for enhanced metrics and logging
   - CPU-based auto-scaling policies
   - Security groups with least-privilege network access

3. **ECS Fargate** - Serverless container orchestration
   - ECS Cluster with Container Insights enabled
   - Fargate and Fargate Spot capacity providers
   - Auto-scaling based on CPU and memory utilization
   - Deployment circuit breakers for safe rollouts
   - CloudWatch Logs integration

4. **IAM Security** - Least-privilege access control
   - Separate roles for EC2, ECS, and Lambda
   - Fine-grained policies scoped to specific resources
   - Instance profiles for EC2 workloads
   - Task execution and task roles for ECS
   - Lambda execution roles with minimal permissions

5. **Lambda Automation** - Serverless functions for infrastructure management
   - Resource monitoring and health checks
   - Automated metric collection and reporting
   - S3 event processing
   - Scheduled execution via EventBridge
   - CloudWatch alarms for error monitoring

6. **S3 Storage** - Secure artifact storage
   - Versioning enabled for data protection
   - Server-side encryption (AES-256)
   - Public access blocked by default
   - Lifecycle policies for cost optimization
   - Access logging to separate bucket

7. **CloudWatch Monitoring** - Comprehensive observability
   - Unified dashboard for all infrastructure metrics
   - Log aggregation from all services
   - Metric filters for error tracking
   - Composite alarms for critical issues
   - CloudWatch Insights query definitions
   - Optional SNS notifications

## 📋 Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- AWS account with appropriate permissions to create resources
- Basic understanding of AWS services and Terraform

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/iotda-ol/rsa1-mlaw-aws-terraform-production-platform.git
cd rsa1-mlaw-aws-terraform-production-platform
```

### 2. Configure Variables

Copy the example variables file and customize it for your environment:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` to set your desired configuration:

```hcl
project_name = "my-production-platform"
aws_region   = "us-east-1"

# EC2 Configuration
ec2_instance_type    = "t3.micro"
ec2_min_size         = 1
ec2_max_size         = 4
ec2_desired_capacity = 2

# ECS Configuration
ecs_desired_count = 2
ecs_min_capacity  = 1
ecs_max_capacity  = 10

# Enable CloudWatch alarms via email
create_sns_topic = true
alarm_email      = "your-email@example.com"
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Deploy the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. View Outputs

After successful deployment, Terraform will display outputs including:

```bash
terraform output
```

## 📦 Module Structure

```
.
├── main.tf                 # Root module orchestrating all components
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── terraform.tfvars.example # Example configuration
├── modules/
│   ├── vpc/               # VPC and networking resources
│   ├── ec2/               # EC2 Auto Scaling Group
│   ├── ecs/               # ECS Fargate cluster and service
│   ├── iam/               # IAM roles and policies
│   ├── lambda/            # Lambda functions for automation
│   ├── s3/                # S3 buckets for artifacts and logs
│   └── cloudwatch/        # CloudWatch dashboards and alarms
└── README.md              # This file
```

## 🔐 Security Features

This architecture implements multiple layers of security:

- **Network Security**: Private subnets for compute, NAT gateways for outbound access
- **IAM Least Privilege**: Minimal permissions scoped to specific resources
- **Encryption**: Server-side encryption for S3 buckets
- **IMDSv2**: Enforced on EC2 instances for metadata security
- **VPC Flow Logs**: Network traffic monitoring and auditing
- **Public Access Blocking**: S3 buckets blocked from public access
- **Security Groups**: Restrictive ingress rules, permissive egress

## 📊 Monitoring and Observability

The infrastructure includes comprehensive monitoring:

- **CloudWatch Dashboard**: Unified view of EC2, ECS, Lambda, and S3 metrics
- **Log Aggregation**: Centralized logging from all services
- **Metric Filters**: Automated error detection and counting
- **Custom Metrics**: Application-specific metrics from Lambda
- **Composite Alarms**: Multi-condition alerting for critical issues
- **CloudWatch Insights**: Pre-configured queries for troubleshooting

## 🎯 Use Cases

This reference architecture is suitable for:

- **Web Applications**: Scalable web tier with EC2 or ECS
- **Microservices**: Container-based services on ECS Fargate
- **Batch Processing**: Lambda-based event-driven workflows
- **API Backends**: RESTful APIs with auto-scaling
- **Development/Staging Environments**: Cost-effective infrastructure for testing
- **Learning**: Understanding production AWS architectures

## 💰 Cost Optimization

The architecture includes several cost optimization features:

- **Fargate Spot**: 70% discount for fault-tolerant workloads
- **S3 Lifecycle Policies**: Automatic transition to cheaper storage classes
- **Auto Scaling**: Scale down during low-traffic periods
- **T3 Instances**: Burstable performance for variable workloads
- **Log Retention**: Automatic log expiration to reduce storage costs

## 🧹 Cleanup

To destroy all resources and avoid ongoing costs:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

**Warning**: This will permanently delete all resources created by this configuration.

## 📝 Customization

### Modifying Instance Types

Edit `terraform.tfvars`:

```hcl
ec2_instance_type = "t3.small"  # Change to desired instance type
```

### Changing Region

Edit `terraform.tfvars`:

```hcl
aws_region = "us-west-2"  # Change to desired region
```

### Adjusting Auto Scaling

Edit `terraform.tfvars`:

```hcl
ec2_min_size         = 2
ec2_max_size         = 10
ec2_desired_capacity = 4
```

### Using Custom Container Images

Edit `terraform.tfvars`:

```hcl
ecs_container_image = "your-registry/your-image:tag"
ecs_container_port  = 8080
```

## 🔧 Advanced Configuration

### Remote State Management

For team collaboration, configure remote state in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

### Multi-Environment Deployment

Use Terraform workspaces or separate variable files:

```bash
terraform workspace new production
terraform workspace new staging
terraform workspace select production
```

## 📚 Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/intro.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is a reference architecture for educational and demonstration purposes. Review and adjust security settings, costs, and configurations according to your specific requirements before using in production.

## 🙋 Support

For questions or issues, please open an issue in the GitHub repository.
