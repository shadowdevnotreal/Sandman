# Sandman Script Versions

Sandman is available in three versions for Windows:

## 1. PowerShell Version (Recommended)

**File**: `sandman.ps1` / `wsb-manager-enhanced.ps1`

### Features
- Native Windows integration
- Full Windows Sandbox support
- Multi-modification mode
- Live configuration preview
- Best performance on Windows

### Requirements
- Windows 10 Pro/Enterprise or Windows 11
- PowerShell 5.1 or later (built into Windows)
- Windows Sandbox feature enabled

### Usage
```powershell
# Method 1: Bypass execution policy once
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1

# Method 2: Unblock file permanently
Unblock-File -Path .\sandman.ps1
.\sandman.ps1

# Method 3: Run from setup launcher
.\Launch-Sandman.cmd
```

### Advantages
- Native Windows tool
- No additional dependencies
- Direct .wsb file support
- Best integration with Windows features

---

## 2. Python Version

**File**: `sandman.py`

### Features
- Cross-version compatibility (Python 3.6+)
- Simple, readable code
- Easy to extend and customize
- Platform-agnostic codebase

### Requirements
- Windows 10 Pro/Enterprise or Windows 11
- Python 3.6 or later
- Windows Sandbox feature enabled

### Installation
```bash
# Download Python from python.org or use Microsoft Store
python --version  # Verify installation

# Or use Chocolatey
choco install python
```

### Usage
```bash
# Run directly
python sandman.py

# Or make it executable (Git Bash/WSL)
chmod +x sandman.py
./sandman.py
```

### Advantages
- Familiar language for Python developers
- Easy to modify and extend
- Works in any Python environment
- Good for scripting and automation

### Example: Automation
```python
from sandman import WsbManager, SandmanConfig

config = SandmanConfig()
manager = WsbManager(config)

# Create sandbox programmatically
xml = manager.create_xml(
    memory_mb=8192,
    networking="Disable",
    mapped_folders=[{"path": "C:\\secure", "readonly": True}]
)

manager.save_wsb(Path("auto-sandbox.wsb"), xml)
```

---

## 3. Bash Version (WSL/Git Bash)

**File**: `sandman.sh`

### Features
- Works in Windows Subsystem for Linux (WSL)
- Works in Git Bash / MSYS2 / Cygwin
- Unix-style scripting on Windows
- Familiar for Linux users

### Requirements
- Windows 10 Pro/Enterprise or Windows 11
- WSL (Windows Subsystem for Linux) OR Git Bash installed
- Windows Sandbox feature enabled

### Installation
```bash
# WSL (Ubuntu/Debian)
# Already have bash

# Or install Git Bash
# Download from: https://git-scm.com/downloads
```

### Usage
```bash
# Make executable
chmod +x sandman.sh

# Run
./sandman.sh

# Or with bash explicitly
bash sandman.sh
```

### Advantages
- Familiar for Linux/Unix users
- Scriptable from bash scripts
- Works in WSL environments
- Good for automation pipelines

### Notes for WSL Users
- .wsb files are created in Windows filesystem
- Default workspace: `/mnt/c/Users/YourName/Documents/wsb-files`
- Launches Windows Sandbox (not WSL container)

---

## Comparison Matrix

| Feature | PowerShell | Python | Bash |
|---------|-----------|--------|------|
| **Native Windows** | ✅ Yes | ⚠️ Via Python | ⚠️ Via WSL/Git Bash |
| **No Dependencies** | ✅ Yes | ❌ Needs Python | ❌ Needs WSL/Git Bash |
| **Multi-change Mode** | ✅ Yes | ⚠️ Basic | ⚠️ Basic |
| **Live Preview** | ✅ Yes | ✅ Yes | ⚠️ Limited |
| **Easy to Extend** | ⚠️ Medium | ✅ Easy | ⚠️ Medium |
| **Automation** | ✅ Excellent | ✅ Excellent | ✅ Excellent |
| **Performance** | ✅ Fast | ✅ Fast | ⚠️ Slightly slower |
| **Recommended For** | All users | Python devs | Linux users |

---

## Which Version Should I Use?

### Use PowerShell if:
- ✅ You want the best Windows integration
- ✅ You don't want to install anything extra
- ✅ You want the enhanced features (multi-change, preview)
- ✅ **Recommended for most users!**

### Use Python if:
- ✅ You're familiar with Python
- ✅ You want to automate sandbox creation
- ✅ You need to extend the tool with custom features
- ✅ You're building a larger Python project

### Use Bash if:
- ✅ You use WSL regularly
- ✅ You're comfortable with Linux/Unix tools
- ✅ You want to integrate with bash scripts
- ✅ You're coming from a Linux background

---

## Feature Availability

| Feature | PowerShell | Python | Bash |
|---------|-----------|--------|------|
| Create .wsb | ✅ | ✅ | ✅ |
| List files | ✅ | ✅ | ✅ |
| Edit files | ✅ | ✅ | ✅ |
| Validate | ✅ | ✅ | ✅ |
| Launch sandbox | ✅ | ✅ | ✅ |
| Multi-change mode | ✅ Enhanced | ⚠️ Basic | ⚠️ Basic |
| Live preview | ✅ | ✅ | ⚠️ |
| Color output | ✅ | ✅ | ✅ |
| Config file support | ✅ | ✅ | ✅ |
| Backup files | ✅ | ✅ | ⚠️ |

---

## Installation

### PowerShell (All Windows users)
```powershell
# Run setup
.\setup.cmd

# Launch Sandman
.\sandman.ps1
```

### Python (Python users)
```bash
# Install Python if needed
python --version

# Run Sandman
python sandman.py
```

### Bash (WSL/Git Bash users)
```bash
# Make executable
chmod +x sandman.sh

# Run Sandman
./sandman.sh
```

---

## Configuration

All three versions use the same `config.json`:

```json
{
  "version": "1.0.0",
  "workspace": {
    "windows": "%USERPROFILE%\\Documents\\wsb-files"
  },
  "git": {
    "includeCoAuthoredBy": false
  },
  "editor": {
    "windows": "notepad.exe"
  },
  "sandbox": {
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": true
  }
}
```

---

## Examples

### PowerShell
```powershell
# Create and launch in one command
.\sandman.ps1
# Press [1] → Create
# Press [7] → Launch
```

### Python
```python
# Programmatic creation
from sandman import WsbManager, SandmanConfig

config = SandmanConfig()
manager = WsbManager(config)

xml = manager.create_xml(memory_mb=4096)
manager.save_wsb(Path("test.wsb"), xml)
manager.launch_sandbox(Path("test.wsb"))
```

### Bash
```bash
# Script automation
./sandman.sh <<EOF
1
my-sandbox
4096
y
/mnt/c/share
n
EOF
```

---

## Troubleshooting

### PowerShell
- **Execution Policy Error**: Run `PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1`
- **Script Won't Run**: Use `Unblock-File -Path .\sandman.ps1`

### Python
- **Module Not Found**: Ensure Python 3.6+ is installed
- **Permission Error**: Run as Administrator if needed

### Bash
- **Command Not Found**: Use `bash sandman.sh` instead of `./sandman.sh`
- **WSL Path Issues**: Workspace is `/mnt/c/Users/...` in WSL

---

## Getting Help

- Main documentation: [README.md](../README.md)
- Quick reference: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- Feature enablement: Run `enable-sandbox-features.ps1`

---

**All three versions manage the same .wsb files!** Choose based on your preference and workflow.
