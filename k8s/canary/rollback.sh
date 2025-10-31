#!/bin/bash
# Script to rollback Canary deployment

NAMESPACE="aceest-fitness"

echo "Rolling back Canary deployment..."

# Scale canary to 0
kubectl scale deployment aceest-fitness-canary -n $NAMESPACE --replicas=0

echo "Canary deployment scaled to 0."
echo "All traffic now routed to stable version."
echo "To restart canary, scale it back up: kubectl scale deployment aceest-fitness-canary -n $NAMESPACE --replicas=1"
