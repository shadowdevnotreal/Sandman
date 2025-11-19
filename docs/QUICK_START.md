# Sandman - Quick Start Guide

Get up and running with Sandman in 5 minutes!

---

## What is Sandman?

Sandman is a Windows Sandbox manager that lets you create isolated Windows environments for testing, development, or running untrusted code safely.

**Windows-Only:** Requires Windows 10 Pro/Enterprise (build 18305+) or Windows 11.

---

## Prerequisites

Before you start, ensure you have:

- **Windows 10 Pro/Enterprise** (build 18305+) or **Windows 11**
  - **NOT** Windows Home edition
- **Administrator access** (to enable Windows Sandbox)
- **CPU virtualization enabled** in BIOS (Intel VT-x or AMD-V)

---

## Installation

### Step 1: Clone or Download

```powershell
# Using Git
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# Or download ZIP and extract
```

### Step 2: Enable Windows Sandbox

**Automated (Recommended):**

```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
```

This script will:
- Check your Windows version and edition
- Verify CPU virtualization
- Enable Windows Sandbox feature
- Prompt for restart if needed

**Manual Method:**

1. Open Settings → Apps → Optional Features
2. Click "More Windows features"
3. Check "Windows Sandbox"
4. Click OK and restart

### Step 3: Run Setup

```powershell
.\setup.cmd
```

This creates your workspace directory at `%USERPROFILE%\Documents\wsb-files`.

### Step 4: Launch Sandman

**PowerShell (Recommended):**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

**Python Version:**
```powershell
python scripts\sandman.py
```

**Bash Version (WSL or Git Bash):**
```bash
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
Shared folder: (leave empty or enter: C:\Users\YourName\Documents\share)
```

Your configuration is now saved as a `.wsb` file!

### 2. Launch the Sandbox

```
Press [6] - Launch sandbox
Select: my-first-sandbox
Sandbox starts!
```

A new Windows Sandbox window will open with your configuration.

### 3. Modify a Configuration

```
Press [5] - Modify
Select: my-first-sandbox
Make changes:
  - Set Memory: 8192 MB
  - Toggle Networking: Disable
  - Add/remove shared folders
Press [11] - SAVE & EXIT
```

---

## Common Tasks

### Create a Secure Sandbox (No Network)

Perfect for testing untrusted software or malware analysis.

```
[1] Create new
Name: secure-test
Memory: 2048
Networking: n
Shared folder: (empty)
```

### Create a Development Sandbox

For development work with shared project folders.

```
[1] Create new
Name: dev-environment
Memory: 8192
Networking: y
Shared folder: C:\Users\YourName\Projects\myproject
Read/Write? y
```

### List All Configurations

```
Press [2] - List configurations
```

Shows all your `.wsb` files with modification times.

### Validate Before Launching

```
Press [4] - Validate & Inspect
Select configuration
Review settings and check for errors
```

Sandman will verify:
- Memory is within valid range (256MB - 128GB)
- All setting values are valid
- Shared folders exist on your system

### Open Configuration in Editor

```
Press [3] - Edit (open in editor)
Select configuration
```

Opens the `.wsb` XML file in your configured editor (default: Notepad).

---

## Understanding Configuration Files

Sandman creates `.wsb` (Windows Sandbox) configuration files in XML format.

**Example:**
```xml
<Configuration>
  <Networking>Default</Networking>
  <VGpu>Default</VGpu>
  <MemoryInMB>4096</MemoryInMB>
  <AudioInput>Default</AudioInput>
  <VideoInput>Default</VideoInput>
  <PrinterRedirection>Enable</PrinterRedirection>
  <ClipboardRedirection>Enable</ClipboardRedirection>
  <ProtectedClient>Enable</ProtectedClient>

  <MappedFolders>
    <MappedFolder>
      <HostFolder>C:\Users\YourName\Documents\share</HostFolder>
      <ReadOnly>false</ReadOnly>
    </MappedFolder>
  </MappedFolders>
</Configuration>
```

**Location:** `%USERPROFILE%\Documents\wsb-files\`

---

## Using Templates

Sandman includes pre-configured templates for quick starts:

### Available Templates

1. **minimal-sandbox.wsb** - Basic 2GB sandbox
2. **secure-sandbox.wsb** - Isolated, no network
3. **development-sandbox.wsb** - 8GB with shared folders
4. **Full-Sandbox.wsb** - Full-featured configuration

### Copy a Template

```powershell
# Copy to workspace
copy templates\secure-sandbox.wsb "%USERPROFILE%\Documents\wsb-files\my-secure.wsb"

# Edit if needed
notepad "%USERPROFILE%\Documents\wsb-files\my-secure.wsb"

