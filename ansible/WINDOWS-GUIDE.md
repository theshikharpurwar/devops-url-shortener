# 🪟 Windows User Guide - Phase 3: Ansible

## Complete Step-by-Step Guide for Windows Users (Without WSL 2)

Since you're running Windows without WSL 2, this guide walks you through configuring the Jenkins server by SSH-ing into it and running Ansible locally on the EC2 instance.

---

## 📋 Prerequisites

Before starting, ensure you have:

1. ✅ **Phase 2 Completed** - Terraform infrastructure is deployed
2. ✅ **Jenkins Public IP** - From `terraform output jenkins_public_ip`
3. ✅ **SSH Private Key** - Located at `C:\Users\YourUsername\.ssh\id_rsa`
4. ✅ **GitHub Repository** - Your code is pushed to GitHub
5. ✅ **Windows PowerShell** or **Command Prompt** or **PuTTY**

---

## 🚀 Execution Steps

### Step 1: Get Your Jenkins Server IP Address

Open **PowerShell** on Windows:

```powershell
# Navigate to your project terraform directory
cd D:\devops-url-shortener\terraform

# Get the Jenkins public IP
terraform output jenkins_public_ip
```

**Example Output:**
```
"54.123.45.67"
```

**📝 Write down this IP address!** You'll use it throughout this guide.

---

### Step 2: Connect to Jenkins Server via SSH

#### Option A: Using PowerShell (Recommended for Windows 10/11)

```powershell
# SSH command format:
# ssh -i PATH_TO_PRIVATE_KEY ubuntu@JENKINS_PUBLIC_IP

# Example:
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67
```

**First-time connection:**
- You'll see: `The authenticity of host '54.123.45.67' can't be established.`
- Type: `yes` and press Enter

**If you get "WARNING: UNPROTECTED PRIVATE KEY FILE":**

1. Right-click on `id_rsa` file
2. Properties → Security → Advanced
3. Click "Disable inheritance"
4. Remove all users except your account
5. Give your account "Full control"
6. Click OK

#### Option B: Using PuTTY (Alternative Method)

**Step 2.1: Install PuTTY**

Download from: https://www.putty.org/

**Step 2.2: Convert .pem Key (if needed)**

If you have a `.pem` file instead of `id_rsa`:

1. Open **PuTTYgen** (installed with PuTTY)
2. Click "Load"
3. Select your `.pem` file (change file type to "All Files")
4. Click "Save private key"
5. Save as `jenkins-key.ppk`

**Step 2.3: Connect with PuTTY**

1. Open **PuTTY**
2. **Host Name:** `ubuntu@54.123.45.67` (your actual IP)
3. **Port:** `22`
4. **Connection type:** `SSH`
5. Left menu: **Connection → SSH → Auth**
6. **Private key file:** Browse to your `.ppk` file
7. Click **Open**
8. Click **Yes** if prompted about server key

---

### Step 3: You're Now Inside the Jenkins Server!

You should see a prompt like:

```
ubuntu@ip-10-0-101-45:~$
```

This means you're successfully connected to the Jenkins EC2 instance.

---

### Step 4: Install Ansible and Git

Run these commands inside the SSH session:

```bash
# Update package lists
sudo apt update

# Install Ansible and Git
sudo apt install ansible git -y
```

**Expected output:**
```
Reading package lists... Done
Building dependency tree... Done
...
ansible is already the newest version
git is already the newest version
```

**Verify installation:**

```bash
# Check Ansible
ansible --version

# Check Git
git --version
```

---

### Step 5: Clone Your GitHub Repository

```bash
# Clone your repository (replace with your actual repo URL)
git clone https://github.com/YOUR_USERNAME/devops-url-shortener.git

# Example:
# git clone https://github.com/johndoe/devops-url-shortener.git
```

**If your repo is private:**

GitHub will prompt for credentials:

```
Username: your-github-username
Password: [Use Personal Access Token, NOT your password]
```

**How to create a Personal Access Token:**
1. Go to GitHub.com → Settings → Developer settings
2. Personal access tokens → Tokens (classic)
3. Generate new token
4. Select scopes: `repo` (full control)
5. Generate and copy the token
6. Use this token as the password when cloning

**Navigate to the repository:**

```bash
cd devops-url-shortener
ls -la
```

You should see:
```
ansible/
terraform/
src/
views/
Dockerfile
docker-compose.yml
...
```

---

### Step 6: Navigate to Ansible Directory

```bash
cd ansible
ls -la
```

You should see:
```
playbook-jenkins.yml
README.md
WINDOWS-GUIDE.md
```

---

### Step 7: Run the Ansible Playbook

```bash
# Execute the playbook
ansible-playbook playbook-jenkins.yml
```

**What happens:**

The playbook will run for approximately **5-10 minutes** and perform these tasks:

1. ✅ Update apt cache
2. ✅ Install Java 17
3. ✅ Install Docker
4. ✅ Install Jenkins
5. ✅ Install kubectl
6. ✅ Install AWS CLI
7. ✅ Configure permissions
8. ✅ Display Jenkins initial admin password

**You'll see output like:**

```
PLAY [Configure Jenkins CI/CD Server] *********************************

TASK [Gathering Facts] *************************************************
ok: [localhost]

