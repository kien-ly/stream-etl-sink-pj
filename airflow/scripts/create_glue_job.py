#!/usr/bin/env python3
"""Create a simple Glue job locally using boto3."""

import boto3
import json

def create_glue_job():
    # Initialize Glue client
    glue = boto3.client('glue', region_name='ap-southeast-1')
    
    job_name = 'simple-time-job'
    script_location = 's3://YOUR_BUCKET/scripts/simple_glue_job.py'  # Replace with your S3 bucket
    role_arn = 'arn:aws:iam::YOUR_ACCOUNT:role/YOUR_GLUE_ROLE'  # Replace with your IAM role
    
    try:
        response = glue.create_job(
            Name=job_name,
            Role=role_arn,
            Command={
                'Name': 'glueetl',
                'ScriptLocation': script_location,
                'PythonVersion': '3'
            },
            DefaultArguments={
                '--TempDir': 's3://YOUR_BUCKET/temp/',
                '--enable-metrics': '',
                '--enable-continuous-cloudwatch-log': 'true',
                '--job-language': 'python'
            },
            MaxRetries=0,
            Timeout=60,  # 60 minutes
            GlueVersion='4.0',
            NumberOfWorkers=2,
            WorkerType='G.1X',
            Description='Simple job that prints current time'
        )
        
        print(f"✅ Glue job '{job_name}' created successfully!")
        print(f"Job ARN: {response.get('Name')}")
        
    except glue.exceptions.AlreadyExistsException:
        print(f"⚠️  Job '{job_name}' already exists")
        
    except Exception as e:
        print(f"❌ Error creating job: {e}")

if __name__ == "__main__":
    create_glue_job()