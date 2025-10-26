# 🔐 Jenkins Server Access Guide

## Instance Details
- **Public IP**: `98.84.35.193`
- **Jenkins UI**: http://98.84.35.193:8080
- **Instance ID**: `i-0a60538ef6130dff0`
- **Username**: `ubuntu`

## ⚠️ SSH Key Issue on Windows
The SSH private key has RSA format compatibility issues with Windows OpenSSH client.

## ✅ Solutions to Access Jenkins

### Option 1: AWS Systems Manager Session Manager (Recommended)
1. Install SSM Plugin: https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-windows.html
2. Connect:
   ```powershell
   aws ssm start-session --target i-0a60538ef6130dff0
   ```

### Option 2: Convert Key to OpenSSH Format
```powershell
# Convert RSA key to OpenSSH format
ssh-keygen -p -f "$env:USERPROFILE\.ssh\jenkins-server-key.pem" -m pem -P "" -N ""
```

### Option 3: Use PuTTY
1. Download PuTTY: https://www.putty.org/
2. Convert key using PuTTYgen:
   - Load `jenkins-server-key.pem`
   - Save as `.ppk` file
3. Connect using PuTTY:
   - Host: `ubuntu@98.84.35.193`
   - Auth: Browse to `.ppk` file

### Option 4: Use WSL (Windows Subsystem for Linux)
```bash
# In WSL terminal
cp /mnt/c/Users/Shikhar\ Purwar/.ssh/jenkins-server-key.pem ~/.ssh/
chmod 400 ~/.ssh/jenkins-server-key.pem
ssh -i ~/.ssh/jenkins-server-key.pem ubuntu@98.84.35.193
```

### Option 5: Access via AWS Console
1. Go to EC2 Console: https://console.aws.amazon.com/ec2/
2. Select instance `i-0a60538ef6130dff0`
3. Click "Connect" → "Session Manager" → "Connect"

## 📋 Commands to Run After Connecting

### 1. Check if User Data Script Completed
```bash
sudo cat /var/log/user-data-complete.txt
cloud-init status
```

### 2. Verify Docker Installation
```bash
docker --version
docker-compose --version
sudo systemctl status docker
```

### 3. Install Jenkins using Docker
```bash
# Create Jenkins directory
mkdir -p ~/jenkins_home
sudo chown -R 1000:1000 ~/jenkins_home

# Run Jenkins container
docker run -d \
  --name jenkins \
  --restart=unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v ~/jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts

# Wait ~1 minute for Jenkins to start, then get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 4. Configure AWS ECR Access
```bash
# Configure AWS credentials (already have IAM role attached)
aws ecr get-login-password --region us-east-1
```

## 🚀 Next Steps
1. Connect to Jenkins server using one of the options above
2. Install Jenkins using Docker
3. Access Jenkins UI at http://98.84.35.193:8080
4. Complete Jenkins setup wizard with initial admin password
5. Install recommended plugins + Docker plugin
6. Create your first pipeline!

## 🔒 Security Note
**IMPORTANT**: SSH is currently open to `0.0.0.0/0` for troubleshooting.
After setup, run this to restrict it back to your IP:
```powershell
cd D:\devops-url-shortener\terraform
# Edit jenkins.tf and change SSH cidr_blocks back to [var.jenkins_allowed_ip]
terraform apply -auto-approve
```
