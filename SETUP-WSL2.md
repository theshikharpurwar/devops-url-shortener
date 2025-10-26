# WSL 2 Setup Guide for Windows 11

## Prerequisites Check

This guide will help you set up your Windows 11 machine for local development using WSL 2, Docker Desktop, and VS Code.

---

## Step 1: Enable and Install WSL 2

### Check if WSL is Already Installed
Open **PowerShell** as Administrator and run:
```powershell
wsl --status
```

If WSL is installed, you'll see version information. If not, proceed with installation.

### Install WSL 2
1. Open **PowerShell** as Administrator
2. Run the following command:
```powershell
wsl --install
```

3. This will:
   - Enable required Windows features
   - Install the latest Linux kernel
   - Set WSL 2 as default
   - Install Ubuntu as the default distribution

4. **Restart your computer** when prompted

5. After restart, Ubuntu will launch automatically. Create your UNIX username and password.

### Verify WSL 2 is Default
```powershell
wsl --list --verbose
```

You should see:
```
  NAME      STATE           VERSION
* Ubuntu    Running         2
```

If VERSION shows `1`, upgrade it:
```powershell
wsl --set-version Ubuntu 2
wsl --set-default-version 2
```

---

## Step 2: Install Docker Desktop

### Download and Install
1. Download **Docker Desktop for Windows** from: https://www.docker.com/products/docker-desktop/
2. Run the installer
3. **Important**: During installation, ensure "Use WSL 2 instead of Hyper-V" is checked
4. Restart your computer after installation

### Configure Docker Desktop for WSL 2
1. Open **Docker Desktop**
2. Go to **Settings** (gear icon)
3. Navigate to **General**:
   - ✅ Ensure "Use the WSL 2 based engine" is checked
4. Navigate to **Resources** → **WSL Integration**:
   - ✅ Enable "Enable integration with my default WSL distro"
   - ✅ Enable integration with "Ubuntu"
5. Click **Apply & Restart**

### Verify Docker in WSL 2
Open a new WSL 2 terminal (Ubuntu) and run:
```bash
docker --version
docker-compose --version
docker ps
```

All commands should work without errors.

---

## Step 3: Install and Configure VS Code

### Install VS Code
1. Download from: https://code.visualstudio.com/
2. Install on Windows (not inside WSL)

### Install WSL Extension
1. Open VS Code
2. Go to Extensions (Ctrl+Shift+X)
3. Search for **"WSL"** (by Microsoft)
4. Click **Install**

### Install Additional Recommended Extensions
- **Docker** (by Microsoft) - for Docker file support
- **Remote - Containers** (by Microsoft)
- **GitLens** (optional, for advanced Git features)

---

## Step 4: Set Up Your Project in WSL 2

### Access WSL from VS Code
1. Open VS Code
2. Press **F1** or **Ctrl+Shift+P**
3. Type: `WSL: Connect to WSL`
4. A new VS Code window opens connected to WSL

**OR** from your WSL terminal:
```bash
cd ~
mkdir projects
cd projects
code .
```

### Navigate to Your Project Directory
In your WSL terminal inside VS Code:
```bash
cd /mnt/d/devops-url-shortener
```

**Note**: Windows drives are mounted under `/mnt/` in WSL:
- `D:\` becomes `/mnt/d/`
- `C:\` becomes `/mnt/c/`

---

## Step 5: Verify Everything Works

Run these commands in your WSL 2 terminal:

```bash
# Check WSL version
cat /etc/os-release

# Check Docker
docker --version
docker-compose --version

# Check Node.js (we'll install this next if needed)
node --version
npm --version

# Check Git
git --version
```

---

## Installing Node.js in WSL 2 (Recommended for Development)

While we'll run the app in Docker, it's useful to have Node.js installed locally for development:

```bash
# Install Node.js using nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Restart your terminal or run:
source ~/.bashrc

# Install Node.js LTS
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

---

## Quick Troubleshooting

### Issue: Docker commands don't work in WSL
**Solution**: 
- Ensure Docker Desktop is running
- Check WSL Integration in Docker Desktop settings
- Restart Docker Desktop

### Issue: VS Code doesn't connect to WSL
**Solution**:
- Ensure WSL extension is installed
- Try: `wsl --shutdown` in PowerShell, then restart WSL

### Issue: Slow file performance
**Solution**:
- Always work in the Linux filesystem (`~` or `/home/username/`), not in `/mnt/c/` or `/mnt/d/`
- For this project, consider copying it to `~/projects/devops-url-shortener`

---

## ✅ You're Ready!

Once all steps are complete, you can proceed with the project setup. Your development environment is now configured with:
- ✅ WSL 2 (Ubuntu)
- ✅ Docker Desktop with WSL 2 backend
- ✅ VS Code with WSL extension
- ✅ Proper integration between all tools

**Next Step**: Follow the instructions in `README.md` to build and run the URL shortener application locally.
