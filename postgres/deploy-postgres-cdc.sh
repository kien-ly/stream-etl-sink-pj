#!/bin/bash
NAMESPACE=dt

set -e

echo "🚀 Deploying PostgreSQL with CDC configuration..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# echo "${YELLOW}📝 Creating namespace if not exists...${NC}"
if ! kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo "${YELLOW}📝 Namespace '$NAMESPACE' does not exist. Creating...${NC}"
  kubectl create namespace "$NAMESPACE"
else
  echo "${GREEN} Namespace '$NAMESPACE' already exists.${NC}"
fi

echo "${YELLOW}🔑 Checking postgres credentials...${NC}"
if ! kubectl get secret postgres-credentials -n $NAMESPACE > /dev/null 2>&1; then
  echo "${RED}❌ Error: postgres-credentials secret not found!${NC}"
  echo "Please run: ../secrets/create-secrets.sh"
  exit 1
fi

# Create legacy secret name for backward compatibility
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USERNAME=$(kubectl get secret postgres-credentials -n $NAMESPACE -o jsonpath='{.data.username}' | base64 -d) \
  --from-literal=POSTGRES_PASSWORD=$(kubectl get secret postgres-credentials -n $NAMESPACE -o jsonpath='{.data.password}' | base64 -d) \
  --from-literal=POSTGRES_DB=$(kubectl get secret postgres-credentials -n $NAMESPACE -o jsonpath='{.data.database}' | base64 -d) \
  --namespace=$NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo "${YELLOW}🗃️ Applying PostgreSQL CDC configuration...${NC}"
kubectl apply -f postgres-cdc-deployment.yaml

echo "${YELLOW}⏳ Waiting for PostgreSQL pod to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s

echo "${GREEN}✅ PostgreSQL with CDC setup completed!${NC}"

echo "${YELLOW}📊 Checking deployment status...${NC}"
kubectl get pods -n $NAMESPACE -l app=postgres
kubectl get svc -n $NAMESPACE postgresql

echo "${YELLOW}🔍 Verifying CDC configuration...${NC}"
echo "Checking if logical replication is enabled..."
kubectl exec -n $NAMESPACE deployment/postgresql -- psql -U postgres -d testdb -c "SHOW wal_level;"

echo "Checking publications..."
kubectl exec -n $NAMESPACE deployment/postgresql -- psql -U postgres -d testdb -c "SELECT * FROM pg_publication;"

echo "Checking replication slots..."
kubectl exec -n $NAMESPACE deployment/postgresql -- psql -U postgres -d testdb -c "SELECT * FROM pg_replication_slots;"

echo "Checking table data..."
kubectl exec -n $NAMESPACE deployment/postgresql -- psql -U postgres -d testdb -c "SELECT table_name, row_count FROM (SELECT 'directus_users' as table_name, COUNT(*) as row_count FROM public.directus_users UNION ALL SELECT 'product' as table_name, COUNT(*) as row_count FROM public.product UNION ALL SELECT 'event' as table_name, COUNT(*) as row_count FROM public.event) t;"
# kubectl exec -n redpanda2 deployment/postgresql -- psql -U postgres -d testdb -c "SELECT table_name, row_count FROM (SELECT 'directus_users' as table_name, COUNT(*) as row_count FROM public.directus_users UNION ALL SELECT 'product' as table_name, COUNT(*) as row_count FROM public.product UNION ALL SELECT 'event' as table_name, COUNT(*) as row_count FROM public.event) t;"

echo "${GREEN}🎉 PostgreSQL CDC setup verification completed!${NC}"

echo "${YELLOW}📝 Next steps:${NC}"
echo "1. Start port-forward to Kafka Connect: kubectl port-forward svc/kafka-connect 8083:8083 -n redpanda"
echo "2. Create Debezium connector via REST API"
echo "3. Test CDC by making data changes"

echo "${GREEN}✅ Deployment completed successfully!${NC}" 