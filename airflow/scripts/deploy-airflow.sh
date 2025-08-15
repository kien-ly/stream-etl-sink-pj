#!/bin/bash

NAMESPACE=dt
RELEASE_NAME=airflow

echo "🚀 Deploying Airflow with ECR images..."

# Update Helm dependencies
echo "📦 Updating Helm dependencies..."
cd helm/
helm dependency update

# Deploy Airflow
echo "🛠️  Installing/Upgrading Airflow..."
helm upgrade --install $RELEASE_NAME . \
    --namespace $NAMESPACE \
    --create-namespace \
    --values airflow-overrides.yaml \
    --wait \
    --timeout 10m

echo "✅ Airflow deployed successfully!"

# Get status
echo "📊 Checking deployment status..."
kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=airflow