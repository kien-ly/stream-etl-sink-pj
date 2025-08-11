# PostgreSQL CDC with Kafka Connect & Redpanda

A comprehensive Change Data Capture (CDC) solution using PostgreSQL, Debezium, Kafka Connect, and Redpanda for real-time data streaming and replication.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   PostgreSQL    │───▶│  Kafka Connect   │───▶│    Redpanda     │───▶│  Target Systems │
│  (Source DB)    │    │   (Debezium)     │    │   (Streaming)   │    │   (Sinks)       │
└─────────────────┘    └──────────────────┘    └─────────────────┘    └─────────────────┘
```

### Components

- **PostgreSQL**: Source database with logical replication enabled
- **Kafka Connect**: Distributed streaming platform with Debezium connectors
- **Redpanda**: High-performance Kafka-compatible streaming platform
- **Kafka UI**: Web interface for monitoring topics and messages

## 📋 Prerequisites

- Kubernetes cluster (v1.20+)
- Helm 3.x
- kubectl configured
- Docker registry access (ECR)

## 🚀 Quick Start

### 1. Deploy Redpanda

```bash
cd redpanda/
./setup.sh
```

### 2. Deploy PostgreSQL with CDC

```bash
cd postgres/
./deploy-postgres-cdc.sh
```

### 3. Deploy Kafka Connect

```bash
cd kafka-connect/
helm install kafka-connect . -n dt
```

### 4. Verify CDC Pipeline

```bash
# Check connector status
kubectl port-forward svc/kafka-connect 8083:8083 -n dt
curl http://localhost:8083/connectors/debezium-postgres/status

# Test data changes
kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c "INSERT INTO public.product (name, price) VALUES ('Test Product', 99.99);"

# Consume CDC messages
kubectl exec -n dt dt-redpanda-0 -- rpk topic consume cdc.public.product --brokers localhost:9093
```

## 📁 Project Structure

```
dt/
├── postgres/                    # PostgreSQL with CDC configuration
│   ├── deploy-postgres-cdc.sh   # Deployment script
│   ├── postgres-cdc-deployment.yaml # K8s manifests
│   ├── init-dummy-data.sql      # Sample data
│   └── test.sh                  # Testing utilities
├── kafka-connect/               # Kafka Connect Helm chart
│   ├── templates/               # Kubernetes templates
│   ├── values.yaml              # Configuration values
│   ├── Chart.yaml               # Helm chart metadata
│   └── docs/                    # Documentation
├── redpanda/                    # Redpanda streaming platform
│   └── setup.sh                 # Installation script
├── kafka-ui/                    # Kafka UI for monitoring
│   └── values.yaml              # UI configuration
└── temp/                        # Temporary files
```

## 🔧 Configuration

### PostgreSQL CDC Settings

Key configurations in `postgres-cdc-deployment.yaml`:

```yaml
# WAL Configuration for CDC
wal_level: logical
max_wal_senders: 10
max_replication_slots: 10
max_logical_replication_workers: 4
```

### Kafka Connect Configuration

Main settings in `kafka-connect/values.yaml`:

```yaml
# Redpanda connection
CONNECT_BOOTSTRAP_SERVERS: "dt-redpanda-0.dt-redpanda.dt.svc.cluster.local:9093"

# Debezium PostgreSQL connector
connectors:
  debezium:
    enabled: true
    database:
      hostname: "postgresql.dt.svc.cluster.local"
      port: "5432"
      user: "postgres"
      dbname: "testdb"
```

## 📊 Sample Data

The system includes pre-configured sample data:

- **directus_users**: User management data
- **product**: E-commerce product catalog
- **event**: Event management system

Tables are automatically created with foreign key relationships and JSON metadata support.

## 🔍 Monitoring & Testing

### Check System Health

```bash
# PostgreSQL status
kubectl get pods -n dt -l app=postgres

# Kafka Connect status
kubectl get pods -n dt -l app=kafka-connect

