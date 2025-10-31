pipeline {
    agent any

    environment {
        // Docker Registry Configuration
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_IMAGE_NAME = 'aceest-fitness'
        DOCKER_CREDENTIALS_ID = 'dockerhub-credentials'

        // Application versioning
        APP_VERSION = "1.3.${BUILD_NUMBER}"

        // SonarQube Configuration
        SONAR_PROJECT_KEY = 'aceest-fitness'
        SONAR_HOST_URL = 'http://localhost:9000'

        // Kubernetes Configuration
        KUBE_NAMESPACE = 'aceest-fitness'
        KUBE_CONFIG_ID = 'kubeconfig-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from Git repository..."
                    checkout scm
                    sh 'git rev-parse HEAD > commit-hash.txt'
                    env.GIT_COMMIT_HASH = readFile('commit-hash.txt').trim()
                    echo "Git Commit Hash: ${env.GIT_COMMIT_HASH}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                script {
                    echo "Installing Python dependencies..."
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install --upgrade pip
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    echo "Running unit tests with Pytest..."
                    sh '''
                        . venv/bin/activate
                        pytest test_aceest_fitness_app.py -v --junitxml=test-results.xml --cov=aceest_fitness_app --cov-report=xml --cov-report=html
                    '''
                }
            }
            post {
                always {
                    junit 'test-results.xml'
                    publishHTML(target: [
                        reportDir: 'htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Code Coverage Report'
                    ])
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "Running SonarQube static code analysis..."
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                            sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=aceest_fitness_app.py \
                                -Dsonar.tests=test_aceest_fitness_app.py \
                                -Dsonar.python.coverage.reportPaths=coverage.xml \
                                -Dsonar.python.version=3.11 \
                                -Dsonar.host.url=${SONAR_HOST_URL}
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    echo "Checking SonarQube Quality Gate..."
                    timeout(time: 5, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh """
                        docker build -t ${DOCKER_IMAGE_NAME}:${APP_VERSION} \
                                     -t ${DOCKER_IMAGE_NAME}:latest \
                                     --build-arg BUILD_DATE=\$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
                                     --build-arg VCS_REF=${GIT_COMMIT_HASH} \
                                     --build-arg VERSION=${APP_VERSION} .
                    """
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    echo "Testing Docker image..."
                    sh '''
                        # Stop any existing container
                        docker stop aceest-fitness-test 2>/dev/null || true
                        docker rm aceest-fitness-test 2>/dev/null || true

                        # Run container in test mode
                        docker run -d --name aceest-fitness-test -p 5001:5000 ${DOCKER_IMAGE_NAME}:${APP_VERSION}

                        # Wait for application to start
                        sleep 5

                        # Test health endpoint
                        curl -f http://localhost:5001/ || exit 1

                        # Clean up
                        docker stop aceest-fitness-test
                        docker rm aceest-fitness-test
                    '''
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                script {
                    echo "Pushing Docker image to registry..."
                    docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS_ID) {
                        sh """
                            docker tag ${DOCKER_IMAGE_NAME}:${APP_VERSION} ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${APP_VERSION}
                            docker tag ${DOCKER_IMAGE_NAME}:latest ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest
                            docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${APP_VERSION}
                            docker push ${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes - Rolling Update') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Deploying to Kubernetes with Rolling Update strategy..."
                    withKubeConfig([credentialsId: KUBE_CONFIG_ID]) {
                        sh """
                            kubectl apply -f k8s/namespace.yaml
                            kubectl set image deployment/aceest-fitness-rolling \
                                aceest-fitness=${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${APP_VERSION} \
                                -n ${KUBE_NAMESPACE}
                            kubectl rollout status deployment/aceest-fitness-rolling -n ${KUBE_NAMESPACE}
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes - Blue-Green') {
            when {
                branch 'release/*'
            }
            steps {
                script {
                    echo "Deploying to Kubernetes with Blue-Green strategy..."
                    withKubeConfig([credentialsId: KUBE_CONFIG_ID]) {
                        sh """
                            # Deploy green version
                            kubectl apply -f k8s/blue-green/deployment-green.yaml -n ${KUBE_NAMESPACE}
                            kubectl set image deployment/aceest-fitness-green \
                                aceest-fitness=${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${APP_VERSION} \
                                -n ${KUBE_NAMESPACE}
                            kubectl wait --for=condition=available --timeout=300s \
                                deployment/aceest-fitness-green -n ${KUBE_NAMESPACE}

                            # Switch service to green
                            kubectl patch service aceest-fitness-service \
                                -p '{"spec":{"selector":{"version":"green"}}}' \
                                -n ${KUBE_NAMESPACE}

                            echo "Blue-Green deployment completed. Green is now active."
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes - Canary') {
            when {
                branch 'develop'
            }
            steps {
                script {
                    echo "Deploying to Kubernetes with Canary strategy..."
                    withKubeConfig([credentialsId: KUBE_CONFIG_ID]) {
                        sh """
                            # Deploy canary version (10% traffic)
                            kubectl apply -f k8s/canary/deployment-canary.yaml -n ${KUBE_NAMESPACE}
                            kubectl set image deployment/aceest-fitness-canary \
                                aceest-fitness=${DOCKER_REGISTRY}/${DOCKER_IMAGE_NAME}:${APP_VERSION} \
                                -n ${KUBE_NAMESPACE}
                            kubectl rollout status deployment/aceest-fitness-canary -n ${KUBE_NAMESPACE}

                            echo "Canary deployment completed. 10% traffic routing to new version."
                        """
                    }
                }
            }
        }

        stage('Smoke Tests') {
            steps {
                script {
                    echo "Running smoke tests on deployed application..."
                    sh '''
                        # Get service endpoint
                        SERVICE_URL=$(kubectl get svc aceest-fitness-service -n ${KUBE_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

                        if [ -z "$SERVICE_URL" ]; then
                            SERVICE_URL="http://localhost:30000"
                        fi

                        # Test health endpoint
                        curl -f ${SERVICE_URL}/ || exit 1

                        echo "Smoke tests passed successfully!"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
            slackSend(
                color: 'good',
                message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' - Version ${APP_VERSION} deployed"
            )
        }
        failure {
            echo "Pipeline failed!"
            slackSend(
                color: 'danger',
                message: "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
            )
        }
        always {
            cleanWs()
            sh 'docker system prune -f'
        }
    }
}
