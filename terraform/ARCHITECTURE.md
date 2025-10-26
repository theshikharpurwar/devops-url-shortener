# AWS Infrastructure Architecture

## 🏗️ High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (us-east-1)                      │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    VPC (10.0.0.0/16)                         │   │
│  │                                                               │   │
│  │  ┌──────────────────────┐      ┌──────────────────────┐     │   │
│  │  │   Public Subnet 1    │      │   Public Subnet 2    │     │   │
│  │  │   (10.0.101.0/24)    │      │   (10.0.102.0/24)    │     │   │
│  │  │   us-east-1a         │      │   us-east-1b         │     │   │
│  │  │                      │      │                      │     │   │
│  │  │  ┌──────────────┐    │      │                      │     │   │
│  │  │  │   Jenkins    │    │      │                      │     │   │
│  │  │  │   EC2        │    │      │                      │     │   │
│  │  │  │   t2.medium  │◄───┼──────┼─── Internet         │     │   │
│  │  │  │   Port 8080  │    │      │    Gateway           │     │   │
│  │  │  │   Port 22    │    │      │                      │     │   │
│  │  │  └──────────────┘    │      │                      │     │   │
│  │  │                      │      │                      │     │   │
│  │  │  ┌──────────────┐    │      │  ┌──────────────┐   │     │   │
│  │  │  │ NAT Gateway  │    │      │  │ NAT Gateway  │   │     │   │
│  │  │  │   (Optional) │    │      │  │  (Optional)  │   │     │   │
│  │  │  └──────┬───────┘    │      │  └──────┬───────┘   │     │   │
│  │  └─────────┼────────────┘      └─────────┼───────────┘     │   │
│  │            │                              │                 │   │
│  │  ┌─────────▼──────────┐      ┌───────────▼─────────┐       │   │
│  │  │  Private Subnet 1  │      │  Private Subnet 2   │       │   │
│  │  │  (10.0.1.0/24)     │      │  (10.0.2.0/24)      │       │   │
│  │  │  us-east-1a        │      │  us-east-1b         │       │   │
│  │  │                    │      │                     │       │   │
│  │  │  ┌──────────────┐  │      │  ┌──────────────┐  │       │   │
│  │  │  │  EKS Node 1  │  │      │  │  EKS Node 2  │  │       │   │
│  │  │  │  t3.medium   │  │      │  │  t3.medium   │  │       │   │
│  │  │  │              │  │      │  │              │  │       │   │
│  │  │  │  ┌────────┐  │  │      │  │  ┌────────┐  │  │       │   │
│  │  │  │  │ Pods   │  │  │      │  │  │ Pods   │  │  │       │   │
│  │  │  │  │ (API)  │  │  │      │  │  │ (API)  │  │  │       │   │
│  │  │  │  └────────┘  │  │      │  │  └────────┘  │  │       │   │
│  │  │  └──────┬───────┘  │      │  └──────┬───────┘  │       │   │
│  │  │         │          │      │         │          │       │   │
│  │  │         │          │      │         │          │       │   │
│  │  │  ┌──────▼──────────┴──────┴─────────▼────────┐ │       │   │
│  │  │  │        DocumentDB Cluster                 │ │       │   │
│  │  │  │        db.t3.medium                        │ │       │   │
│  │  │  │        Port 27017                          │ │       │   │
│  │  │  └───────────────────────────────────────────┘ │       │   │
│  │  │                                                 │       │   │
│  │  └─────────────────────────────────────────────────┘       │   │
│  │                                                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                   External Services                          │   │
│  │                                                               │   │
│  │  ┌──────────────────┐    ┌──────────────────┐               │   │
│  │  │  ECR Repository  │    │  Secrets Manager │               │   │
│  │  │  url-shortener   │    │  DB Password     │               │   │
│  │  │  -api            │    │                  │               │   │
│  │  └──────────────────┘    └──────────────────┘               │   │
│  │                                                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

External:
┌──────────────────┐         ┌──────────────────┐
│  S3 Bucket       │         │  DynamoDB        │
│  tfstate storage │         │  state locking   │
└──────────────────┘         └──────────────────┘
```

## 🔒 Security Groups

### Jenkins Security Group
- **Inbound:**
  - Port 22 (SSH) from YOUR_IP/32
  - Port 8080 (Jenkins UI) from 0.0.0.0/0
  - All ports from VPC CIDR
- **Outbound:**
  - All traffic

### EKS Cluster Security Group
- **Inbound:**
  - Port 443 from Jenkins SG
  - Node-to-node communication
- **Outbound:**
  - All traffic

### DocumentDB Security Group
- **Inbound:**
  - Port 27017 from EKS Node SG
  - Port 27017 from Jenkins SG
  - Port 27017 from Private Subnet CIDRs
- **Outbound:**
  - All traffic

## 📊 Network Flow

### User Access Flow
```
Internet User → Jenkins (Public IP:8080) → Jenkins UI
Developer → SSH (Port 22) → Jenkins Server
```

### CI/CD Pipeline Flow
```
Developer → Git Push → GitHub
                         ↓
                      Jenkins
                         ↓
                    Docker Build
                         ↓
                    Push to ECR
                         ↓
                    Deploy to EKS
                         ↓
                    Pods Running
                         ↓
                    Connect to DocumentDB
