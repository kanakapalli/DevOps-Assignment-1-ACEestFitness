# 🔑 Service Credentials - Quick Reference

## Running Services

Both services are currently running and ready for configuration:

- **Jenkins**: http://localhost:8080
- **SonarQube**: http://localhost:9000

---

## Jenkins Login

### Initial Setup (First Time)

**Unlock Password:**
```
7ce20481d7cd4b20a0bd56f874b6ec01
```

**Steps:**
1. Open: http://localhost:8080
2. Paste the unlock password above
3. Click "Continue"
4. Choose "Install suggested plugins" (wait 3-5 minutes)
5. Create your own admin account:
   - Username: *(your choice, e.g., admin)*
   - Password: *(your choice, e.g., admin123)*
   - Full Name: *(your name)*
   - Email: *(your email)*
6. Click "Save and Continue"

### After Initial Setup

Use the admin username and password you created during setup.

---

## SonarQube Login

### Default Credentials

**Username:**
```
admin
```

**Password:**
```
admin
```

### First Login

1. Open: http://localhost:9000
2. Login with: `admin` / `admin`
3. You'll be prompted: **"Please change your password"**
4. Enter new password: *(your choice, e.g., admin123)*
5. Confirm password
6. Click "Update"

### After Password Change

Use `admin` and your new password.

---

## SonarQube Token (After Creating Project)

After you create the project in SonarQube, you'll generate a token:

**Token Name:** `aceest-fitness-token`

**Your Token:** *(will be generated, save it here)*
```
squ_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**To use the token:**
```bash
export SONAR_TOKEN=squ_YOUR_TOKEN_HERE
./run-sonarqube-analysis.sh
```

---

## Docker Hub (For Image Push)

**Username:** *(your Docker Hub username)*

**Password:** *(your Docker Hub password)*

**To push images:**
```bash
./push-docker-images.sh <your-dockerhub-username>
# Enter your Docker Hub password when prompted
```

---

## Quick Access Commands

```bash
# Open Jenkins in browser
open http://localhost:8080

# Open SonarQube in browser
open http://localhost:9000

# Check services are running
docker ps | grep -E "jenkins|sonarqube"

# View Jenkins logs
docker logs -f jenkins

# View SonarQube logs
docker logs -f sonarqube

# Stop services
docker stop jenkins sonarqube

# Start services
docker start jenkins sonarqube

# Restart services
docker restart jenkins sonarqube
```

---

## Getting Jenkins Password Again

If you forget the Jenkins unlock password:

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Output:
```
7ce20481d7cd4b20a0bd56f874b6ec01
```

---

## Getting SonarQube Status

Check if SonarQube is ready:

```bash
curl -s http://localhost:9000/api/system/status
```

Should return: `{"status":"UP"}`

---

## Summary Table

| Service | URL | Initial Username | Initial Password | Notes |
|---------|-----|------------------|------------------|-------|
| **Jenkins** | http://localhost:8080 | N/A | `7ce20481d7cd4b20a0bd56f874b6ec01` | Create admin user during setup |
| **SonarQube** | http://localhost:9000 | `admin` | `admin` | Change password on first login |
| **Docker Hub** | https://hub.docker.com | Your username | Your password | For pushing images |

---

## Security Note

⚠️ **IMPORTANT**: These are development/local credentials only.

- ✅ Safe for local testing and screenshots
- ❌ **DO NOT** use these credentials in production
- ❌ **DO NOT** commit this file to a public repository
- ✅ Change all passwords if deploying to production

---

## Need Help?

If services aren't responding:

```bash
# Check if containers are running
docker ps

# If stopped, start them
docker start jenkins sonarqube

# Wait 30 seconds for Jenkins, 2 minutes for SonarQube
# Then try accessing again
```

For detailed setup instructions, see:
- **SCREENSHOT_GUIDE.md** - Complete screenshot workflow
- **JENKINS_SETUP.md** - Detailed Jenkins configuration
- **SONARQUBE_SETUP.md** - Detailed SonarQube setup

---

**All services are ready! Start with SonarQube or Jenkins - both are waiting for you.** 🚀
