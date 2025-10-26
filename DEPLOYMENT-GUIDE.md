# Deployment Guide - Phase 4

Complete guide for deploying the URL Shortener application to AWS EKS using Jenkins CI/CD pipeline.

---

## Table of Contents

1. [Prerequisites Checklist](#prerequisites-checklist)
2. [Pre-Deployment Steps](#pre-deployment-steps)
3. [Deploy Application](#deploy-application)
4. [Verify Deployment](#verify-deployment)
5. [Access Application](#access-application)
6. [Monitoring & Logs](#monitoring--logs)
7. [Rollback Procedure](#rollback-procedure)
8. [Scaling](#scaling)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites Checklist

Before deploying, ensure you have completed:

- [x] **Phase 1**: Local development environment set up
- [x] **Phase 2**: AWS infrastructure provisioned with Terraform
- [x] **Phase 3**: Jenkins server configured with Ansible
- [x] **Phase 4 Setup**: Jenkins configured (see JENKINS-SETUP.md)
- [x] **GitHub Repo**: Code pushed to GitHub repository
- [x] **Jenkins Pipeline**: Pipeline job created and configured

### Verify Infrastructure

```powershell
# PowerShell - from d:\devops-url-shortener\terraform
cd d:\devops-url-shortener\terraform

# Check all resources are created
terraform output
```

Expected outputs:
- ✅ `ecr_repository_url`
- ✅ `eks_cluster_endpoint`
- ✅ `eks_cluster_name`
- ✅ `docdb_cluster_endpoint`
- ✅ `docdb_secret_name`
- ✅ `jenkins_public_ip`

---

## Pre-Deployment Steps

### 1. Update Jenkinsfile with Your Values

Edit `d:\devops-url-shortener\Jenkinsfile`:

```groovy
environment {
    AWS_REGION = 'us-east-1'  // ← Your region
    AWS_ACCOUNT_ID = credentials('aws-account-id')
    
    // Get this from: terraform output ecr_repository_url
    ECR_REPOSITORY_URL = "<YOUR_ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/url-shortener"
    
    // Get this from: terraform output eks_cluster_name  
    EKS_CLUSTER_NAME = '<YOUR_EKS_CLUSTER_NAME>'
    
    // Get this from: terraform output docdb_secret_name
    DB_SECRET_NAME = '<YOUR_DB_SECRET_NAME>'
    
    KUBE_NAMESPACE = 'default'
}
```

**How to get values:**

```powershell
# PowerShell
cd d:\devops-url-shortener\terraform

# Copy these values into Jenkinsfile
terraform output ecr_repository_url
terraform output eks_cluster_name
terraform output docdb_secret_name
```

### 2. Commit Code to GitHub

```powershell
# PowerShell
cd d:\devops-url-shortener

# Stage all Phase 4 files
git add Jenkinsfile
git add k8s/
git add JENKINS-SETUP.md
git add DEPLOYMENT-GUIDE.md

# Commit
git commit -m "Add Phase 4: Kubernetes manifests and Jenkins pipeline"

# Push to GitHub
git push origin main
```

### 3. Verify Jenkins Configuration

Open Jenkins: `http://<JENKINS_PUBLIC_IP>:8080`

Check:
- ✅ AWS credentials configured
- ✅ Pipeline job created (`url-shortener-pipeline`)
- ✅ GitHub webhook configured
- ✅ Docker accessible to Jenkins user

---

## Deploy Application

### Method 1: Automatic Deployment (Webhook)

Simply push code to GitHub:

```powershell
# PowerShell
cd d:\devops-url-shortener

# Make any change
echo "# Deployment $(Get-Date)" >> README.md

git add .
git commit -m "Trigger deployment"
git push origin main
```

Jenkins will automatically:
1. Detect the push (via webhook)
2. Trigger the pipeline
3. Build, push, and deploy

### Method 2: Manual Deployment

1. Open Jenkins: `http://<JENKINS_PUBLIC_IP>:8080`
2. Click on **"url-shortener-pipeline"**
3. Click **"Build Now"** (left sidebar)
4. Watch the pipeline progress in real-time

---

## Verify Deployment

### 1. Monitor Pipeline Execution

In Jenkins:
1. Click on the running build (e.g., `#1`, `#2`)
2. Click **"Console Output"** to see logs
3. Wait for all stages to complete (5-10 minutes)

**Pipeline Stages:**
1. ✅ Checkout - Pull code from GitHub
2. ✅ Build Docker Image - Build container locally
3. ✅ Login to AWS ECR - Authenticate with ECR
4. ✅ Push Docker Image - Upload to ECR
5. ✅ Fetch Database Credentials - Get from Secrets Manager
6. ✅ Deploy to EKS - Apply manifests, create secret, deploy

### 2. Check Kubernetes Resources

SSH into Jenkins server (or use any machine with kubectl configured):

```bash
# SSH into Jenkins
ssh -i <your-key.pem> ubuntu@<JENKINS_PUBLIC_IP>

# Configure kubectl (if not already done)
aws eks update-kubeconfig --region us-east-1 --name <EKS_CLUSTER_NAME>

# Verify connection
kubectl cluster-info
kubectl get nodes
```

**Check Deployment:**

```bash
# Get deployment status
kubectl get deployments
kubectl describe deployment url-shortener-deployment

# Should show:
# NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
# url-shortener-deployment    2/2     2            2           5m
```

**Check Pods:**

```bash
# Get pod status
kubectl get pods -l app=url-shortener -o wide

# Should show 2 pods in "Running" state:
# NAME                                         READY   STATUS    RESTARTS   AGE
# url-shortener-deployment-xxxxxxxxx-xxxxx     1/1     Running   0          5m
# url-shortener-deployment-xxxxxxxxx-xxxxx     1/1     Running   0          5m
```

**Check Service:**

```bash
# Get service and Load Balancer
kubectl get service url-shortener-service

# Should show:
# NAME                    TYPE           CLUSTER-IP      EXTERNAL-IP                                                              PORT(S)        AGE
# url-shortener-service   LoadBalancer   10.100.xx.xx    a1b2c3d4e5f6g7h8i9j0.us-east-1.elb.amazonaws.com   80:31234/TCP   5m
```

**Important**: The `EXTERNAL-IP` is your Load Balancer DNS. It may show `<pending>` for 3-5 minutes while AWS provisions it.

### 3. Check Pod Logs

```bash
# Get logs from one pod
kubectl logs -l app=url-shortener --tail=50

# Follow logs in real-time
kubectl logs -l app=url-shortener --tail=50 -f

# Check for errors
kubectl logs -l app=url-shortener | grep -i error
```

**Healthy logs should show:**
```
Server is running on port 8001
MongoDB connected successfully
```

**If you see connection errors:**
```
MongoNetworkError: failed to connect to server
```
See [Troubleshooting](#troubleshooting) section.

---

## Access Application

### 1. Get Load Balancer URL

```bash
# Method 1: kubectl
kubectl get service url-shortener-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Method 2: AWS Console
# Go to EC2 → Load Balancers → Find the NLB created by Kubernetes
```

You'll get a URL like:
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4-0123456789abcdef.elb.us-east-1.amazonaws.com
```

### 2. Test Application

Open in browser:
```
http://<LOAD_BALANCER_DNS>/
```

You should see the URL Shortener homepage!

### 3. Test Functionality

**Shorten a URL:**
1. Enter a long URL: `https://www.example.com/very/long/path/to/resource`
2. Click **"Shorten URL"**
3. You'll get a short URL: `http://<LOAD_BALANCER_DNS>/abc123`

**Access Short URL:**
1. Click the short URL or paste in browser
2. You should be redirected to the original long URL

### 4. Test Health Endpoint

```bash
# Health check endpoint
curl http://<LOAD_BALANCER_DNS>/health

# Should return:
# {"status":"ok"}
```

### 5. Test Load Balancing

You have 2 pods running. Test that traffic is distributed:

```bash
# Make multiple requests
for i in {1..10}; do
  curl -s http://<LOAD_BALANCER_DNS>/health | jq .
done

# Check logs from both pods to see requests distributed
kubectl logs -l app=url-shortener --tail=20
```

---

## Monitoring & Logs

### Application Logs

```bash
# All pods
kubectl logs -l app=url-shortener --tail=100

# Specific pod
kubectl logs <POD_NAME> --tail=100

# Follow logs
kubectl logs -l app=url-shortener -f

# Previous pod instance (if crashed)
kubectl logs <POD_NAME> --previous
```

### Pod Events

```bash
# Describe pod (shows events)
kubectl describe pod <POD_NAME>

# Get events for all pods
kubectl get events --field-selector involvedObject.kind=Pod --sort-by='.metadata.creationTimestamp'
```

### Resource Usage

```bash
# CPU and memory usage
kubectl top pods -l app=url-shortener

# Node resource usage
kubectl top nodes
```

### Service Status

```bash
# Describe service
kubectl describe service url-shortener-service

# Get endpoints (pod IPs)
kubectl get endpoints url-shortener-service
```

### Database Connection

```bash
# Check if pods can reach database
kubectl exec -it <POD_NAME> -- /bin/sh

# Inside pod:
nc -zv <DOCDB_HOST> 27017
env | grep MONGO
exit
```

---

## Rollback Procedure

### Rollback to Previous Version

If something goes wrong with a deployment:

```bash
# Check rollout history
kubectl rollout history deployment/url-shortener-deployment

# Rollback to previous revision
kubectl rollout undo deployment/url-shortener-deployment

# Rollback to specific revision
kubectl rollout undo deployment/url-shortener-deployment --to-revision=2

# Check rollback status
kubectl rollout status deployment/url-shortener-deployment
```

### Manual Rollback (Specific Image)

```bash
# Set image to previous build
kubectl set image deployment/url-shortener-deployment \
  url-shortener=<ECR_URL>:42

# Where 42 is a previous build number
```

---

## Scaling

### Manual Scaling

```bash
# Scale to 3 replicas
kubectl scale deployment url-shortener-deployment --replicas=3

# Verify
kubectl get pods -l app=url-shortener
```

### Auto-Scaling (Horizontal Pod Autoscaler)

Create HPA based on CPU usage:

```bash
# Create HPA
kubectl autoscale deployment url-shortener-deployment \
  --cpu-percent=70 \
  --min=2 \
  --max=10

# Check HPA status
kubectl get hpa
kubectl describe hpa url-shortener-deployment
```

**Example HPA manifest** (`k8s/hpa.yml`):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: url-shortener-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: url-shortener-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

Apply:
```bash
kubectl apply -f k8s/hpa.yml
```

---

## Troubleshooting

### Issue 1: Pods Stuck in "Pending"

**Symptoms:**
```bash
kubectl get pods
# NAME                                    READY   STATUS    RESTARTS   AGE
# url-shortener-deployment-xxx-xxx        0/1     Pending   0          2m
```

**Diagnose:**
```bash
kubectl describe pod <POD_NAME>
# Look for events like:
# - "Insufficient cpu"
# - "Insufficient memory"
# - "No nodes are available"
```

**Solutions:**
- **Insufficient resources**: Scale down replicas or increase node size
- **No nodes**: Check EKS node group is running
  ```bash
  kubectl get nodes
  aws eks describe-nodegroup --cluster-name <CLUSTER> --nodegroup-name <NODEGROUP>
  ```

---

### Issue 2: Pods Stuck in "ImagePullBackOff"

**Symptoms:**
```bash
kubectl get pods
# NAME                                    READY   STATUS             RESTARTS   AGE
# url-shortener-deployment-xxx-xxx        0/1     ImagePullBackOff   0          2m
```

**Diagnose:**
```bash
kubectl describe pod <POD_NAME>
# Look for:
# - "Failed to pull image"
# - "unauthorized: authentication required"
```

**Solutions:**

1. **Check ECR image exists:**
   ```bash
   aws ecr describe-images --repository-name url-shortener --region us-east-1
   ```

2. **Verify EKS has permission to pull from ECR:**
   - EKS node IAM role should have `AmazonEC2ContainerRegistryReadOnly` policy
   - Check in Terraform outputs or AWS Console

3. **Check image name in deployment:**
   ```bash
   kubectl get deployment url-shortener-deployment -o jsonpath='{.spec.template.spec.containers[0].image}'
   ```
   Should match ECR URL format

---

### Issue 3: Pods Running but Crashing (CrashLoopBackOff)

**Symptoms:**
```bash
kubectl get pods
# NAME                                    READY   STATUS             RESTARTS   AGE
# url-shortener-deployment-xxx-xxx        0/1     CrashLoopBackOff   5          5m
```

**Diagnose:**
```bash
# Check logs
kubectl logs <POD_NAME>

# Check previous instance logs
kubectl logs <POD_NAME> --previous
```

**Common causes:**

1. **Database connection failed:**
   ```
   MongoNetworkError: failed to connect to server
   ```
   - Check DocumentDB security group allows traffic from EKS nodes
   - Verify connection string is correct
   - Check secret is created: `kubectl get secret docdb-secret`

2. **Missing environment variables:**
   ```
   Error: MONGO_URL is not defined
   ```
   - Verify secret exists and has correct keys
   - Check deployment.yml has correct secretKeyRef

3. **Application error:**
   - Check logs for stack traces
   - Verify code is working (test locally with Docker)

---

### Issue 4: Load Balancer Stuck in "Pending"

**Symptoms:**
```bash
kubectl get service url-shortener-service
# EXTERNAL-IP shows <pending> for > 5 minutes
```

**Diagnose:**
```bash
kubectl describe service url-shortener-service
# Look for events/warnings
```

**Solutions:**

1. **Check VPC subnet tags:**
   EKS requires specific tags on subnets for Load Balancer provisioning.
   
   Public subnets need:
   ```
   kubernetes.io/role/elb = 1
   ```
   
   Terraform should have added these (check `vpc.tf`).

2. **Check AWS Load Balancer Controller:**
   ```bash
   # Install if not present (should be automatic in EKS 1.30)
   kubectl get deployment -n kube-system aws-load-balancer-controller
   ```

3. **Check service controller logs:**
   ```bash
   kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
   ```

4. **Verify security groups:**
   - EKS nodes security group should allow inbound from Load Balancer
   - Load Balancer security group should allow inbound from internet (0.0.0.0/0:80)

---

### Issue 5: Application Accessible but Database Errors

**Symptoms:**
- Application loads but can't create/retrieve URLs
- Logs show: `MongoError: connection timeout`

**Diagnose:**
```bash
# Check if pods can reach DocumentDB
kubectl exec -it <POD_NAME> -- /bin/sh
nc -zv <DOCDB_HOST> 27017
```

**Solutions:**

1. **Check DocumentDB security group:**
   ```bash
   # Get security group ID from Terraform
   terraform output docdb_security_group_id
   
   # Verify it allows inbound from EKS nodes on port 27017
   aws ec2 describe-security-groups --group-ids <SG_ID>
   ```

2. **Verify secret values:**
   ```bash
   # Get secret
   kubectl get secret docdb-secret -o yaml
   
   # Decode values (base64)
   kubectl get secret docdb-secret -o jsonpath='{.data.connection-string}' | base64 -d
   ```

3. **Check DocumentDB cluster status:**
   ```bash
   aws docdb describe-db-clusters --db-cluster-identifier <CLUSTER_ID>
   # Status should be "available"
   ```

4. **Test connection from Jenkins (has network access):**
   ```bash
   # SSH to Jenkins
   ssh ubuntu@<JENKINS_IP>
   
   # Install mongo shell (if needed)
   wget https://repo.mongodb.org/apt/ubuntu/dists/focal/mongodb-org/5.0/multiverse/binary-amd64/mongodb-mongosh_1.10.6_amd64.deb
   sudo dpkg -i mongodb-mongosh_1.10.6_amd64.deb
   
   # Test connection
   mongosh "mongodb://<USERNAME>:<PASSWORD>@<DOCDB_HOST>:27017/?tls=true&replicaSet=rs0"
   ```

---

### Issue 6: "Unauthorized" Errors in Jenkins Pipeline

**Stage:** Login to AWS ECR or Deploy to EKS

**Error:**
```
error: You must be logged in to the server (Unauthorized)
```

**Solutions:**

1. **Verify AWS credentials in Jenkins:**
   - Go to Jenkins → Manage Credentials
   - Check `aws-credentials` exists
   - Verify Access Key and Secret Key are correct

2. **Verify IAM permissions:**
   ```bash
   # On Jenkins server
   aws sts get-caller-identity
   
   # Test ECR access
   aws ecr describe-repositories --region us-east-1
   
   # Test EKS access
   aws eks describe-cluster --name <CLUSTER_NAME> --region us-east-1
   ```

3. **Update kubeconfig:**
   ```bash
   # On Jenkins server
   aws eks update-kubeconfig --region us-east-1 --name <CLUSTER_NAME>
   kubectl cluster-info
   ```

---

## Post-Deployment Checklist

After successful deployment:

- [ ] Application accessible via Load Balancer URL
- [ ] Can create short URLs
- [ ] Can access short URLs (redirects work)
- [ ] Health endpoint returns `{"status":"ok"}`
- [ ] Both pods are running and healthy
- [ ] Database connection working (no errors in logs)
- [ ] Jenkins pipeline passes all stages
- [ ] GitHub webhook triggering builds
- [ ] Rollback tested (optional but recommended)

---

## Clean Up (When Done)

To avoid AWS charges:

### 1. Delete Kubernetes Resources

```bash
kubectl delete -f k8s/service.yml
kubectl delete -f k8s/deployment.yml
kubectl delete secret docdb-secret
```

### 2. Destroy Terraform Infrastructure

```powershell
# PowerShell
cd d:\devops-url-shortener\terraform

terraform destroy

# Type "yes" when prompted
```

This will delete:
- EKS cluster
- ECR repository
- DocumentDB cluster
- Jenkins EC2 instance
- VPC and all networking
- S3 bucket (if empty)

---

## Next Steps

Congratulations! You've successfully deployed a production-ready URL Shortener with full CI/CD automation! 🎉

**Optional Enhancements:**

1. **Custom Domain Name**
   - Register domain in Route 53
   - Create CNAME record pointing to Load Balancer
   - Add SSL certificate (AWS Certificate Manager)

2. **HTTPS/SSL**
   - Create ACM certificate
   - Update service to use HTTPS Load Balancer
   - Redirect HTTP → HTTPS

3. **Monitoring & Alerts**
   - Set up CloudWatch dashboards
   - Configure alarms for pod crashes, high CPU, errors
   - Integrate with Slack/email notifications

4. **Backup & Disaster Recovery**
   - Enable DocumentDB automated backups
   - Create snapshot schedule
   - Document restore procedure

5. **Security Hardening**
   - Enable network policies in Kubernetes
   - Scan Docker images for vulnerabilities
   - Implement secrets rotation
   - Use AWS WAF with Load Balancer

---

**Phase 4 Complete!** 🚀

You now have a fully automated, production-grade DevOps pipeline!