```

### Application Traffic Flow
```
Internet → ALB/NLB → EKS Service → EKS Pods → DocumentDB
```

## 🗄️ Data Flow

### DocumentDB Connection
```
EKS Pods → (Private Network) → DocumentDB Cluster
         → Secrets Manager (for credentials)
```

### Container Registry
```
Jenkins → Docker Build → Push to ECR
EKS Nodes → Pull from ECR → Run Containers
```

## 💾 Persistent Storage

### Terraform State
- **S3 Bucket:** `my-team-url-shortener-tfstate`
- **DynamoDB Table:** `terraform-state-lock`
- **Encryption:** AES256
- **Versioning:** Enabled

### DocumentDB Data
- **Storage:** Encrypted EBS volumes
- **Backup:** 7-day retention
- **Replication:** Multi-AZ capable

### Container Images
- **ECR Repository:** Encrypted
- **Lifecycle:** Keep last 10 tagged, delete untagged after 7 days

## 🌐 DNS and Load Balancing

**Phase 4 will add:**
- Application Load Balancer (ALB) for HTTP/HTTPS traffic
- Route53 for DNS management
- SSL/TLS certificates via ACM

## 📈 Scalability

### Current Configuration
- **EKS Nodes:** 2 (min: 1, max: 4)
- **DocumentDB Instances:** 1 (can scale to 15)
- **Jenkins:** Single instance (consider Jenkins on Kubernetes for HA)

### Auto-Scaling
- **EKS:** Cluster Autoscaler enabled
- **Pods:** Horizontal Pod Autoscaler (HPA) - to be configured
- **DocumentDB:** Manual scaling (add read replicas)

## 🔐 IAM Roles and Permissions

### Jenkins EC2 Role
- ECR PowerUser (push/pull images)
- EKS Cluster Policy (deploy to Kubernetes)
- SSM Managed Instance (for Systems Manager)

### EKS Node Role
- EKS Worker Node Policy
- ECR Read Only (pull images)
- EBS CSI Driver (manage volumes)
- Secrets Manager Read (DocumentDB credentials)

### EBS CSI Driver Role
- EBS CSI Driver Policy (manage EBS volumes for PVs)

## 💰 Cost Breakdown

### Monthly Costs (Approximate)

| Component | Specification | Monthly Cost |
|-----------|--------------|--------------|
| **Compute** |
| Jenkins EC2 | t2.medium (1 instance) | $30 |
| EKS Control Plane | Managed service | $72 |
| EKS Worker Nodes | t3.medium × 2 | $60 |
| **Database** |
| DocumentDB | db.t3.medium × 1 | $120 |
| **Networking** |
| NAT Gateway | 1 gateway | $32 |
| Data Transfer | ~50GB/month | $5 |
| **Storage** |
| EBS Volumes | ~100GB total | $10 |
| ECR Storage | ~10GB images | $1 |
| S3 (tfstate) | <1GB | <$1 |
| **Secrets** |
| Secrets Manager | 1 secret | $0.40 |
| **Total** | | **~$330/month** |

### Cost Optimization Strategies

1. **Stop when not in use:**
   - Stop Jenkins EC2 instance
   - Scale EKS nodes to 0
   - Delete DocumentDB cluster (for dev)

2. **Use Spot Instances:**
   - EKS nodes can use Spot (save 70%)

3. **Single NAT Gateway:**
   - Already configured (vs. 1 per AZ)

4. **Reserved Instances:**
   - For production workloads

## 🔧 Monitoring and Logging (Future Phase)

**To be added:**
- CloudWatch Logs for all services
- CloudWatch Metrics dashboards
- X-Ray for distributed tracing
- Prometheus + Grafana on EKS
- ELK Stack for log aggregation

## 🔄 High Availability Considerations

**Current Setup:**
- ✅ Multi-AZ VPC
- ✅ EKS control plane (managed, HA by default)
- ✅ EKS nodes in multiple AZs
- ⚠️ Single NAT Gateway (cost optimization)
- ⚠️ Single DocumentDB instance
- ⚠️ Single Jenkins instance

**Production Enhancements:**
- NAT Gateway per AZ
- DocumentDB with read replicas
- Jenkins on Kubernetes with persistent storage
- Application Load Balancer
- Auto-scaling enabled

## 📚 Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [DocumentDB Best Practices](https://docs.aws.amazon.com/documentdb/latest/developerguide/best_practices.html)
- [Terraform AWS Modules](https://registry.terraform.io/namespaces/terraform-aws-modules)

---

**This architecture is designed for learning and development. For production, implement additional HA, monitoring, and security measures.**
