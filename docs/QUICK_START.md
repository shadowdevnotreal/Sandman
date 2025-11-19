# Sandman - Quick Start Guide

Get up and running with Sandman in 5 minutes!

---

## What is Sandman?

Sandman is a cross-platform sandbox manager that lets you create isolated environments for testing, development, or running untrusted code safely.

---

## Installation

### Windows

```powershell
# 1. Download or clone Sandman
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# 2. Run setup
.\setup.cmd

# 3. Launch Sandman
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### Linux

```bash
# 1. Download or clone Sandman
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# 2. Run setup
chmod +x setup.sh
./setup.sh

# 3. Launch Sandman
./scripts/sandman.sh
```

### macOS

```bash
# 1. Download or clone Sandman
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# 2. Run setup
chmod +x setup.sh
./setup.sh

# 3. Launch Sandman
./scripts/sandman.sh
```

---

## First Steps

### 1. Create Your First Sandbox

```
Launch Sandman
Press [1] - Create new configuration
Enter name: my-first-sandbox
Memory (MB): 4096
Enable networking? y
Shared folder: (leave empty or specify a path)
```

Your configuration is now saved!

### 2. Launch the Sandbox

```
Press [6] - Launch sandbox
Select your configuration
Sandbox starts!
```

### 3. Modify a Configuration

```
Press [5] - Modify
Select your configuration
Make changes:
  - Change memory
  - Toggle networking
  - Add/remove shared folders
Press [11] - SAVE & EXIT
```

---

## Common Tasks

### Create a Secure Sandbox (No Network)

```
[1] Create new
Name: secure-test
Memory: 2048
Networking: n
Shared folder: (empty)
```

### Create a Development Sandbox

```
[1] Create new
Name: dev-environment
Memory: 8192
Networking: y
Shared folder: /path/to/your/project
Read/Write? y
```

### List All Configurations

```
Press [2] - List configurations
```

### Validate Before Launching

```
Press [4] - Validate & Inspect
Select configuration
Review settings and check for errors
```

---

## Platform-Specific Notes

### Windows
- Requires Windows 10 Pro/Enterprise or Windows 11
- Enable Windows Sandbox feature first
- Uses `.wsb` XML configuration files

### Linux
- Requires Docker or systemd-nspawn
- Uses `.sandbox` INI-style configuration files
- May need to add user to docker group

### macOS
- Requires Docker Desktop for Mac
- Uses `.sandbox` INI-style configuration files
- Some directories may require permissions

---

## Troubleshooting

### Windows: "Windows Sandbox is not available"

**Solution:**
1. Open Settings → Apps → Optional Features
2. Click "More Windows features"
3. Check "Windows Sandbox"
4. Restart computer

### Linux/macOS: "Docker not found"

**Solution:**
```bash
# Linux (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo usermod -aG docker $USER

# macOS
# Install Docker Desktop from:
# https://docs.docker.com/desktop/install/mac-install/
```

### PowerShell Execution Policy Error

**Solution:**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### Permission Denied (Linux)

**Solution:**
```bash
# Add your user to docker group
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

---

## Next Steps

- **[User Guide](USER_GUIDE.md)** - Learn all features in detail
- **[Cross-Platform Guide](CROSS_PLATFORM.md)** - Platform-specific information
- **[Script Versions](SCRIPT_VERSIONS.md)** - PowerShell vs Bash versions
- **[Templates](../templates/)** - Pre-configured sandbox examples

---

## Quick Reference

| Action | Menu Option |
|--------|-------------|
| Create new sandbox | [1] |
| List all sandboxes | [2] |
| Edit configuration | [3] |
| Validate configuration | [4] |
| Modify settings | [5] |
| Export templates | [5] or [6]* |
| Launch sandbox | [6] or [7]* |
| Quit | [q] |

*Menu numbering varies by version (PowerShell vs Bash)

---

## Support

- **Issues:** [GitHub Issues](https://github.com/shadowdevnotreal/Sandman/issues)
- **Documentation:** Check the `docs/` folder
- **Main README:** [../README.md](../README.md)

---

**Ready to sandbox! 🚀**
