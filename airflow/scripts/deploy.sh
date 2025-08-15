#!/bin/bash

NAMESPACE="dt-airflow"

echo "🚀 Deploying Airflow for Glue jobs..."

# Create secrets
if ! kubectl get secret airflow-credentials -n $NAMESPACE > /dev/null 2>&1; then
  bash helm/create-secrets.sh
fi

# Deploy
helm upgrade --install airflow bitnami/airflow \
  --namespace $NAMESPACE \
  --create-namespace \
  --timeout 10m \
  -f helm/minimal.yaml

if [ $? -eq 0 ]; then
  echo "✅ Deployed successfully!"
  echo "🌐 Access: kubectl port-forward -n $NAMESPACE svc/airflow-web 8080:8080"
  echo "🔑 Password: kubectl get secret -n $NAMESPACE airflow-credentials -o jsonpath='{.data.airflow-password}' | base64 -d"
fi