# Deployment Guide

This guide provides step-by-step instructions for deploying the production-grade AWS infrastructure.

## Prerequisites Checklist

Before deploying, ensure you have:

- [ ] AWS account with administrative access
- [ ] AWS CLI installed and configured
- [ ] Terraform >= 1.0 installed
- [ ] Basic understanding of AWS services
- [ ] Sufficient AWS service limits for your region

## Pre-Deployment Steps

### 1. AWS CLI Configuration

Configure your AWS credentials:

```bash
aws configure
```

Provide:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Default output format (json)

Verify your configuration:

```bash
aws sts get-caller-identity
```

### 2. Check AWS Service Limits

Verify your account has sufficient limits:

```bash
# Check VPC limit
aws ec2 describe-account-attributes --attribute-names max-vpcs

# Check EC2 instance limit
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-1216C47A
```

### 3. Choose Deployment Region

Select an AWS region based on:
- Geographic proximity to users
- Service availability
- Compliance requirements
- Cost considerations

Popular regions:
- `us-east-1` - US East (N. Virginia) - Largest service offering
- `us-west-2` - US West (Oregon) - Cost-effective
- `eu-west-1` - Europe (Ireland) - EU compliance
- `ap-southeast-1` - Asia Pacific (Singapore) - APAC users

## Deployment Process

### Step 1: Clone the Repository

```bash
git clone https://github.com/iotda-ol/rsa1-mlaw-aws-terraform-production-platform.git
cd rsa1-mlaw-aws-terraform-production-platform
```

### Step 2: Configure Variables

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your preferred settings:

```hcl
# Basic Configuration
project_name = "my-prod-platform"
aws_region   = "us-east-1"

# Resource Tags
common_tags = {
  Project     = "MyProductionPlatform"
  Environment = "Production"
  ManagedBy   = "Terraform"
  Owner       = "DevOps Team"
  CostCenter  = "Engineering"
}

# EC2 Configuration
ec2_instance_type    = "t3.micro"  # Change based on workload
ec2_min_size         = 1
ec2_max_size         = 4
ec2_desired_capacity = 2

# ECS Configuration
ecs_container_image  = "nginx:latest"  # Replace with your image
ecs_container_port   = 80
ecs_desired_count    = 2
ecs_min_capacity     = 1
ecs_max_capacity     = 10

# Monitoring
create_sns_topic = true
alarm_email      = "ops-team@example.com"  # Your email
```

### Step 3: Initialize Terraform

Download required providers and modules:

```bash
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 4: Plan Deployment

Generate an execution plan:

```bash
terraform plan -out=tfplan
```

Review the plan carefully:
- Number of resources to create
- Resource types
- Dependencies
- Estimated costs

### Step 5: Deploy Infrastructure

Apply the Terraform configuration:

```bash
terraform apply tfplan
```

Or interactively:

```bash
terraform apply
```

Type `yes` when prompted.

Deployment typically takes 5-10 minutes.

### Step 6: Verify Deployment

Check the outputs:

```bash
terraform output
```

Verify resources in AWS Console:

1. **VPC Dashboard**
   - Check VPC creation
   - Verify subnets in multiple AZs
   - Confirm NAT Gateways

2. **EC2 Dashboard**
   - Verify Auto Scaling Group
   - Check running instances
   - Review security groups

3. **ECS Console**
   - Confirm cluster creation
   - Check running tasks
   - Verify service status

4. **CloudWatch Console**
   - Open the dashboard
   - Review metrics
   - Check log groups

5. **S3 Console**
   - Verify artifacts bucket
   - Check encryption settings
   - Review lifecycle policies

6. **Lambda Console**
   - Verify function creation
   - Check recent executions
   - Review CloudWatch logs

### Step 7: Configure SNS Notifications (Optional)

If you enabled SNS notifications:

1. Check your email for subscription confirmation
2. Click the confirmation link
3. Verify subscription in AWS SNS Console

## Post-Deployment Configuration

### Configure Application Deployment

#### For EC2 Instances

1. Create an AMI with your application
2. Update `terraform.tfvars`:
   ```hcl
   ami_id = "ami-xxxxxxxxxxxx"
   ```
3. Apply changes:
   ```bash
   terraform apply
   ```

#### For ECS Fargate

1. Push your Docker image to ECR:
   ```bash
   # Create ECR repository
   aws ecr create-repository --repository-name my-app
   
   # Get login command
   aws ecr get-login-password --region us-east-1 | \
     docker login --username AWS --password-stdin \
     123456789012.dkr.ecr.us-east-1.amazonaws.com
   
   # Build and push image
   docker build -t my-app .
   docker tag my-app:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
   docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest
   ```

2. Update `terraform.tfvars`:
   ```hcl
   ecs_container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
   ```

3. Apply changes:
   ```bash
   terraform apply
   ```

### Configure Lambda Functions

To customize the Lambda functions:

1. Edit the Python code in `modules/lambda/index.py`
2. Update the function logic as needed
3. Repackage:
   ```bash
   cd modules/lambda
   zip lambda_function.zip index.py
   ```
4. Apply changes:
   ```bash
   terraform apply
   ```

## Monitoring & Maintenance

### Access CloudWatch Dashboard

1. Navigate to CloudWatch Console
2. Select "Dashboards"
3. Open the project dashboard
4. Pin to your favorites

### View Logs

```bash
# ECS logs
aws logs tail /aws/ecs/prod-platform --follow

