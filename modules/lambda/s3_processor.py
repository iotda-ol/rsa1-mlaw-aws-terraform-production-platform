import json
import os
from datetime import datetime

def handler(event, context):
    """
    Lambda function for processing S3 events.
    Triggered when new objects are uploaded to the artifacts bucket.
    """
    
    project_name = os.environ.get('PROJECT_NAME')
    
    print(f"S3 Processor triggered for project: {project_name}")
    print(f"Event: {json.dumps(event)}")
    
    for record in event.get('Records', []):
        if record['eventName'].startswith('ObjectCreated:'):
            bucket = record['s3']['bucket']['name']
            key = record['s3']['object']['key']
            size = record['s3']['object']['size']
            
            print(f"New object created: s3://{bucket}/{key} (size: {size} bytes)")
            
            # Add custom processing logic here
            # For example: validate file, transform data, trigger workflows, etc.
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'S3 event processed successfully',
            'timestamp': datetime.utcnow().isoformat()
        })
    }
