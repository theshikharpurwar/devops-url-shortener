# GitHub Setup Script for URL Shortener Project
# Run this script from D:\devops-url-shortener directory

Write-Host "`n🚀 GitHub Setup for URL Shortener Project`n" -ForegroundColor Cyan

# Step 1: Check if we're in the right directory
$currentDir = Get-Location
if ($currentDir.Path -ne "D:\devops-url-shortener") {
    Write-Host "❌ Please run this script from D:\devops-url-shortener directory" -ForegroundColor Red
    Write-Host "Current directory: $currentDir" -ForegroundColor Yellow
    exit 1
}

# Step 2: Check if git is installed
try {
    git --version | Out-Null
    Write-Host "✅ Git is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Git is not installed. Please install Git first: https://git-scm.com/download/win" -ForegroundColor Red
    exit 1
}

# Step 3: Check if .gitignore exists, create if not
if (-not (Test-Path ".gitignore")) {
    Write-Host "📝 Creating .gitignore file..." -ForegroundColor Yellow
    
    @"
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
terraform/*.log

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
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
    
    Write-Host "✅ .gitignore created" -ForegroundColor Green
}

# Step 4: Initialize git if not already done
if (-not (Test-Path ".git")) {
    Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
} else {
    Write-Host "✅ Git repository already exists" -ForegroundColor Green
}

# Step 5: Configure git user (if not configured)
$gitUserName = git config user.name
$gitUserEmail = git config user.email

if (-not $gitUserName) {
    $userName = Read-Host "Enter your GitHub username"
    git config user.name "$userName"
    Write-Host "✅ Git user name configured: $userName" -ForegroundColor Green
}

if (-not $gitUserEmail) {
    $userEmail = Read-Host "Enter your GitHub email"
    git config user.email "$userEmail"
    Write-Host "✅ Git user email configured: $userEmail" -ForegroundColor Green
}

# Step 6: Add all files
Write-Host "`n📝 Adding files to git..." -ForegroundColor Yellow
git add .

# Step 7: Show what will be committed
Write-Host "`n📋 Files to be committed:" -ForegroundColor Cyan
git status

# Step 8: Create initial commit
Write-Host "`n💾 Creating initial commit..." -ForegroundColor Yellow
git commit -m "Initial commit: DevOps URL Shortener with simplified Docker deployment"

Write-Host "✅ Initial commit created" -ForegroundColor Green

# Step 9: Instructions for creating GitHub repository
Write-Host "`n" -NoNewline
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "📚 Next Steps:" -ForegroundColor Cyan
Write-Host "=" -ForegroundColor Cyan -NoNewline
Write-Host "=" * 80 -ForegroundColor Cyan

Write-Host "`n1️⃣  Go to GitHub and create a new repository:" -ForegroundColor Yellow
Write-Host "   https://github.com/new" -ForegroundColor White

Write-Host "`n2️⃣  Repository settings:" -ForegroundColor Yellow
Write-Host "   - Name: devops-url-shortener" -ForegroundColor White
Write-Host "   - Description: DevOps URL Shortener with CI/CD pipeline" -ForegroundColor White
Write-Host "   - Visibility: Public or Private (your choice)" -ForegroundColor White
Write-Host "   - ❌ DO NOT initialize with README, .gitignore, or license" -ForegroundColor Red

Write-Host "`n3️⃣  After creating the repository, copy the repository URL" -ForegroundColor Yellow
Write-Host "   Format: https://github.com/YOUR_USERNAME/devops-url-shortener.git" -ForegroundColor White

$repoUrl = Read-Host "`n📎 Paste your GitHub repository URL here"

if ($repoUrl) {
    Write-Host "`n🔗 Adding remote origin..." -ForegroundColor Yellow
    git remote add origin $repoUrl
    Write-Host "✅ Remote origin added" -ForegroundColor Green
    
    Write-Host "`n🚀 Pushing to GitHub..." -ForegroundColor Yellow
    git branch -M main
    git push -u origin main
    
    Write-Host "`n" -NoNewline
    Write-Host "=" -ForegroundColor Green -NoNewline
    Write-Host "=" * 80 -ForegroundColor Green
    Write-Host "🎉 SUCCESS! Code pushed to GitHub!" -ForegroundColor Green
    Write-Host "=" -ForegroundColor Green -NoNewline
    Write-Host "=" * 80 -ForegroundColor Green
    
    Write-Host "`n✅ Your repository: $repoUrl" -ForegroundColor Cyan
    Write-Host "✅ Branch: main" -ForegroundColor Cyan
    Write-Host "`n📋 Next: Configure Jenkins to use this repository!" -ForegroundColor Yellow
} else {
    Write-Host "`n⚠️  No repository URL provided. You can add it manually later:" -ForegroundColor Yellow
    Write-Host "   git remote add origin YOUR_REPO_URL" -ForegroundColor White
    Write-Host "   git branch -M main" -ForegroundColor White
    Write-Host "   git push -u origin main" -ForegroundColor White
}

Write-Host "`n✨ Done!`n" -ForegroundColor Green
