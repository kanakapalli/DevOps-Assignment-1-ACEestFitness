#!/bin/bash
# Complete Deployment Setup Script
# This script helps you complete all runtime deployments for Assignment 2
# Usage: ./complete-deployment.sh

set -e

echo "=========================================="
echo "  ACEest Fitness - Complete Deployment"
echo "  Assignment 2 Runtime Setup"
echo "=========================================="
echo ""

# Color codes for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if Docker is running
check_docker() {
    if ! command_exists docker; then
        print_error "Docker is not installed"
        echo "Install from: https://www.docker.com/products/docker-desktop"
        return 1
    fi

    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop."
        return 1
    fi

    print_success "Docker is running"
    return 0
}

# Main menu
show_menu() {
    echo ""
    echo "=========================================="
    echo "What would you like to do?"
    echo "=========================================="
    echo "1) Push Docker images to Docker Hub"
    echo "2) Start Jenkins server"
    echo "3) Start SonarQube server"
    echo "4) Run SonarQube analysis"
    echo "5) Deploy to Kubernetes (Minikube)"
    echo "6) Run all tests locally"
    echo "7) View deployment status"
    echo "8) Stop all services"
    echo "9) Complete setup guide (interactive)"
    echo "0) Exit"
    echo ""
    read -p "Enter your choice [0-9]: " choice
}

# Option 1: Push Docker images
push_docker_images() {
    echo ""
    echo "=========================================="
    echo "  Push Docker Images to Docker Hub"
    echo "=========================================="
    echo ""

    read -p "Enter your Docker Hub username: " dockerhub_username

    if [ -z "$dockerhub_username" ]; then
        print_error "Username cannot be empty"
        return 1
    fi

    ./push-docker-images.sh "$dockerhub_username"
}

# Option 2: Start Jenkins
start_jenkins() {
    echo ""
    echo "=========================================="
    echo "  Starting Jenkins Server"
    echo "=========================================="
    echo ""

    if docker ps -a | grep -q jenkins; then
        if docker ps | grep -q jenkins; then
            print_info "Jenkins is already running"
            echo "Access at: http://localhost:8080"
        else
            print_info "Starting existing Jenkins container..."
            docker start jenkins
            print_success "Jenkins started"
        fi
    else
        print_info "Creating new Jenkins container..."
        docker volume create jenkins_home
        docker run -d \
          --name jenkins \
          -p 8080:8080 \
          -p 50000:50000 \
          -v jenkins_home:/var/jenkins_home \
          -v /var/run/docker.sock:/var/run/docker.sock \
          jenkins/jenkins:lts

        print_success "Jenkins container created"
        print_info "Waiting 30 seconds for Jenkins to start..."
        sleep 30

        echo ""
        echo "Initial admin password:"
        docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword || true
    fi

    echo ""
    print_success "Jenkins is running at: http://localhost:8080"
    echo ""
    print_info "See JENKINS_SETUP.md for configuration instructions"
}

# Option 3: Start SonarQube
start_sonarqube() {
    echo ""
    echo "=========================================="
    echo "  Starting SonarQube Server"
    echo "=========================================="
    echo ""

    if docker ps -a | grep -q sonarqube; then
        if docker ps | grep -q sonarqube; then
            print_info "SonarQube is already running"
            echo "Access at: http://localhost:9000"
        else
            print_info "Starting existing SonarQube container..."
            docker start sonarqube
            print_success "SonarQube started"
        fi
    else
        print_info "Creating new SonarQube container..."
        docker run -d \
          --name sonarqube \
          -p 9000:9000 \
          -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
          sonarqube:lts-community

        print_success "SonarQube container created"
        print_info "Waiting 2 minutes for SonarQube to initialize..."
        sleep 120
    fi

    echo ""
    print_success "SonarQube is running at: http://localhost:9000"
    echo "Default credentials: admin / admin"
    echo ""
    print_info "See SONARQUBE_SETUP.md for configuration instructions"
}

# Option 4: Run SonarQube analysis
run_sonarqube_analysis() {
    echo ""
    echo "=========================================="
    echo "  Run SonarQube Analysis"
    echo "=========================================="
    echo ""

    if [ -z "$SONAR_TOKEN" ]; then
        print_error "SONAR_TOKEN not set"
        echo ""
        echo "To set your token:"
        echo "  export SONAR_TOKEN=<your-token>"
        echo ""
        echo "Get token from: http://localhost:9000 → My Account → Security"
        return 1
    fi

    ./run-sonarqube-analysis.sh
}

