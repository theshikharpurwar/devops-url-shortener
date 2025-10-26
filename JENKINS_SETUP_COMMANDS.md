# 🚀 Jenkins Setup Commands (Run in AWS Session Manager Terminal)

## Step 1: Verify User Data Script Completed ✅
```bash
# Check if setup is complete
sudo cat /var/log/user-data-complete.txt

# Check cloud-init status
cloud-init status
```

Expected output: `status: done`

---

## Step 2: Verify Docker Installation ✅
```bash
# Check Docker version
docker --version

# Check Docker Compose version
docker-compose --version

# Check Docker service status
sudo systemctl status docker

# Test Docker (optional)
docker ps
```

Expected: Docker 27.x and Docker Compose 2.x installed

---

## Step 3: Switch to Ubuntu User (Important!)
```bash
# SSM connects as ssm-user, switch to ubuntu
sudo su - ubuntu
```

---

## Step 4: Install Jenkins using Docker 🎯
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
  --user root \
  jenkins/jenkins:lts

# Wait ~30 seconds for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30
```

---

## Step 5: Get Jenkins Initial Admin Password 🔑
```bash
# Get the initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Copy this password!** You'll need it to access Jenkins UI.

---

## Step 6: Check Jenkins Container Status
```bash
# Verify Jenkins is running
docker ps

# Check Jenkins logs (optional)
docker logs jenkins --tail 50
```

---

## Step 7: Install Docker CLI inside Jenkins Container (for CI/CD)
```bash
# Install Docker inside Jenkins container for pipeline builds
docker exec -u root jenkins bash -c "
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release && \
  curl -fsSL https://get.docker.com -o get-docker.sh && \
  sh get-docker.sh && \
  usermod -aG docker jenkins
"

# Restart Jenkins to apply changes
docker restart jenkins

# Wait for restart
sleep 30
```

---

## Step 8: Verify ECR Access (AWS Credentials)
```bash
# Test AWS CLI (should work via IAM instance role)
aws sts get-caller-identity

# Test ECR login
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 094822715133.dkr.ecr.us-east-1.amazonaws.com
```

Expected: Login Succeeded

---

## 🎉 Next Steps

1. **Access Jenkins UI**: Open http://98.84.35.193:8080 in your browser
2. **Unlock Jenkins**: Paste the initial admin password you copied
3. **Install Plugins**: Select "Install suggested plugins"
4. **Create Admin User**: Set up your admin account
5. **Start Using Jenkins**: Create your first pipeline!

---

## 📝 Quick Reference

| Item | Value |
|------|-------|
| Jenkins UI | http://98.84.35.193:8080 |
| ECR Repository | 094822715133.dkr.ecr.us-east-1.amazonaws.com/url-shortener-api |
| Jenkins Container | `docker ps` to see status |
| Jenkins Logs | `docker logs jenkins` |
| Restart Jenkins | `docker restart jenkins` |

---

## 🔧 Troubleshooting

### Jenkins not starting?
```bash
docker logs jenkins
```

### Permission denied errors?
```bash
# Make sure you're running as ubuntu user
whoami  # should show "ubuntu"

# Fix permissions
sudo chown -R 1000:1000 ~/jenkins_home
```

### Can't access Jenkins UI?
```bash
# Check if Jenkins is listening
docker exec jenkins netstat -tuln | grep 8080

# Check security group allows port 8080
curl -I http://localhost:8080
```
