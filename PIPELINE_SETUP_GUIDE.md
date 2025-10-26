# 🚀 Quick Start: Push to GitHub and Setup Jenkins Pipeline

## ✅ What's Ready
- ✅ Jenkinsfile created (simplified for Docker deployment)
- ✅ Infrastructure deployed (Jenkins + ECR)
- ✅ Setup script created

---

## 📦 Step 1: Push Code to GitHub (5 minutes)

### Option A: Automated Script (Recommended)
```powershell
cd D:\devops-url-shortener
.\setup-github.ps1
```

The script will:
1. Check Git installation
2. Create .gitignore
3. Initialize Git repository
4. Create initial commit
5. Guide you through creating GitHub repo
6. Push code to GitHub

### Option B: Manual Steps
```powershell
cd D:\devops-url-shortener

# Initialize Git
git init

# Add files
git add .

# Commit
git commit -m "Initial commit: DevOps URL Shortener"

# Create repository on GitHub: https://github.com/new
# Name: devops-url-shortener

# Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/devops-url-shortener.git
git branch -M main
git push -u origin main
```

---

## 🔧 Step 2: Configure Jenkins Pipeline (10 minutes)

### 1. Install Required Plugins

In Jenkins (http://98.84.35.193:8080):

1. **Manage Jenkins** → **Plugins** → **Available plugins**
2. Search and install:
   - ✅ **Docker Pipeline**
   - ✅ **Git plugin** (usually pre-installed)
3. Click **Install** and restart Jenkins

### 2. Create Pipeline Job

1. Click **"New Item"** or **"+ New Item"**
2. Enter name: `url-shortener-pipeline`
3. Select **"Pipeline"**
4. Click **OK**

### 3. Configure Pipeline

In the pipeline configuration:

**General Section:**
- ✅ Check **"GitHub project"**
- Project URL: `https://github.com/YOUR_USERNAME/devops-url-shortener/`

**Build Triggers:**
- ✅ Check **"Poll SCM"** (optional - for auto-build)
- Schedule: `H/5 * * * *` (checks every 5 minutes)

**Pipeline Section:**
- Definition: **"Pipeline script from SCM"**
- SCM: **Git**
- Repository URL: `https://github.com/YOUR_USERNAME/devops-url-shortener.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

Click **Save**

---

## 🚀 Step 3: Run First Build

1. Click **"Build Now"** on the pipeline page
2. Watch the pipeline stages in real-time
3. Pipeline stages:
   - ✅ Checkout (pull code from GitHub)
   - ✅ Build Docker Image
   - ✅ Login to ECR
   - ✅ Push to ECR
   - ✅ Deploy (run container)
   - ✅ Cleanup

**Expected time:** 2-5 minutes for first build

---

## 🎯 Step 4: Verify Deployment

After successful build:

1. **Check Jenkins logs** - Should show "Pipeline completed successfully!"
2. **Verify container running:**
   - In AWS Session Manager terminal:
   ```bash
   docker ps
   ```
   You should see `url-shortener` container running

3. **Access Application:**
   - Open: **http://98.84.35.193:3000**
   - Your URL shortener should be live!

---

## 📋 Troubleshooting

### Build fails at "Build Docker Image"
```bash
# In AWS Session Manager, check if Dockerfile exists
ls -la ~/workspace/url-shortener-pipeline/Dockerfile
```

### Build fails at "Login to ECR"
```bash
# Verify AWS CLI works
aws sts get-caller-identity

# Test ECR login manually
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 094822715133.dkr.ecr.us-east-1.amazonaws.com
```

### Application not accessible
```bash
# Check if container is running
docker ps

# Check container logs
docker logs url-shortener

# Check if port 3000 is exposed
docker port url-shortener
```

---

## 🔄 Making Updates

After setup, to deploy code changes:

1. Make changes to code locally
2. Commit and push:
   ```powershell
   git add .
   git commit -m "Your change description"
   git push
   ```
3. Jenkins will automatically detect changes (if Poll SCM enabled)
4. Or click **"Build Now"** manually

---

## 📊 What Happens in the Pipeline

```
┌──────────────┐
│   GitHub     │ ← Your code repository
└──────┬───────┘
       │
       │ git clone
       ↓
┌──────────────┐
│   Jenkins    │ ← Build server
└──────┬───────┘
       │
       │ docker build
       ↓
┌──────────────┐
│ Docker Image │
└──────┬───────┘
       │
       │ docker push
       ↓
┌──────────────┐
│     ECR      │ ← Image registry
└──────┬───────┘
       │
       │ docker pull & run
       ↓
┌──────────────┐
│  Application │ ← Running on Jenkins server
│  Port 3000   │    http://98.84.35.193:3000
└──────────────┘
```

---

## 🎉 Success Indicators

✅ GitHub repository created with code  
✅ Jenkins pipeline configured  
✅ First build successful  
✅ Docker image pushed to ECR  
✅ Application running on http://98.84.35.193:3000  
✅ Auto-deployment on code changes working  

---

## 📝 Important URLs

| Service | URL |
|---------|-----|
| GitHub Repo | https://github.com/YOUR_USERNAME/devops-url-shortener |
| Jenkins UI | http://98.84.35.193:8080 |
| Application | http://98.84.35.193:3000 |
| ECR Repository | 094822715133.dkr.ecr.us-east-1.amazonaws.com/url-shortener-api |

---

## 🚀 Next Steps (Optional Enhancements)

- [ ] Add webhook for automatic builds (GitHub → Jenkins)
- [ ] Add tests to pipeline
- [ ] Configure notifications (email/Slack)
- [ ] Add staging environment
- [ ] Implement blue-green deployment
- [ ] Add monitoring and logging

Good luck! 🎊