# Launch via Sandman
.\sandman.ps1
# Press [6] Launch
```

---

## Script Versions

Sandman offers three script versions - choose what works best for you:

| Version | Command | Best For |
|---------|---------|----------|
| **PowerShell** | `.\sandman.ps1` | Native Windows, full-featured UI |
| **Python** | `python scripts\sandman.py` | Python developers, cross-scripting |
| **Bash** | `./scripts/sandman.sh` | WSL/Git Bash users |

All versions work with the same `.wsb` files and provide the same functionality.

---

## Troubleshooting

### "Windows Sandbox is not available"

**Cause:** Windows Sandbox feature not enabled
**Fix:**
```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
# Or enable manually: Settings → Apps → Optional Features → Windows Sandbox
```

### "This edition of Windows doesn't support Windows Sandbox"

**Cause:** Running Windows Home
**Fix:** Upgrade to Windows 10/11 Pro, Enterprise, or Education

### PowerShell execution policy error

**Cause:** Script execution blocked by policy
**Fix:**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
# Or permanently:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Virtualization is not enabled"

**Cause:** CPU virtualization disabled in BIOS
**Fix:**
1. Restart computer
2. Enter BIOS/UEFI (usually F2, F10, DEL, or ESC)
3. Find "Intel VT-x" or "AMD-V" setting
4. Enable it
5. Save and exit

### Sandbox launches but files aren't accessible

**Cause:** Shared folder path incorrect or doesn't exist
**Fix:**
1. Validate configuration: Press [4]
2. Check folder path exists
3. Ensure path uses absolute Windows format (C:\...)
4. Create folder if needed: `mkdir "C:\path\to\folder"`

### Configuration won't save

**Cause:** Invalid configuration values
**Fix:** Use Sandman's modify feature (Press [5]) which validates all inputs

---

## Next Steps

### Learn More

- **[Script Versions](SCRIPT_VERSIONS.md)** - Detailed comparison of PowerShell vs Python vs Bash
- **[Contributing](CONTRIBUTING.md)** - How to contribute to Sandman
- **[Main README](../README.md)** - Complete documentation

### Explore Templates

Check the `templates/` directory for pre-configured examples:
```powershell
dir templates\*.wsb
```

### Customize Configuration

Edit `config.json` to change:
- Workspace location
- Default memory allocation
- Default text editor
- Auto-backup settings

---

## Quick Reference Card

### Main Menu Options

| Option | Action |
|--------|--------|
| **[1]** | Create new configuration |
| **[2]** | List all configurations |
| **[3]** | Edit (open in text editor) |
| **[4]** | Validate & Inspect |
| **[5]** | Modify (interactive changes) |
| **[6]** | Launch Windows Sandbox |
| **[q]** | Quit |

### Keyboard Shortcuts (PowerShell Version)

- **Ctrl+C** - Cancel current operation
- **Enter** - Confirm selection/input
- **ESC** - Usually returns to previous menu (check script version)

### Common Settings

| Setting | Values | Recommended |
|---------|--------|-------------|
| **Memory** | 256 MB - 128 GB | 4096 MB (4 GB) |
| **Networking** | Default, Disable | Default (unless testing untrusted code) |
| **VGpu** | Default, Disable | Default (better performance) |
| **ClipboardRedirection** | Enable, Disable | Enable (convenience) |
| **ProtectedClient** | Enable, Disable | Enable (security) |

---

## Tips & Tricks

### Tip 1: Use Templates as Starting Points

Don't start from scratch - copy a template and modify it:
```powershell
copy templates\development-sandbox.wsb %USERPROFILE%\Documents\wsb-files\my-dev.wsb
```

### Tip 2: Create Multiple Profiles

Create different configurations for different use cases:
- `testing-unsafe.wsb` - No network, read-only shares
- `dev-nodejs.wsb` - Network enabled, project folder mapped
- `quick-test.wsb` - Minimal 2GB for fast launches

### Tip 3: Backup Important Configs

Sandman auto-creates `.bak` files, but also manually backup:
```powershell
copy %USERPROFILE%\Documents\wsb-files\important.wsb %USERPROFILE%\Documents\wsb-files\backups\
```

### Tip 4: Share Configs with Team

`.wsb` files are portable! Share them via:
- Git repository
- Network share
- Email/Teams/Slack

Just ensure recipients adjust `HostFolder` paths to match their systems.

### Tip 5: Use Read-Only Shares for Safety

When testing untrusted software, use read-only mapped folders:
```xml
<ReadOnly>true</ReadOnly>
```

This prevents the sandbox from modifying your host files.

---

## Support

- **Issues:** [GitHub Issues](https://github.com/shadowdevnotreal/Sandman/issues)
- **Documentation:** `docs/` folder
- **Main README:** [../README.md](../README.md)

---

**Ready to sandbox safely! 🛡️**
