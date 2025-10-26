# 🏗️ Infrastructure Architecture - Phase 1-3

## Complete System Architecture Overview

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                          DEVELOPER WORKSTATION                       ┃
┃                          (Windows 11 Machine)                        ┃
┃  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  ┃
┃  │   VS Code    │  │  PowerShell  │  │   Web Browser            │  ┃
┃  │   + WSL Ext  │  │  (SSH Client)│  │   (Jenkins UI Access)    │  ┃
┃  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────────┘  ┃
┗━━━━━━━━━┿━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━━━━━┿━━━━━━━━━━━━━━━━━━┛
           │                 │                     │
           │ Git Push        │ SSH (Port 22)       │ HTTP (Port 8080)
           ▼                 ▼                     ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                            GITHUB                                    ┃
┃                   Source Code Repository                             ┃
┃  ┌────────────────────────────────────────────────────────────────┐ ┃
┃  │  devops-url-shortener/                                         │ ┃
┃  │  ├── src/           (Node.js application code)                 │ ┃
┃  │  ├── terraform/     (Infrastructure as Code)                   │ ┃
┃  │  ├── ansible/       (Configuration Management)                 │ ┃
┃  │  ├── Dockerfile     (Container image definition)               │ ┃
┃  │  └── docker-compose.yml  (Local development)                   │ ┃
┃  └────────────────────────────────────────────────────────────────┘ ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                                │
                                │ Webhook Trigger (Phase 4)
                                ▼
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃                          AWS CLOUD (us-east-1)                       ┃
┃                                                                       ┃
┃  ┌────────────────────────────────────────────────────────────────┐ ┃
┃  │                    VPC: url-shortener-vpc                      │ ┃
┃  │                    CIDR: 10.0.0.0/16                           │ ┃
┃  │                                                                │ ┃
┃  │  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │ ┃
┃  │  ┃         PUBLIC SUBNETS (Internet-facing)              ┃  │ ┃
┃  │  ┃         10.0.101.0/24, 10.0.102.0/24                  ┃  │ ┃
┃  │  ┃                                                        ┃  │ ┃
┃  │  ┃  ┌─────────────────────────────────────────────────┐  ┃  │ ┃
┃  │  ┃  │  🖥️  JENKINS EC2 SERVER (t2.medium)           │  ┃  │ ┃
┃  │  ┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  ┃  │ ┃
┃  │  ┃  │  Public IP: 54.x.x.x                           │  ┃  │ ┃
┃  │  ┃  │  Security Group: SSH (22), Jenkins (8080)      │  ┃  │ ┃
┃  │  ┃  │                                                 │  ┃  │ ┃
┃  │  ┃  │  Installed Software (Phase 3):                 │  ┃  │ ┃
┃  │  ┃  │  ✅ Ubuntu 22.04                               │  ┃  │ ┃
┃  │  ┃  │  ✅ Java 17 (Jenkins runtime)                  │  ┃  │ ┃
┃  │  ┃  │  ✅ Jenkins (CI/CD server)                     │  ┃  │ ┃
┃  │  ┃  │  ✅ Docker + Docker Compose                    │  ┃  │ ┃
┃  │  ┃  │  ✅ kubectl (K8s CLI)                          │  ┃  │ ┃
┃  │  ┃  │  ✅ AWS CLI v2                                 │  ┃  │ ┃
┃  │  ┃  │  ✅ Git                                        │  ┃  │ ┃
┃  │  ┃  │                                                 │  ┃  │ ┃
┃  │  ┃  │  IAM Role: Jenkins-Role                        │  ┃  │ ┃
┃  │  ┃  │  - ECR Push/Pull                               │  ┃  │ ┃
┃  │  ┃  │  - EKS Full Access                             │  ┃  │ ┃
┃  │  ┃  │  - Secrets Manager Read                        │  ┃  │ ┃
┃  │  ┃  └─────────────────────────────────────────────────┘  ┃  │ ┃
┃  │  ┃                                                        ┃  │ ┃
┃  │  ┃  ┌─────────────────────────────────────────────────┐  ┃  │ ┃
┃  │  ┃  │  🌐 Internet Gateway                           │  ┃  │ ┃
┃  │  ┃  └─────────────────────────────────────────────────┘  ┃  │ ┃
┃  │  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │ ┃
┃  │                              │                                │ ┃
┃  │                              │ NAT Gateway                    │ ┃
┃  │                              ▼                                │ ┃
┃  │  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │ ┃
┃  │  ┃         PRIVATE SUBNETS (Isolated)                 ┃  │ ┃
┃  │  ┃         10.0.1.0/24, 10.0.2.0/24                   ┃  │ ┃
┃  │  ┃                                                        ┃  │ ┃
┃  │  ┃  ┌─────────────────────────────────────────────────┐  ┃  │ ┃
┃  │  ┃  │  ☸️  EKS CLUSTER (Kubernetes)                  │  ┃  │ ┃
┃  │  ┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  ┃  │ ┃
┃  │  ┃  │  Name: url-shortener-eks                       │  ┃  │ ┃
┃  │  ┃  │  Version: 1.30                                  │  ┃  │ ┃
┃  │  ┃  │                                                 │  ┃  │ ┃
┃  │  ┃  │  Worker Nodes (t3.medium):                     │  ┃  │ ┃
┃  │  ┃  │  ┌──────────┐  ┌──────────┐                   │  ┃  │ ┃
┃  │  ┃  │  │  Node 1  │  │  Node 2  │                   │  ┃  │ ┃
┃  │  ┃  │  │          │  │          │                   │  ┃  │ ┃
┃  │  ┃  │  │ Ready to │  │ Ready to │                   │  ┃  │ ┃
┃  │  ┃  │  │  deploy  │  │  deploy  │                   │  ┃  │ ┃
┃  │  ┃  │  │ (Phase 4)│  │ (Phase 4)│                   │  ┃  │ ┃
┃  │  ┃  │  └──────────┘  └──────────┘                   │  ┃  │ ┃
┃  │  ┃  └─────────────────────────────────────────────────┘  ┃  │ ┃
┃  │  ┃                                                        ┃  │ ┃
┃  │  ┃  ┌─────────────────────────────────────────────────┐  ┃  │ ┃
┃  │  ┃  │  🗄️  DOCUMENTDB CLUSTER (MongoDB-compatible)   │  ┃  │ ┃
┃  │  ┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │  ┃  │ ┃
┃  │  ┃  │  Endpoint: url-shortener-docdb.xxx             │  ┃  │ ┃
┃  │  ┃  │  Port: 27017                                    │  ┃  │ ┃
┃  │  ┃  │  Instance: db.t3.medium                         │  ┃  │ ┃
┃  │  ┃  │  Storage: Encrypted                             │  ┃  │ ┃
┃  │  ┃  │                                                 │  ┃  │ ┃
┃  │  ┃  │  Credentials stored in:                        │  ┃  │ ┃
┃  │  ┃  │  AWS Secrets Manager                           │  ┃  │ ┃
┃  │  ┃  └─────────────────────────────────────────────────┘  ┃  │ ┃
┃  │  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │ ┃
┃  └────────────────────────────────────────────────────────────────┘ ┃
┃                                                                       ┃
┃  ┌────────────────────────────────────────────────────────────────┐ ┃
┃  │  📦 ECR REPOSITORY (Container Registry)                       │ ┃
┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ ┃
┃  │  Name: url-shortener-api                                      │ ┃
┃  │  URL: xxxx.dkr.ecr.us-east-1.amazonaws.com/url-shortener-api  │ ┃
┃  │  Scan on Push: Enabled                                        │ ┃
┃  │  Encryption: AES256                                           │ ┃
┃  │                                                                │ ┃
┃  │  Images (Phase 4):                                            │ ┃
┃  │  - url-shortener-api:latest                                   │ ┃
┃  │  - url-shortener-api:v1.0.0                                   │ ┃
┃  └────────────────────────────────────────────────────────────────┘ ┃
┃                                                                       ┃
┃  ┌────────────────────────────────────────────────────────────────┐ ┃
┃  │  🔐 AWS SECRETS MANAGER                                       │ ┃
┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ ┃
┃  │  Secret: url-shortener-docdb-password                         │ ┃
┃  │  Contains: DB username, password, endpoint, port              │ ┃
┃  └────────────────────────────────────────────────────────────────┘ ┃
┃                                                                       ┃
┃  ┌────────────────────────────────────────────────────────────────┐ ┃
┃  │  💾 S3 BUCKET (Terraform State)                               │ ┃
┃  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  │ ┃
┃  │  Name: my-team-url-shortener-tfstate                          │ ┃
┃  │  Versioning: Enabled                                          │ ┃
┃  │  Encryption: AES256                                           │ ┃
┃  │  Public Access: Blocked                                       │ ┃
┃  │                                                                │ ┃
┃  │  DynamoDB Table: terraform-state-lock                         │ ┃
┃  │  (Prevents concurrent Terraform runs)                         │ ┃
┃  └────────────────────────────────────────────────────────────────┘ ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

