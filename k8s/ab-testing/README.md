# A/B Testing Deployment Strategy

## Overview

A/B testing (split testing) runs two versions simultaneously and routes different users to each version to compare performance, user behavior, or feature effectiveness.

## Benefits

- **Data-Driven Decisions**: Compare metrics between versions
- **Risk Mitigation**: Limit exposure to new features
- **User Feedback**: Gather real user responses
- **Gradual Rollout**: Control percentage of users seeing new version

## Architecture

```
User Request → Load Balancer
              ├─ 50% → Version A (Control) → Response
              └─ 50% → Version B (Variant) → Response
```

## Traffic Routing Methods

### 1. Percentage-Based (Weight)
- 50/50 split (default)
- 80/20 split (safer)
- 90/10 split (conservative)

### 2. Header-Based
- Route by custom header `x-version: b`
- Useful for testing specific users

### 3. Cookie-Based
- Sticky sessions for consistent UX
- User always sees same version

### 4. User Segment-Based
- Route by user ID, region, or device type

## Prerequisites

### Option 1: With Istio (Recommended)
```bash
# Install Istio
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
istioctl install --set profile=default -y

# Enable for namespace
kubectl label namespace aceest-fitness istio-injection=enabled
```

### Option 2: Without Istio (Nginx)
Use nginx-based routing (see nginx-config.yaml).

## Deployment

### Step 1: Deploy Both Versions

```bash
# Deploy Version A (control)
kubectl apply -f deployment-version-a.yaml

# Deploy Version B (variant)
kubectl apply -f deployment-version-b.yaml

# Create services
kubectl apply -f service.yaml
```

### Step 2: Configure Traffic Routing

#### 50/50 Split
```bash
kubectl apply -f virtualservice-istio.yaml
```

#### 80/20 Split (safer)
```bash
# Edit virtualservice-istio.yaml to use 80-20 split
kubectl apply -f virtualservice-istio.yaml
```

## Testing A/B Routing

### Test Version A (Control)
```bash
# Normal request (50% chance of A)
curl http://localhost:30004/
```

### Force Version B (Variant)
```bash
# Use custom header
curl -H "x-version: b" http://localhost:30004/
```

### Test Cookie-Based Routing
```bash
# Set cookie for Version B
curl -H "Cookie: ab_test=version_b" http://localhost:30004/
```

## Monitor A/B Test Results

### Compare Traffic Distribution
```bash
# Version A traffic
kubectl logs -f deployment/aceest-fitness-version-a -n aceest-fitness | wc -l

# Version B traffic
kubectl logs -f deployment/aceest-fitness-version-b -n aceest-fitness | wc -l
```

### Compare Response Times
```bash
# Version A latency
kubectl top pods -n aceest-fitness -l version=version-a

# Version B latency
kubectl top pods -n aceest-fitness -l version=version-b
```

### Compare Error Rates
```bash
# Version A errors
kubectl logs deployment/aceest-fitness-version-a -n aceest-fitness | grep -i error | wc -l

# Version B errors
kubectl logs deployment/aceest-fitness-version-b -n aceest-fitness | grep -i error | wc -l
```

## Adjust Traffic Split

### Change to 80/20 (More Conservative)
```yaml
# In virtualservice-istio.yaml
- route:
  - destination:
      host: aceest-fitness-version-a-service
    weight: 80  # 80% to A
  - destination:
      host: aceest-fitness-version-b-service
    weight: 20  # 20% to B
```

```bash
kubectl apply -f virtualservice-istio.yaml
```

### Change to 10/90 (Promote B)
```yaml
- route:
  - destination:
      host: aceest-fitness-version-a-service
    weight: 10
  - destination:
      host: aceest-fitness-version-b-service
    weight: 90
```

## Metrics to Track

### Key Performance Indicators (KPIs)

1. **Conversion Rate**: Users completing desired action
2. **Response Time**: Average latency per version
3. **Error Rate**: Percentage of failed requests
4. **User Engagement**: Time spent, pages viewed
5. **Bounce Rate**: Users leaving immediately

### Example Analysis

```bash
# Create test load
for i in {1..100}; do
  curl http://localhost:30004/workouts
done

# Compare results
echo "Version A requests:"
kubectl logs deployment/aceest-fitness-version-a -n aceest-fitness | grep -c "GET /workouts"

echo "Version B requests:"
kubectl logs deployment/aceest-fitness-version-b -n aceest-fitness | grep -c "GET /workouts"
```

## Decision Making

### Version B is Better
If Version B shows:
- ✅ Lower error rate
- ✅ Faster response time
- ✅ Higher user engagement

