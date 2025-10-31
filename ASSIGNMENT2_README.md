# ACEest Fitness & Gym - Assignment 2: DevOps CI/CD Implementation

## Project Overview

This project implements a comprehensive CI/CD pipeline for the ACEest Fitness & Gym application, demonstrating industry-standard DevOps practices including automated testing, containerization, and multiple Kubernetes deployment strategies.

## Application Version Evolution

The application has evolved through multiple versions:

- **v1.0**: Basic Tkinter GUI with workout tracking
- **v1.1**: Added categories (Warm-up, Workout, Cool-down) with improved UI
- **v1.2**: Added tabbed interface with workout charts and diet plans
- **v1.2.1**: Added progress tracking with matplotlib visualization
- **v1.2.2**: Enhanced UI with modern styling and better UX
- **v1.2.3**: Further UI improvements with color schemes
- **v1.3**: Complete rewrite as Flask REST API with user management, progress tracking, and calorie calculations

## Architecture Overview

### Technology Stack

- **Application**: Flask 3.0.0 (Python 3.11)
- **Testing**: Pytest with 29 comprehensive test cases
- **Containerization**: Docker with multi-layer optimization
- **CI/CD**: Jenkins with automated pipeline
- **Code Quality**: SonarQube for static analysis
- **Orchestration**: Kubernetes (Minikube/Cloud)
- **Version Control**: Git & GitHub

### Flask REST API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Health check and API information |
| `/users` | POST | Create or update user profile |
| `/users/<user_id>` | GET | Get user profile by ID |
| `/workouts` | POST | Add a workout session |
| `/workouts` | GET | Get all workouts |
| `/workouts/<category>` | GET | Get workouts by category |
| `/progress` | GET | Get overall progress statistics |
| `/progress/<user_id>` | GET | Get user-specific progress |
| `/workouts` | DELETE | Clear all workouts (testing) |

## CI/CD Pipeline Implementation

### Pipeline Stages

1. **Checkout**: Clone repository and get commit hash
2. **Install Dependencies**: Set up Python virtual environment
3. **Run Unit Tests**: Execute 29 test cases with coverage reporting
4. **SonarQube Analysis**: Static code analysis and quality gates
5. **Build Docker Image**: Create containerized application
6. **Test Docker Image**: Verify container functionality
7. **Push to Registry**: Upload to Docker Hub
8. **Deploy to Kubernetes**: Using selected deployment strategy
9. **Smoke Tests**: Verify deployment success

### Jenkins Configuration

```groovy
// Key environment variables
DOCKER_IMAGE_NAME = 'aceest-fitness'
APP_VERSION = "1.3.${BUILD_NUMBER}"
KUBE_NAMESPACE = 'aceest-fitness'
```

## Deployment Strategies

### 1. Rolling Update Deployment

**Use Case**: Standard production deployments with minimal downtime

**Features**:
- Gradual pod replacement
- Zero downtime deployment
- Automatic rollback on failure
- Health checks ensure pod readiness

**Configuration**:
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

**Deploy Command**:
```bash
kubectl apply -f k8s/rolling/deployment.yaml
kubectl apply -f k8s/rolling/service.yaml
```

**Access**: http://localhost:30000

### 2. Blue-Green Deployment

**Use Case**: Major releases requiring instant switch and easy rollback

**Features**:
- Two identical environments (Blue and Green)
- Instant traffic switching
- Easy rollback by switching back
- Zero downtime

**Deployment Process**:

1. Deploy to Green environment:
```bash
kubectl apply -f k8s/blue-green/deployment-green.yaml
```

2. Test Green environment:
```bash
kubectl port-forward service/aceest-fitness-green-service 8080:80 -n aceest-fitness
curl http://localhost:8080/
```

3. Switch traffic to Green:
```bash
./k8s/blue-green/switch.sh
```

