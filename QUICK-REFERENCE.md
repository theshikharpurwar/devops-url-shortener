# 🚀 DevOps URL Shortener - Quick Reference

Your one-page guide to the complete DevOps pipeline!

---

## 📊 Project Status

**All 4 Phases: ✅ COMPLETE**

| Phase | Status | Time to Deploy |
|-------|--------|----------------|
| Phase 1: Local Development | ✅ | 15 minutes |
| Phase 2: Infrastructure (Terraform) | ✅ | 20 minutes |
| Phase 3: Configuration (Ansible) | ✅ | 5 minutes |
| Phase 4: CI/CD Pipeline (Jenkins/K8s) | ✅ | 10 minutes |

**Total Setup Time**: ~50 minutes (first time)  
**Subsequent Deployments**: < 5 minutes (automated!)

---

## 🗂️ Project Files Overview

```
devops-url-shortener/
├── src/                           # Application source code
│   ├── models/url.js             # MongoDB schema
│   ├── routes/url.js             # Express routes
│   ├── controllers/urlController.js
│   └── connect.js
│
├── views/index.ejs               # Frontend UI
├── index.js                      # Server entry point
├── package.json                  # Dependencies
│
├── Dockerfile                    # Container image
├── docker-compose.yml            # Local orchestration
├── Jenkinsfile                   # CI/CD pipeline ⭐ NEW
│
├── k8s/                          # Kubernetes manifests ⭐ NEW
│   ├── deployment.yml            # Pod deployment (2 replicas)
│   └── service.yml               # LoadBalancer service
│
├── terraform/                    # Infrastructure as Code
│   ├── versions.tf               # Terraform config
│   ├── variables.tf              # Input variables
│   ├── vpc.tf                    # VPC network
│   ├── eks.tf                    # Kubernetes cluster
│   ├── ecr.tf                    # Container registry
│   ├── jenkins.tf                # CI/CD server
│   ├── database.tf               # DocumentDB
│   └── outputs.tf                # Resource outputs
│
├── ansible/                      # Configuration management
│   └── playbook-jenkins.yml      # Jenkins setup
│
└── Documentation/
    ├── README.md                 # Main guide
    ├── JENKINS-SETUP.md          # Jenkins config ⭐ NEW
    ├── DEPLOYMENT-GUIDE.md       # Deploy guide ⭐ NEW
    ├── PHASE4-COMPLETE.md        # Phase 4 summary ⭐ NEW
    └── (10+ other guides...)
```

---

## ⚡ Quick Commands

### Phase 1: Local Development

```bash
# Start application locally
cd /mnt/d/devops-url-shortener  # WSL 2
docker-compose up --build

# Access app
http://localhost:8001

# Stop
docker-compose down
```

### Phase 2: Infrastructure (Terraform)

```powershell
# PowerShell
cd d:\devops-url-shortener\terraform

# Initialize
terraform init

# Create infrastructure
terraform apply

# Get outputs
terraform output

# Destroy (cleanup)
terraform destroy
```

### Phase 3: Configuration (Ansible)

```powershell
# PowerShell - SSH to Jenkins server
ssh -i <key.pem> ubuntu@<JENKINS_IP>

# On Jenkins server
cd /home/ubuntu
ansible-playbook playbook-jenkins.yml

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Phase 4: CI/CD Deployment

```powershell
# PowerShell - Push code to trigger pipeline
cd d:\devops-url-shortener
git add .
git commit -m "Deploy to production"
git push origin main

# Jenkins webhook auto-triggers deployment!
```

**Monitor**: `http://<JENKINS_IP>:8080`

### Kubernetes Management

```bash
# SSH to Jenkins or any machine with kubectl
aws eks update-kubeconfig --region us-east-1 --name <CLUSTER_NAME>

# Check pods
kubectl get pods -l app=url-shortener

# Check service
kubectl get service url-shortener-service

# Get Load Balancer URL
kubectl get svc url-shortener-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# View logs
kubectl logs -l app=url-shortener --tail=50 -f

# Scale
kubectl scale deployment url-shortener-deployment --replicas=3

# Rollback
kubectl rollout undo deployment/url-shortener-deployment
```

---

## 🔑 Key Terraform Outputs

Get these after `terraform apply`:

```bash
terraform output
```

You'll need:
- `jenkins_public_ip` → Access Jenkins UI
- `ecr_repository_url` → Update Jenkinsfile
- `eks_cluster_name` → Update Jenkinsfile
- `docdb_secret_name` → Update Jenkinsfile
- `eks_configure_command` → Setup kubectl

---

## 🎯 Essential URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Local App** | `http://localhost:8001` | Phase 1 testing |
| **Jenkins** | `http://<JENKINS_IP>:8080` | CI/CD dashboard |
| **Production App** | `http://<LOAD_BALANCER_DNS>` | Live application |
| **Health Check** | `http://<LOAD_BALANCER_DNS>/health` | Monitor status |

---

## 📋 Deployment Checklist

### Before First Deployment

- [ ] Update `Jenkinsfile` with Terraform outputs
- [ ] Configure Jenkins (plugins, credentials)
- [ ] Create pipeline job in Jenkins
- [ ] Set up GitHub webhook
- [ ] Commit all code to GitHub

### Each Deployment

- [ ] Make code changes
- [ ] Test locally with Docker Compose
- [ ] Commit and push to GitHub
- [ ] Monitor Jenkins pipeline
- [ ] Verify pods are running
- [ ] Test application via Load Balancer

---

## 🐛 Common Issues & Fixes

### Issue: Docker not working in WSL 2
```bash
# Check Docker Desktop is running
# Enable WSL Integration in Docker Desktop Settings
# Restart WSL: wsl --shutdown (PowerShell)
```