# Redpanda status
kubectl get pods -n dt -l app.kubernetes.io/name=redpanda
```

### CDC Testing

1. **Make data changes**:
   ```sql
   INSERT INTO public.product (name, price, category) VALUES ('New Product', 199.99, 'Electronics');
   UPDATE public.product SET price = 299.99 WHERE id = 1;
   DELETE FROM public.product WHERE id = 2;
   ```

2. **Monitor CDC topics**:
   ```bash
   # List CDC topics
   kubectl exec -n dt dt-redpanda-0 -- rpk topic list

   # Consume messages
   kubectl exec -n dt dt-redpanda-0 -- rpk topic consume cdc.public.product
   ```

### Connector Management

```bash
# List connectors
curl http://localhost:8083/connectors

# Check connector status
curl http://localhost:8083/connectors/debezium-postgres/status

# View connector configuration
curl http://localhost:8083/connectors/debezium-postgres/config
```

## 🛠️ Troubleshooting

### Common Issues

1. **Connector fails to start**
   - Check PostgreSQL connectivity
   - Verify replication slot exists
   - Ensure logical replication is enabled

2. **No CDC messages**
   - Confirm table is included in `table.include.list`
   - Check publication exists: `SELECT * FROM pg_publication;`
   - Verify replication slot: `SELECT * FROM pg_replication_slots;`

3. **Connection timeouts**
   - Check network policies
   - Verify service DNS resolution
   - Confirm authentication credentials

### Debug Commands

```bash
# PostgreSQL logs
kubectl logs -n dt deployment/postgresql

# Kafka Connect logs
kubectl logs -n dt deployment/kafka-connect

# Redpanda logs
kubectl logs -n dt dt-redpanda-0

# Check replication configuration
kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c "SHOW wal_level;"
```

## 🔐 Security

### Authentication

- **PostgreSQL**: Username/password authentication with replication privileges
- **Redpanda**: SASL/SCRAM-SHA-512 authentication
- **Kafka Connect**: Secure credential management via Kubernetes secrets

### Network Security

- All components deployed within Kubernetes namespace
- ClusterIP services for internal communication
- Configurable ingress for external access

## 📈 Performance Tuning

### PostgreSQL Optimization

```yaml
# Resource allocation
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"

# WAL settings
wal_keep_size: 1024MB
max_wal_senders: 10
```

### Kafka Connect Scaling

```yaml
# Horizontal scaling
replicaCount: 3

# Resource allocation
resources:
  requests:
    cpu: "500m"
    memory: "1Gi"
  limits:
    cpu: "2"
    memory: "2Gi"
```

## 🚀 Production Deployment

### Checklist

- [ ] Configure persistent storage for PostgreSQL
- [ ] Set up monitoring and alerting
- [ ] Implement backup and recovery procedures
- [ ] Configure SSL/TLS encryption
- [ ] Set resource limits and requests
- [ ] Configure network policies
- [ ] Set up log aggregation
- [ ] Test disaster recovery procedures

### Scaling Considerations

- **PostgreSQL**: Consider read replicas for high read workloads
- **Kafka Connect**: Scale workers based on connector throughput
- **Redpanda**: Adjust partition count and replication factor
- **Storage**: Use high-performance storage classes (e.g., gp3)

## 📖 Documentation

### Online Documentation
- **Live Docs**: [https://your-domain.github.io/dt-cdc-project](https://your-domain.github.io/dt-cdc-project)
- **Local Development**: `./build-docs.sh serve`

### Build Documentation Locally
```bash
# Install dependencies
pip install -r requirements.txt

# Build and serve
./build-docs.sh serve

# Or build only
mkdocs build
```

## 📚 Additional Resources

- [Debezium Documentation](https://debezium.io/documentation/)
- [Redpanda Documentation](https://docs.redpanda.com/)
- [Kafka Connect Documentation](https://kafka.apache.org/documentation/#connect)
- [PostgreSQL Logical Replication](https://www.postgresql.org/docs/current/logical-replication.html)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for real-time data streaming**