4. Verify and scale down Blue:
```bash
kubectl scale deployment aceest-fitness-blue --replicas=0 -n aceest-fitness
```

**Access**: http://localhost:30001

### 3. Canary Deployment

**Use Case**: Gradual rollout to subset of users for validation

**Features**:
- Progressive traffic shifting (10% → 50% → 100%)
- Risk mitigation through gradual rollout
- Easy rollback if issues detected
- Monitor metrics before full rollout

**Deployment Process**:

1. Deploy Canary (10% traffic):
```bash
kubectl apply -f k8s/canary/deployment-stable.yaml
kubectl apply -f k8s/canary/deployment-canary.yaml
kubectl apply -f k8s/canary/service.yaml
```

2. Monitor canary metrics and errors:
```bash
kubectl logs -f deployment/aceest-fitness-canary -n aceest-fitness
```

3. If successful, promote to full production:
```bash
./k8s/canary/promote.sh
```

4. If issues detected, rollback:
```bash
./k8s/canary/rollback.sh
```

**Traffic Distribution**:
- Stable: 9 replicas (90%)
- Canary: 1 replica (10%)

**Access**: http://localhost:30002

## Testing Strategy

### Unit Tests (29 test cases)

**Coverage Areas**:
- Home endpoint (1 test)
- User management (9 tests)
- Workout management (12 tests)
- Progress tracking (6 tests)
- Integration workflows (1 test)

**Run Tests**:
```bash
# Run all tests
pytest test_aceest_fitness_app.py -v

# Run with coverage
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=html

# View coverage report
open htmlcov/index.html
```

**Test Results**: ✅ All 29 tests passing

## Docker Configuration

### Dockerfile Features

- Multi-layer build for optimal caching
- Non-root user for security
- Health checks included
- Minimal image size using Python slim
- Environment variable configuration

### Build and Run

```bash
# Build image
docker build -t aceest-fitness:v1.3.0 .

# Run container
docker run -d -p 5000:5000 aceest-fitness:v1.3.0

# Test application
curl http://localhost:5000/
```

### Docker Hub

```bash
# Tag for registry
docker tag aceest-fitness:v1.3.0 your-dockerhub-username/aceest-fitness:v1.3.0

# Push to Docker Hub
docker push your-dockerhub-username/aceest-fitness:v1.3.0
```

## SonarQube Integration

### Configuration

Project configuration is in `sonar-project.properties`:

```properties
sonar.projectKey=aceest-fitness
sonar.projectName=ACEest Fitness & Gym Tracker
sonar.sources=aceest_fitness_app.py
sonar.tests=test_aceest_fitness_app.py
sonar.python.coverage.reportPaths=coverage.xml
```

### Run Analysis

```bash
# With coverage
pytest --cov=aceest_fitness_app --cov-report=xml

# Run SonarQube scanner
sonar-scanner
```

## Kubernetes Deployment Guide

### Prerequisites

1. **Minikube** (local) or **Cloud Kubernetes** (AWS/Azure/GCP)
2. **kubectl** configured
3. **Docker** installed

### Initial Setup

```bash
# Start Minikube (if using local)
minikube start --cpus=4 --memory=8192

# Create namespace
kubectl apply -f k8s/namespace.yaml

# Verify namespace
kubectl get namespaces
```

### Deploy Application

Choose your deployment strategy:

#### Option 1: Rolling Update (Recommended for Production)
```bash
kubectl apply -f k8s/rolling/
kubectl get deployments -n aceest-fitness
kubectl get pods -n aceest-fitness
```

#### Option 2: Blue-Green (Recommended for Major Releases)
```bash
kubectl apply -f k8s/blue-green/deployment-blue.yaml
kubectl apply -f k8s/blue-green/deployment-green.yaml
kubectl apply -f k8s/blue-green/service.yaml
```

#### Option 3: Canary (Recommended for Risk Mitigation)
```bash
kubectl apply -f k8s/canary/
kubectl get deployments -n aceest-fitness
```