# Lambda logs
aws logs tail /aws/lambda/prod-platform-automation --follow

# VPC Flow Logs
aws logs tail /aws/vpc/prod-platform-flow-logs --follow
```

### Check Resource Health

```bash
# EC2 Auto Scaling Group
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names prod-platform-asg

# ECS Service
aws ecs describe-services \
  --cluster prod-platform-cluster \
  --services prod-platform-service

# Lambda Function
aws lambda get-function \
  --function-name prod-platform-automation
```

## Scaling Operations

### Scale EC2 Capacity

Update `terraform.tfvars`:

```hcl
ec2_min_size         = 2
ec2_max_size         = 8
ec2_desired_capacity = 4
```

Apply:

```bash
terraform apply
```

### Scale ECS Service

Update `terraform.tfvars`:

```hcl
ecs_desired_count = 4
ecs_min_capacity  = 2
ecs_max_capacity  = 20
```

Apply:

```bash
terraform apply
```

## Troubleshooting

### Common Issues

#### Issue: Terraform Init Fails

**Solution:**
- Check internet connectivity
- Verify Terraform version
- Clear `.terraform` directory and retry

#### Issue: AWS Authentication Error

**Solution:**
```bash
# Verify credentials
aws sts get-caller-identity

# Reconfigure if needed
aws configure
```

#### Issue: Resource Limit Exceeded

**Solution:**
- Request limit increase in AWS Console
- Use smaller instance types
- Reduce desired capacity

#### Issue: VPC CIDR Conflict

**Solution:**
- Change `vpc_cidr` in `terraform.tfvars`
- Ensure no overlap with existing VPCs

#### Issue: ECS Task Failing to Start

**Solution:**
1. Check CloudWatch logs
2. Verify container image exists
3. Check IAM role permissions
4. Verify subnet connectivity

### Get Help

If you encounter issues:

1. Check Terraform output for error messages
2. Review CloudWatch logs
3. Verify AWS service status
4. Consult AWS documentation
5. Open an issue on GitHub

## Backup & Disaster Recovery

### State File Backup

The Terraform state contains your infrastructure configuration.

**Important:** Enable remote state for production:

1. Create S3 bucket for state:
   ```bash
   aws s3 mb s3://my-terraform-state-bucket
   ```

2. Create DynamoDB table for locking:
   ```bash
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST
   ```

3. Update `main.tf` backend configuration:
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "my-terraform-state-bucket"
       key            = "production/terraform.tfstate"
       region         = "us-east-1"
       encrypt        = true
       dynamodb_table = "terraform-state-lock"
     }
   }
   ```

4. Migrate state:
   ```bash
   terraform init -migrate-state
   ```

### Export Resource Configuration

```bash
# Export current state
terraform show > current-state.txt

# Export outputs
terraform output -json > outputs.json
```

## Cost Management

### Estimate Monthly Costs

Approximate monthly costs (us-east-1):

- **VPC & Networking**
  - NAT Gateway: $32/month × 2 = $64
  - Data transfer: ~$10-50/month

- **EC2 (t3.micro × 2)**
  - Instances: $7.50/month × 2 = $15
  - EBS volumes: ~$5/month

- **ECS Fargate (256 CPU, 512 MB × 2)**
  - Tasks: ~$12/month

- **Lambda**
  - Free tier covers most use cases
  - Additional: ~$0-5/month

- **S3**
  - Storage: $0.023/GB
  - Requests: Minimal

- **CloudWatch**
  - Logs: $0.50/GB
  - Metrics: Free tier + ~$5/month

**Estimated Total: $100-150/month**

### Reduce Costs

1. **Use Spot Instances:**
   - ECS Fargate Spot saves 70%
   - EC2 Spot for non-critical workloads

2. **Right-size Resources:**
   - Monitor CloudWatch metrics
   - Scale down unused capacity

3. **Use Reserved Instances:**
   - For predictable workloads
   - 1-3 year commitments

4. **Enable Auto Scaling:**
   - Scale down during off-hours
   - Implement scheduled scaling

5. **Optimize Storage:**
   - S3 lifecycle policies enabled
   - Delete old logs

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

**Warning:** This permanently deletes all resources. Ensure you have backups of important data.

### Partial Cleanup

To remove specific resources:

```bash
# Remove Lambda only
terraform destroy -target=module.lambda

# Remove EC2 Auto Scaling Group only
terraform destroy -target=module.ec2
```

## Next Steps

After successful deployment:

1. [ ] Configure application deployment
2. [ ] Set up CI/CD pipeline
3. [ ] Configure monitoring alerts
4. [ ] Document runbooks
5. [ ] Schedule backup procedures
6. [ ] Plan capacity scaling
7. [ ] Review security settings
8. [ ] Set up cost alerts

## Support

For additional help:
- Review [README.md](README.md)
- Check [ARCHITECTURE.md](ARCHITECTURE.md)
- Open an issue on GitHub
- Consult AWS documentation
