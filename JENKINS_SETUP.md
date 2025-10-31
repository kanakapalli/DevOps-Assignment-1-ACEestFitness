# Jenkins Setup and Execution Guide

This guide will help you set up Jenkins, configure the pipeline, and generate successful build runs for your assignment submission.

## Option 1: Quick Setup with Docker (Recommended)

### Step 1: Start Jenkins in Docker

```bash
# Create a Jenkins volume for persistent data
docker volume create jenkins_home

# Run Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

### Step 2: Get Initial Admin Password

```bash
# Wait 30 seconds for Jenkins to start, then get password
sleep 30
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Copy this password - you'll need it to unlock Jenkins.

### Step 3: Access Jenkins

1. Open browser: http://localhost:8080
2. Paste the admin password
3. Click "Install suggested plugins"
4. Create your admin user account

### Step 4: Install Required Plugins

Navigate to: **Manage Jenkins** → **Manage Plugins** → **Available**

Install these plugins:
- ✅ Docker Pipeline
- ✅ GitHub Integration
- ✅ SonarQube Scanner
- ✅ Kubernetes CLI
- ✅ Pipeline
- ✅ Slack Notification (optional)

Click "Download now and install after restart"

### Step 5: Configure Docker Hub Credentials

1. Go to: **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **Add Credentials**
4. Fill in:
   - Kind: `Username with password`
   - Username: `<your-dockerhub-username>`
   - Password: `<your-dockerhub-password>`
   - ID: `docker-hub-credentials`
   - Description: `Docker Hub`
5. Click **Create**

### Step 6: Create Pipeline Job

1. Click **New Item**
2. Enter name: `aceest-fitness-cicd`
3. Select **Pipeline**
4. Click **OK**

5. In the configuration page:
   - **Description**: `ACEest Fitness CI/CD Pipeline`
   - **Pipeline** section:
     - Definition: `Pipeline script from SCM`
     - SCM: `Git`
     - Repository URL: `https://github.com/<your-username>/DevOps-Assignment-1-ACEestFitness`
     - Branch: `*/assignment-2-cicd`
     - Script Path: `Jenkinsfile`
   - Click **Save**

### Step 7: Run the Pipeline

1. Click **Build Now**
2. Watch the build progress in the console output
3. Build should complete successfully

### Step 8: Capture Screenshots for Submission

Take screenshots of:
1. ✅ **Pipeline Overview**: Shows all stages (green checkmarks)
2. ✅ **Console Output**: Shows successful test execution (29 passed)
3. ✅ **Build History**: Shows multiple successful builds
4. ✅ **Test Results**: Shows test reports

---

## Option 2: Local Jenkins Installation

### macOS

```bash
# Install via Homebrew
brew install jenkins-lts

# Start Jenkins
brew services start jenkins-lts

# Get initial password
cat /usr/local/var/jenkins_home/secrets/initialAdminPassword
```

Access at: http://localhost:8080

### Linux (Ubuntu/Debian)

```bash
# Add Jenkins repository
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

# Install Jenkins
sudo apt update
sudo apt install jenkins -y

# Start Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Access at: http://localhost:8080

### Windows

1. Download Jenkins Windows installer from: https://www.jenkins.io/download/
2. Run the installer
3. Follow the installation wizard
4. Access at: http://localhost:8080

---

## Configuring SonarQube Integration in Jenkins

### Step 1: Add SonarQube Server

1. Go to: **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers** section
3. Click **Add SonarQube**
4. Fill in:
   - Name: `SonarQube`
   - Server URL: `http://localhost:9000` (or your SonarQube URL)
   - Server authentication token: (get from SonarQube)
5. Click **Save**

---

## Generating Build History for Submission

Run the pipeline multiple times to show consistency:

```bash
# Method 1: Via Jenkins UI
# Click "Build Now" 3-5 times

# Method 2: Via Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ build aceest-fitness-cicd -w

# Method 3: Via API with curl
curl -X POST http://localhost:8080/job/aceest-fitness-cicd/build \
  --user admin:your-api-token
```

---

## Expected Pipeline Output

Your successful pipeline should show:

```
✅ Stage 1: Checkout - SUCCESS (5s)
✅ Stage 2: Install Dependencies - SUCCESS (15s)
✅ Stage 3: Run Unit Tests - SUCCESS (2s)
   - 29 tests passed
   - 0 tests failed
   - Code coverage: High
✅ Stage 4: SonarQube Analysis - SUCCESS (10s)
✅ Stage 5: Quality Gate - SUCCESS (3s)
✅ Stage 6: Build Docker Image - SUCCESS (35s)
✅ Stage 7: Test Docker Image - SUCCESS (5s)
✅ Stage 8: Push to Docker Registry - SUCCESS (20s)
✅ Stage 9: Deploy to Kubernetes - SUCCESS (15s)

Total Duration: ~2 minutes
Status: SUCCESS
```

---

## Troubleshooting

### Jenkins Can't Access Docker

**Problem**: Jenkins pipeline fails at Docker build stage.

**Solution**: Give Jenkins access to Docker socket:

```bash
# Docker-based Jenkins
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Local Jenkins (Linux)
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Pipeline Fails at SonarQube Stage

**Problem**: "SonarQube server not configured"

**Solution**: Either:
1. Set up SonarQube (see SONARQUBE_SETUP.md), OR
2. Temporarily comment out SonarQube stages in Jenkinsfile

### Kubernetes Deployment Fails

**Problem**: kubectl not found or not configured

**Solution**:
```bash
# Install kubectl
brew install kubectl  # macOS
# or
sudo apt install kubectl  # Linux

# Configure for Minikube
minikube start
kubectl config use-context minikube
```

---

## What to Submit

For your assignment submission, provide:

1. **Jenkins Pipeline URL**: `http://<your-jenkins-url>/job/aceest-fitness-cicd/`
2. **Screenshots** (take 4-5 screenshots):
   - Pipeline overview with all green stages
   - Console output showing test results
   - Build history showing multiple successful runs
   - Test report dashboard
3. **Build Logs**: Export a successful build log as `.txt` file

### Export Build Log

```bash
# Via Jenkins UI:
# Build #X → Console Output → Click "View as plain text" → Save

# Via curl:
curl http://localhost:8080/job/aceest-fitness-cicd/lastSuccessfulBuild/consoleText > jenkins-build-log.txt
```

---

## Quick Commands Reference

```bash
# Start Jenkins (Docker)
docker start jenkins

# Stop Jenkins (Docker)
docker stop jenkins

# View Jenkins logs
docker logs -f jenkins

# Restart Jenkins
docker restart jenkins

# Access Jenkins CLI
docker exec -it jenkins bash
```

---

## Cloud Alternatives (If Local Setup Has Issues)

If you can't run Jenkins locally, use these cloud options:

### 1. Jenkins Cloud (Free Trial)
- URL: https://www.cloudbees.com/
- Free tier available
- Pre-configured environment

### 2. GitHub Actions (Alternative to Jenkins)
Create `.github/workflows/ci.yml`:
```yaml
name: CI/CD Pipeline
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          pip install -r requirements.txt
          pytest -v
      - name: Build Docker
        run: docker build -t aceest-fitness:${{ github.sha }} .
```

---

**Next Steps**:
1. Run the Docker command above to start Jenkins
2. Follow steps 2-7 to configure the pipeline
3. Run "Build Now" 3-5 times to generate build history
4. Take screenshots for submission
5. Move to SonarQube setup (see SONARQUBE_SETUP.md)
