# Troubleshooting Guide

Common issues and their solutions for the CDC pipeline.

## Quick Diagnostics

### Health Check Commands

```bash
# Check all pods status
kubectl get pods -n dt

# Check services
kubectl get svc -n dt

# Check secrets
kubectl get secrets -n dt
```

## Common Issues

### 1. Connector Fails to Start

**Symptoms:**
- Connector status shows `FAILED`
- Error messages in Kafka Connect logs

**Diagnosis:**
```bash
# Check connector status
curl http://localhost:8083/connectors/debezium-postgres/status

# Check Kafka Connect logs
kubectl logs -n dt deployment/kafka-connect
```

**Solutions:**

=== "PostgreSQL Connectivity"
    ```bash
    # Test PostgreSQL connection
    kubectl exec -n dt deployment/postgresql -- pg_isready -U postgres
    
    # Check network connectivity
    kubectl exec -n dt deployment/kafka-connect -- nc -zv postgresql.dt.svc.cluster.local 5432
    ```

=== "Replication Slot Issues"
    ```bash
    # Check replication slots
    kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
    "SELECT * FROM pg_replication_slots;"
    
    # Drop and recreate slot if needed
    kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
    "SELECT pg_drop_replication_slot('debezium_slot');"
    ```

=== "Logical Replication"
    ```bash
    # Verify WAL level
    kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
    "SHOW wal_level;"
    
    # Should return 'logical'
    ```

### 2. No CDC Messages

**Symptoms:**
- Connector running but no messages in topics
- Empty topic consumption

**Diagnosis:**
```bash
# List topics
kubectl exec -n dt dt-redpanda-0 -- rpk topic list

# Check topic partitions
kubectl exec -n dt dt-redpanda-0 -- rpk topic describe cdc.public.product
```

**Solutions:**

=== "Table Configuration"
    ```bash
    # Check connector config
    curl http://localhost:8083/connectors/debezium-postgres/config | jq '.config."table.include.list"'
    
    # Verify publication
    kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
    "SELECT * FROM pg_publication;"
    ```

=== "Initial Snapshot"
    ```bash
    # Check snapshot status
    curl http://localhost:8083/connectors/debezium-postgres/status | jq '.tasks[0].trace'
    
    # Force snapshot restart
    curl -X POST http://localhost:8083/connectors/debezium-postgres/restart
    ```

### 3. Authentication Failures

**Symptoms:**
- Connection refused errors
- Authentication failed messages

**Diagnosis:**
```bash
# Check secrets
kubectl get secret postgres-credentials -n dt -o yaml
kubectl get secret redpanda-credentials -n dt -o yaml

# Decode secret values
kubectl get secret postgres-credentials -n dt -o jsonpath='{.data.password}' | base64 -d
```

**Solutions:**

=== "PostgreSQL Auth"
    ```bash
    # Test authentication
    kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c "SELECT 1;"
    
    # Check pg_hba.conf
    kubectl exec -n dt deployment/postgresql -- cat /etc/postgresql/pg_hba.conf
    ```

=== "Redpanda Auth"
    ```bash
    # Test Redpanda auth
    kubectl exec -n dt dt-redpanda-0 -- rpk cluster info \
    -X user=superuser -X pass="$(kubectl get secret redpanda-credentials -n dt -o jsonpath='{.data.password}' | base64 -d)" \
    -X sasl.mechanism=SCRAM-SHA-512
    ```

## Performance Issues

### High CPU/Memory Usage

**PostgreSQL:**
```bash
# Check resource usage
kubectl top pod -n dt -l app=postgres

# Analyze slow queries
kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
"SELECT query, calls, total_time, mean_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10;"
```

**Kafka Connect:**
```bash
# Check JVM metrics
kubectl exec -n dt deployment/kafka-connect -- jps -v

# Monitor connector metrics
curl http://localhost:8083/connectors/debezium-postgres/metrics
```

### Network Latency

```bash
# Test network latency between components
kubectl exec -n dt deployment/kafka-connect -- ping postgresql.dt.svc.cluster.local
kubectl exec -n dt deployment/kafka-connect -- ping dt-redpanda-0.dt-redpanda.dt.svc.cluster.local
```

## Log Analysis

### Centralized Logging

```bash
# PostgreSQL logs
kubectl logs -n dt deployment/postgresql --tail=100

# Kafka Connect logs
kubectl logs -n dt deployment/kafka-connect --tail=100

# Redpanda logs
kubectl logs -n dt dt-redpanda-0 --tail=100
```

### Log Patterns

Common error patterns to look for:

| Pattern | Component | Issue |
|---------|-----------|-------|
| `connection refused` | All | Network connectivity |
| `authentication failed` | PostgreSQL/Redpanda | Credential issues |
| `replication slot does not exist` | Debezium | Slot configuration |
| `topic does not exist` | Kafka Connect | Topic creation |

## Recovery Procedures

### Connector Recovery

```bash
# Restart connector
curl -X POST http://localhost:8083/connectors/debezium-postgres/restart

# Delete and recreate connector
curl -X DELETE http://localhost:8083/connectors/debezium-postgres
# Then redeploy via Helm
```

### Database Recovery

```bash
# Restart PostgreSQL
kubectl rollout restart deployment/postgresql -n dt

# Reset replication slot
kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
"SELECT pg_drop_replication_slot('debezium_slot');"
```

!!! tip "Prevention"
    - Monitor resource usage regularly
    - Set up alerting for critical metrics
    - Implement automated health checks
    - Keep backups of configurations