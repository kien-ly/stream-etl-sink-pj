#!/bin/bash

NAMESPACE=dt-flink

echo "🧹 Cleaning up namespace: $NAMESPACE"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo "❌ Namespace '$NAMESPACE' does not exist."
  exit 0
fi

# Delete all Helm releases in the namespace
echo "📦 Removing Helm releases..."
helm list -n $NAMESPACE --short | xargs -r helm uninstall -n $NAMESPACE

# Force delete all resources
echo "🗑️  Deleting all resources..."
kubectl delete all --all -n $NAMESPACE --force --grace-period=0
kubectl delete pvc --all -n $NAMESPACE --force --grace-period=0
kubectl delete secrets --all -n $NAMESPACE --force --grace-period=0
kubectl delete configmaps --all -n $NAMESPACE --force --grace-period=0

# Delete the namespace
echo "🔥 Deleting namespace..."
kubectl delete namespace $NAMESPACE --force --grace-period=0

echo "✅ Cleanup completed for namespace: $NAMESPACE"