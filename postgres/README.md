# PostgreSQL CDC Setup cho Local Development

## 📋 Tổng quan

Thư mục này chứa cấu hình PostgreSQL được tối ưu hóa cho Change Data Capture (CDC) với Debezium. Setup này bao gồm:

- **PostgreSQL 16** với cấu hình logical replication
- **Debezium-ready configuration** cho Kafka Connect
- **Dummy data** cho testing CDC
- **Automatic CDC setup** với publications và permissions

## 🏗️ Cấu trúc Files

```
local/
├── postgres-cdc-deployment.yaml   # Full Kubernetes deployment
├── deploy-postgres-cdc.sh         # Deployment script
└── README.md                      # Documentation này
```

## 🔧 Các Thành phần chính

### 1. ConfigMap: `postgres-cdc-config`
- **postgresql.conf**: Cấu hình CDC với `wal_level = logical`
- **pg_hba.conf**: Authentication settings cho replication
- **init-cdc.sql**: CDC setup script (publications, users, permissions)
- **init-dummy-data.sql**: Test data với 3 tables

### 2. Deployment: `postgresql`
- PostgreSQL 16 container
- Volume mounts cho config và init scripts
- Resource limits và health checks
- Automatic CDC initialization

### 3. Service: `postgresql`
- ClusterIP service expose port 5432
- Accessible từ other pods trong cluster

## 🚀 Deployment

### Cách 1: Sử dụng Script (Khuyến nghị)

```bash
cd local/
chmod +x deploy-postgres-cdc.sh
./deploy-postgres-cdc.sh
```

### Cách 2: Manual Deployment

```bash
# Tạo namespace
kubectl create namespace test-deploy

# Tạo secret
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USERNAME=postgres \
  --from-literal=POSTGRES_PASSWORD=password123 \
  --from-literal=POSTGRES_DB=testdb \
  --namespace=test-deploy

# Deploy PostgreSQL
kubectl apply -f postgres-cdc-deployment.yaml

# Kiểm tra status
kubectl get pods -n test-deploy -l app=postgres
```

## 🔍 Verification

Sau khi deploy, script sẽ tự động verify:

1. **WAL Level**: `logical` (required cho CDC)
2. **Publications**: `debezium_pub` cho all tables
3. **Dummy Data**: 5 users, 5 products, 5 events
4. **Connectivity**: PostgreSQL service ready

### Manual Verification

```bash
# Connect to PostgreSQL
kubectl exec -it deployment/postgresql -n test-deploy -- psql -U postgres -d testdb

# Check CDC configuration
testdb=# SHOW wal_level;
testdb=# SELECT * FROM pg_publication;
testdb=# SELECT * FROM pg_replication_slots;

# Check data
testdb=# SELECT COUNT(*) FROM public.directus_users;
testdb=# SELECT COUNT(*) FROM public.product;
testdb=# SELECT COUNT(*) FROM public.event;
```

## 📊 Database Schema

### Tables được tạo:
1. **directus_users**: User management (5 records)
2. **product**: Product catalog (5 records)
3. **event**: Event management (5 records)

### CDC Publications:
- **debezium_pub**: Publication cho tất cả tables
- Ready cho Debezium connector

## 🔗 Kết nối với Kafka Connect

### 1. Đảm bảo Kafka Connect running:
```bash
kubectl get pods -n redpanda -l "app.kubernetes.io/name=kafka-connect"
```

### 2. Port forward Kafka Connect:
```bash
kubectl port-forward svc/kafka-connect 8083:8083 -n redpanda
```

### 3. Tạo Debezium Connector:
```bash
curl -X POST http://localhost:8083/connectors \
  -H "Content-Type: application/json" \
  -d '{
    "name": "debezium-postgres-cdc",
    "config": {
      "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
      "database.hostname": "postgresql.test-deploy.svc.cluster.local",
      "database.port": "5432",
      "database.user": "postgres",
      "database.password": "password123",
      "database.dbname": "testdb",
      "database.server.name": "postgres-cdc",
      "plugin.name": "pgoutput",
      "slot.name": "debezium_slot",
      "publication.name": "debezium_pub",
      "topic.prefix": "cdc",
      "table.include.list": "public.directus_users,public.product,public.event",
      "key.converter": "org.apache.kafka.connect.json.JsonConverter",
      "key.converter.schemas.enable": true,
      "value.converter": "org.apache.kafka.connect.json.JsonConverter",
      "value.converter.schemas.enable": true,
      "topic.creation.enable": true,
      "topic.creation.default.replication.factor": 1,
      "topic.creation.default.partitions": 1
    }
  }'
```

## 🧪 Testing CDC

### 1. Kiểm tra connector status:
```bash
curl -s http://localhost:8083/connectors/debezium-postgres-cdc/status | jq .
```

### 2. Make data changes để test CDC:
```sql
-- Connect to PostgreSQL
kubectl exec -it deployment/postgresql -n test-deploy -- psql -U postgres -d testdb

-- Insert new user
INSERT INTO public.directus_users (first_name, last_name, email, status) 
VALUES ('Test', 'User', 'test.user@example.com', 'active');

-- Update product
UPDATE public.product SET price = 26000000.00 WHERE name = 'Laptop ASUS ROG';

-- Delete event
DELETE FROM public.event WHERE title = 'Startup Pitch Competition';
```

### 3. Kiểm tra Kafka topics:
```bash
# List topics (nếu có Kafka CLI)
kubectl exec -it deployment/redpanda-0 -n redpanda -- rpk topic list

# Hoặc check Kafka Connect logs
kubectl logs deployment/kafka-connect -n redpanda
```

## 🔧 Troubleshooting

### PostgreSQL không start:
```bash
kubectl logs deployment/postgresql -n test-deploy
kubectl describe pod -l app=postgres -n test-deploy
```

### CDC không hoạt động:
```bash
# Check WAL level
kubectl exec deployment/postgresql -n test-deploy -- psql -U postgres -d testdb -c "SHOW wal_level;"

# Check publications
kubectl exec deployment/postgresql -n test-deploy -- psql -U postgres -d testdb -c "SELECT * FROM pg_publication;"
```

### Connector không connect:
```bash
# Check connector logs
curl -s http://localhost:8083/connectors/debezium-postgres-cdc/status | jq .

# Check Kafka Connect logs
kubectl logs deployment/kafka-connect -n redpanda
```

## 🧹 Cleanup

```bash
# Delete PostgreSQL deployment
kubectl delete -f postgres-cdc-deployment.yaml

# Delete namespace (optional)
kubectl delete namespace test-deploy
```

## ⚙️ Configuration Details

### Cấu hình PostgreSQL cho CDC:
- `wal_level = logical`: Enable logical replication
- `max_wal_senders = 10`: Support multiple replication connections
- `max_replication_slots = 10`: Support multiple replication slots
- `max_logical_replication_workers = 4`: Parallel replication workers

### Security:
- Replication user với minimal permissions
- MD5 authentication cho external connections
- Trust authentication cho local connections

### Performance:
- `shared_buffers = 128MB`: Memory allocation
- Resource limits: 512MB RAM, 500m CPU
- Health checks với proper timeouts

---

✅ **Ready for CDC testing with Debezium!** 