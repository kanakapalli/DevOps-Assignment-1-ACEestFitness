#!/bin/bash
# Script to promote Canary deployment to full production

NAMESPACE="aceest-fitness"

echo "Promoting Canary to full production..."

# Get the canary image version
CANARY_IMAGE=$(kubectl get deployment aceest-fitness-canary -n $NAMESPACE -o jsonpath='{.spec.template.spec.containers[0].image}')
echo "Canary image: $CANARY_IMAGE"

# Update stable deployment with canary image
kubectl set image deployment/aceest-fitness-stable aceest-fitness=$CANARY_IMAGE -n $NAMESPACE

# Wait for rollout to complete
kubectl rollout status deployment/aceest-fitness-stable -n $NAMESPACE

# Scale canary to 0 (no longer needed)
kubectl scale deployment aceest-fitness-canary -n $NAMESPACE --replicas=0

echo "Promotion complete! All traffic now routed to new version."
echo "Canary deployment scaled to 0."
