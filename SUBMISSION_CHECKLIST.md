# Assignment 2 Submission Checklist

Use this checklist to ensure you have completed all requirements before submitting your assignment.

---

## 🔑 QUICK CREDENTIALS REFERENCE

**Both services are running! Use these to login:**

### Jenkins - http://localhost:8080
- **Unlock Password**: `7ce20481d7cd4b20a0bd56f874b6ec01`
- *(Create your own admin user during setup)*

### SonarQube - http://localhost:9000
- **Username**: `admin`
- **Password**: `admin`
- *(Change password on first login)*

**📄 See CREDENTIALS.md for complete details**

---

## ✅ Part 1: Code and Configuration (COMPLETED)

- ✅ Flask REST API with 9 endpoints (`aceest_fitness_app.py`)
- ✅ 29 comprehensive unit tests (`test_aceest_fitness_app.py`)
- ✅ All tests passing (100% pass rate)
- ✅ Dockerfile with security best practices
- ✅ Jenkinsfile with 9-stage CI/CD pipeline
- ✅ SonarQube configuration (`sonar-project.properties`)
- ✅ Requirements.txt with all dependencies
- ✅ Version control with 7 application versions preserved
- ✅ 5 Kubernetes deployment strategies:
  - ✅ Rolling Update (`k8s/rolling/`)
  - ✅ Blue-Green (`k8s/blue-green/`)
  - ✅ Canary (`k8s/canary/`)
  - ✅ Shadow (`k8s/shadow/`)
  - ✅ A/B Testing (`k8s/ab-testing/`)
- ✅ Complete documentation:
  - ✅ ASSIGNMENT2_README.md (3000+ lines)
  - ✅ QUICKSTART.md
  - ✅ ASSIGNMENT_REPORT.md (2-3 pages)
  - ✅ READMEs for each deployment strategy

**Status**: ✅ ALL CODE COMPLETE

---

## 📋 Part 2: Runtime Deployments (TO DO)

These require you to run the setup steps and capture evidence.

### 1. Docker Hub Repository

**What you need:**
- [ ] Docker Hub account created
- [ ] Images pushed to Docker Hub
- [ ] Multiple versions available (v1.0.0, v1.1.0, v1.2.0, v1.3.0, latest)
- [ ] Repository URL documented

**How to complete:**
```bash
# Run the provided script
chmod +x push-docker-images.sh
./push-docker-images.sh <your-dockerhub-username>
```

**What to submit:**
- Docker Hub repository URL: `https://hub.docker.com/r/<username>/aceest-fitness`
- Screenshot showing all image tags

**Time required:** 5-10 minutes

---

### 2. Jenkins Pipeline

**What you need:**
- [ ] Jenkins running (Docker or local)
- [ ] Pipeline configured with Jenkinsfile
- [ ] 3-5 successful build runs completed
- [ ] Build history captured

**How to complete:**
1. Follow `JENKINS_SETUP.md` to start Jenkins
2. Configure the pipeline
3. Run "Build Now" 3-5 times
4. Take screenshots

**What to submit:**
- Jenkins pipeline URL: `http://<your-jenkins>/job/aceest-fitness-cicd/`
- Screenshots:
  - [ ] Pipeline overview (all stages green)
  - [ ] Console output showing test results (29 passed)
  - [ ] Build history showing multiple runs
  - [ ] Test report dashboard
- Build log file: `jenkins-build-log.txt`

**Time required:** 20-30 minutes

---

### 3. SonarQube Analysis

**What you need:**
- [ ] SonarQube running (Docker or cloud)
- [ ] Project created: `aceest-fitness`
- [ ] Analysis completed
- [ ] Quality Gate passed

**How to complete:**
1. Follow `SONARQUBE_SETUP.md` to start SonarQube
2. Create project and get token
3. Run analysis script
4. Capture results

**What to submit:**
- SonarQube project URL: `http://localhost:9000/dashboard?id=aceest-fitness`
- Screenshots:
  - [ ] Quality Gate status (Passed)
  - [ ] Reliability rating (A)
  - [ ] Security rating (A)
  - [ ] Maintainability rating (A)
  - [ ] Coverage percentage
  - [ ] Overview dashboard
- Optional: PDF export of report

**Time required:** 15-20 minutes

---

### 4. Kubernetes Deployment (Optional but Recommended)

**What you need:**
- [ ] Kubernetes cluster running (Minikube or cloud)
- [ ] At least one deployment strategy deployed
- [ ] Application accessible via kubectl port-forward or NodePort
- [ ] Pods running successfully

**How to complete:**
```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Deploy using Rolling Update
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/rolling/

# Verify deployment
kubectl get pods -n aceest-fitness
kubectl get services -n aceest-fitness

# Access application
kubectl port-forward service/aceest-fitness-service 8080:80 -n aceest-fitness

# Test
curl http://localhost:8080/
```

**What to submit:**
- Screenshots:
  - [ ] `kubectl get pods -n aceest-fitness` output
  - [ ] `kubectl get services -n aceest-fitness` output
  - [ ] Application response via curl or browser
  - [ ] Deployment rollout status
- Kubernetes cluster URL (if using cloud)

**Time required:** 15-25 minutes

---

## 📝 Part 3: Documentation

**Assignment Report:**
- [ ] Student name and ID filled in `ASSIGNMENT_REPORT.md`
- [ ] GitHub repository URL added
- [ ] Docker Hub username added
- [ ] All URLs updated with your actual values

