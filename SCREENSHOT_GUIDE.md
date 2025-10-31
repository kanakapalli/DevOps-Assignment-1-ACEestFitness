# Screenshot Guide - Assignment 2 Submission

Both Jenkins and SonarQube are now running! Follow these steps to configure them and take screenshots.

## 🔑 LOGIN CREDENTIALS (SAVE THIS!)

### **Jenkins** - http://localhost:8080
**Initial Unlock Password:**
```
7ce20481d7cd4b20a0bd56f874b6ec01
```
*After setup, you'll create your own admin username and password*

### **SonarQube** - http://localhost:9000
**Default Login:**
- Username: `admin`
- Password: `admin`

*You'll be prompted to change the password on first login*

---

## ✅ Current Status

- ✅ **Jenkins**: Running at http://localhost:8080
- ✅ **SonarQube**: Running at http://localhost:9000
- ✅ **Tests**: All 29 tests passing (94% coverage)
- ✅ **Coverage Report**: Generated (coverage.xml)
- ✅ **sonar-scanner**: Installed and ready

---

## Step 1: Set Up SonarQube (15 minutes)

### 1.1 Access SonarQube
1. Open browser: **http://localhost:9000**
2. Login with default credentials:
   - Username: `admin`
   - Password: `admin`
3. You'll be prompted to change password - set a new one

### 1.2 Create Project
1. Click **"Create Project"** → **"Manually"**
2. Fill in:
   - **Project key**: `aceest-fitness`
   - **Display name**: `ACEest Fitness & Gym Tracker`
3. Click **"Set Up"**
4. Choose **"Locally"**

### 1.3 Generate Token
1. **Token name**: `aceest-fitness-token`
2. Click **"Generate"**
3. **IMPORTANT**: Copy the token and save it!

Example token format: `squ_a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0`

### 1.4 Run Analysis

Open terminal and run:

```bash
# Set the token (replace with your actual token)
export SONAR_TOKEN=squ_YOUR_TOKEN_HERE

# Navigate to project
cd /Users/kanakapallianurag/Documents/GitHub/DevOps-Assignment-1-ACEestFitness

# Run analysis
./run-sonarqube-analysis.sh
```

### 1.5 Take SonarQube Screenshots

Once analysis completes, take these screenshots:

**Screenshot 1: Quality Dashboard**
- Go to: http://localhost:9000/dashboard?id=aceest-fitness
- Capture full dashboard showing:
  - ✅ Quality Gate: Passed
  - ✅ Reliability Rating: A
  - ✅ Security Rating: A
  - ✅ Maintainability Rating: A
  - ✅ Coverage: ~94%
  - ✅ Code Smells count
  - ✅ Lines of code: 125

**Screenshot 2: Quality Gate Details**
- Click on **"Quality Gate"** tab
- Shows all conditions passed

**Screenshot 3: Coverage Report**
- Click on **"Coverage"** tab
- Shows 94% coverage breakdown

---

## Step 2: Set Up Jenkins (20 minutes)

### 2.1 Initial Setup
1. Open browser: **http://localhost:8080**
2. Paste unlock password: `7ce20481d7cd4b20a0bd56f874b6ec01`
3. Click **"Install suggested plugins"** (wait 3-5 minutes)
4. Create admin user:
   - Username: `admin`
   - Password: (your choice)
   - Full name: (your name)
   - Email: (your email)
5. Click **"Save and Continue"** → **"Start using Jenkins"**

### 2.2 Install Additional Plugins

1. Go to: **Manage Jenkins** → **Manage Plugins** → **Available**
2. Search and install:
   - ✅ Docker Pipeline
   - ✅ Docker
   - ✅ SonarQube Scanner
3. Check **"Restart Jenkins when installation is complete"**

### 2.3 Configure Docker Hub Credentials

1. **Manage Jenkins** → **Manage Credentials**
2. Click **(global)** domain
3. Click **"Add Credentials"**
4. Fill in:
   - Kind: `Username with password`
   - Username: `<your-dockerhub-username>`
   - Password: `<your-dockerhub-password>`
   - ID: `docker-hub-credentials`
   - Description: `Docker Hub`
5. Click **"Create"**

### 2.4 Configure SonarQube Server

1. **Manage Jenkins** → **Configure System**
2. Scroll to **"SonarQube servers"**
3. Check **"Enable injection of SonarQube server configuration"**
4. Click **"Add SonarQube"**
5. Fill in:
   - Name: `SonarQube`
   - Server URL: `http://host.docker.internal:9000`
   - Server authentication token: Click "Add" → "Jenkins"
     - Kind: `Secret text`
     - Secret: `<your-sonarqube-token>`
     - ID: `sonarqube-token`
     - Click "Add"
   - Select `sonarqube-token` from dropdown
