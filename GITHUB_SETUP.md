# 📦 Push Code to GitHub - Step by Step Guide

## Prerequisites
- Git installed on your machine
- GitHub account

---

## Step 1: Initialize Git Repository (if not already done)

```powershell
cd D:\devops-url-shortener
git init
```

---

## Step 2: Create .gitignore File

Make sure you have a `.gitignore` file to exclude sensitive files:

```
# Node modules
node_modules/
npm-debug.log*

# Environment variables
.env
.env.local
.env.*.local

# Terraform
terraform/.terraform/
terraform/*.tfstate
terraform/*.tfstate.backup
terraform/.terraform.lock.hcl
terraform/terraform.tfvars

# SSH Keys
*.pem
*.key
.ssh/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Build outputs
dist/
build/
