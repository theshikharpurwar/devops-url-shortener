# Phase 3: Configuration Management with Ansible (Windows)

## 📋 Overview

This directory contains the Ansible playbook to configure the Jenkins EC2 server. Since you're running Windows without WSL 2, we'll SSH into the Jenkins server and run Ansible locally on that machine.

## 📁 Files

```
ansible/
├── playbook-jenkins.yml    # Main Ansible playbook for Jenkins configuration
├── README.md               # This file
└── WINDOWS-GUIDE.md        # Detailed Windows setup instructions
```

## 🎯 What the Playbook Does

The `playbook-jenkins.yml` playbook will:

1. ✅ Update system packages
2. ✅ Install Java 17 (required for Jenkins)
3. ✅ Install Docker and Docker Compose
4. ✅ Install Jenkins CI/CD server
5. ✅ Install kubectl (Kubernetes CLI)
6. ✅ Install AWS CLI v2
7. ✅ Configure permissions (add Jenkins user to Docker group)
8. ✅ Retrieve and display the Jenkins initial admin password

## 🚀 Quick Start (Windows)

### Prerequisites

Before you begin, ensure you have:

- ✅ Phase 2 completed (Terraform infrastructure deployed)
- ✅ Jenkins EC2 Public IP (from `terraform output jenkins_public_ip`)
- ✅ SSH private key file (usually `~/.ssh/id_rsa` or a `.pem` file)
- ✅ Your GitHub repository URL

### Step-by-Step Execution

#### Step 1: Get Jenkins Server IP

From your project directory on Windows (PowerShell):

```powershell
# Navigate to terraform directory
cd D:\devops-url-shortener\terraform

# Get Jenkins public IP
terraform output jenkins_public_ip
```

**Save this IP address!** Example: `54.123.45.67`

#### Step 2: SSH into Jenkins Server

**Option A: Using PowerShell/CMD (Recommended)**

```powershell
# SSH using your private key
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67

# If you get a "bad permissions" error, fix the key permissions first:
# Right-click id_rsa → Properties → Security → Advanced
# Remove all permissions except your user account with Full Control
```

**Option B: Using PuTTY (Alternative)**

1. Download PuTTY: https://www.putty.org/
2. If using `.pem` key, convert it using PuTTYgen:
   - Open PuTTYgen
   - Load → Select your `.pem` file
   - Save private key → Save as `.ppk`
3. Open PuTTY:
   - Host Name: `ubuntu@54.123.45.67`
   - Connection → SSH → Auth → Browse to your `.ppk` file
   - Click "Open"

#### Step 3: Install Ansible and Git on Jenkins Server

Once connected via SSH, run:

```bash
# Update package lists
sudo apt update

# Install Ansible and Git
sudo apt install ansible git -y

# Verify installation
ansible --version
git --version
```

#### Step 4: Clone Your GitHub Repository

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/devops-url-shortener.git

# Navigate to the repository
cd devops-url-shortener

# Verify the ansible directory exists
ls -la ansible/
```

**Note:** If your repository is private, you'll need to authenticate. Use a Personal Access Token:

```bash
# GitHub will prompt for username and password
# Username: your-github-username
# Password: your-personal-access-token (not your actual password!)
```

#### Step 5: Run the Ansible Playbook

```bash
# Navigate to the ansible directory
cd ansible

# Run the playbook
ansible-playbook playbook-jenkins.yml

# The playbook will run for ~5-10 minutes
```

**What you'll see:**
- Each task will show `ok`, `changed`, or `failed`
- At the end, you'll see the Jenkins initial admin password
- **SAVE THIS PASSWORD!**

#### Step 6: Verify Installation

```bash
# Check Docker
docker --version
sudo systemctl status docker

# Check Jenkins
sudo systemctl status jenkins

# Check kubectl
kubectl version --client

# Check AWS CLI
aws --version
```

#### Step 7: Access Jenkins UI

1. Open your web browser (on Windows)
2. Go to: `http://54.123.45.67:8080` (use your actual IP)
3. You should see the Jenkins "Unlock Jenkins" page
4. Paste the initial admin password from Step 5
5. Click "Continue"

#### Step 8: Complete Jenkins Setup

1. **Install Suggested Plugins** (recommended)
   - Jenkins will automatically install common plugins
   - This takes ~3-5 minutes

2. **Create First Admin User**
   - Username: `admin` (or your choice)
   - Password: Choose a strong password
   - Full name: Your name
   - Email: Your email

3. **Instance Configuration**
   - Jenkins URL: `http://54.123.45.67:8080` (or use the default)
   - Click "Save and Finish"

4. **Start Using Jenkins!**
   - Click "Start using Jenkins"

#### Step 9: Log Out of SSH

```bash
# Exit the SSH session
exit
```

## 🔧 Troubleshooting

### SSH Connection Refused

```powershell
# Check if the security group allows your IP
# Get your current IP
curl https://api.ipify.org

# Update terraform.tfvars with new IP if it changed
# Then run: terraform apply
```

### Ansible Playbook Fails

```bash
# Check if running as sudo
ansible-playbook playbook-jenkins.yml -vvv

# The -vvv flag shows detailed output for debugging
```

### Jenkins Not Accessible on Port 8080

```bash
# Check if Jenkins is running
sudo systemctl status jenkins

# Check if port 8080 is listening
sudo netstat -tlnp | grep 8080

# Restart Jenkins
sudo systemctl restart jenkins
```

### Can't Find Initial Admin Password

```bash
# Manually retrieve the password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Docker Permission Denied

```bash
# Verify Jenkins user is in docker group
groups jenkins

# If not in docker group, run:
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## 📊 Post-Installation Checklist

After running the playbook, verify:

- [ ] SSH connection to Jenkins server works
- [ ] Ansible playbook completed successfully
- [ ] Docker is installed and running
- [ ] Jenkins is running on port 8080
- [ ] kubectl is installed
- [ ] AWS CLI is installed
- [ ] Jenkins initial admin password retrieved
- [ ] Jenkins UI is accessible from browser
- [ ] Jenkins setup wizard completed
- [ ] First admin user created

## 🔐 Security Notes

1. **SSH Key Security**
   - Keep your private key secure
   - Never commit private keys to Git
   - Use proper file permissions

2. **Jenkins Security**
   - Change the default admin password immediately
   - Enable security features in Jenkins
   - Use HTTPS in production (not configured in this phase)

3. **AWS Credentials**
   - Don't hardcode AWS credentials
   - Use IAM roles (already configured via Terraform)
   - The Jenkins EC2 instance has an IAM role attached

## 📚 Next Steps

After Phase 3 is complete:

1. ✅ Jenkins is fully configured
2. ✅ All necessary tools are installed
3. 🚀 Ready for Phase 4: CI/CD Pipeline
   - Create Jenkinsfile
   - Set up GitHub webhooks
   - Configure Jenkins jobs
   - Deploy to EKS

## 🆘 Need Help?

If you encounter issues:

1. Check the Troubleshooting section above
2. Review the Ansible playbook output for errors
3. Check AWS Console for EC2 instance status
4. Verify security group rules in AWS
5. Check Jenkins logs: `sudo journalctl -u jenkins -f`

## 📖 Additional Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Docker Documentation](https://docs.docker.com/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)

---

**Phase 3 Complete!** 🎉 Your Jenkins server is now fully configured and ready for CI/CD pipeline setup.
