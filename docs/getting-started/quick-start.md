# Quick Start Guide

Get your CDC pipeline running in minutes with this step-by-step guide.

## Prerequisites

- Kubernetes cluster (v1.20+)
- Helm 3.x installed
- kubectl configured
- Docker registry access

## Deployment Steps

### 1. Create Secrets

!!! warning "Security First"
    Always create secrets before deploying any components to avoid hardcoded credentials.

```bash
cd secrets/
chmod +x create-secrets.sh
./create-secrets.sh
```

### 2. Deploy Redpanda

```bash
cd redpanda/
./setup.sh
```

### 3. Deploy PostgreSQL with CDC

```bash
cd postgres/
./deploy-postgres-cdc.sh
```

### 4. Deploy Kafka Connect

```bash
cd kafka-connect/
helm install kafka-connect . -n dt
```

## Verification

### Check Component Status

=== "PostgreSQL"
    ```bash
    kubectl get pods -n dt -l app=postgres
    kubectl logs -n dt deployment/postgresql
    ```

=== "Redpanda"
    ```bash
    kubectl get pods -n dt -l app.kubernetes.io/name=redpanda
    kubectl exec -n dt dt-redpanda-0 -- rpk cluster info
    ```

=== "Kafka Connect"
    ```bash
    kubectl get pods -n dt -l app=kafka-connect
    curl http://localhost:8083/connectors
    ```

### Test CDC Pipeline

1. **Port forward to Kafka Connect**:
   ```bash
   kubectl port-forward svc/kafka-connect 8083:8083 -n dt
   ```

2. **Check connector status**:
   ```bash
   curl http://localhost:8083/connectors/debezium-postgres/status
   ```

3. **Make a data change**:
   ```bash
   kubectl exec -n dt deployment/postgresql -- psql -U postgres -d testdb -c \
   "INSERT INTO public.product (name, price) VALUES ('Test Product', 99.99);"
   ```

4. **Consume CDC messages**:
   ```bash
   kubectl exec -n dt dt-redpanda-0 -- rpk topic consume cdc.public.product --brokers localhost:9093
   ```

!!! success "Success!"
    If you see CDC messages, your pipeline is working correctly!

## Next Steps

- [Configure monitoring](../components/monitoring.md)
- [Set up additional connectors](../components/kafka-connect.md)
- [Review security settings](../security/overview.md)