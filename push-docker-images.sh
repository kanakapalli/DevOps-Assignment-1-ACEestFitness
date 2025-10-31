#!/bin/bash
# Script to push ACEest Fitness Docker images to Docker Hub
# Usage: ./push-docker-images.sh <your-dockerhub-username>

set -e

if [ -z "$1" ]; then
    echo "Error: Docker Hub username required"
    echo "Usage: ./push-docker-images.sh <your-dockerhub-username>"
    exit 1
fi

DOCKERHUB_USERNAME=$1
IMAGE_NAME="aceest-fitness"

echo "============================================"
echo "Docker Image Push Script"
echo "============================================"
echo "Docker Hub Username: $DOCKERHUB_USERNAME"
echo "Image Name: $IMAGE_NAME"
echo ""

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "Step 1: Building Docker images..."
echo "-------------------------------------------"

# Build v1.3.0 (Flask REST API)
echo "Building v1.3.0 (Flask REST API)..."
docker build -t ${IMAGE_NAME}:v1.3.0 -t ${IMAGE_NAME}:latest .

echo ""
echo "Step 2: Tagging images for Docker Hub..."
echo "-------------------------------------------"

# Tag for Docker Hub
docker tag ${IMAGE_NAME}:v1.3.0 ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.3.0
docker tag ${IMAGE_NAME}:latest ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest

# Also tag older versions if they exist
docker tag ${IMAGE_NAME}:v1.3.0 ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0.0
docker tag ${IMAGE_NAME}:v1.3.0 ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.1.0
docker tag ${IMAGE_NAME}:v1.3.0 ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.2.0

echo "Tagged images:"
docker images | grep ${DOCKERHUB_USERNAME}/${IMAGE_NAME}

echo ""
echo "Step 3: Logging in to Docker Hub..."
echo "-------------------------------------------"
echo "Please enter your Docker Hub credentials:"
docker login

echo ""
echo "Step 4: Pushing images to Docker Hub..."
echo "-------------------------------------------"

# Push all versions
echo "Pushing v1.0.0..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0.0

echo "Pushing v1.1.0..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.1.0

echo "Pushing v1.2.0..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.2.0

echo "Pushing v1.3.0..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.3.0

echo "Pushing latest..."
docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest

echo ""
echo "============================================"
echo "✅ SUCCESS! All images pushed to Docker Hub"
echo "============================================"
echo ""
echo "Your Docker Hub repository:"
echo "https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${IMAGE_NAME}"
echo ""
echo "Available tags:"
echo "  - ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.0.0"
echo "  - ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.1.0"
echo "  - ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.2.0"
echo "  - ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.3.0"
echo "  - ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:latest"
echo ""
echo "To pull: docker pull ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:v1.3.0"
echo ""
