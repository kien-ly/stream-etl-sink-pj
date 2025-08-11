# Prerequisites

Before deploying the CDC pipeline, ensure you have the following requirements met.

## Infrastructure Requirements

### Kubernetes Cluster
- **Version**: 1.20 or higher
- **Nodes**: Minimum 3 nodes (for high availability)
- **Resources**: 
  - CPU: 4 cores minimum
  - Memory: 8GB minimum
  - Storage: 50GB minimum

### Storage Classes
- **Persistent Volumes**: Required for PostgreSQL and Redpanda
- **Recommended**: `gp3` for AWS EKS
- **Performance**: SSD-backed storage for optimal performance

## Software Requirements

### Command Line Tools

| Tool | Version | Purpose |
|------|---------|---------|
| kubectl | 1.20+ | Kubernetes management |
| helm | 3.x | Package management |
| curl | Any | API testing |
| jq | Any | JSON processing |

### Installation Commands

=== "macOS"
    ```bash
    # Install via Homebrew
    brew install kubectl helm curl jq
    ```

=== "Linux"
    ```bash
    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Install Helm
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    ```

=== "Windows"
    ```powershell
    # Install via Chocolatey
    choco install kubernetes-cli kubernetes-helm curl jq
    ```

## Access Requirements

### Docker Registry
- **ECR Access**: Required for custom images
- **Credentials**: AWS CLI configured or IAM roles
- **Images**: 
  - `079957391273.dkr.ecr.ap-southeast-1.amazonaws.com/aisdph/kafka-connect:7.2.2with-plugins-v2`
  - `079957391273.dkr.ecr.ap-southeast-1.amazonaws.com/aidph/redpanda:v25.1.2`

### Kubernetes Permissions
Required RBAC permissions:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cdc-operator
rules:
- apiGroups: [""]
  resources: ["pods", "services", "secrets", "configmaps"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "statefulsets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
```

## Network Requirements

### Ports
| Component | Port | Protocol | Purpose |
|-----------|------|----------|---------|
| PostgreSQL | 5432 | TCP | Database connections |
| Kafka Connect | 8083 | TCP | REST API |
| Redpanda | 9093 | TCP | Kafka protocol |
| Redpanda | 8081 | TCP | Schema registry |

### DNS Resolution
- Internal cluster DNS must be functional
- External DNS for image pulls and updates

## Validation

### Cluster Readiness
```bash
# Check cluster info
kubectl cluster-info

# Check node status
kubectl get nodes

# Check storage classes
kubectl get storageclass
```

### Tool Versions
```bash
# Verify versions
kubectl version --client
helm version
curl --version
jq --version
```

!!! success "Ready to Deploy"
    Once all prerequisites are met, proceed to the [Quick Start Guide](quick-start.md).