# Option 5: Deploy to Kubernetes
deploy_kubernetes() {
    echo ""
    echo "=========================================="
    echo "  Deploy to Kubernetes (Minikube)"
    echo "=========================================="
    echo ""

    if ! command_exists kubectl; then
        print_error "kubectl is not installed"
        echo "Install with: brew install kubectl"
        return 1
    fi

    if ! command_exists minikube; then
        print_error "minikube is not installed"
        echo "Install with: brew install minikube"
        return 1
    fi

    # Check if Minikube is running
    if ! minikube status >/dev/null 2>&1; then
        print_info "Starting Minikube..."
        minikube start --cpus=4 --memory=8192
    else
        print_success "Minikube is running"
    fi

    echo ""
    echo "Choose deployment strategy:"
    echo "1) Rolling Update (recommended)"
    echo "2) Blue-Green"
    echo "3) Canary"
    echo "4) Shadow (requires Istio)"
    echo "5) A/B Testing (requires Istio)"
    echo ""
    read -p "Enter choice [1-5]: " deploy_choice

    # Create namespace
    kubectl apply -f k8s/namespace.yaml

    case $deploy_choice in
        1)
            print_info "Deploying with Rolling Update strategy..."
            kubectl apply -f k8s/rolling/
            ;;
        2)
            print_info "Deploying with Blue-Green strategy..."
            kubectl apply -f k8s/blue-green/
            ;;
        3)
            print_info "Deploying with Canary strategy..."
            kubectl apply -f k8s/canary/
            ;;
        4)
            print_info "Deploying with Shadow strategy..."
            print_info "Note: Requires Istio service mesh"
            kubectl apply -f k8s/shadow/
            ;;
        5)
            print_info "Deploying with A/B Testing strategy..."
            print_info "Note: Requires Istio service mesh"
            kubectl apply -f k8s/ab-testing/
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac

    echo ""
    print_info "Waiting for pods to be ready..."
    sleep 10

    kubectl get pods -n aceest-fitness
    kubectl get services -n aceest-fitness

    echo ""
    print_success "Deployment complete!"
    echo ""
    print_info "Access application with:"
    echo "  kubectl port-forward service/aceest-fitness-service 8080:80 -n aceest-fitness"
    echo "  curl http://localhost:8080/"
}

# Option 6: Run tests locally
run_tests() {
    echo ""
    echo "=========================================="
    echo "  Running Tests Locally"
    echo "=========================================="
    echo ""

    if ! command_exists pytest; then
        print_info "Installing dependencies..."
        pip install -r requirements.txt
    fi

    pytest test_aceest_fitness_app.py -v --cov=aceest_fitness_app --cov-report=term

    echo ""
    print_success "All tests completed"
}

# Option 7: View deployment status
view_status() {
    echo ""
    echo "=========================================="
    echo "  Deployment Status"
    echo "=========================================="
    echo ""

    # Check Docker
    if check_docker; then
        echo ""
        echo "Docker Containers:"
        echo "-------------------"
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "jenkins|sonarqube|NAMES" || echo "No jenkins or sonarqube containers running"
    fi

    echo ""
    echo "Kubernetes Status:"
    echo "-------------------"
    if command_exists kubectl && minikube status >/dev/null 2>&1; then
        kubectl get pods -n aceest-fitness 2>/dev/null || echo "No pods in aceest-fitness namespace"
    else
        echo "Kubernetes not running"
    fi

    echo ""
    echo "Access URLs:"
    echo "-------------------"
    echo "Jenkins:    http://localhost:8080"
    echo "SonarQube:  http://localhost:9000"
    echo "App (K8s):  kubectl port-forward service/aceest-fitness-service 8080:80 -n aceest-fitness"
    echo ""
}

# Option 8: Stop all services
stop_services() {
    echo ""
    echo "=========================================="
    echo "  Stopping All Services"
    echo "=========================================="
    echo ""

    read -p "Are you sure? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        echo "Cancelled"
        return
    fi

    print_info "Stopping Docker containers..."
    docker stop jenkins sonarqube 2>/dev/null || true

    print_info "Stopping Minikube..."
    minikube stop 2>/dev/null || true

    print_success "All services stopped"
}

# Option 9: Complete setup guide
complete_setup() {
    echo ""
    echo "=========================================="
    echo "  Complete Setup Guide (Interactive)"
    echo "=========================================="
    echo ""

    print_info "This will guide you through all deployment steps"
    echo ""

    # Step 1: Docker Hub
    echo "Step 1: Docker Hub"
    echo "-------------------"
    read -p "Push images to Docker Hub? (y/n): " do_docker
    if [ "$do_docker" = "y" ]; then
        push_docker_images
    fi

    # Step 2: Jenkins
    echo ""
    echo "Step 2: Jenkins"
    echo "-------------------"
    read -p "Start Jenkins server? (y/n): " do_jenkins
    if [ "$do_jenkins" = "y" ]; then
        start_jenkins
    fi

    # Step 3: SonarQube
    echo ""
    echo "Step 3: SonarQube"
    echo "-------------------"
    read -p "Start SonarQube server? (y/n): " do_sonar
    if [ "$do_sonar" = "y" ]; then
        start_sonarqube
    fi

    # Step 4: Tests
    echo ""
    echo "Step 4: Tests"
    echo "-------------------"
    read -p "Run tests locally? (y/n): " do_tests
    if [ "$do_tests" = "y" ]; then
        run_tests
    fi

    echo ""
    print_success "Setup complete!"
    echo ""
    print_info "Next steps:"
    echo "1. Configure Jenkins pipeline (see JENKINS_SETUP.md)"
    echo "2. Run SonarQube analysis after getting token"
    echo "3. Deploy to Kubernetes if needed"
    echo "4. Take screenshots for submission"
    echo ""
}

# Main loop
main() {
    # Check prerequisites
    if ! check_docker; then
        exit 1
    fi

    while true; do
        show_menu

        case $choice in
            1) push_docker_images ;;
            2) start_jenkins ;;
            3) start_sonarqube ;;
            4) run_sonarqube_analysis ;;
            5) deploy_kubernetes ;;
            6) run_tests ;;
            7) view_status ;;
            8) stop_services ;;
            9) complete_setup ;;
            0)
                echo ""
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 0-9."
                ;;
        esac

        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run main function
main
