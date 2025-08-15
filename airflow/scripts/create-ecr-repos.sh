#!/bin/bash

AWS_REGION="ap-southeast-1"
AWS_ACCOUNT_ID="079957391273"

echo "🏗️  Creating ECR repositories for Airflow dependencies..."

# Create PostgreSQL ECR repository
echo "📦 Creating postgresql repository..."
aws ecr create-repository \
    --repository-name aidph/postgresql \
    --region $AWS_REGION \
    --profile vns \
    --image-scanning-configuration scanOnPush=true

# Create Redis ECR repository  
echo "📦 Creating redis repository..."
aws ecr create-repository \
    --repository-name aidph/redis \
    --region $AWS_REGION \
    --profile vns \
    --image-scanning-configuration scanOnPush=true

# Create Bitnami Common ECR repository
echo "📦 Creating bitnami-common repository..."
aws ecr create-repository \
    --repository-name aidph/bitnami-common \
    --region $AWS_REGION \
    --profile vns \
    --image-scanning-configuration scanOnPush=true

echo "✅ ECR repositories created successfully!"
echo ""
echo "📋 Repository URLs:"
echo "PostgreSQL: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/aidph/postgresql"
echo "Redis: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/aidph/redis"  
echo "Bitnami Common: $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/aidph/bitnami-common"