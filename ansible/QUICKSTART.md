# ⚡ Quick Reference - Phase 3 (Windows)

## 🎯 Goal
Configure Jenkins server using Ansible (running locally on EC2)

## 📋 Prerequisites
- Terraform Phase 2 completed
- Jenkins EC2 public IP
- SSH private key (id_rsa or .pem)
- GitHub repo with code

---

## 🚀 Quick Steps

### 1. Get Jenkins IP (Windows PowerShell)
```powershell
cd D:\devops-url-shortener\terraform
terraform output jenkins_public_ip
# Save the IP (e.g., 54.123.45.67)
```

### 2. SSH to Jenkins (Windows PowerShell)
```powershell
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67
```

### 3. Install Ansible & Git (on EC2)
```bash
sudo apt update
sudo apt install ansible git -y
```

### 4. Clone Repository (on EC2)
```bash
git clone https://github.com/YOUR_USERNAME/devops-url-shortener.git
cd devops-url-shortener/ansible
```

### 5. Run Ansible Playbook (on EC2)
```bash
ansible-playbook playbook-jenkins.yml
# Save the initial admin password shown at the end!
```

### 6. Exit SSH (on EC2)
```bash
exit
```

### 7. Access Jenkins (Windows Browser)
```
http://54.123.45.67:8080
```
- Paste initial admin password
- Install suggested plugins
- Create admin user
- Done! ✅

---

## 🔧 Common Commands

### If Using PuTTY
```
Host: ubuntu@54.123.45.67
Port: 22
Auth: Browse to .ppk file
```

### Retrieve Password Later
```bash
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
exit
```

### Restart Jenkins
```bash
ssh -i C:\Users\YourUsername\.ssh\id_rsa ubuntu@54.123.45.67
sudo systemctl restart jenkins
exit
```

---

## ⏱️ Time Estimate
- SSH setup: 2 minutes
- Ansible installation: 1 minute
- Run playbook: 5-10 minutes
- Jenkins UI setup: 5 minutes
- **Total: ~15-20 minutes**

---

## ✅ Success Criteria
- [ ] SSH connection works
- [ ] Ansible playbook completes successfully
- [ ] Initial password saved
- [ ] Jenkins UI accessible
- [ ] Admin user created
- [ ] Ready for Phase 4

---

**See `WINDOWS-GUIDE.md` for detailed step-by-step instructions**
