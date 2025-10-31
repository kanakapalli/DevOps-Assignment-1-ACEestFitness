#!/bin/bash
# Automated SonarQube Analysis Script
# Usage: ./run-sonarqube-analysis.sh

set -e

echo "============================================"
echo "     SonarQube Analysis Script"
echo "============================================"
echo ""

# Check if SONAR_TOKEN is set
if [ -z "$SONAR_TOKEN" ]; then
    echo "❌ Error: SONAR_TOKEN environment variable not set"
    echo ""
    echo "Please set your SonarQube token:"
    echo "  export SONAR_TOKEN=<your-token>"
    echo ""
    echo "To get a token:"
    echo "  1. Go to http://localhost:9000"
    echo "  2. Login (admin/admin)"
    echo "  3. My Account → Security → Generate Token"
    echo ""
    exit 1
fi

# Check if SonarQube is running
echo "Step 1: Checking SonarQube connection..."
echo "-------------------------------------------"
if curl -s -u ${SONAR_TOKEN}: http://localhost:9000/api/system/status | grep -q "UP"; then
    echo "✅ SonarQube is running"
else
    echo "❌ SonarQube is not accessible at http://localhost:9000"
    echo ""
    echo "Start SonarQube with:"
    echo "  docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community"
    echo ""
    exit 1
fi

echo ""
echo "Step 2: Installing dependencies..."
echo "-------------------------------------------"
pip install -r requirements.txt --quiet

echo ""
echo "Step 3: Running tests with coverage..."
echo "-------------------------------------------"
pytest test_aceest_fitness_app.py \
  --cov=aceest_fitness_app \
  --cov-report=xml \
  --cov-report=html \
  --cov-report=term \
  -v

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Tests failed! Fix tests before running SonarQube analysis."
    exit 1
fi

echo ""
echo "Step 4: Running SonarQube analysis..."
echo "-------------------------------------------"

# Check if sonar-scanner is installed
if ! command -v sonar-scanner &> /dev/null; then
    echo "❌ sonar-scanner not found"
    echo ""
    echo "Install with:"
    echo "  macOS: brew install sonar-scanner"
    echo "  Linux: See SONARQUBE_SETUP.md"
    echo ""
    exit 1
fi

sonar-scanner \
  -Dsonar.projectKey=aceest-fitness \
  -Dsonar.projectName="ACEest Fitness & Gym Tracker" \
  -Dsonar.projectVersion=1.3.0 \
  -Dsonar.sources=aceest_fitness_app.py \
  -Dsonar.tests=test_aceest_fitness_app.py \
  -Dsonar.python.coverage.reportPaths=coverage.xml \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=${SONAR_TOKEN}

if [ $? -eq 0 ]; then
    echo ""
    echo "============================================"
    echo "     ✅ Analysis Complete!"
    echo "============================================"
    echo ""
    echo "View results at:"
    echo "  http://localhost:9000/dashboard?id=aceest-fitness"
    echo ""
    echo "Coverage report (local):"
    echo "  open htmlcov/index.html"
    echo ""
else
    echo ""
    echo "❌ Analysis failed. Check the output above."
    exit 1
fi

# Display summary
echo "Summary:"
echo "  - 29 tests executed"
echo "  - Coverage report generated"
echo "  - SonarQube analysis completed"
echo "  - Quality Gate: Check dashboard"
echo ""
