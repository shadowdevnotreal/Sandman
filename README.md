# Sandman - Windows Sandbox Manager

> Simple, powerful Windows Sandbox configuration and management

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)](https://github.com/shadowdevnotreal/Sandman)

---

## What is Sandman?

Sandman is a comprehensive Windows Sandbox management tool that makes it easy to create, configure, and launch isolated Windows environments. Whether you're testing software, running untrusted code, or creating development environments, Sandman provides a simple interface with powerful features.

**Windows-Only:** Sandman uses Windows Sandbox, a feature available in Windows 10 Pro/Enterprise (build 18305+) and Windows 11.

### Key Features

- **Multiple Script Versions** - PowerShell, Python, or Bash (WSL/Git Bash)
- **Interactive Menus** - Easy-to-use terminal interface
- **Multi-Modification Mode** - Make multiple changes before saving
- **Live Preview** - See your configuration in real-time
- **Validation** - Pre-flight checks before launching
- **Template System** - Quick-start with pre-configured templates
- **Automated Setup** - One-command installation
- **Feature Enablement** - Automatic Windows Sandbox feature setup

---

## Quick Start

### Windows (PowerShell)

```powershell
# Run setup
.\setup.cmd

# Launch Sandman
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### Alternative Script Versions

**Python version:**
```powershell
python scripts\sandman.py
```

**Bash version (WSL or Git Bash):**
```bash
./scripts/sandman.sh
```

---

## Requirements

### Windows System Requirements

- **OS**: Windows 10 Pro/Enterprise (build 18305+) or Windows 11
- **Edition**: Pro, Enterprise, or Education (NOT Home)
- **Feature**: Windows Sandbox (can be auto-enabled with included script)
- **CPU**: Virtualization enabled in BIOS (Intel VT-x or AMD-V)
- **RAM**: At least 4GB recommended

### Script Requirements

- **PowerShell**: Version 5.1+ (built-in on Windows 10/11)
- **Python**: Version 3.6+ (optional, for Python version)
- **Bash**: WSL or Git Bash (optional, for Bash version)

---

## Enable Windows Sandbox

Use the included automated script:

```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
```

This script will:
- Check Windows version and edition compatibility
- Verify CPU virtualization support
- Enable Windows Sandbox feature
- Prompt for restart if needed

**Manual enablement:**
1. Open Settings → Apps → Optional Features
2. Click "More Windows features"
3. Check "Windows Sandbox"
4. Restart computer

---

## Features

### Core Functionality

- **Create** - Guided wizard for new sandbox configurations
- **List** - View all your sandbox configurations
- **Edit** - Open configurations in your preferred editor
- **Validate** - Check configurations before launching
- **Modify** - Interactive menu to change settings
- **Launch** - Start your sandbox with validation

### Advanced Features

- **Multi-Change Mode** - Make multiple modifications in one session
- **Live Configuration Preview** - See changes as you make them
- **Automatic Backups** - Never lose your configurations
- **Template Library** - Pre-configured setups for common use cases
- **Path Validation** - Ensures shared folders exist
- **Memory Limits** - Configurable resource allocation (256MB - 128GB)
- **Network Control** - Enable/disable network access per sandbox
- **vGPU Support** - Hardware acceleration options
- **Folder Mapping** - Share folders between host and sandbox

---

## Usage Examples

### Create a New Sandbox

```powershell
.\sandman.ps1
# Press [1] Create new configuration
# Enter name: my-sandbox
# Enter memory (MB): 4096
# Enable networking? y
# Shared folder path: C:\Users\YourName\Documents\share
```

### Modify Existing Configuration

```powershell
.\sandman.ps1
# Press [5] Modify
# Select configuration
# Make changes (memory, networking, folders)
# Press [11] SAVE & EXIT
```

### Launch a Sandbox

```powershell
.\sandman.ps1
# Press [6] Launch sandbox
# Select configuration
# Sandbox starts!
```

---

## Configuration

Sandman uses `config.json` for settings:

```json
{
  "version": "1.0.0",
  "workspace": {
    "windows": "%USERPROFILE%\\Documents\\wsb-files"
  },
  "git": {
    "includeCoAuthoredBy": false
  },
  "sandbox": {
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": true
  },
  "editor": {
    "windows": "notepad.exe"
  }
}
```

### Customization

Edit `config.json` to customize:
- **Workspace location** - Where configurations are stored
- **Default memory** - Default RAM allocation
- **Editor preference** - Your favorite text editor
- **Auto-backup** - Automatic `.bak` file creation

---

## Templates

Sandman includes pre-configured templates:

- **Full-Featured** - 8GB RAM, networking enabled, shared folder
- **Secure** - 2GB RAM, networking disabled, no shared folders, protected client
- **Minimal** - 2GB RAM, basic configuration
- **Development** - 8GB RAM, optimized for development work with folder mapping

Find templates in the `templates/` directory.

---

## Script Versions

Sandman provides three script versions for different workflows:

| Version | File | Best For |
|---------|------|----------|
| **PowerShell (Enhanced)** | `scripts/wsb-manager-enhanced.ps1` | Full-featured, multi-modification mode, best UX |
| **Python** | `scripts/sandman.py` | Cross-scripting workflows, Python developers |
| **Bash** | `scripts/sandman.sh` | WSL/Git Bash users, Unix-like commands |

All versions work with the same `.wsb` configuration files and provide the same core functionality.

See [SCRIPT_VERSIONS.md](docs/SCRIPT_VERSIONS.md) for detailed comparison.

---

## Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - Get up and running fast
- **[Script Versions](docs/SCRIPT_VERSIONS.md)** - PowerShell vs Python vs Bash
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute
- **[Pattern Library](docs/pattern-library.md)** - Reusable development patterns
- **[Resolution Log](docs/project-resolution-log.md)** - Development audit trail

---

## Installation

### Automated Setup

```powershell
# Clone repository
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# Run setup
.\setup.cmd
```

The setup script will:
- Create workspace directory (`%USERPROFILE%\Documents\wsb-files`)
- Verify Windows Sandbox availability
- Check PowerShell version
- Optionally enable Windows Sandbox feature
- Create launcher shortcuts

### Manual Setup

1. Clone or download this repository
2. Create workspace directory manually: `mkdir "%USERPROFILE%\Documents\wsb-files"`
3. Enable Windows Sandbox feature (see Requirements section)
4. Run `.\sandman.ps1` to start

---

## File Structure

```
Sandman/
├── README.md                  # This file
├── LICENSE                    # MIT License
├── .gitignore                # Git ignore patterns
├── config.json                # Configuration file
├── setup.cmd                  # Windows installer
├── sandman.ps1                # Main PowerShell launcher
│
├── scripts/                   # Script versions
│   ├── wsb-manager-enhanced.ps1   # Enhanced PowerShell (primary)
│   ├── sandman.py                 # Python version
│   ├── sandman.sh                 # Bash version (WSL/Git Bash)
│   └── enable-sandbox-features.ps1 # Windows feature enabler
│
├── templates/                 # Sandbox templates
│   ├── Full-Sandbox.wsb       # Full-featured template
│   ├── minimal-sandbox.wsb    # Minimal template
│   ├── secure-sandbox.wsb     # Security-focused template
│   └── development-sandbox.wsb # Development environment
│
└── docs/                      # Documentation
    ├── QUICK_START.md         # Quick start guide
    ├── SCRIPT_VERSIONS.md     # Version comparison
    ├── CONTRIBUTING.md        # Contribution guidelines
    ├── pattern-library.md     # Development patterns
    └── project-resolution-log.md # Audit trail
```

---

## Troubleshooting

### "Windows Sandbox is not available"

**Problem:** Windows Sandbox feature is not enabled
**Solution:**
```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
# Or manually enable via Settings → Apps → Optional Features
```

### PowerShell execution policy error

**Problem:** Script execution blocked by policy
**Solution:**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### "This edition of Windows doesn't support Windows Sandbox"

**Problem:** Running Windows Home edition
**Solution:** Windows Sandbox requires Windows 10/11 Pro, Enterprise, or Education. Upgrade your Windows edition.

### "Virtualization is not enabled"

**Problem:** CPU virtualization disabled in BIOS
**Solution:**
1. Restart computer and enter BIOS/UEFI (usually F2, F10, or DEL)
2. Find "Intel VT-x" or "AMD-V" setting
3. Enable virtualization
4. Save and exit BIOS

### Configuration file won't launch

**Problem:** Invalid .wsb configuration
**Solution:**
```powershell
# Use validation feature
.\sandman.ps1
# Press [4] Validate & Inspect
# Fix any reported errors
```

---

## Use Cases

### Software Testing
Create isolated environments to test software without affecting your main system. Perfect for trying new applications or updates.

### Security Research
Run untrusted code safely in a sandboxed environment with network isolation.

### Development
Set up clean development environments with specific configurations and shared project folders.

### Training & Demos
Create reproducible environments for training sessions or product demonstrations.

### Malware Analysis
Safely examine suspicious files in an isolated environment (use secure template with networking disabled).

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for:
- Code of conduct
- Development workflow
- Pull request process
- Coding standards

---

## Changelog

### v1.0.0 (Current)
- Initial release
- PowerShell, Python, and Bash script versions
- Multi-modification mode with live preview
- Template system with 4 pre-configured templates
- Automated Windows Sandbox feature enablement
- Interactive menus with validation
- Automatic configuration backups

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Credits & Acknowledgments

**Development Methodology:**
This project was built using a systematic, quality-focused approach:
- *Measure twice, cut once* - Thorough planning prevents rework
- *Clarity before velocity* - Well-defined goals and architecture
- *Pattern learning* - Continuous improvement through reflection

**Special Thanks:**
- Windows Sandbox team at Microsoft
- All contributors and users

---

## Support

- **Documentation:** Check the `docs/` folder
- **Issues:** [GitHub Issues](https://github.com/shadowdevnotreal/Sandman/issues)
- **Discussions:** [GitHub Discussions](https://github.com/shadowdevnotreal/Sandman/discussions)

---

## Project Status

**Active Development** - Regularly maintained and updated.

### Roadmap
- [ ] Web-based configuration UI
- [ ] Additional templates for specific use cases
- [ ] PowerShell module for easier integration
- [ ] CI/CD integration helpers
- [ ] Configuration import/export tools

---

**Made with precision and care for Windows Sandbox users.**

---

### Quick Links

- [Get Started](docs/QUICK_START.md) - Installation and first steps
- [Script Versions](docs/SCRIPT_VERSIONS.md) - Choose your preferred version
- [Contribute](docs/CONTRIBUTING.md) - Join the development
