# Shadow Deployment Strategy

## Overview

Shadow deployment (also called Dark Launch) runs the new version alongside production, receiving a mirror of live traffic. The shadow version processes requests but responses are discarded - only production responses reach users.

## Benefits

- **Zero Risk**: New version doesn't affect real users
- **Real Traffic Testing**: Test with actual production workload patterns
- **Performance Validation**: Compare response times and resource usage
- **Bug Detection**: Find issues before full deployment

## Architecture

```
User Request → Production (v1.3.0) → User Response ✅
            ↓ (mirrored)
            → Shadow (latest) → Logged/Discarded ❌
```

## Prerequisites

### Option 1: With Istio Service Mesh (Recommended)
```bash
# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
istioctl install --set profile=default -y

# Enable Istio injection for namespace
kubectl label namespace aceest-fitness istio-injection=enabled
```

### Option 2: Without Istio (Using Nginx)
Use the nginx-based configuration (see below).

## Deployment

### With Istio

1. **Deploy production and shadow versions**:
```bash
kubectl apply -f deployment-production.yaml
kubectl apply -f deployment-shadow.yaml
kubectl apply -f service.yaml
```

2. **Apply Istio traffic mirroring**:
```bash
kubectl apply -f virtualservice-istio.yaml
```

3. **Verify traffic mirroring**:
```bash
# Send test request
curl http://<production-service-ip>/

# Check shadow logs to see mirrored traffic
kubectl logs -f deployment/aceest-fitness-shadow -n aceest-fitness
```

### Without Istio (Nginx Alternative)

If Istio is not available, use Nginx as a proxy:

```bash
# Deploy using nginx mirror configuration
kubectl apply -f deployment-production.yaml
kubectl apply -f deployment-shadow.yaml
kubectl apply -f service.yaml
kubectl apply -f nginx-mirror-config.yaml
```

## Monitor Shadow Deployment

### Check Shadow Logs
```bash
# Real-time logs
kubectl logs -f deployment/aceest-fitness-shadow -n aceest-fitness

# Recent logs
kubectl logs --tail=100 deployment/aceest-fitness-shadow -n aceest-fitness
```

### Compare Metrics
```bash
# Production metrics
kubectl top pods -n aceest-fitness -l version=production

# Shadow metrics
kubectl top pods -n aceest-fitness -l version=shadow
```

### Check for Errors
```bash
# Count errors in shadow
kubectl logs deployment/aceest-fitness-shadow -n aceest-fitness | grep -i error | wc -l

# View specific errors
kubectl logs deployment/aceest-fitness-shadow -n aceest-fitness | grep -i error
```

## Traffic Mirroring Percentage

Adjust the mirror percentage in `virtualservice-istio.yaml`:

```yaml
mirrorPercentage:
  value: 100.0  # 100% of traffic
```

Options:
- `100.0` - Mirror all traffic (recommended for testing)
- `50.0` - Mirror 50% of traffic
- `10.0` - Mirror 10% of traffic

## Promotion Process

After validating shadow deployment:

1. **Verify shadow is healthy**:
```bash
kubectl get pods -n aceest-fitness -l version=shadow
```

2. **Check error rates are acceptable**:
```bash
# Compare error rates between production and shadow
kubectl logs deployment/aceest-fitness-production -n aceest-fitness | grep -i error | wc -l
kubectl logs deployment/aceest-fitness-shadow -n aceest-fitness | grep -i error | wc -l
```

3. **Promote shadow to production**:
```bash
# Update production to use shadow image
kubectl set image deployment/aceest-fitness-production \
  aceest-fitness=$(kubectl get deployment aceest-fitness-shadow -n aceest-fitness -o jsonpath='{.spec.template.spec.containers[0].image}') \
  -n aceest-fitness

# Scale down old shadow
kubectl scale deployment aceest-fitness-shadow --replicas=0 -n aceest-fitness
```

## Rollback

If issues are detected in shadow:

```bash
# Simply scale down shadow deployment
kubectl scale deployment aceest-fitness-shadow --replicas=0 -n aceest-fitness

# Production continues unaffected
```

## Cleanup

```bash
# Remove shadow deployment
kubectl delete -f deployment-shadow.yaml

# Remove traffic mirroring
kubectl delete -f virtualservice-istio.yaml

# Keep production running
```

## Use Cases

1. **Major Version Upgrades**: Test v2.0 with real traffic before launch
2. **Performance Testing**: Validate new code handles production load
3. **Database Migration**: Test new schema with production queries
4. **Algorithm Changes**: Compare results of old vs new algorithms

## Monitoring Best Practices

1. **Log Comparison**: Compare logs between production and shadow
2. **Latency Tracking**: Monitor if shadow is slower than production
3. **Error Rates**: Shadow should have similar or lower error rates
4. **Resource Usage**: Ensure shadow doesn't use excessive resources

## Access

- **Production Service**: Port 30003
- **Shadow Service**: Internal only (ClusterIP)

```bash
# Access production
curl http://localhost:30003/

# Monitor shadow (no direct access)
kubectl logs -f deployment/aceest-fitness-shadow -n aceest-fitness
```

## Limitations

1. **Read-Only Testing**: Best for read operations; write operations may cause data inconsistency
2. **Resource Cost**: Running duplicate infrastructure
3. **Requires Service Mesh**: Full features need Istio or similar

## Troubleshooting

### Issue: Shadow not receiving traffic
```bash
# Check Istio injection
kubectl get pod -n aceest-fitness -l version=shadow -o jsonpath='{.items[0].spec.containers[*].name}'

# Should show "istio-proxy" container

# Check VirtualService
kubectl get virtualservice -n aceest-fitness
```

### Issue: Too many shadow pods
```bash
# Adjust replicas based on mirrored traffic volume
kubectl scale deployment aceest-fitness-shadow --replicas=1 -n aceest-fitness
```