### Monitoring and Troubleshooting

```bash
# Check deployment status
kubectl rollout status deployment/aceest-fitness-rolling -n aceest-fitness

# View logs
kubectl logs -f deployment/aceest-fitness-rolling -n aceest-fitness

# Get pod details
kubectl describe pod <pod-name> -n aceest-fitness

# Access application
kubectl port-forward service/aceest-fitness-service 8080:80 -n aceest-fitness
```

### Rollback Procedures

#### Rolling Update Rollback
```bash
kubectl rollout undo deployment/aceest-fitness-rolling -n aceest-fitness
kubectl rollout history deployment/aceest-fitness-rolling -n aceest-fitness
```

#### Blue-Green Rollback
```bash
# Switch back to blue
./k8s/blue-green/switch.sh
```

#### Canary Rollback
```bash
# Scale canary to 0
./k8s/canary/rollback.sh
```

## Challenges Faced and Solutions

### Challenge 1: Converting Tkinter to Flask API
**Issue**: Original application was GUI-based with local storage.
**Solution**: Redesigned as RESTful API with in-memory database, maintaining all features while enabling containerization and scalability.

### Challenge 2: Comprehensive Test Coverage
**Issue**: Need extensive test coverage for CI/CD confidence.
**Solution**: Implemented 29 test cases covering all endpoints, edge cases, and integration scenarios, achieving high code coverage.

### Challenge 3: Zero-Downtime Deployments
**Issue**: Application updates causing service interruptions.
**Solution**: Implemented three deployment strategies (Rolling, Blue-Green, Canary) with health checks and readiness probes.

### Challenge 4: Environment Configuration
**Issue**: Different configurations for development, testing, and production.
**Solution**: Used environment variables and Kubernetes ConfigMaps for flexible configuration management.

## Key Automation Outcomes

1. **Automated Testing**: 29 tests run automatically on every commit
2. **Continuous Integration**: Jenkins pipeline triggers on git push
3. **Code Quality Gates**: SonarQube enforces quality standards
4. **Automated Deployment**: Three deployment strategies with rollback
5. **Container Registry**: Automatic versioning and push to Docker Hub
6. **Health Monitoring**: Built-in health checks and readiness probes

## Performance Metrics

- **Build Time**: ~2-3 minutes
- **Test Execution**: <1 second for all 29 tests
- **Docker Build**: ~30-40 seconds
- **Deployment Time**: ~1-2 minutes
- **Zero Downtime**: Achieved with all deployment strategies

## Future Improvements

1. **Persistent Storage**: Add database (PostgreSQL/MongoDB)
2. **Authentication**: Implement JWT-based authentication
3. **Monitoring**: Add Prometheus and Grafana
4. **Logging**: Centralized logging with ELK stack
5. **API Gateway**: Add Nginx or Kong for API management
6. **Auto-scaling**: Implement HPA (Horizontal Pod Autoscaler)
7. **CI/CD**: Add automated performance and security testing

## Repository Structure

```
.
├── aceest_fitness_app.py          # Main Flask application
├── test_aceest_fitness_app.py     # Comprehensive test suite
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Container configuration
├── Jenkinsfile                    # CI/CD pipeline definition
├── sonar-project.properties       # SonarQube configuration
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml
│   ├── rolling/                  # Rolling update strategy
│   ├── blue-green/              # Blue-green strategy
│   └── canary/                  # Canary strategy
├── versions/                     # Historical versions
└── ASSIGNMENT2_README.md         # This file
```

## Contact and Support

For questions or issues, please contact the development team or raise an issue in the GitHub repository.

## Acknowledgments

This project demonstrates modern DevOps practices as part of the Introduction to DevOps course (CSIZG514/SEZG514) at Taxila Business School.

---

**Version**: 1.3.0
**Last Updated**: October 31, 2025
**Author**: DevOps Team - ACEest Fitness & Gym
