#!/bin/bash
# Quick script to open all services in browser

echo "Opening services in your default browser..."
echo ""

# Wait a moment
sleep 1

# Open Jenkins
echo "Opening Jenkins: http://localhost:8080"
open http://localhost:8080 2>/dev/null || xdg-open http://localhost:8080 2>/dev/null || echo "  → Please open manually: http://localhost:8080"

# Wait before opening next
sleep 2

# Open SonarQube
echo "Opening SonarQube: http://localhost:9000"
open http://localhost:9000 2>/dev/null || xdg-open http://localhost:9000 2>/dev/null || echo "  → Please open manually: http://localhost:9000"

echo ""
echo "=========================================="
echo "Services Information"
echo "=========================================="
echo ""
echo "Jenkins:"
echo "  URL: http://localhost:8080"
echo "  Username: admin"
echo "  Password: 7ce20481d7cd4b20a0bd56f874b6ec01"
echo ""
echo "SonarQube:"
echo "  URL: http://localhost:9000"
echo "  Username: admin"
echo "  Password: admin (change on first login)"
echo ""
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Set up SonarQube (create project & token)"
echo "2. Run: export SONAR_TOKEN=<your-token>"
echo "3. Run: ./run-sonarqube-analysis.sh"
echo "4. Set up Jenkins pipeline"
echo "5. Take screenshots"
echo ""
echo "See SCREENSHOT_GUIDE.md for detailed instructions"
echo ""
