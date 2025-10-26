# Phase 2: Infrastructure as Code with Terraform

## 📋 Overview

This directory contains Terraform code to provision all AWS infrastructure for the URL Shortener DevOps project.

## 🏗️ Infrastructure Components

| Component | Purpose | AWS Service |
|-----------|---------|-------------|
| **VPC** | Network isolation | VPC, Subnets, IGW, NAT Gateway |
| **ECR** | Docker image registry | Elastic Container Registry |
| **Jenkins** | CI/CD server | EC2 (t2.medium) |
| **EKS** | Kubernetes cluster | Elastic Kubernetes Service |
| **DocumentDB** | MongoDB-compatible database | Amazon DocumentDB |

## 📁 File Structure

```
terraform/
├── versions.tf              # Terraform & provider versions, S3 backend
├── variables.tf             # Input variables
├── vpc.tf                   # VPC and networking (using AWS module)
├── ecr.tf                   # Container registry
├── jenkins.tf               # Jenkins EC2 instance
├── eks.tf                   # Kubernetes cluster (using AWS module)
├── database.tf              # DocumentDB cluster
├── outputs.tf               # Output values
├── terraform.tfvars.example # Example variables file
├── setup-backend.sh         # Script to create S3 backend
└── README.md                # This file
```

## 🚀 Prerequisites

### 1. Install Terraform

```bash
# Download Terraform for Linux (WSL 2)
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip

# Unzip
unzip terraform_1.6.6_linux_amd64.zip

# Move to /usr/local/bin
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

### 2. Install AWS CLI

```bash
# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Verify installation
aws --version
```

### 3. Configure AWS Credentials

```bash
# Run AWS configure
aws configure

# You'll be prompted for:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region (use: us-east-1)
# - Default output format (use: json)

# Verify configuration
aws sts get-caller-identity
```

### 4. Generate SSH Key Pair

```bash
# Generate SSH key for Jenkins access
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Verify key was created
ls -la ~/.ssh/
```

### 5. Get Your Public IP Address

```bash
# Get your public IP (needed for Jenkins security group)
curl https://checkip.amazonaws.com

# Save this IP - you'll need it in terraform.tfvars
```

## 📝 Step-by-Step Deployment Guide

### Step 1: Navigate to Terraform Directory

```bash
cd /mnt/d/devops-url-shortener/terraform
```

### Step 2: Create S3 Backend (One-Time Setup)

The S3 backend allows your team to share Terraform state files.

```bash
# Make the script executable
chmod +x setup-backend.sh

# Run the backend setup script
./setup-backend.sh
```

**What this does:**
- Creates an S3 bucket: `my-team-url-shortener-tfstate`
- Enables versioning for state file history
- Enables encryption for security
- Blocks public access
- Creates a DynamoDB table for state locking

### Step 3: Create Your Variables File

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
nano terraform.tfvars
# OR
code terraform.tfvars
```

**Important: Update these values in `terraform.tfvars`:**

```hcl
# Replace YOUR_IP_ADDRESS with your actual IP from Step 5 of prerequisites
jenkins_allowed_ip = "203.0.113.42/32"  # Example: your actual IP

# Optional: Customize other settings
aws_region = "us-east-1"
environment = "dev"
project_name = "url-shortener"
```

### Step 4: Initialize Terraform

```bash
# Initialize Terraform (downloads providers and modules)
terraform init
```

**Expected output:**
```
Initializing the backend...
Successfully configured the backend "s3"!
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

### Step 5: Validate Configuration

```bash
# Check for syntax errors
terraform validate

# Format code (optional, but good practice)
terraform fmt
```

### Step 6: Review the Execution Plan

```bash
# Generate and review the plan
terraform plan

# Optional: Save the plan to a file
terraform plan -out=tfplan
```

**Review the output carefully!** Terraform will show:
- Resources to be created (green `+`)
- Resources to be modified (yellow `~`)
- Resources to be destroyed (red `-`)

**Expected resources:**
- ~40-50 resources will be created
- Including: VPC, subnets, security groups, EC2, EKS, DocumentDB, ECR, etc.

### Step 7: Apply the Configuration

```bash
# Apply the configuration
terraform apply

# OR, if you saved a plan:
terraform apply tfplan
```

**Type `yes` when prompted.**

⏰ **Estimated time:** 15-20 minutes (EKS cluster takes the longest)

### Step 8: Review Outputs

After successful deployment, Terraform will display important information:

```bash
# View all outputs
terraform output

# View specific output
terraform output jenkins_public_ip
terraform output eks_cluster_endpoint
terraform output ecr_repository_url
terraform output docdb_cluster_endpoint

# View the quick reference guide
terraform output quick_reference
```

### Step 9: Configure kubectl for EKS

```bash
# Configure kubectl to connect to your EKS cluster
aws eks update-kubeconfig --region us-east-1 --name url-shortener-eks

# Verify connection
kubectl get nodes

# You should see 2 nodes in "Ready" state
```

### Step 10: Verify All Resources

```bash
# Check Jenkins server
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
echo "Jenkins UI: http://$JENKINS_IP:8080"

# Check ECR repository
terraform output ecr_repository_url

# Check DocumentDB credentials
aws secretsmanager get-secret-value \
  --region us-east-1 \
  --secret-id url-shortener-docdb-password \
  --query SecretString \
  --output text | jq .
