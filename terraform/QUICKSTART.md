# 🚀 Quick Start Guide - Phase 2: Terraform

This is a condensed version for quick reference. See `terraform/README.md` for detailed explanations.

## ⚡ Prerequisites Setup (One-Time)

```bash
# 1. Install Terraform
wget https://releases.hashicorp.com/terraform/1.6.6/terraform_1.6.6_linux_amd64.zip
unzip terraform_1.6.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform version

# 2. Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version

# 3. Configure AWS
aws configure
# Enter your AWS Access Key ID
# Enter your AWS Secret Access Key
# Region: us-east-1
# Output: json

# 4. Generate SSH Key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# 5. Get Your IP
curl https://checkip.amazonaws.com
# Save this IP!
```

## 🏗️ Deploy Infrastructure (Main Steps)

```bash
# Navigate to terraform directory
cd /mnt/d/devops-url-shortener/terraform

# Step 1: Setup S3 Backend (one-time)
chmod +x setup-backend.sh
./setup-backend.sh

# Step 2: Create variables file
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
# Update jenkins_allowed_ip with YOUR IP from above!

# Step 3: Initialize Terraform
terraform init

# Step 4: Review plan
terraform plan

# Step 5: Deploy! (takes ~15-20 minutes)
terraform apply
# Type: yes

# Step 6: Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name url-shortener-eks

# Step 7: Verify
kubectl get nodes
terraform output quick_reference
```

## 📊 Quick Commands

```bash
# View outputs
terraform output
terraform output jenkins_public_ip
terraform output ecr_repository_url

# Get DocumentDB password
aws secretsmanager get-secret-value \
  --region us-east-1 \
  --secret-id url-shortener-docdb-password \
  --query SecretString --output text | jq .

# Access Jenkins
JENKINS_IP=$(terraform output -raw jenkins_public_ip)
echo "Jenkins UI: http://$JENKINS_IP:8080"
ssh -i ~/.ssh/id_rsa ubuntu@$JENKINS_IP

# Destroy everything (when done testing)
terraform destroy
```

## ⚠️ Critical Notes

1. **Update `terraform.tfvars`** with YOUR IP address!
2. **Phase 2 costs ~$314/month** - destroy when not in use
3. **EKS cluster takes ~15 minutes** to create
4. **Save outputs** - you'll need them for Phase 3 & 4

## ✅ Success Checklist

- [ ] Terraform init successful
- [ ] terraform apply completed without errors
- [ ] kubectl get nodes shows 2 nodes
- [ ] Jenkins accessible at http://JENKINS_IP:8080
- [ ] ECR repository created
- [ ] DocumentDB cluster running
- [ ] All outputs displayed correctly

**Next: Phase 3 - Ansible for Jenkins configuration** 🎯
