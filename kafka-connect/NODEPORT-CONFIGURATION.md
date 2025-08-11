# Kafka Connect NodePort Configuration Guide

## Tổng quan

Bản cập nhật này giải quyết vấn đề khi Redpanda chuyển từ LoadBalancer sang NodePort. Script `load-connectors.sh` đã được cải thiện để:

1. **Tự động phát hiện endpoint** khi sử dụng NodePort
2. **Cải thiện error handling** và retry logic
3. **Flexible configuration** thông qua environment variables
4. **Không cần truyền config connector thủ công** khi port forward

## Cách hoạt động

### Auto-Detection cho NodePort

Script sẽ tự động thử các endpoint sau theo thứ tự:
1. `localhost:8083` (default)
2. `127.0.0.1:8083`
3. `kafka-connect:8083` 
4. `kafka-connect.dt.svc.cluster.local:8083`
5. Service name từ environment variables

### Cải thiện Error Handling

- **Retry logic**: Tối đa 3 lần retry cho mỗi connector
- **Timeout configuration**: Configurable timeouts cho curl requests
- **Health checks**: Periodic health checks mỗi 5 phút
- **Detailed logging**: Chi tiết về trạng thái loading connectors

## Configuration

### Thông qua Values.yaml

```yaml
connectors:
  autoLoad:
    enabled: true
    retryInterval: 5
    maxRetries: 12
    # Connector loader endpoint configuration
    connectHost: ""          # Auto-detect nếu empty
    connectPort: "8083"      # Port của Kafka Connect
    connectUrl: ""           # Override full URL nếu cần
    maxWaitTime: 300         # Thời gian chờ tối đa (seconds)
```

### Environment Variables

Các environment variables được set tự động trong deployment:

| Variable | Default | Mô tả |
|----------|---------|--------|
| `KAFKA_CONNECT_HOST` | `localhost` | Hostname của Kafka Connect |
| `KAFKA_CONNECT_PORT` | `8083` | Port của Kafka Connect |
| `KAFKA_CONNECT_URL` | auto | Full URL override |
| `MAX_WAIT_TIME` | `300` | Thời gian chờ tối đa |
| `RETRY_INTERVAL` | `5` | Khoảng cách retry |
| `KAFKA_CONNECT_SERVICE_NAME` | auto | Service name trong K8s |
| `KAFKA_CONNECT_NAMESPACE` | auto | Namespace trong K8s |

## Sử dụng với NodePort

### Khi Redpanda sử dụng NodePort:

1. **Không cần thay đổi gì** - Script sẽ tự động phát hiện
2. **Port forward như bình thường**:
   ```bash
   kubectl port-forward svc/kafka-connect 8083:8083 -n dt
   ```
3. **Connectors sẽ tự động load** mà không cần truyền config thủ công

### Custom Configuration cho NodePort:

Nếu cần custom configuration:

```yaml
connectors:
  autoLoad:
    connectHost: "your-nodeport-host"
    connectPort: "30083"  # NodePort number
    # hoặc
    connectUrl: "http://your-cluster-ip:30083"
```

## Troubleshooting

### Logs để debug:

```bash
# Xem logs của connector-loader sidecar
kubectl logs -f deployment/kafka-connect -c connector-loader -n dt

# Xem status của connectors
kubectl port-forward svc/kafka-connect 8083:8083 -n dt
curl http://localhost:8083/connectors
```

### Các lỗi thường gặp:

1. **"Failed to connect after X seconds"**
   - Check Kafka Connect service đang chạy
   - Verify port forward đúng port
   - Check network connectivity

2. **"Connector failed to load"**
   - Check connector configuration trong ConfigMap
   - Verify database connections
   - Check Kafka/Redpanda connectivity

3. **Auto-detection không hoạt động**
   - Set manual `connectUrl` trong values.yaml
   - Check service names và namespaces

## Best Practices

1. **Monitoring**: Logs của connector-loader sẽ show health checks định kỳ
2. **Configuration**: Sử dụng values.yaml thay vì hardcode endpoints
3. **Debugging**: Enable verbose logging bằng cách check logs
4. **High Availability**: Script sẽ retry và continue monitoring ngay cả khi có failures

## Migration từ LoadBalancer

Không cần migration steps - chỉ cần:
1. Update Redpanda sang NodePort
2. Deploy bản cập nhật này
3. Script sẽ tự động adapt
