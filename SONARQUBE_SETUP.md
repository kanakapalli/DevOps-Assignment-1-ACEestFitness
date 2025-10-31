# SonarQube Setup and Code Analysis Guide

This guide will help you set up SonarQube, run code analysis, and generate quality reports for your assignment submission.

## Quick Setup with Docker (Recommended)

### Step 1: Start SonarQube in Docker

```bash
# Run SonarQube Community Edition
docker run -d \
  --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community
```

**Note**: SonarQube takes 1-2 minutes to start. Wait before accessing.

### Step 2: Access SonarQube

1. Open browser: http://localhost:9000
2. Wait for SonarQube to fully start (you'll see the login page)
3. Default credentials:
   - Username: `admin`
   - Password: `admin`
4. You'll be prompted to change the password - choose a new one

### Step 3: Create Project

1. Click **Create Project** → **Manually**
2. Fill in:
   - **Project key**: `aceest-fitness`
   - **Display name**: `ACEest Fitness & Gym Tracker`
3. Click **Set Up**
4. Choose **Locally**
5. Generate token:
   - Token name: `aceest-fitness-token`
   - Click **Generate**
   - **COPY AND SAVE THIS TOKEN** - you'll need it

### Step 4: Install SonarQube Scanner

#### macOS
```bash
brew install sonar-scanner
```

#### Linux
```bash
# Download SonarScanner
wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip

# Extract
unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux /opt/sonar-scanner

# Add to PATH
echo 'export PATH="/opt/sonar-scanner/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

#### Windows
1. Download from: https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
2. Extract to `C:\sonar-scanner`
3. Add `C:\sonar-scanner\bin` to PATH

### Step 5: Configure SonarQube Token

Your project already has `sonar-project.properties` configured. Now add your token:

```bash
# Navigate to project directory
cd /Users/kanakapallianurag/Documents/GitHub/DevOps-Assignment-1-ACEestFitness

# Set environment variable (temporary)
export SONAR_TOKEN=<paste-your-token-here>

# Or add to your shell profile for persistence
echo 'export SONAR_TOKEN=<your-token>' >> ~/.zshrc  # macOS
echo 'export SONAR_TOKEN=<your-token>' >> ~/.bashrc  # Linux
```

### Step 6: Run Code Analysis

```bash
# Make sure you're in the project directory
cd /Users/kanakapallianurag/Documents/GitHub/DevOps-Assignment-1-ACEestFitness

# Generate coverage report first
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=xml --cov-report=html

# Run SonarQube analysis
sonar-scanner \
  -Dsonar.projectKey=aceest-fitness \
  -Dsonar.sources=aceest_fitness_app.py \
  -Dsonar.tests=test_aceest_fitness_app.py \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=${SONAR_TOKEN}
```

### Step 7: View Results

1. Go to: http://localhost:9000
2. Click on **aceest-fitness** project
3. You'll see the quality dashboard with:
   - ✅ **Bugs**: Should be 0
   - ✅ **Vulnerabilities**: Should be 0
   - ✅ **Code Smells**: Should be low
   - ✅ **Coverage**: Should show test coverage
   - ✅ **Duplications**: Should be low
   - ✅ **Security Hotspots**: Should be 0

---

## Expected SonarQube Results

Your analysis should show:

```
====================================
     SonarQube Analysis Results
====================================

Project: ACEest Fitness & Gym Tracker
Version: 1.3.0
Analysis Status: ✅ PASSED

Quality Gate: ✅ PASSED

Reliability Rating: A (0 bugs)
Security Rating: A (0 vulnerabilities)
Maintainability Rating: A (few code smells)
Coverage: ~85-95%
Duplications: <3%
Lines of Code: ~500

====================================
```

---

## Integration with Jenkins

### Add SonarQube Credentials to Jenkins

1. Go to Jenkins: **Manage Jenkins** → **Manage Credentials**
2. Click **Add Credentials**
3. Fill in:
   - Kind: `Secret text`
   - Secret: `<your-sonarqube-token>`
   - ID: `sonarqube-token`
   - Description: `SonarQube Authentication Token`
4. Click **Create**

### Configure SonarQube Server in Jenkins

1. **Manage Jenkins** → **Configure System**
2. Scroll to **SonarQube servers**
3. Click **Add SonarQube**
4. Fill in:
   - Name: `SonarQube`
   - Server URL: `http://localhost:9000`
   - Server authentication token: Select `sonarqube-token` from dropdown
5. Click **Save**

### Test Integration

Run your Jenkins pipeline again. The SonarQube stages should now pass:
- ✅ Stage 4: SonarQube Analysis
- ✅ Stage 5: Quality Gate

---

## Alternative: Run Analysis Without SonarQube Server

If you can't run SonarQube server, you can still generate a local report:

```bash
# Install pylint for static analysis
pip install pylint

# Run pylint
pylint aceest_fitness_app.py --output-format=json > pylint-report.json

# View report
cat pylint-report.json
```

---

## Troubleshooting

### SonarQube Won't Start

**Problem**: Container exits immediately or won't start.

**Solution**: Increase Docker memory to 4GB:
```bash
# Docker Desktop → Settings → Resources → Memory: 4GB

# Then restart SonarQube
docker rm -f sonarqube
docker run -d --name sonarqube -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community
```

### "Compute Engine" Error

**Problem**: SonarQube shows "Compute Engine is not operational".

**Solution**: Wait 2-3 minutes for SonarQube to fully initialize:
```bash
# Check logs
docker logs -f sonarqube

# Wait for: "SonarQube is operational"
```

### Analysis Fails with "Project Not Found"

**Problem**: Scanner can't find project on server.

**Solution**: Make sure project key matches:
```bash
# In sonar-project.properties:
sonar.projectKey=aceest-fitness

# In scanner command:
-Dsonar.projectKey=aceest-fitness
```

### Coverage Report Not Showing

**Problem**: SonarQube shows 0% coverage.

**Solution**: Generate coverage XML first:
```bash
# Run tests with coverage
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=xml

# Verify coverage.xml exists
ls -la coverage.xml

# Then run sonar-scanner
sonar-scanner -Dsonar.login=${SONAR_TOKEN}
```

---

## What to Submit for Assignment

### 1. SonarQube Dashboard Screenshot

Capture the main dashboard showing:
- ✅ Quality Gate status (Passed)
- ✅ Reliability rating (A)
- ✅ Security rating (A)
- ✅ Maintainability rating (A)
- ✅ Coverage percentage
- ✅ Code smells count
- ✅ Lines of code

### 2. Project URL

Provide the SonarQube project URL:
```
http://localhost:9000/dashboard?id=aceest-fitness
```

### 3. Quality Gate Details

Take screenshot of **Quality Gate** conditions:
- ✅ Coverage on new code > 80%
- ✅ Duplicated lines < 3%
- ✅ Maintainability rating = A
- ✅ Reliability rating = A
- ✅ Security rating = A

### 4. Export PDF Report (Optional)

SonarQube allows exporting reports:
1. Go to project dashboard
2. Click **More** → **Export as PDF**
3. Save as `sonarqube-analysis-report.pdf`

---

## Quick Commands Reference

```bash
# Start SonarQube
docker start sonarqube

# Stop SonarQube
docker stop sonarqube

# View logs
docker logs -f sonarqube

# Restart SonarQube
docker restart sonarqube

# Remove and recreate
docker rm -f sonarqube
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community

# Run analysis (quick command)
pytest --cov=aceest_fitness_app --cov-report=xml && sonar-scanner -Dsonar.login=${SONAR_TOKEN}
```

---

## Automated Analysis Script

Create a script for easy re-analysis:

```bash
#!/bin/bash
# run-sonarqube-analysis.sh

echo "Step 1: Running tests with coverage..."
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=xml --cov-report=html -v

if [ $? -ne 0 ]; then
    echo "❌ Tests failed! Fix tests before running SonarQube analysis."
    exit 1
fi

echo ""
echo "Step 2: Running SonarQube analysis..."
sonar-scanner \
  -Dsonar.projectKey=aceest-fitness \
  -Dsonar.sources=aceest_fitness_app.py \
  -Dsonar.tests=test_aceest_fitness_app.py \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=${SONAR_TOKEN}

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Analysis complete!"
    echo "View results: http://localhost:9000/dashboard?id=aceest-fitness"
else
    echo "❌ Analysis failed. Check the output above."
    exit 1
fi
```

Save this and run:
```bash
chmod +x run-sonarqube-analysis.sh
./run-sonarqube-analysis.sh
```

---

## Cloud Alternatives

If you can't run SonarQube locally:

### SonarCloud (Free for public repos)

1. Go to: https://sonarcloud.io
2. Sign in with GitHub
3. Click **Analyze new project**
4. Select your repository
5. Follow setup wizard
6. Results available at: `https://sonarcloud.io/project/overview?id=<your-project>`

Benefits:
- ✅ No local installation needed
- ✅ Automatic analysis on push
- ✅ Integration with GitHub
- ✅ Professional reports

---

## Understanding the Results

### Quality Gate Conditions

- **Bugs**: Logic errors that should be fixed
- **Vulnerabilities**: Security issues
- **Code Smells**: Maintainability issues
- **Coverage**: Percentage of code tested
- **Duplications**: Repeated code blocks

### Ratings (A-E Scale)

- **A**: Excellent (0-5% issues)
- **B**: Good (6-10% issues)
- **C**: Moderate (11-20% issues)
- **D**: Poor (21-50% issues)
- **E**: Very Poor (>50% issues)

Your project should achieve A ratings across all categories.

---

**Next Steps**:
1. Start SonarQube with Docker command above
2. Access http://localhost:9000 and create project
3. Run `pytest` with coverage
4. Run `sonar-scanner` with your token
5. Take screenshots of the dashboard
6. Include SonarQube URL in your assignment submission
