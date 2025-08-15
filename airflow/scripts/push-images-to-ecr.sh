#!/bin/bash

AWS_REGION="ap-southeast-1"
AWS_ACCOUNT_ID="079957391273"
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION --profile vns | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "📦 Pulling and pushing PostgreSQL..."
docker pull bitnami/postgresql:16
docker tag bitnami/postgresql:16 $ECR_REGISTRY/aidph/postgresql:16
docker push $ECR_REGISTRY/aidph/postgresql:16


echo "📦 Pulling and pushing Redis..."
docker pull bitnami/redis:7.4
docker tag bitnami/redis:7.4 $ECR_REGISTRY/aidph/redis:7.4
docker push $ECR_REGISTRY/aidph/redis:7.4

echo "✅ Images pushed to ECR successfully!"
echo ""
echo "📋 Available images:"
echo "PostgreSQL: $ECR_REGISTRY/aidph/postgresql:16"
echo "Redis: $ECR_REGISTRY/aidph/redis:7.4"