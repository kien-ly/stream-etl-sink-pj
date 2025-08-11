#!/bin/bash
NAMESPACE=dt

# Generate secure random passwords
POSTGRES_PASSWORD=$(openssl rand -base64 32)
REDPANDA_PASSWORD=$(openssl rand -base64 32)
REPLICATOR_PASSWORD=$(openssl rand -base64 32)

# Create PostgreSQL secret
kubectl create secret generic postgres-credentials \
  --from-literal=username=postgres \
  --from-literal=password="$POSTGRES_PASSWORD" \
  --from-literal=database=testdb \
  --from-literal=replicator-password="$REPLICATOR_PASSWORD" \
  --namespace=$NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Create Redpanda secret
kubectl create secret generic redpanda-credentials \
  --from-literal=username=superuser \
  --from-literal=password="$REDPANDA_PASSWORD" \
  --namespace=$NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Create superusers file for Redpanda
echo "superuser:$REDPANDA_PASSWORD:SCRAM-SHA-512" > /tmp/superusers.txt
kubectl create secret generic redpanda-superusers \
  --from-file=superusers.txt=/tmp/superusers.txt \
  --namespace=$NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

rm /tmp/superusers.txt

echo "✅ Secrets created successfully!"
echo "📝 Save these credentials securely:"
echo "PostgreSQL Password: $POSTGRES_PASSWORD"
echo "Redpanda Password: $REDPANDA_PASSWORD"
echo "Replicator Password: $REPLICATOR_PASSWORD"