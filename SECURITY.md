# Security Best Practices

## 🔐 Credential Management

### 1. Generate Secrets (Required First Step)

```bash
# Create all required secrets with random passwords
cd secrets/
chmod +x create-secrets.sh
./create-secrets.sh
```

### 2. Deployment Order

```bash
# 1. Create secrets first
cd secrets/ && ./create-secrets.sh

# 2. Deploy Redpanda
cd ../redpanda/ && ./setup.sh

# 3. Deploy PostgreSQL
cd ../postgres/ && ./deploy-postgres-cdc.sh

# 4. Deploy Kafka Connect
cd ../kafka-connect/ && helm install kafka-connect . -n dt
```

## 🛡️ Security Features

### Kubernetes Secrets
- All passwords generated with `openssl rand -base64 32`
- Secrets stored in Kubernetes etcd (encrypted at rest)
- No hardcoded credentials in code

### Secret References
- PostgreSQL: `postgres-credentials`
- Redpanda: `redpanda-credentials`, `redpanda-superusers`
- Kafka Connect: References both secrets via `extraEnvFrom`

### Access Control
- SASL/SCRAM-SHA-512 authentication for Redpanda
- PostgreSQL replication user with minimal privileges
- Kubernetes RBAC for service accounts

## 🔄 Password Rotation

```bash
# Rotate PostgreSQL password
kubectl patch secret postgres-credentials -n dt -p='{"data":{"password":"'$(openssl rand -base64 32 | base64 -w 0)'"}}'

# Rotate Redpanda password
kubectl patch secret redpanda-credentials -n dt -p='{"data":{"password":"'$(openssl rand -base64 32 | base64 -w 0)'"}}'

# Restart deployments to pick up new passwords
kubectl rollout restart deployment/postgresql -n dt
kubectl rollout restart deployment/kafka-connect -n dt
```

## ⚠️ Important Notes

- Never commit secrets to version control
- Use external secret management (AWS Secrets Manager, HashiCorp Vault) in production
- Enable audit logging for secret access
- Regularly rotate passwords