**Action**: Promote B to 100%
```bash
# Route all traffic to B
kubectl patch virtualservice aceest-fitness-ab-testing-vs -n aceest-fitness --type merge -p '
{
  "spec": {
    "http": [{
      "route": [{
        "destination": {
          "host": "aceest-fitness-version-b-service",
          "port": {"number": 80}
        },
        "weight": 100
      }]
    }]
  }
}'
```

### Version A is Better
If Version A outperforms:
- ❌ Rollback to A

**Action**: Route all traffic to A
```bash
kubectl patch virtualservice aceest-fitness-ab-testing-vs -n aceest-fitness --type merge -p '
{
  "spec": {
    "http": [{
      "route": [{
        "destination": {
          "host": "aceest-fitness-version-a-service",
          "port": {"number": 80}
        },
        "weight": 100
      }]
    }]
  }
}'
```

## Advanced Routing Rules

### Route by User ID
```yaml
# Route users with ID ending in 0-4 to A, 5-9 to B
- match:
  - headers:
      user-id:
        regex: ".*[0-4]$"
  route:
  - destination:
      host: aceest-fitness-version-a-service
- match:
  - headers:
      user-id:
        regex: ".*[5-9]$"
  route:
  - destination:
      host: aceest-fitness-version-b-service
```

### Route by Region
```yaml
- match:
  - headers:
      x-region:
        exact: "us-west"
  route:
  - destination:
      host: aceest-fitness-version-b-service
- route:
  - destination:
      host: aceest-fitness-version-a-service
```

## Cleanup

### Remove Version B (Rollback)
```bash
kubectl delete -f deployment-version-b.yaml
kubectl patch virtualservice aceest-fitness-ab-testing-vs -n aceest-fitness --type merge -p '{"spec":{"http":[{"route":[{"destination":{"host":"aceest-fitness-version-a-service"},"weight":100}]}]}}'
```

### Remove Version A (Full Promotion of B)
```bash
kubectl delete -f deployment-version-a.yaml
kubectl patch virtualservice aceest-fitness-ab-testing-vs -n aceest-fitness --type merge -p '{"spec":{"http":[{"route":[{"destination":{"host":"aceest-fitness-version-b-service"},"weight":100}]}]}}'
```

## Best Practices

1. **Statistical Significance**: Run test long enough for valid data
2. **Single Variable**: Change only one thing between versions
3. **Consistent UX**: Use cookies for sticky sessions
4. **Monitor Continuously**: Watch for anomalies
5. **Document Results**: Record metrics and decisions

## Common Use Cases

1. **UI/UX Changes**: Test new design vs old
2. **Algorithm Optimization**: Compare recommendation engines
3. **Pricing Strategies**: Test different pricing tiers
4. **Feature Flags**: Gradually roll out new features
5. **Performance Improvements**: Validate optimizations

## Troubleshooting

### Traffic not splitting evenly
```bash
# Check VirtualService
kubectl get virtualservice aceest-fitness-ab-testing-vs -n aceest-fitness -o yaml

# Verify weights sum to 100
```

### Users seeing inconsistent versions
```bash
# Enable sticky sessions with cookies
# Already configured in DestinationRule with consistentHash
```

### Version B getting more load than expected
```bash
# Check actual pod count
kubectl get pods -n aceest-fitness -l version=version-b

# Scale if needed
kubectl scale deployment aceest-fitness-version-b --replicas=3 -n aceest-fitness
```

## Sample Test Script

```bash
#!/bin/bash
# Test A/B routing distribution

VERSION_A=0
VERSION_B=0

for i in {1..100}; do
  RESPONSE=$(curl -s http://localhost:30004/)
  # Assume response includes version identifier
  if echo "$RESPONSE" | grep -q "VERSION_A"; then
    ((VERSION_A++))
  else
    ((VERSION_B++))
  fi
done

echo "Version A: $VERSION_A requests ($(($VERSION_A))%)"
echo "Version B: $VERSION_B requests ($(($VERSION_B))%)"
```

## Access

- **Service Endpoint**: Port 30004
- **Version A Service**: aceest-fitness-version-a-service (internal)
- **Version B Service**: aceest-fitness-version-b-service (internal)

```bash
# Test with percentage-based routing
curl http://localhost:30004/

# Test with header-based routing
curl -H "x-version: b" http://localhost:30004/
```

---

**Strategy**: A/B Testing (Split Testing)
**Traffic Control**: Percentage, Header, Cookie, User Segment
**Use Case**: Feature validation, UX testing, algorithm comparison
