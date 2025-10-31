#!/bin/bash
# Script to switch between Blue and Green deployments

NAMESPACE="aceest-fitness"
SERVICE="aceest-fitness-service"

# Get current active version
CURRENT_VERSION=$(kubectl get service $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.version}')

echo "Current active version: $CURRENT_VERSION"

# Switch to the other version
if [ "$CURRENT_VERSION" == "blue" ]; then
    NEW_VERSION="green"
else
    NEW_VERSION="blue"
fi

echo "Switching to: $NEW_VERSION"

# Patch the service to point to the new version
kubectl patch service $SERVICE -n $NAMESPACE -p "{\"spec\":{\"selector\":{\"version\":\"$NEW_VERSION\"}}}"

echo "Service switched to $NEW_VERSION version"
echo "Verify the switch with: kubectl get service $SERVICE -n $NAMESPACE -o yaml"

# Optional: Scale down the old version after verification
read -p "Do you want to scale down the $CURRENT_VERSION deployment? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl scale deployment aceest-fitness-$CURRENT_VERSION -n $NAMESPACE --replicas=0
    echo "$CURRENT_VERSION deployment scaled down to 0"
fi
