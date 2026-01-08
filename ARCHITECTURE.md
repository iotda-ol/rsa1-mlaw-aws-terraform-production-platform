# Architecture Diagram

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (VPC)                           │
│                                                                     │
│  ┌──────────────────────┐         ┌──────────────────────┐        │
│  │   Public Subnets     │         │   Public Subnets     │        │
│  │      (AZ-1)          │         │      (AZ-2)          │        │
│  │                      │         │                      │        │
│  │  ┌────────────────┐  │         │  ┌────────────────┐  │        │
│  │  │  NAT Gateway   │  │         │  │  NAT Gateway   │  │        │
│  │  └────────────────┘  │         │  └────────────────┘  │        │
│  └──────────┬───────────┘         └──────────┬───────────┘        │
│             │                                 │                     │
│  ┌──────────▼───────────┐         ┌──────────▼───────────┐        │
│  │   Private Subnets    │         │   Private Subnets    │        │
│  │      (AZ-1)          │         │      (AZ-2)          │        │
│  │                      │         │                      │        │
│  │  ┌────────────────┐  │         │  ┌────────────────┐  │        │
│  │  │ EC2 Instances  │  │         │  │ EC2 Instances  │  │        │
│  │  │   (ASG)        │  │         │  │   (ASG)        │  │        │
│  │  └────────────────┘  │         │  └────────────────┘  │        │
│  │                      │         │                      │        │
│  │  ┌────────────────┐  │         │  ┌────────────────┐  │        │
│  │  │  ECS Tasks     │  │         │  │  ECS Tasks     │  │        │
│  │  │  (Fargate)     │  │         │  │  (Fargate)     │  │        │
│  │  └────────────────┘  │         │  └────────────────┘  │        │
│  └──────────────────────┘         └──────────────────────┘        │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                        Supporting Services                          │
│                                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐             │
│  │   Lambda     │  │      S3      │  │  CloudWatch  │             │
│  │  Functions   │  │   Buckets    │  │  Monitoring  │             │
│  │              │  │              │  │              │             │
│  │ - Automation │  │ - Artifacts  │  │ - Dashboard  │             │
│  │ - S3 Events  │  │ - Logs       │  │ - Alarms     │             │
│  └──────────────┘  └──────────────┘  └──────────────┘             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      IAM Security Layer                             │
│                                                                     │
│  EC2 Roles → CloudWatch + S3 Read Access                           │
│  ECS Roles → CloudWatch + S3 Read/Write Access                     │
│  Lambda Roles → EC2/ECS Describe + S3 + CloudWatch                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Component Interactions

### Data Flow

1. **EC2 Auto Scaling Group**
   - Instances launch in private subnets
   - CloudWatch agent sends metrics and logs
   - Access S3 artifacts via IAM role
   - Outbound internet via NAT Gateway

2. **ECS Fargate Service**
   - Tasks run in private subnets
   - Pull container images from registry
   - Write logs to CloudWatch
   - Scale based on CPU/memory metrics

3. **Lambda Functions**
   - Scheduled automation (EventBridge)
   - S3 event processing
   - Monitor EC2 and ECS resources
   - Store reports in S3

4. **CloudWatch Monitoring**
   - Aggregate logs from all services
   - Custom metrics from Lambda
   - Dashboard for visualization
   - Alarms for critical issues

5. **S3 Storage**
   - Artifacts bucket with versioning
   - Logs bucket for access logs
   - Lifecycle policies for cost optimization
   - Encryption at rest (AES-256)

## Network Architecture

### VPC CIDR: 10.0.0.0/16

- **Public Subnets** (AZ1: 10.0.0.0/24, AZ2: 10.0.1.0/24)
  - Internet Gateway attached
  - NAT Gateways deployed
  - Route to 0.0.0.0/0 via IGW

- **Private Subnets** (AZ1: 10.0.2.0/24, AZ2: 10.0.3.0/24)
  - EC2 instances
  - ECS tasks
  - Route to 0.0.0.0/0 via NAT Gateway

## Security Architecture

### Defense in Depth

1. **Network Layer**
   - VPC isolation
   - Security groups (stateful firewall)
   - Private subnets for compute
   - VPC Flow Logs enabled

2. **Identity & Access**
   - Least-privilege IAM roles
   - Resource-based policies
   - No hardcoded credentials
   - Instance profiles for EC2

3. **Data Protection**
   - S3 encryption at rest
   - S3 versioning enabled
   - Public access blocked
   - Access logging enabled

4. **Monitoring & Detection**
   - CloudWatch Logs aggregation
   - Metric filters for errors
   - Alarms for anomalies
   - VPC Flow Logs

## Scalability

### Auto Scaling Mechanisms

1. **EC2 Auto Scaling**
   - CPU-based scaling policies
   - Min: 1, Max: 4 instances
   - 5-minute evaluation periods
   - Gradual scale-up/down

2. **ECS Service Auto Scaling**
   - CPU utilization target: 70%
   - Memory utilization target: 80%
   - Min: 1, Max: 10 tasks
   - Target tracking scaling

3. **Cost Optimization**
   - Fargate Spot for non-critical tasks
   - T3 burstable instances
   - Auto-scale down during low traffic
   - S3 lifecycle transitions

## High Availability

### Multi-AZ Deployment

- Resources deployed across 2+ availability zones
- NAT Gateways in each AZ
- ECS tasks distributed across AZs
- EC2 instances spread across AZs
- Auto Scaling ensures capacity

## Disaster Recovery

### Backup & Recovery

1. **S3 Versioning**
   - All artifacts versioned
   - Accidental deletion protection
   - Point-in-time recovery

2. **CloudWatch Logs**
   - Retained for 30 days
   - Exportable to S3
   - Query with Insights

3. **Infrastructure as Code**
   - All resources defined in Terraform
   - Version controlled
   - Repeatable deployments
   - Easy to recreate in DR region