TASK [Update apt cache] ************************************************
changed: [localhost]

TASK [Install prerequisite packages] ***********************************
changed: [localhost]

...
(many more tasks)
...

TASK [Display Jenkins initial admin password] **************************
ok: [localhost] => {
    "msg": [
        "========================================",
        "🎉 JENKINS CONFIGURATION COMPLETE! 🎉",
        "========================================",
        "",
        "Jenkins Initial Admin Password:",
        "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6",
        "",
        "Access Jenkins at:",
        "http://54.123.45.67:8080",
        "",
        "========================================",
        "SAVE THIS PASSWORD - You'll need it for first-time setup!",
        "========================================"
    ]
}

PLAY RECAP *************************************************************
localhost : ok=30  changed=20  unreachable=0  failed=0  skipped=2
```

**🚨 IMPORTANT: Copy and save the Jenkins initial admin password!**

Example password: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`

---

### Step 8: Verify Installation (Optional but Recommended)

While still connected via SSH:

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

All commands should work without errors.

---

### Step 9: Log Out of SSH Session

```bash
# Exit the SSH connection
exit
```

You'll be returned to your Windows PowerShell/Command Prompt.

---

## 🌐 Access Jenkins from Your Windows Browser

### Step 1: Open Jenkins UI

On your **Windows machine**, open your web browser (Chrome, Edge, Firefox):

```
http://54.123.45.67:8080
```

*(Replace with your actual Jenkins IP)*

### Step 2: Unlock Jenkins

You'll see the **"Unlock Jenkins"** page.

1. Paste the **initial admin password** from Step 7
2. Click **Continue**

### Step 3: Install Plugins

Choose **"Install suggested plugins"** (recommended)

Jenkins will install common plugins automatically (~3-5 minutes).

### Step 4: Create First Admin User

Fill in the form:

- **Username:** `admin` (or your choice)
- **Password:** Choose a strong password
- **Confirm password:** Same password
- **Full name:** Your name
- **Email:** Your email address

Click **Save and Continue**

### Step 5: Instance Configuration

- **Jenkins URL:** `http://54.123.45.67:8080` (keep the default)
- Click **Save and Finish**

### Step 6: Start Using Jenkins!

Click **"Start using Jenkins"**

🎉 **Congratulations! Jenkins is now fully configured!**

---

## ✅ Verification Checklist

Make sure all of these are complete:

- [ ] SSH connection to Jenkins server successful
- [ ] Ansible and Git installed on Jenkins server
- [ ] GitHub repository cloned
- [ ] Ansible playbook executed successfully
- [ ] Jenkins initial admin password saved
- [ ] Jenkins UI accessible at `http://JENKINS_IP:8080`
- [ ] Jenkins unlocked with initial password
- [ ] Suggested plugins installed
- [ ] First admin user created
- [ ] Jenkins dashboard is visible

---

## 🐛 Troubleshooting

### Problem: SSH connection times out

**Solution:**

```powershell
# Check your current public IP
curl https://api.ipify.org

# If your IP changed, update Terraform
cd D:\devops-url-shortener\terraform
# Edit terraform.tfvars and update jenkins_allowed_ip
terraform apply
```

### Problem: "Permission denied (publickey)"

**Solution:**

Make sure you're using the correct private key:

```powershell
# Verify key exists
dir C:\Users\YourUsername\.ssh\id_rsa

# Use full path in SSH command
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67
```

### Problem: PuTTY shows "Network error: Connection timed out"

**Solution:**

1. Check security group in AWS Console
2. Verify inbound rule for port 22 from your IP
3. Verify Jenkins instance is running
4. Try using PowerShell method instead

### Problem: Ansible playbook fails

**Solution:**

```bash
# Run with verbose output
ansible-playbook playbook-jenkins.yml -vvv

# Check if you have sudo privileges
sudo -l
```

### Problem: Can't access Jenkins UI

**Solution:**

```bash
# SSH back into Jenkins server
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67

# Check Jenkins status
sudo systemctl status jenkins

# If stopped, start it
sudo systemctl start jenkins

# Check firewall (should be open)
sudo ufw status
```

### Problem: Forgot to save initial password

**Solution:**

```bash
# SSH into Jenkins server
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67

# Retrieve password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Copy the password
exit
```

---

## 🎯 Next Steps

Now that Phase 3 is complete, you're ready for **Phase 4: CI/CD Pipeline**!

In Phase 4, you'll:

1. Create Kubernetes deployment files
2. Write a Jenkinsfile for the CI/CD pipeline
3. Configure Jenkins jobs
4. Set up GitHub webhooks
5. Deploy the URL shortener to EKS

---

## 📞 Quick Reference Commands

### Get Jenkins IP
```powershell
cd D:\devops-url-shortener\terraform
terraform output jenkins_public_ip
```

### SSH to Jenkins
```powershell
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@JENKINS_IP
```

### Retrieve Initial Password
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

### Restart Jenkins
```bash
sudo systemctl restart jenkins
```

### Check Jenkins Status
```bash
sudo systemctl status jenkins
```

---

**Phase 3 Complete!** ✅ Your Jenkins server is fully configured and accessible from Windows. You're ready for the CI/CD pipeline! 🚀
