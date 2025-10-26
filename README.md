# DevOps URL Shortener - Phase 1: Local Development

[![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-20+-blue.svg)](https://www.docker.com/)
[![MongoDB](https://img.shields.io/badge/MongoDB-Latest-green.svg)](https://www.mongodb.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> **End-to-End DevOps Pipeline Project** - A complete URL shortener application with containerization, built for learning CI/CD, Kubernetes, AWS, and Infrastructure as Code.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Phase 1: Local Development](#-phase-1-local-development-current)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [API Documentation](#-api-documentation)
- [Testing the Application](#-testing-the-application)
- [Troubleshooting](#-troubleshooting)
- [Next Phases](#-next-phases)

---

## 🎯 Project Overview

This is a **complete DevOps project** designed to demonstrate the full software development lifecycle with modern DevOps practices. We're building a URL shortener application and deploying it through a professional CI/CD pipeline.

### The Complete Journey (4 Phases)

| Phase | Focus | Tools | Status |
|-------|-------|-------|--------|
| **Phase 1** | **Local Development** | Node.js, MongoDB, Docker, Docker Compose | ✅ **COMPLETE** |
| **Phase 2** | **Infrastructure as Code** | Terraform, AWS (VPC, EKS, ECR, DocumentDB) | ✅ **COMPLETE** |
| **Phase 3** | **Configuration Management** | Ansible, Jenkins Setup | ✅ **COMPLETE** |
| **Phase 4** | **CI/CD Pipeline & Deployment** | Jenkins, Kubernetes, AWS EKS | ✅ **COMPLETE** |

**Current Status**: 🟢 **Phase 4 - Complete Pipeline Deployed!**

---

## 🚀 Phase 1: Local Development

In this phase, you will:

✅ Get a fully functional Node.js URL shortener application  
✅ Containerize the application using Docker  
✅ Run the entire stack locally with Docker Compose  
✅ Test all API endpoints  
✅ Understand the codebase before moving to cloud deployment  

### ➡️ Next: Phase 2 - Infrastructure as Code

See **[terraform/README.md](terraform/README.md)** or **[terraform/QUICKSTART.md](terraform/QUICKSTART.md)**  

---

## ⚙️ Prerequisites

### 1️⃣ Windows 11 Setup (CRITICAL)

Since you're on Windows 11, you **MUST** use **WSL 2** for this project. Follow these steps:

#### **Step 1: Install WSL 2**
Open PowerShell as Administrator and run:
```powershell
wsl --install
```

Restart your computer, then verify:
```powershell
wsl --list --verbose
```

You should see `VERSION 2` for Ubuntu.

📖 **Detailed Instructions**: See [SETUP-WSL2.md](./SETUP-WSL2.md) for complete WSL 2 setup.

#### **Step 2: Install Docker Desktop**
1. Download from: https://www.docker.com/products/docker-desktop/
2. Install with **WSL 2 backend enabled**
3. In Docker Desktop Settings:
   - ✅ Enable "Use the WSL 2 based engine"
   - ✅ Enable WSL Integration with Ubuntu

#### **Step 3: Install VS Code + WSL Extension**
1. Install VS Code: https://code.visualstudio.com/
2. Install the **WSL** extension (by Microsoft)
3. Open VS Code and connect to WSL:
   - Press `F1` → Type `WSL: Connect to WSL`

### 2️⃣ Required Software (Inside WSL 2)

Open your WSL 2 terminal (Ubuntu) in VS Code and verify:

```bash
# Check Docker
docker --version
docker-compose --version

# Check Git
git --version
```

If anything is missing, refer to [SETUP-WSL2.md](./SETUP-WSL2.md).

---

## 🏁 Quick Start

### Step 1: Navigate to Project Directory

**Important**: In WSL 2, your Windows drives are mounted under `/mnt/`:

```bash
# Navigate to your project
cd /mnt/d/devops-url-shortener

# Verify you're in the right place
pwd
ls -la
```

You should see files like `package.json`, `Dockerfile`, `docker-compose.yml`, etc.

### Step 2: Build and Run with Docker Compose

Run the following command in your WSL 2 terminal:

```bash
docker-compose up --build
```

**What happens:**
- Docker builds the Node.js application image
- Downloads MongoDB image (if not already cached)
- Starts both `api` and `mongo` services
- Creates a network for inter-service communication
- Sets up persistent volumes for MongoDB data

**Expected Output:**
```
url-shortener-mongo    | waiting for connections on port 27017
url-shortener-api      | ✅ MongoDB Connected Successfully
url-shortener-api      | 🚀 Server started on port 8001
```

### Step 3: Access the Application

Open your browser and go to:

```
http://localhost:8001
```

You should see a beautiful URL shortener interface! 🎉

---

## 📁 Project Structure

```
devops-url-shortener/
│
├── src/
│   ├── models/
│   │   └── url.js                    # Mongoose URL schema
│   ├── routes/
│   │   └── url.js                    # Express routes
│   ├── controllers/
│   │   └── urlController.js          # Business logic
│   └── connect.js                    # MongoDB connection
│
├── views/
│   └── index.ejs                     # Frontend UI
│
├── index.js                          # Express server entry point
├── package.json                      # Dependencies
├── Dockerfile                        # Container image definition
├── docker-compose.yml                # Multi-container orchestration
├── .dockerignore                     # Docker build exclusions
├── .gitignore                        # Git exclusions
│
└── Documentation/
    ├── README.md                     # This file
    ├── SETUP-WSL2.md                 # WSL 2 setup guide
    └── PROJECT-STRUCTURE.md          # Detailed structure docs
```

---

## 📡 API Documentation

### 1. Create Short URL

**Endpoint**: `POST /url`

**Request Body**:
```json
{
  "url": "https://www.example.com/very/long/url/here"
}
```

**Response**:
```json
{
  "success": true,
  "id": "XyZ123",
  "shortUrl": "http://localhost:8001/XyZ123",
  "originalUrl": "https://www.example.com/very/long/url/here"
}
```

**cURL Example**:
```bash
curl -X POST http://localhost:8001/url \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com/yourusername/repo"}'
```

### 2. Redirect to Original URL

**Endpoint**: `GET /:shortId`

**Example**: `http://localhost:8001/XyZ123`

This will redirect you to the original URL.

### 3. Get Analytics

**Endpoint**: `GET /url/analytics/:shortId`

**Example**: `http://localhost:8001/url/analytics/XyZ123`

**Response**:
```json
{
  "success": true,
  "shortId": "XyZ123",
  "originalUrl": "https://github.com/yourusername/repo",
  "totalClicks": 5,
  "visitHistory": [
    {
      "timestamp": "2025-10-25T10:30:00.000Z",
      "userAgent": "Mozilla/5.0...",
      "ipAddress": "::1"
    }
  ],
  "createdAt": "2025-10-25T10:00:00.000Z",
  "updatedAt": "2025-10-25T10:30:00.000Z"
}
```

### 4. Health Check

**Endpoint**: `GET /health`

**Response**:
```json
{
  "status": "OK",
  "message": "Server is running",
  "timestamp": "2025-10-25T10:30:00.000Z"
}
```

---

## 🧪 Testing the Application

### Test 1: Using the Web Interface

1. Open http://localhost:8001
2. Enter a long URL (e.g., `https://github.com/yourusername/long-repo-name`)
3. Click "Shorten URL"
4. Copy the shortened URL
5. Open it in a new tab - you should be redirected!

### Test 2: Using cURL (Recommended for DevOps)

```bash
# Test 1: Create a short URL
curl -X POST http://localhost:8001/url \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.google.com"}'

# Expected output: {"success":true,"id":"abc123",...}

# Test 2: Get analytics (replace abc123 with your ID)
curl http://localhost:8001/url/analytics/abc123

# Test 3: Health check
curl http://localhost:8001/health
```

### Test 3: Using PowerShell (Windows)

```powershell
# Create a short URL
Invoke-RestMethod -Uri "http://localhost:8001/url" `
  -Method Post `
  -ContentType "application/json" `
  -Body '{"url": "https://www.google.com"}'
```

---

## 🐛 Troubleshooting

### Issue 1: "docker: command not found"

**Solution**: 
- Ensure Docker Desktop is running
- Verify WSL Integration is enabled in Docker Desktop Settings
- Restart WSL: `wsl --shutdown` (in PowerShell), then reopen

### Issue 2: "Cannot connect to MongoDB"

**Solution**:
```bash
# Check if MongoDB container is running
docker ps

# Check MongoDB logs
docker logs url-shortener-mongo

# Restart the entire stack
docker-compose down
docker-compose up --build
```

### Issue 3: Port 8001 already in use

**Solution**:
```bash
# Find what's using the port
netstat -ano | findstr :8001

# Kill the process (PowerShell as Admin)
Stop-Process -Id <PID> -Force

# Or change the port in docker-compose.yml
# Change "8001:8001" to "8002:8001"
```

### Issue 4: Slow file performance in WSL

**Solution**: Always work in the Linux filesystem, not `/mnt/`:

```bash
# Copy project to Linux filesystem
cp -r /mnt/d/devops-url-shortener ~/projects/devops-url-shortener
cd ~/projects/devops-url-shortener
```

### Issue 5: Changes not reflecting after rebuild

**Solution**:
```bash
# Stop all containers
docker-compose down

# Remove volumes and rebuild
docker-compose down -v
docker-compose up --build
```

---

## 🛑 Stopping the Application

```bash
# Stop containers (keeps data)
docker-compose stop

# Stop and remove containers (keeps volumes)
docker-compose down

# Stop, remove containers AND delete all data
docker-compose down -v
```

---

## 📊 Viewing Logs

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View logs for specific service
docker-compose logs -f api
docker-compose logs -f mongo
```

---

## 🔍 Useful Docker Commands

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# View container resource usage
docker stats

# Execute command in running container
docker exec -it url-shortener-api sh

# Access MongoDB shell
docker exec -it url-shortener-mongo mongosh

# Remove unused images and containers
docker system prune -a
```

---

## 📚 Next Phases

### ✅ Phase 2: Infrastructure as Code (COMPLETE)
- ✅ Provision AWS VPC, EKS Cluster
- ✅ Set up DocumentDB (managed MongoDB)
- ✅ Create ECR repository for Docker images
- ✅ Configure S3 for Terraform state

**Guide**: [terraform/README.md](terraform/README.md)

### ✅ Phase 3: Configuration Management (COMPLETE)
- ✅ Automate Jenkins EC2 server setup
- ✅ Install required tools (Docker, kubectl, etc.)
- ✅ Configure Jenkins plugins

**Guide**: [ansible/README.md](ansible/README.md)

### ✅ Phase 4: CI/CD Pipeline (COMPLETE) 
- ✅ Create Kubernetes manifests (deployments, services)
- ✅ Write Jenkinsfile for automated pipeline
- ✅ Set up Git webhooks for auto-deployment
- ✅ Deploy to AWS EKS

**Guides**: 
- [JENKINS-SETUP.md](JENKINS-SETUP.md) - Configure Jenkins
- [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) - Deploy application
- [PHASE4-COMPLETE.md](PHASE4-COMPLETE.md) - Summary & next steps

---

## 👥 Team

- **Team Size**: 3 members
- **Your Role**: DevOps Engineer / Full-Stack Developer
- **Instructor**: Senior DevOps Lead

---

## 📝 Learning Objectives

By completing this project, you will learn:

✅ **Containerization**: Docker, multi-stage builds, optimization  
✅ **Orchestration**: Docker Compose, Kubernetes  
✅ **Cloud**: AWS services (EC2, EKS, ECR, DocumentDB, S3)  
✅ **IaC**: Terraform for infrastructure provisioning  
✅ **Config Management**: Ansible for server configuration  
✅ **CI/CD**: Jenkins pipeline, automated deployments  
✅ **Version Control**: Git workflows, branching strategies  
✅ **DevOps Best Practices**: 12-factor apps, health checks, logging  

---

## 📞 Need Help?

1. **WSL Issues**: See [SETUP-WSL2.md](./SETUP-WSL2.md)
2. **File Structure Questions**: See [PROJECT-STRUCTURE.md](./PROJECT-STRUCTURE.md)
3. **Docker Issues**: Check the Troubleshooting section above

---

## 🎓 Educational Use

This project is designed for educational purposes as part of a university DevOps course. Feel free to modify and extend it for your learning!

---

## 📄 License

MIT License - See LICENSE file for details

---

## ✅ Phase 1 Checklist

- [x] WSL 2 is installed and working
- [x] Docker Desktop is running with WSL 2 backend
- [x] VS Code is connected to WSL
- [x] `docker-compose up --build` runs without errors
- [x] Application is accessible at http://localhost:8001
- [x] You can create and use shortened URLs
- [x] You understand the codebase structure
- [x] All API endpoints are tested and working

**Phase 1 Complete! ✅**

---

## ✅ Phase 2 Checklist

**Infrastructure as Code with Terraform**

Before moving to Phase 3, ensure:

- [ ] Terraform and AWS CLI installed
- [ ] AWS credentials configured (`aws configure`)
- [ ] SSH key pair generated (`~/.ssh/id_rsa`)
- [ ] S3 backend created (run `setup-backend.sh`)
- [ ] `terraform.tfvars` created with YOUR IP address
- [ ] `terraform apply` completed successfully
- [ ] All ~40-50 resources created in AWS
- [ ] EKS cluster accessible (`kubectl get nodes`)
- [ ] Jenkins UI accessible at http://JENKINS_IP:8080
- [ ] ECR repository created
- [ ] DocumentDB cluster running
- [ ] All outputs saved for Phase 3

**Quick Start:** See [terraform/QUICKSTART.md](terraform/QUICKSTART.md)  
**Full Guide:** See [terraform/README.md](terraform/README.md)

**Once all items are checked, you're ready for Phase 3! 🚀**

---

## ✅ Phase 3 Checklist

**Configuration Management with Ansible**

Before moving to Phase 4, ensure:

- [ ] Jenkins server is accessible via SSH
- [ ] Ansible playbook executed successfully
- [ ] Jenkins is running on port 8080
- [ ] Docker installed and jenkins user added to docker group
- [ ] kubectl installed and configured
- [ ] AWS CLI v2 installed
- [ ] Initial Jenkins admin password retrieved
- [ ] Jenkins setup wizard completed

**Quick Start:** See [ansible/QUICKSTART.md](ansible/QUICKSTART.md)  
**Full Guide:** See [ansible/README.md](ansible/README.md)  
**Windows Guide:** See [ansible/WINDOWS-GUIDE.md](ansible/WINDOWS-GUIDE.md)

**Once all items are checked, you're ready for Phase 4! 🚀**

---

## ✅ Phase 4 Checklist

**CI/CD Pipeline & Kubernetes Deployment**

Deployment checklist:

- [ ] Jenkinsfile updated with Terraform outputs (ECR URL, EKS cluster, DB secret)
- [ ] Jenkins plugins installed (Docker Pipeline, Amazon ECR, Kubernetes CLI)
- [ ] AWS credentials configured in Jenkins
- [ ] Pipeline job created (`url-shortener-pipeline`)
- [ ] GitHub webhook configured
- [ ] Code committed and pushed to GitHub
- [ ] Pipeline executed successfully (all 6 stages pass)
- [ ] Kubernetes deployment created (2 pods running)
- [ ] Load Balancer provisioned and accessible
- [ ] Application accessible via Load Balancer URL
- [ ] URL shortening working end-to-end
- [ ] Health check endpoint responding

**Setup Guide:** See [JENKINS-SETUP.md](JENKINS-SETUP.md)  
**Deployment Guide:** See [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)  
**Summary:** See [PHASE4-COMPLETE.md](PHASE4-COMPLETE.md)

**Once all items are checked, your DevOps pipeline is COMPLETE! 🎉**

---

Made with ❤️ for DevOps learning | October 2025