```

## 🔍 Important Outputs Explained

### ECR Repository URL
```
123456789012.dkr.ecr.us-east-1.amazonaws.com/url-shortener-api
```
Use this to push Docker images in Phase 4.

### Jenkins Public IP
```
54.123.45.67
```
Access Jenkins at: `http://54.123.45.67:8080`

SSH to Jenkins: `ssh -i ~/.ssh/id_rsa ubuntu@54.123.45.67`

### EKS Cluster Endpoint
```
https://ABC123XYZ.gr7.us-east-1.eks.amazonaws.com
```
Used by kubectl to communicate with the cluster.

### DocumentDB Endpoint
```
url-shortener-docdb-cluster.cluster-xyz.us-east-1.docdb.amazonaws.com:27017
```
Your application will connect to this endpoint.

## 🛠️ Common Terraform Commands

```bash
# Show current state
terraform show

# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.jenkins

# Refresh state
terraform refresh

# Destroy specific resource
terraform destroy -target=aws_instance.jenkins

# Destroy everything (⚠️ DANGER!)
terraform destroy
```

## 🔐 Security Best Practices

### 1. Protect Your State File
- ✅ State is stored in S3 with encryption
- ✅ Versioning is enabled for rollback
- ✅ DynamoDB provides state locking

### 2. Secrets Management
- ✅ Database password stored in AWS Secrets Manager
- ✅ No hardcoded credentials in code
- ✅ Use IAM roles instead of access keys where possible

### 3. Network Security
- ✅ Private subnets for EKS and DocumentDB
- ✅ Security groups restrict access
- ✅ NAT Gateway for private subnet internet access

### 4. Access Control
- ✅ Jenkins SSH limited to your IP
- ✅ EKS API endpoint has security groups
- ✅ DocumentDB only accessible from EKS/Jenkins

## 💰 Cost Optimization Tips

### Current Configuration Costs (Approximate)
| Resource | Instance Type | Monthly Cost (est.) |
|----------|---------------|---------------------|
| Jenkins EC2 | t2.medium | ~$30 |
| EKS Control Plane | - | $72 |
| EKS Nodes (2x) | t3.medium | ~$60 |
| DocumentDB (1x) | db.t3.medium | ~$120 |
| NAT Gateway | - | ~$32 |
| **Total** | | **~$314/month** |

### To Reduce Costs:
1. **Stop instances when not in use:**
   ```bash
   # Stop Jenkins
   aws ec2 stop-instances --instance-ids $(terraform output -raw jenkins_instance_id)
   
   # Scale EKS to 0 nodes
   aws eks update-nodegroup-config \
     --cluster-name url-shortener-eks \
     --nodegroup-name url-shortener-node-group \
     --scaling-config minSize=0,maxSize=4,desiredSize=0
   ```

2. **Use Spot Instances for EKS nodes** (modify `eks.tf`)

3. **Reduce DocumentDB to smaller instance** (change in `variables.tf`)

4. **Destroy resources after testing:**
   ```bash
   terraform destroy
   ```

## 🐛 Troubleshooting

### Error: "Backend initialization required"
```bash
terraform init -reconfigure
```

### Error: "Insufficient permissions"
Check your AWS IAM permissions. You need:
- EC2 Full Access
- VPC Full Access
- EKS Full Access
- DocumentDB Full Access
- ECR Full Access
- Secrets Manager Full Access
- IAM permissions to create roles

### Error: "Resource already exists"
```bash
# Import existing resource
terraform import aws_s3_bucket.tfstate my-team-url-shortener-tfstate

# Or destroy and recreate
terraform destroy -target=RESOURCE_NAME
terraform apply
```

### Error: "SSH key not found"
```bash
# Verify SSH key exists
ls -la ~/.ssh/id_rsa.pub

# If not, create it:
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

### EKS Cluster Not Accessible
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name url-shortener-eks

# Check AWS credentials
aws sts get-caller-identity

# Verify cluster exists
aws eks describe-cluster --name url-shortener-eks --region us-east-1
```

### Jenkins Server Not Accessible
```bash
# Check security group allows your current IP
CURRENT_IP=$(curl -s https://checkip.amazonaws.com)
echo "Your current IP: $CURRENT_IP"

# Update terraform.tfvars with new IP if changed
# Then run: terraform apply
```

## 📚 Next Steps

After successful deployment:

1. ✅ **Verify all resources are running**
2. ✅ **Access Jenkins UI** and note the initial admin password
3. ✅ **Test kubectl connection** to EKS
4. ✅ **Retrieve DocumentDB credentials** from Secrets Manager
5. 🚀 **Move to Phase 3**: Ansible configuration for Jenkins
6. 🚀 **Move to Phase 4**: Create CI/CD pipeline

## 🔗 Useful Links

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [AWS DocumentDB User Guide](https://docs.aws.amazon.com/documentdb/)
- [Terraform S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)

## 🆘 Need Help?

If you encounter issues:
1. Check the Troubleshooting section above
2. Review Terraform output for error messages
3. Check AWS Console for resource status
4. Review security group rules
5. Verify AWS credentials and permissions

---

**Phase 2 Complete!** 🎉 Your AWS infrastructure is now ready for Phase 3 (Ansible) and Phase 4 (CI/CD Pipeline).