**Repository:**
- [ ] All changes committed to `assignment-2-cicd` branch
- [ ] Pushed to GitHub
- [ ] README.md updated with your information
- [ ] Repository is public (or instructor has access)

---

## 📤 What to Submit

Create a submission document (PDF or Word) with:

### Section 1: Repository Information
```
GitHub Repository: https://github.com/<username>/DevOps-Assignment-1-ACEestFitness
Branch: assignment-2-cicd
Commit Hash: <latest commit hash>
```

### Section 2: Deployment URLs
```
Docker Hub: https://hub.docker.com/r/<username>/aceest-fitness
Jenkins: http://<jenkins-url>/job/aceest-fitness-cicd/
SonarQube: http://<sonarqube-url>/dashboard?id=aceest-fitness
Kubernetes: <if deployed to cloud>
```

### Section 3: Evidence

**Docker Hub** (1-2 pages):
- Repository screenshot showing multiple tags
- Docker pull command example

**Jenkins** (2-3 pages):
- Pipeline overview screenshot
- Console output showing test results
- Build history
- Build log excerpt (first 50 lines of successful build)

**SonarQube** (1-2 pages):
- Quality dashboard screenshot
- Quality Gate details
- Coverage report
- Code metrics summary

**Kubernetes** (1-2 pages, if deployed):
- Deployment status
- Pod listing
- Service configuration
- Application curl response

### Section 4: Assignment Report
- Include `ASSIGNMENT_REPORT.md` content (2-3 pages)

**Total submission**: Approximately 8-12 pages including screenshots

---

## ⏱️ Time Estimates

| Task | Time Required |
|------|---------------|
| Docker Hub push | 5-10 minutes |
| Jenkins setup and runs | 20-30 minutes |
| SonarQube analysis | 15-20 minutes |
| Kubernetes deployment | 15-25 minutes (optional) |
| Screenshots and documentation | 15-20 minutes |
| **Total** | **70-105 minutes** |

---

## 🚀 Quick Start Commands

Run these in order to complete all runtime deployments:

```bash
# Navigate to project directory
cd /Users/kanakapallianurag/Documents/GitHub/DevOps-Assignment-1-ACEestFitness

# 1. Push Docker images (5 min)
chmod +x push-docker-images.sh
./push-docker-images.sh <your-dockerhub-username>

# 2. Start Jenkins (5 min setup + 20 min config)
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Wait 30 seconds, then get password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
# Follow JENKINS_SETUP.md for full configuration

# 3. Start SonarQube (10 min)
docker run -d --name sonarqube -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community

# Wait 2 minutes for SonarQube to start
# Access http://localhost:9000 (admin/admin)
# Follow SONARQUBE_SETUP.md for analysis

# 4. Run tests and analysis
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=xml -v
sonar-scanner -Dsonar.login=${SONAR_TOKEN}

# 5. Deploy to Kubernetes (optional)
minikube start --cpus=4 --memory=8192
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/rolling/
kubectl get pods -n aceest-fitness
```

---

## 🔍 Verification Checklist

Before submitting, verify:

### Docker Hub
- [ ] Can access repository: `https://hub.docker.com/r/<username>/aceest-fitness`
- [ ] Can see at least 4 tags (v1.0.0, v1.1.0, v1.2.0, v1.3.0, latest)
- [ ] Can pull image: `docker pull <username>/aceest-fitness:latest`

### Jenkins
- [ ] Pipeline shows "SUCCESS" status
- [ ] All 9 stages completed successfully
- [ ] Test results show "29 passed"
- [ ] Build history shows at least 3 runs

### SonarQube
- [ ] Quality Gate shows "Passed"
- [ ] All ratings are A or B
- [ ] Coverage is displayed
- [ ] No critical bugs or vulnerabilities

### GitHub
- [ ] All files committed to `assignment-2-cicd` branch
- [ ] Latest commit pushed
- [ ] Repository accessible (public or instructor added)

---

## ❓ If You Get Stuck

### Priority Order for Completion

**Must Have** (Required for passing):
1. ✅ All code complete (already done)
2. 📦 Docker Hub with images
3. 🔧 Jenkins with successful runs
4. 📊 SonarQube analysis results

**Nice to Have** (Demonstrates advanced skills):
5. ☸️ Kubernetes deployment
6. 📸 Additional screenshots and metrics

### Minimum Viable Submission

If you're short on time, focus on:
1. Docker Hub push (5 minutes)
2. Jenkins setup with 3 successful runs (25 minutes)
3. SonarQube analysis (15 minutes)
4. Screenshots of above (10 minutes)

**Total**: ~55 minutes for minimum viable submission

---

## 📞 Support Resources

- **JENKINS_SETUP.md**: Detailed Jenkins configuration guide
- **SONARQUBE_SETUP.md**: Step-by-step SonarQube setup
- **QUICKSTART.md**: Quick commands for local testing
- **ASSIGNMENT2_README.md**: Complete technical documentation

---

## ✅ Final Checklist Before Submission

- [ ] Completed all "Must Have" items
- [ ] Created submission document with all URLs
- [ ] Included required screenshots (minimum 6-8)
- [ ] Updated ASSIGNMENT_REPORT.md with your information
- [ ] Committed and pushed all changes
- [ ] Verified all URLs are accessible
- [ ] Spell-checked submission document
- [ ] PDF/Word document is well-formatted
- [ ] File naming: `<YourName>_DevOps_Assignment2.pdf`

---

**Ready to Submit!** 🎉

Good luck with your submission!