---

## 🔄 Data Flow (Current State - Phase 3)

### Development Workflow

```
1. Developer writes code (Windows/VS Code)
              ↓
2. Code committed to Git
              ↓
3. Pushed to GitHub repository
              ↓
4. [Phase 4: Jenkins webhook triggered automatically]
              ↓
5. [Phase 4: Jenkins builds Docker image]
              ↓
6. [Phase 4: Image pushed to ECR]
              ↓
7. [Phase 4: Deployed to EKS]
```

### Current Access Patterns

```
Windows Machine
       │
       ├─→ SSH (Port 22) ────→ Jenkins EC2
       │
       └─→ HTTPS (Port 8080) ─→ Jenkins Web UI
```

---

## 🛡️ Security Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY LAYERS                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Layer 1: Network Isolation (VPC)                          │
│  ├─ Public Subnets: Jenkins only                           │
│  └─- Private Subnets: EKS, DocumentDB (no direct internet) │
│                                                             │
│  Layer 2: Security Groups (Firewall Rules)                 │
│  ├─ Jenkins SG: SSH from your IP, HTTP:8080 from anywhere  │
│  ├─ EKS SG: Allow Jenkins, deny external                   │
│  └─ DocumentDB SG: Allow EKS only                          │
│                                                             │
│  Layer 3: IAM Roles (No Hardcoded Credentials)             │
│  ├─ Jenkins Role: ECR, EKS, Secrets Manager access         │
│  └─ EKS Node Role: ECR pull, Secrets Manager read          │
│                                                             │
│  Layer 4: Secrets Management                               │
│  └─ AWS Secrets Manager: DocumentDB credentials            │
│                                                             │
│  Layer 5: Encryption                                       │
│  ├─ EBS volumes: Encrypted at rest                         │
│  ├─ DocumentDB: Encrypted storage                          │
│  └─ S3 state: Encrypted                                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Resource Inventory