### Issue: Terraform apply fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 backend exists
aws s3 ls s3://my-team-url-shortener-tfstate
```

### Issue: Jenkins can't access ECR
```bash
# On Jenkins server
aws ecr get-login-password --region us-east-1

# Verify IAM role attached to EC2 instance
aws sts get-caller-identity
```

### Issue: Pods stuck in Pending
```bash
# Check nodes
kubectl get nodes

# Describe pod to see events
kubectl describe pod <POD_NAME>

# Check resource usage
kubectl top nodes
```

### Issue: Load Balancer stuck in Pending
```bash
# Wait 3-5 minutes (AWS provisioning)
kubectl describe service url-shortener-service

# Check VPC subnet tags in Terraform outputs
```

### Issue: Database connection fails
```bash
# Check security groups allow traffic
# Verify secret exists
kubectl get secret docdb-secret

# Check secret values
kubectl get secret docdb-secret -o yaml

# View pod logs
kubectl logs -l app=url-shortener
```

---

## 📚 Documentation Index

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **README.md** | Main overview | Start here |
| **terraform/QUICKSTART.md** | Fast Terraform setup | Phase 2 quick start |
| **terraform/README.md** | Full infrastructure guide | Phase 2 detailed |
| **ansible/WINDOWS-GUIDE.md** | Windows-specific Ansible | Phase 3 (Windows users) |
| **JENKINS-SETUP.md** | Configure Jenkins | Phase 4 setup |
| **DEPLOYMENT-GUIDE.md** | Deploy & troubleshoot | Phase 4 deployment |
| **PHASE4-COMPLETE.md** | Phase 4 summary | After completion |
| **ARCHITECTURE.md** | System architecture | Understanding design |

---

## 🏗️ Architecture at a Glance

```
GitHub (Code) 
    ↓ webhook
Jenkins (CI/CD) 
    ↓ build & push
Amazon ECR (Docker Images)
    ↓
Amazon EKS (Kubernetes)
    ├─ Deployment (2 pods)
    ├─ Service (LoadBalancer)
    └─ Secret (DB credentials)
        ↓
Network Load Balancer
    ↓
Internet (Users)

Database: Amazon DocumentDB
Secrets: AWS Secrets Manager
Network: Amazon VPC
```

---

## 🔄 CI/CD Pipeline Stages

1. **Checkout** - Pull code from GitHub
2. **Build** - Create Docker image
3. **Login ECR** - Authenticate with AWS ECR
4. **Push** - Upload image to registry
5. **Fetch Secrets** - Get DB credentials
6. **Deploy** - Update Kubernetes cluster

**Total Time**: ~5-7 minutes per deployment

---

## 💰 AWS Cost Estimate

| Resource | Type | Monthly Cost |
|----------|------|--------------|
| EKS Cluster | Control Plane | $73 |
| EC2 (EKS Nodes) | 2x t3.medium | ~$60 |
| DocumentDB | db.t3.medium | ~$55 |
| EC2 (Jenkins) | t2.medium | ~$35 |
| Load Balancer | NLB | ~$20 |
| **Total** | | **~$243/month** |

**⚠️ Remember to run `terraform destroy` when done to avoid charges!**

---

## 🎯 Testing Checklist

### Phase 1 (Local)
```bash
# Start
docker-compose up --build

# Test
curl http://localhost:8001/health

# Create short URL
curl -X POST http://localhost:8001/url \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}'
```

### Phase 4 (Production)
```bash
# Get Load Balancer URL
kubectl get svc url-shortener-service

# Test health
curl http://<LB_DNS>/health

# Test app in browser
http://<LB_DNS>/
```

---

## 🚀 From Zero to Production

### First Time Setup (50 minutes)

1. **Phase 1** (15 min): `docker-compose up --build`
2. **Phase 2** (20 min): `terraform apply`
3. **Phase 3** (5 min): `ansible-playbook playbook-jenkins.yml`
4. **Phase 4** (10 min): Configure Jenkins + deploy

### Subsequent Deployments (< 5 minutes)

1. Make code changes
2. `git commit -m "Fix bug"`
3. `git push origin main`
4. ☕ Wait for Jenkins to deploy automatically

---

## 🎓 Skills You've Mastered

- ✅ Containerization (Docker)
- ✅ Container Orchestration (Kubernetes)
- ✅ Infrastructure as Code (Terraform)
- ✅ Configuration Management (Ansible)
- ✅ CI/CD Pipelines (Jenkins)
- ✅ Cloud Computing (AWS)
- ✅ Version Control (Git/GitHub)
- ✅ Linux Administration (Ubuntu)
- ✅ Networking (VPC, Load Balancers)
- ✅ Security (IAM, Secrets Manager)
- ✅ Monitoring (Health checks, logs)
- ✅ Troubleshooting & Debugging

---

## 🎉 You Did It!

You've built a **production-grade DevOps pipeline** from scratch!

**What's Next?**
- Add HTTPS with ACM certificates
- Set up monitoring with Prometheus/Grafana
- Implement auto-scaling (HPA)
- Add custom domain name
- Create multi-environment setup (dev/staging/prod)

---

## 📞 Quick Help

**Jenkins not starting?**
→ See JENKINS-SETUP.md, Troubleshooting section

**Deployment failing?**
→ See DEPLOYMENT-GUIDE.md, Troubleshooting section

**Terraform errors?**
→ See terraform/README.md, Troubleshooting section

**General questions?**
→ Check README.md for phase-specific guides

---

**Last Updated**: Phase 4 Complete  
**Total Project Files**: 30+  
**Total Documentation**: 3,000+ lines  
**Status**: 🟢 Production Ready!

Happy Deploying! 🚀
