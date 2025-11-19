# Sandman - Cross-Platform Sandbox Manager

> Simple, powerful, cross-platform sandbox configuration and management

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows | Linux | macOS](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-blue)](https://github.com/shadowdevnotreal/Sandman)

---

## What is Sandman?

Sandman is a comprehensive sandbox management tool that makes it easy to create, configure, and launch isolated environments across Windows, Linux, and macOS. Whether you're testing software, running untrusted code, or creating development environments, Sandman provides a simple interface with powerful features.

### Key Features

- **Cross-Platform Support** - Works on Windows, Linux, and macOS
- **Interactive Menus** - Easy-to-use terminal interface
- **Multi-Modification Mode** - Make multiple changes before saving
- **Live Preview** - See your configuration in real-time
- **Validation** - Pre-flight checks before launching
- **Template System** - Quick-start with pre-configured templates
- **Automated Setup** - One-command installation

---

## Quick Start

### Windows

```powershell
# Run setup
.\setup.cmd

# Launch Sandman
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### Linux

```bash
# Run setup
chmod +x setup.sh && ./setup.sh

# Launch Sandman
./scripts/sandman.sh
```

### macOS

```bash
# Run setup
chmod +x setup.sh && ./setup.sh

# Launch Sandman
./scripts/sandman.sh
```

---

## Platform Support

| Platform | Sandbox Backend | Config Format | Status |
|----------|----------------|---------------|--------|
| **Windows** | Windows Sandbox | `.wsb` (XML) | ✅ Full Support |
| **Linux** | Docker / systemd-nspawn | `.sandbox` (INI) | ✅ Full Support |
| **macOS** | Docker | `.sandbox` (INI) | ✅ Full Support |

See [Cross-Platform Guide](docs/CROSS_PLATFORM.md) for detailed platform-specific information.

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
- **Memory Limits** - Configurable resource allocation

---

## Usage Examples

### Create a New Sandbox

```bash
./sandman.sh
# Press [1] Create new configuration
# Enter name: my-sandbox
# Enter memory (MB): 4096
# Enable networking? y
# Shared folder path: /home/user/share
```

### Modify Existing Configuration

```bash
./sandman.ps1
# Press [5] Modify
# Select configuration
# Make changes (memory, networking, folders)
# Press [11] SAVE & EXIT
```

### Launch a Sandbox

```bash
# Linux/macOS
./scripts/sandman.sh
# Press [6] Launch sandbox
# Select configuration
# Sandbox starts!
```

---

## Configuration

Sandman uses `config.json` for cross-platform settings:

```json
{
  "version": "1.0.0",
  "workspace": {
    "windows": "%USERPROFILE%\\Documents\\wsb-files",
    "linux": "~/.local/share/sandman",
    "macos": "~/Library/Application Support/Sandman"
  },
  "git": {
    "includeCoAuthoredBy": false
  },
  "sandbox": {
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": true
  }
}
```

### Customization

Edit `config.json` to customize:
- **Workspace location** - Where configurations are stored
- **Default memory** - Default RAM allocation
- **Editor preference** - Your favorite text editor
- **Auto-backup** - Automatic `.bak` file creation

See [Configuration Guide](docs/CROSS_PLATFORM.md#configuration-file-configjson) for all options.

---

## Templates

Sandman includes pre-configured templates:

- **Full-Featured** - 8GB RAM, networking enabled, shared folder
- **Secure** - 2GB RAM, networking disabled, no shared folders
- **Minimal** - 2GB RAM, basic configuration
- **Development** - 8GB RAM, optimized for development work

Export sample templates with option `[5]` or `[6]` in the menu.

---

## Documentation

- **[Quick Start Guide](docs/QUICK_START.md)** - Get up and running fast
- **[User Guide](docs/USER_GUIDE.md)** - Comprehensive feature documentation
- **[Cross-Platform Guide](docs/CROSS_PLATFORM.md)** - Platform-specific information
- **[Script Versions](docs/SCRIPT_VERSIONS.md)** - PowerShell vs Bash versions
- **[Contributing Guide](docs/CONTRIBUTING.md)** - How to contribute

---

## Requirements

### Windows
- Windows 10 Pro/Enterprise (build 18305+) or Windows 11
- Windows Sandbox feature enabled
- PowerShell 5.1 or later (built-in)

### Linux
- Any modern distribution
- Docker or systemd-nspawn
- Bash shell
- `jq` (optional, for JSON parsing)

### macOS
- macOS 10.14 (Mojave) or later
- Docker Desktop for Mac
- Bash shell
- `jq` (optional, via Homebrew)

---

## Installation

### Automated Setup

**Windows:**
```powershell
.\setup.cmd
```

**Linux/macOS:**
```bash
chmod +x setup.sh
./setup.sh
```

The setup script will:
- Create workspace directory
- Check dependencies
- Make scripts executable
- Optionally install recommended packages
- Create launcher shortcuts

### Manual Setup

1. Clone or download this repository
2. Create workspace directory manually
3. Make scripts executable (Linux/macOS)
4. Install Docker (Linux/macOS) or enable Windows Sandbox (Windows)

---

## File Structure

```
Sandman/
├── README.md                  # This file
├── config.json                # Configuration file
├── setup.cmd                  # Windows installer
├── setup.sh                   # Linux/macOS installer
├── sandman.ps1                # Main Windows launcher
│
├── scripts/                   # Platform-specific scripts
│   ├── wsb-manager-enhanced.ps1   # Enhanced PowerShell version
│   ├── wsb-manager-fixed.ps1      # Fixed PowerShell version
│   ├── sandman.sh                  # Bash version (Linux/macOS)
│   └── enable-sandbox-features.ps1 # Windows feature enabler
│
├── templates/                 # Sandbox templates
│   ├── Full-Sandbox.wsb      # Full-featured template
│   ├── minimal-sandbox.wsb   # Minimal template
│   └── secure-sandbox.wsb    # Security-focused template
│
└── docs/                      # Documentation
    ├── QUICK_START.md        # Quick start guide
    ├── USER_GUIDE.md         # Comprehensive user guide
    ├── CROSS_PLATFORM.md     # Cross-platform information
    ├── SCRIPT_VERSIONS.md    # Version comparison
    ├── CONTRIBUTING.md       # Contribution guidelines
    └── legacy/               # Legacy documentation
```

---

## Troubleshooting

### Windows

**Problem:** "Windows Sandbox is not available"
- **Solution:** Enable Windows Sandbox feature (Settings → Apps → Optional Features)

**Problem:** PowerShell execution policy error
- **Solution:** `PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1`

### Linux/macOS

**Problem:** "Docker not found"
- **Solution:** Install Docker: `sudo apt-get install docker.io` (Linux) or Docker Desktop (macOS)

**Problem:** Permission denied
- **Solution:** Add user to docker group: `sudo usermod -aG docker $USER`

See [Cross-Platform Guide](docs/CROSS_PLATFORM.md) for more troubleshooting.

---

## Use Cases

### Software Testing
Create isolated environments to test software without affecting your main system.

### Security Research
Run untrusted code safely in a sandboxed environment.

### Development
Set up clean development environments with specific configurations.

### Training & Demos
Create reproducible environments for training or demonstrations.

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
- Cross-platform support (Windows, Linux, macOS)
- Multi-modification mode
- Live configuration preview
- Template system
- Automated setup scripts

See full version history in [legacy documentation](docs/legacy/).

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
- Docker community
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
- [ ] Python version for cross-platform scripting
- [ ] Web-based configuration UI
- [ ] Cloud sandbox support (AWS, Azure, GCP)
- [ ] Template marketplace
- [ ] CI/CD integration

---

**Made with precision and care.**

---

### Quick Links

- [Get Started](docs/QUICK_START.md) - Installation and first steps
- [User Guide](docs/USER_GUIDE.md) - Complete feature documentation
- [Platform Guide](docs/CROSS_PLATFORM.md) - Platform-specific setup
- [Contribute](docs/CONTRIBUTING.md) - Join the development
- [Legacy Docs](docs/legacy/) - Original Windows-specific documentation