### Compute Resources

| Resource | Type | Purpose | Status |
|----------|------|---------|--------|
| Jenkins EC2 | t2.medium | CI/CD Server | ✅ Running & Configured |
| EKS Control Plane | Managed | K8s API Server | ✅ Running |
| EKS Worker Nodes | t3.medium (2x) | Container Runtime | ✅ Ready |

### Network Resources

| Resource | CIDR/Value | Purpose | Status |
|----------|------------|---------|--------|
| VPC | 10.0.0.0/16 | Network Isolation | ✅ Active |
| Public Subnet 1 | 10.0.101.0/24 | Jenkins, NAT | ✅ Active |
| Public Subnet 2 | 10.0.102.0/24 | HA/Failover | ✅ Active |
| Private Subnet 1 | 10.0.1.0/24 | EKS, DocumentDB | ✅ Active |
| Private Subnet 2 | 10.0.2.0/24 | EKS, DocumentDB | ✅ Active |
| Internet Gateway | - | Public internet access | ✅ Active |
| NAT Gateway | - | Private subnet internet | ✅ Active |

### Storage & Database

| Resource | Configuration | Purpose | Status |
|----------|---------------|---------|--------|
| ECR Repository | url-shortener-api | Docker images | ✅ Ready |
| DocumentDB | db.t3.medium | MongoDB database | ✅ Running |
| S3 Bucket | tfstate bucket | Terraform state | ✅ Active |

### Security Resources

| Resource | Purpose | Status |
|----------|---------|--------|
| Jenkins Security Group | Firewall for Jenkins | ✅ Active |
| EKS Security Group | Firewall for K8s | ✅ Active |
| DocumentDB Security Group | Firewall for DB | ✅ Active |
| Secrets Manager Secret | DB credentials | ✅ Created |
| IAM Roles (3) | Service permissions | ✅ Attached |

---

## 🔌 Network Connectivity Matrix

```
┌──────────┬──────────┬─────────┬─────────────┬──────────┐
│   From   │    To    │  Port   │   Protocol  │  Allowed │
├──────────┼──────────┼─────────┼─────────────┼──────────┤
│ Your IP  │ Jenkins  │   22    │    SSH      │    ✅    │
│ Your IP  │ Jenkins  │  8080   │    HTTP     │    ✅    │
│ Jenkins  │ GitHub   │  443    │   HTTPS     │    ✅    │
│ Jenkins  │ ECR      │  443    │   HTTPS     │    ✅    │
│ Jenkins  │ EKS      │  443    │   HTTPS     │    ✅    │
│ Jenkins  │ DocDB    │ 27017   │   MongoDB   │    ✅    │
│ EKS      │ DocDB    │ 27017   │   MongoDB   │    ✅    │
│ EKS      │ ECR      │  443    │   HTTPS     │    ✅    │
│ Internet │ Jenkins  │   22    │    SSH      │    ❌    │
│ Internet │ EKS      │   Any   │    Any      │    ❌    │
│ Internet │ DocDB    │ 27017   │   MongoDB   │    ❌    │
└──────────┴──────────┴─────────┴─────────────┴──────────┘
```

---

## 📈 System State: Phase 3 Complete

### ✅ Deployed & Running

- VPC with public/private subnets
- Internet Gateway
- NAT Gateway
- Jenkins EC2 instance
- EKS Cluster (control plane + 2 worker nodes)
- DocumentDB cluster
- ECR repository
- Security groups
- IAM roles
- Secrets Manager secret

### ✅ Configured & Ready

- Jenkins with all plugins
- Docker on Jenkins
- kubectl on Jenkins
- AWS CLI on Jenkins
- Jenkins user permissions
- Service integrations

### 🔜 Pending (Phase 4)

- Kubernetes deployment manifests
- Jenkinsfile (pipeline definition)
- GitHub webhooks
- Application deployment to EKS
- Load balancer configuration
- DNS setup (optional)

---

**Architecture Status:** 75% Complete  
**Next Phase:** CI/CD Pipeline Implementation
