import json
import boto3
import os
from datetime import datetime

# Initialize AWS clients
ec2 = boto3.client('ec2')
ecs = boto3.client('ecs')
autoscaling = boto3.client('autoscaling')
cloudwatch = boto3.client('cloudwatch')
s3 = boto3.client('s3')

def handler(event, context):
    """
    Lambda function for automating infrastructure monitoring and maintenance tasks.
    
    This function:
    - Monitors EC2 and ECS resources
    - Collects metrics and publishes to CloudWatch
    - Performs health checks
    - Stores reports in S3
    """
    
    project_name = os.environ.get('PROJECT_NAME')
    artifacts_bucket = os.environ.get('ARTIFACTS_BUCKET')
    ecs_cluster_name = os.environ.get('ECS_CLUSTER_NAME')
    asg_name = os.environ.get('ASG_NAME')
    
    print(f"Starting automation for project: {project_name}")
    
    results = {
        'timestamp': datetime.utcnow().isoformat(),
        'project': project_name,
        'checks': []
    }
    
    # Check Auto Scaling Group health
    try:
        asg_response = autoscaling.describe_auto_scaling_groups(
            AutoScalingGroupNames=[asg_name]
        )
        
        if asg_response['AutoScalingGroups']:
            asg = asg_response['AutoScalingGroups'][0]
            results['checks'].append({
                'check': 'asg_health',
                'status': 'success',
                'details': {
                    'desired_capacity': asg['DesiredCapacity'],
                    'min_size': asg['MinSize'],
                    'max_size': asg['MaxSize'],
                    'instances': len(asg['Instances'])
                }
            })
            
            # Publish custom metric
            cloudwatch.put_metric_data(
                Namespace=project_name,
                MetricData=[
                    {
                        'MetricName': 'ASG_InstanceCount',
                        'Value': len(asg['Instances']),
                        'Unit': 'Count'
                    }
                ]
            )
    except Exception as e:
        print(f"Error checking ASG: {str(e)}")
        results['checks'].append({
            'check': 'asg_health',
            'status': 'error',
            'error': str(e)
        })
    
    # Check ECS Cluster health
    try:
        ecs_response = ecs.describe_clusters(clusters=[ecs_cluster_name])
        
        if ecs_response['clusters']:
            cluster = ecs_response['clusters'][0]
            results['checks'].append({
                'check': 'ecs_health',
                'status': 'success',
                'details': {
                    'status': cluster['status'],
                    'running_tasks': cluster['runningTasksCount'],
                    'pending_tasks': cluster['pendingTasksCount'],
                    'active_services': cluster['activeServicesCount']
                }
            })
            
            # Publish custom metrics
            cloudwatch.put_metric_data(
                Namespace=project_name,
                MetricData=[
                    {
                        'MetricName': 'ECS_RunningTasks',
                        'Value': cluster['runningTasksCount'],
                        'Unit': 'Count'
                    },
                    {
                        'MetricName': 'ECS_PendingTasks',
                        'Value': cluster['pendingTasksCount'],
                        'Unit': 'Count'
                    }
                ]
            )
    except Exception as e:
        print(f"Error checking ECS: {str(e)}")
        results['checks'].append({
            'check': 'ecs_health',
            'status': 'error',
            'error': str(e)
        })
    
    # Store report in S3
    try:
        report_key = f"automation-reports/{datetime.utcnow().strftime('%Y/%m/%d')}/report-{context.request_id}.json"
        s3.put_object(
            Bucket=artifacts_bucket,
            Key=report_key,
            Body=json.dumps(results, indent=2),
            ContentType='application/json'
        )
        print(f"Report stored in S3: s3://{artifacts_bucket}/{report_key}")
    except Exception as e:
        print(f"Error storing report in S3: {str(e)}")
    
    return {
        'statusCode': 200,
        'body': json.dumps(results)
    }