6. Click **"Save"**

### 2.5 Create Pipeline Job

1. Click **"New Item"**
2. Enter name: `aceest-fitness-cicd`
3. Select **"Pipeline"**
4. Click **"OK"**
5. In configuration:
   - **Description**: `ACEest Fitness CI/CD Pipeline`
   - **Build Triggers**: Check "GitHub hook trigger for GITScm polling" (optional)
   - **Pipeline** section:
     - Definition: `Pipeline script from SCM`
     - SCM: `Git`
     - Repository URL: `https://github.com/<your-username>/DevOps-Assignment-1-ACEestFitness`
     - Branch Specifier: `*/assignment-2-cicd`
     - Script Path: `Jenkinsfile`
6. Click **"Save"**

### 2.6 Build the Pipeline

**IMPORTANT**: Before running Jenkins, we need to modify the Jenkinsfile to skip SonarQube and Kubernetes stages for local demo.

Open terminal:

```bash
# Build Docker image first (so Jenkins can use it)
docker build -t aceest-fitness:v1.3.0 .
docker tag aceest-fitness:v1.3.0 aceest-fitness:latest
```

Now in Jenkins:

1. Click **"Build Now"**
2. Watch the build progress
3. Build #1 will run

**Expected stages** (some may be skipped):
- ✅ Checkout
- ✅ Install Dependencies
- ✅ Run Unit Tests
- ⚠️ SonarQube Analysis (may skip)
- ⚠️ Build Docker Image
- ⚠️ Test Docker Image

**Run 3-5 builds** to show consistency.

### 2.7 Take Jenkins Screenshots

**Screenshot 1: Pipeline Overview**
- Shows all stages with status
- Green checkmarks for passed stages
- Build #1, #2, #3 visible

**Screenshot 2: Console Output**
- Click on a build → **"Console Output"**
- Shows test results: `29 passed in X seconds`
- Capture the test execution section

**Screenshot 3: Build History**
- Shows list of builds (#1, #2, #3, etc.)
- All showing success (blue/green)

**Screenshot 4: Test Results** (if available)
- Click build → **"Test Result"**
- Shows 29 tests passed

---

## Step 3: Docker Hub (5 minutes)

### 3.1 Push Images

```bash
# Run the script
./push-docker-images.sh <your-dockerhub-username>

# Enter your Docker Hub password when prompted
```

### 3.2 Take Screenshot

1. Go to: **https://hub.docker.com/r/<username>/aceest-fitness**
2. Take screenshot showing:
   - Repository name
   - All tags (v1.0.0, v1.1.0, v1.2.0, v1.3.0, latest)
   - Last pushed date

---

## Summary of Screenshots Needed

### SonarQube (3 screenshots)
1. ✅ Quality Dashboard (main overview)
2. ✅ Quality Gate details
3. ✅ Coverage report

### Jenkins (4 screenshots)
1. ✅ Pipeline overview (all stages)
2. ✅ Console output (test results)
3. ✅ Build history (multiple builds)
4. ✅ Test results dashboard

### Docker Hub (1 screenshot)
1. ✅ Repository with all tags

**Total: 8 screenshots**

---

## Quick Commands Reference

```bash
# Check services status
docker ps

# View Jenkins logs
docker logs -f jenkins

# View SonarQube logs
docker logs -f sonarqube

# Stop services
docker stop jenkins sonarqube

# Start services
docker start jenkins sonarqube

# Run tests locally
pytest test_aceest_fitness_app.py -v

# Run with coverage
pytest test_aceest_fitness_app.py --cov=aceest_fitness_app --cov-report=term

# Build Docker image
docker build -t aceest-fitness:v1.3.0 .
```

---

## Troubleshooting

### Jenkins won't start
```bash
docker restart jenkins
# Wait 30 seconds then try again
```

### SonarQube shows "UP" but won't load
```bash
# Check logs
docker logs sonarqube
# Wait 2-3 minutes for full initialization
```

### Tests failing
```bash
# Make sure you're in project directory
cd /Users/kanakapallianurag/Documents/GitHub/DevOps-Assignment-1-ACEestFitness

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest test_aceest_fitness_app.py -v
```

---

## After Taking Screenshots

1. Organize screenshots in a folder
2. Add them to your submission document
3. Label each screenshot clearly
4. Include URLs for each service
5. Export Jenkins build log (optional but good to have)

---

**You're all set!** Follow the steps above and you'll have all the evidence needed for your assignment submission.

Good luck! 🚀
