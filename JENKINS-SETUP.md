# Jenkins Setup & Configuration Guide

This guide walks you through configuring Jenkins on your AWS EC2 instance to run the CI/CD pipeline for the URL Shortener application.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Jenkins Setup](#initial-jenkins-setup)
3. [Install Required Plugins](#install-required-plugins)
4. [Configure AWS Credentials](#configure-aws-credentials)
5. [Configure Global Tools](#configure-global-tools)
6. [Create Pipeline Job](#create-pipeline-job)
7. [Configure GitHub Webhook](#configure-github-webhook)
8. [Environment Variables Reference](#environment-variables-reference)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before proceeding, ensure you have:

- ✅ **Jenkins server running** on AWS EC2 (configured via Ansible in Phase 3)
- ✅ **Terraform outputs** available (ECR URL, EKS cluster name, DB secret name)
- ✅ **GitHub repository** with code pushed
- ✅ **AWS credentials** with permissions for ECR, EKS, and Secrets Manager

---

## Initial Jenkins Setup

### 1. Access Jenkins

From your Terraform outputs, get the Jenkins public IP:

```bash
# On your Windows machine (PowerShell)
cd d:\devops-url-shortener\terraform
terraform output jenkins_public_ip
```

Open Jenkins in your browser:
```
http://<JENKINS_PUBLIC_IP>:8080
```

### 2. Unlock Jenkins

SSH into your Jenkins server:

```powershell
# PowerShell
ssh -i <path-to-your-key.pem> ubuntu@<JENKINS_PUBLIC_IP>
```

Get the initial admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Copy this password and paste it into the Jenkins unlock screen.

### 3. Install Suggested Plugins

When prompted:
- Select **"Install suggested plugins"**
- Wait for installation to complete (2-3 minutes)

### 4. Create Admin User

Fill in the form:
- **Username**: `admin`
- **Password**: Choose a strong password
- **Full name**: Your name
- **Email**: Your email address

Click **"Save and Continue"** → **"Save and Finish"** → **"Start using Jenkins"**

---

## Install Required Plugins

### Navigate to Plugin Manager

1. Click **"Manage Jenkins"** (left sidebar)
2. Click **"Manage Plugins"** or **"Plugins"**
3. Select the **"Available plugins"** tab

### Install These Plugins

Search for and install the following plugins:

#### Essential Plugins

- [x] **Pipeline** (should already be installed)
- [x] **Docker Pipeline**
- [x] **Amazon ECR**
- [x] **Kubernetes CLI**
- [x] **AWS Credentials**
- [x] **Git**
- [x] **GitHub**
- [x] **Pipeline: AWS Steps**

#### Optional but Recommended

- [ ] **Blue Ocean** (modern UI for pipelines)
- [ ] **Workspace Cleanup**
- [ ] **Timestamper** (adds timestamps to console output)
- [ ] **AnsiColor** (colorized console output)
- [ ] **Email Extension** (for notifications)

### Installation Steps

1. Check the box next to each plugin name
2. Click **"Install without restart"** at the bottom
3. Wait for installation to complete
4. Check **"Restart Jenkins when installation is complete and no jobs are running"**
5. Wait for Jenkins to restart (1-2 minutes)
6. Log back in

---

## Configure AWS Credentials

Jenkins needs AWS credentials to interact with ECR, EKS, and Secrets Manager.

### Create IAM User for Jenkins

If you haven't already, create an IAM user with these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "eks:ListClusters"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note**: Alternatively, use the IAM role attached to the Jenkins EC2 instance (configured in Terraform).

### Add Credentials to Jenkins

#### Option 1: Use EC2 Instance IAM Role (Recommended)

If your Jenkins EC2 instance has the proper IAM role (configured via Terraform), the AWS CLI will automatically use the instance role. No additional credentials needed!

Verify by SSH'ing into Jenkins:

```bash
aws sts get-caller-identity
```

You should see the Jenkins instance role ARN.

#### Option 2: Add AWS Access Keys

If you need to use explicit credentials:

1. Go to **"Manage Jenkins"** → **"Manage Credentials"**
2. Click on **"(global)"** domain
3. Click **"Add Credentials"** (left sidebar)
4. Fill in the form:
   - **Kind**: AWS Credentials
   - **ID**: `aws-credentials`
   - **Description**: `AWS credentials for ECR/EKS`
   - **Access Key ID**: Your AWS access key
   - **Secret Access Key**: Your AWS secret key
5. Click **"OK"**

#### Add AWS Account ID

1. Go to **"Manage Jenkins"** → **"Manage Credentials"**
2. Click **"Add Credentials"**
3. Fill in:
   - **Kind**: Secret text
   - **Secret**: Your AWS account ID (12 digits)
   - **ID**: `aws-account-id`
   - **Description**: `AWS Account ID`
4. Click **"OK"**

---

## Configure Global Tools

### Configure Docker

1. Go to **"Manage Jenkins"** → **"Global Tool Configuration"**
2. Scroll to **"Docker"** section
3. Click **"Add Docker"**
4. Fill in:
   - **Name**: `docker`
   - **Install automatically**: Uncheck (Docker is already installed via Ansible)
   - **Installation root**: `/usr/bin`
5. Click **"Save"**

### Verify kubectl

The `kubectl` CLI was installed via Ansible. Verify it's accessible:

SSH into Jenkins:

```bash
sudo -u jenkins kubectl version --client
```

You should see the kubectl version output.

---

## Create Pipeline Job

### 1. Create New Pipeline

1. From Jenkins dashboard, click **"New Item"** (left sidebar)
2. Enter item name: `url-shortener-pipeline`
3. Select **"Pipeline"**
4. Click **"OK"**

### 2. Configure Pipeline

#### General Section

- [x] **GitHub project** (check this box)
  - **Project url**: `https://github.com/<your-username>/devops-url-shortener/`

#### Build Triggers

- [x] **GitHub hook trigger for GITScm polling**

#### Pipeline Section

- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/<your-username>/devops-url-shortener.git`
- **Credentials**: None (for public repos) or add GitHub credentials
- **Branch Specifier**: `*/main` (or your default branch)
- **Script Path**: `Jenkinsfile`

### 3. Update Environment Variables

Before saving, you need to update the `Jenkinsfile` with your actual values.

#### Edit Jenkinsfile

On your Windows machine, edit `d:\devops-url-shortener\Jenkinsfile`:

```groovy
environment {
    // Update these values from your Terraform outputs
    AWS_REGION = 'us-east-1'  // Your AWS region
    AWS_ACCOUNT_ID = credentials('aws-account-id')
    
    // From: terraform output ecr_repository_url
    ECR_REPOSITORY_URL = "<YOUR_AWS_ACCOUNT_ID>.dkr.ecr.<YOUR_REGION>.amazonaws.com/url-shortener"
    
    // From: terraform output eks_cluster_name
    EKS_CLUSTER_NAME = '<YOUR_EKS_CLUSTER_NAME>'
    
    // From: terraform output docdb_secret_name
    DB_SECRET_NAME = '<YOUR_DB_SECRET_NAME>'
    
    KUBE_NAMESPACE = 'default'
}
```

#### Get Values from Terraform

```powershell
# PowerShell
cd d:\devops-url-shortener\terraform

terraform output ecr_repository_url
terraform output eks_cluster_name
terraform output docdb_secret_name
```

Replace the placeholders in `Jenkinsfile` with these values.

### 4. Save Pipeline

Click **"Save"** at the bottom of the page.

---

## Configure GitHub Webhook

To trigger the pipeline automatically when you push code:

### 1. Get Jenkins Webhook URL

Your webhook URL will be:
```
http://<JENKINS_PUBLIC_IP>:8080/github-webhook/
```

### 2. Add Webhook in GitHub

1. Go to your GitHub repository
2. Click **"Settings"** → **"Webhooks"** → **"Add webhook"**
3. Fill in:
   - **Payload URL**: `http://<JENKINS_PUBLIC_IP>:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Which events**: Select "Just the push event"
   - **Active**: Check this box
4. Click **"Add webhook"**

### 3. Test Webhook

Make a small change and push to GitHub:

```powershell
# PowerShell
cd d:\devops-url-shortener

# Make a small change
echo "# Test" >> README.md

git add .
git commit -m "Test Jenkins webhook"
git push origin main
```

Check Jenkins - you should see a new build triggered automatically!

---

## Environment Variables Reference

The `Jenkinsfile` uses these environment variables:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `AWS_REGION` | AWS region for your resources | `us-east-1` |
| `AWS_ACCOUNT_ID` | Your 12-digit AWS account ID | `123456789012` |
| `ECR_REPOSITORY_URL` | Full ECR repository URL | `123456789012.dkr.ecr.us-east-1.amazonaws.com/url-shortener` |
| `EKS_CLUSTER_NAME` | Name of your EKS cluster | `url-shortener-cluster` |
| `DB_SECRET_NAME` | Secrets Manager secret name | `url-shortener-docdb-credentials` |
| `KUBE_NAMESPACE` | Kubernetes namespace | `default` |

Get these values from Terraform:

```bash
terraform output
```

---

## Troubleshooting

### Pipeline Fails at "Build Docker Image"

**Error**: `docker: command not found`

**Solution**:
```bash
# SSH into Jenkins
ssh ubuntu@<JENKINS_IP>

# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

### Pipeline Fails at "Login to AWS ECR"

**Error**: `Unable to locate credentials`

**Solution**: 
- Verify AWS credentials are configured in Jenkins
- OR verify EC2 instance has the correct IAM role attached
- Test: `aws sts get-caller-identity` on Jenkins server

### Pipeline Fails at "Deploy to EKS"

**Error**: `error: You must be logged in to the server (Unauthorized)`

**Solution**:
```bash
# On Jenkins server
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
kubectl cluster-info
```

Ensure the IAM role/user has `eks:DescribeCluster` permission.

### Load Balancer Not Getting External IP

**Issue**: Service stays in `<pending>` state

**Check**:
```bash
kubectl describe service url-shortener-service
```

**Common causes**:
- EKS cluster doesn't have AWS Load Balancer Controller
- VPC subnets not properly tagged
- Security groups blocking traffic

**Solution**: Wait 3-5 minutes for AWS to provision the Load Balancer.

### Database Connection Fails

**Error**: `MongoNetworkError: failed to connect to server`

**Check**:
1. DocumentDB security group allows traffic from EKS node security group
2. Secret in Secrets Manager has correct format
3. Connection string includes `?tls=true&replicaSet=rs0`

**Debug**:
```bash
# Get pod logs
kubectl logs -l app=url-shortener --tail=100
```

---

## Next Steps

Once Jenkins is configured:

1. ✅ Commit your updated `Jenkinsfile` to GitHub
2. ✅ Push the `k8s/` directory to GitHub
3. ✅ Trigger the pipeline (manual or via webhook)
4. ✅ Monitor the build in Jenkins UI
5. ✅ Get the Load Balancer URL and test your application!

See **DEPLOYMENT-GUIDE.md** for detailed deployment instructions.

---

## Security Best Practices

- ✅ Use IAM roles instead of access keys when possible
- ✅ Restrict Jenkins security group to your IP address for port 8080
- ✅ Enable HTTPS for Jenkins (use reverse proxy with SSL certificate)
- ✅ Regularly update Jenkins and plugins
- ✅ Use least-privilege IAM policies
- ✅ Rotate AWS credentials regularly
- ✅ Enable audit logging in Jenkins

---

**Phase 4 - Jenkins Setup Complete!** 🎉

You're now ready to run your CI/CD pipeline!
