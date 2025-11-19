<div align="center">

# 🛡️ Sandman - Windows Sandbox Manager

### *Sleep easy while running sketchy code* 😴

**The ultimate Windows Sandbox configuration tool that makes isolation effortless**

<img width="1536" height="1024" alt="Sandman Banner" src="https://github.com/user-attachments/assets/0205a8ec-fa74-4029-b641-cc01d349ec86" />

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)](https://github.com/shadowdevnotreal/Sandman)
[![Version](https://img.shields.io/badge/Version-1.2.0-brightgreen)](https://github.com/shadowdevnotreal/Sandman/releases)
[![Made with PowerShell](https://img.shields.io/badge/Made%20with-PowerShell-blue)](https://github.com/PowerShell/PowerShell)

### 🎉 **NEW in v1.2.0**: Usage Analytics | Version Control | Quick Launch Profiles | Desktop Notifications

</div>

---

## 🆕 What's New in v1.2.0

<table>
<tr>
<td width="50%">

### 📊 Usage Analytics
Track sandbox launches, usage patterns, and statistics. Generate reports, export to CSV, and identify your most-used configurations!

**Key Features:**
- Launch frequency tracking
- Runtime statistics
- Usage trends by date/hour
- Top configurations & templates
- CSV export for analysis

### 🔄 Configuration Version Control
Full Git integration for your configurations! Track changes, view history, and revert to any previous version.

**Key Features:**
- Automatic commit on changes
- Complete commit history
- Diff viewing
- Revert to any commit
- Tag important versions

</td>
<td width="50%">

### 🎯 Quick Launch Profiles
One-click preset environments for your daily workflows. Create desktop shortcuts and set default profiles.

**Key Features:**
- One-command launching
- Desktop shortcut creation
- Tag-based organization
- Usage statistics
- Import/export profiles

### 🔔 Desktop Notifications
Stay informed with Windows toast notifications for all sandbox events. Never miss a completion or error!

**Key Features:**
- Launch notifications
- Error alerts
- Completion notices
- Custom notifications
- Configurable sounds

</td>
</tr>
</table>

---

## 🎉 What's in v1.1.0

<table>
<tr>
<td width="50%">

### 🌐 Web-Based UI
Beautiful Flask-powered interface accessible at `http://localhost:5000`. Manage configurations through your browser with a modern, responsive design!

### 🔌 PowerShell Module
Professional module with 7 cmdlets for scripting and automation. Use Sandman in your own PowerShell workflows!

</td>
<td width="50%">

### 📦 11 Specialized Templates
From gaming to malware analysis - we've got templates for every scenario. 7 new templates added!

### 🎨 5 Custom Themes
Cyberpunk, Matrix, Ocean, Minimalist, or Default. Make your terminal match your style!

### 📤 Import/Export
Share configurations with your team. Backup and restore made easy!

</td>
</tr>
</table>

---

## 🎯 What is Sandman?

Ever wanted to test suspicious software without risking your main system? Need a clean environment for development? Want to run untrusted code safely?

**Sandman has you covered.** 🦸‍♂️

Sandman is your friendly neighborhood Windows Sandbox manager that makes creating isolated environments as easy as falling asleep. Whether you're a developer testing new code, a security researcher analyzing malware, or just someone who likes to play it safe, Sandman gives you powerful sandbox control with a ridiculously simple interface.

> **Windows-Only:** Sandman uses Windows Sandbox (Windows 10/11 Pro/Enterprise, build 18305+)

---

## ✨ Why Sandman?

| Feature | What It Means For You |
|---------|---------------------|
| 🎨 **3 Script Flavors** | PowerShell, Python, or Bash - pick your poison! |
| 🌐 **Web-Based UI** | Beautiful browser interface for easy management |
| 🎮 **Interactive Menus** | No command memorization needed |
| 🔄 **Multi-Change Mode** | Tweak multiple settings before saving |
| 👀 **Live Preview** | See exactly what you're creating in real-time |
| ✅ **Smart Validation** | Catches errors before you launch |
| 📦 **11 Templates** | Pre-built configs for every scenario |
| 🚀 **One-Click Setup** | Get running in under 2 minutes |
| 🛠️ **Auto Feature Enable** | Automatically sets up Windows Sandbox for you |
| 🔌 **PowerShell Module** | Use as a module in your own scripts |
| 📤 **Import/Export** | Share and backup configurations easily |
| 🎨 **Custom Themes** | 5 terminal themes to match your style |
| 📊 **Usage Analytics** | Track launches, patterns, and generate reports |
| 🔄 **Version Control** | Git integration with full history and revert |
| 🎯 **Quick Launch Profiles** | One-click presets with desktop shortcuts |
| 🔔 **Desktop Notifications** | Toast notifications for all sandbox events |

---

## 🚀 Quick Start

### PowerShell (Recommended)

```powershell
# 1. Run setup (creates workspace, checks system)
.\setup.cmd

# 2. Launch Sandman
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1

# 3. Press [1] to create your first sandbox
# 4. Press [6] to launch it
# 5. Profit! 🎉
```

### Alternative Interfaces

**🐍 Python Version** (for Python lovers)
```powershell
python scripts\sandman.py
```

**🐚 Bash Version** (for WSL/Git Bash users)
```bash
./scripts/sandman.sh
```

**🌐 Web UI** (the fancy way!)
```powershell
python web/app.py
# Open browser to http://localhost:5000
```

> All versions manage the same Windows Sandbox - just different interfaces!

---

## 🎓 What You Can Do

### 🧪 Software Testing
Test new applications without fear. Break things safely. Roll back by just closing the sandbox.

### 🔐 Security Research
Run sketchy executables in a safe environment. Perfect for malware analysis (use the "secure" template with networking disabled!).

### 💻 Development
Create clean, reproducible dev environments. Test installers. Debug without polluting your main system.

### 🎯 Training & Demos
Spin up identical environments for training sessions or product demos. Every sandbox starts fresh.

### 🕵️ Malware Analysis
Safely examine suspicious files. Network isolation available. Everything disappears when you close it.

---

## 📦 Installation

### Automated (Easy Mode)

```powershell
# Clone the repo
git clone https://github.com/shadowdevnotreal/Sandman.git
cd Sandman

# Run setup
.\setup.cmd

# Done! ✅
```

**What setup does:**
- ✅ Creates your workspace folder
- ✅ Checks Windows Sandbox availability
- ✅ Verifies PowerShell version
- ✅ Offers to enable Windows Sandbox if needed

### Enable Windows Sandbox

**Automatic (Recommended):**
```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
```

This script will:
- 🔍 Check your Windows version (need build 18305+)
- 🔍 Verify you have Pro/Enterprise/Education (not Home)
- 🔍 Check CPU virtualization is enabled
- ✅ Enable Windows Sandbox feature
- 🔄 Prompt for restart if needed

**Manual:**
1. Settings → Apps → Optional Features
2. Click "More Windows features"
3. Check "Windows Sandbox"
4. Restart

---

## 🎨 Templates

Sandman includes **11 ready-to-go templates**:

| Template | RAM | Network | Use Case | Security |
|----------|-----|---------|----------|----------|
| 🚀 **Minimal** | 2GB | ✅ On | Quick testing | ⚠️ Basic |
| 🔒 **Secure** | 2GB | ❌ Off | Malware analysis | 🔐 Maximum |
| 💻 **Development** | 8GB | ✅ On | Coding projects | ⚠️ Basic |
| 🌟 **Full-Featured** | 8GB | ✅ On | General purpose | ⚠️ Basic |
| 🎮 **Gaming Test** | 16GB | ✅ On | Game testing | ⚠️ Basic |
| 🦠 **Malware Analysis** | 2GB | ❌ Off | Analyzing threats | 🔐 Maximum |
| 🌐 **Web Browsing** | 4GB | ✅ On | Safe browsing | 🔐 High |
| 📦 **Node.js Dev** | 8GB | ✅ On | Web development | ⚠️ Basic |
| 📄 **Office Documents** | 4GB | ❌ Off | Testing docs | 🔐 High |
| 🐍 **Python Data Science** | 16GB | ✅ On | ML/Data analysis | ⚠️ Basic |
| 🧪 **Software Testing** | 6GB | ✅ On | General testing | ⚠️ Basic |

Just copy a template to your workspace and launch it!

```powershell
copy templates\secure-sandbox.wsb "%USERPROFILE%\Documents\wsb-files\my-secure.wsb"
```

---

## 🔧 Configuration Options

Create sandboxes with:

- 💾 **Memory**: 256 MB to 128 GB (yes, really!)
- 🌐 **Networking**: Enable or disable internet access
- 🎮 **vGPU**: Hardware acceleration on/off
- 📁 **Shared Folders**: Map host folders (read-only or read-write)
- 🖨️ **Printer Redirection**: Access host printers
- 📋 **Clipboard**: Copy/paste between host and sandbox
- 🎤 **Audio/Video**: Microphone and webcam passthrough
- 🔐 **Protected Mode**: Extra isolation layer

---

## 🎯 Example Usage

### Create a Secure Testing Environment

```
Launch Sandman → [1] Create new
Name: malware-test
Memory: 2048 MB
Networking: n (DISABLED for safety)
Shared folder: (none)
```

Result: Completely isolated sandbox with no network access. Perfect for analyzing suspicious files.

### Create a Development Sandbox

```
Launch Sandman → [1] Create new
Name: python-dev
Memory: 8192 MB
Networking: y (need to install packages)
Shared folder: C:\Users\YourName\Projects\myproject
Read-Write: y
```

Result: 8GB sandbox with your project folder mounted and internet access for installing dependencies.

---

## 🎮 Interactive Features

### Multi-Modification Mode

Make multiple changes without saving until you're ready:

```
[5] Modify → Select config
[1] Set Memory: 8192 MB
[2] Set Networking: Disable
[7] Toggle Clipboard: Disable
[11] SAVE & EXIT
```

All changes are previewed in real-time! 👀

### Validation

Before launching, Sandman checks:
- ✅ Memory within valid range (256MB - 128GB)
- ✅ All settings use valid values
- ✅ Shared folders actually exist
- ✅ Configuration is well-formed XML

No more "why won't this launch?" moments!

---

## 🔍 Requirements

### What You Need

| Requirement | Details |
|------------|---------|
| **OS** | Windows 10 Pro/Enterprise (build 18305+) or Windows 11 |
| **Edition** | Pro, Enterprise, or Education (**NOT** Home) |
| **CPU** | Virtualization enabled (Intel VT-x or AMD-V) |
| **RAM** | 4GB recommended (more is better) |
| **Feature** | Windows Sandbox (auto-enabled by our script) |

### Script Requirements (Pick One)

- ✅ **PowerShell** 5.1+ (built into Windows)
- 🐍 **Python** 3.6+ (optional, for Python version)
- 🐚 **WSL or Git Bash** (optional, for Bash version)

---

## 📁 Project Structure

```
Sandman/
├── 📄 README.md                    ← You are here!
├── ⚖️ LICENSE                      ← MIT licensed
├── 🙈 .gitignore
├── ⚙️ config.json                  ← Your preferences
├── 🚀 sandman.ps1                  ← Main launcher
├── 📦 setup.cmd                    ← Windows setup
│
├── 🌐 web/                         ← Web UI (v1.1.0)
│   ├── app.py                     ← Flask server
│   ├── templates/                 ← HTML templates
│   │   └── index.html
│   └── static/                    ← CSS/JS assets
│       ├── css/styles.css
│       └── js/app.js
│
├── 📜 scripts/
│   ├── wsb-manager-enhanced.ps1   ← PowerShell version (full-featured)
│   ├── sandman.py                 ← Python version
│   ├── sandman.sh                 ← Bash version (WSL/Git Bash)
│   └── enable-sandbox-features.ps1 ← Feature enabler
│
├── 🔌 modules/                     ← PowerShell Module (v1.1.0)
│   └── Sandman/
│       ├── Sandman.psm1           ← Module code
│       └── Sandman.psd1           ← Module manifest
│
├── 📋 templates/                   ← 11 Templates (v1.1.0)
│   ├── minimal-sandbox.wsb
│   ├── secure-sandbox.wsb
│   ├── development-sandbox.wsb
│   ├── Full-Sandbox.wsb
│   ├── gaming-test-sandbox.wsb
│   ├── malware-analysis-sandbox.wsb
│   ├── web-browsing-sandbox.wsb
│   ├── nodejs-development-sandbox.wsb
│   ├── office-documents-sandbox.wsb
│   ├── python-data-science-sandbox.wsb
│   └── software-testing-sandbox.wsb
│
├── 🎨 themes/                      ← Terminal Themes (v1.1.0)
│   ├── default.json
│   ├── cyberpunk.json
│   ├── matrix.json
│   ├── minimalist.json
│   ├── ocean.json
│   └── README.md
│
├── 📊 analytics/                   ← Usage Analytics (v1.2.0 NEW!)
│   ├── analytics.py               ← Analytics tracking
│   └── README.md                  ← Analytics guide
│
├── 🔄 versioncontrol/              ← Config Version Control (v1.2.0 NEW!)
│   ├── config_git.py              ← Git integration
│   └── README.md                  ← Version control guide
│
├── 🎯 profiles/                    ← Quick Launch Profiles (v1.2.0 NEW!)
│   ├── profiles.py                ← Profile manager
│   └── README.md                  ← Profiles guide
│
├── 🔔 notifications/               ← Desktop Notifications (v1.2.0 NEW!)
│   ├── notifier.py                ← Notification system
│   └── README.md                  ← Notifications guide
│
└── 📚 docs/
    ├── QUICK_START.md             ← 5-minute guide
    ├── WEB_UI.md                  ← Web UI documentation
    ├── POWERSHELL_MODULE.md       ← PowerShell module guide
    ├── SCRIPT_VERSIONS.md         ← PowerShell vs Python vs Bash
    ├── CONTRIBUTING.md            ← How to contribute
    ├── pattern-library.md         ← Dev patterns
    └── project-resolution-log.md  ← Audit trail
```

---

## 💡 Tips & Tricks

### 🎯 Pro Tips

**Tip #1:** Use templates as starting points
```powershell
copy templates\development-sandbox.wsb %USERPROFILE%\Documents\wsb-files\my-custom.wsb
# Edit my-custom.wsb to your liking
```

**Tip #2:** Create multiple profiles for different scenarios
- `testing-unsafe.wsb` - No network, read-only
- `dev-nodejs.wsb` - Network on, project folder mapped
- `quick-test.wsb` - 2GB minimal for fast startup

**Tip #3:** Always use read-only mounts for untrusted code
```xml
<ReadOnly>true</ReadOnly>
```

**Tip #4:** Disable networking when testing suspicious files
```xml
<Networking>Disable</Networking>
```

**Tip #5:** Auto-backup is enabled by default
Every time you modify a config, Sandman creates a `.bak` file. You're welcome! 😊

---

## 🐛 Troubleshooting

<details>
<summary><b>❌ "Windows Sandbox is not available"</b></summary>

**Problem:** Windows Sandbox feature not enabled

**Solution:**
```powershell
# Run as Administrator
.\scripts\enable-sandbox-features.ps1
```

Or manually: Settings → Apps → Optional Features → Windows Sandbox
</details>

<details>
<summary><b>❌ PowerShell execution policy error</b></summary>

**Problem:** Script execution blocked

**Solution:**
```powershell
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

Or permanently:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
</details>

<details>
<summary><b>❌ "This edition doesn't support Windows Sandbox"</b></summary>

**Problem:** Running Windows Home edition

**Solution:** Upgrade to Windows 10/11 Pro, Enterprise, or Education. Windows Home doesn't support Windows Sandbox (Microsoft decision, not ours! 🤷‍♂️)
</details>

<details>
<summary><b>❌ "Virtualization is not enabled"</b></summary>

**Problem:** CPU virtualization disabled in BIOS

**Solution:**
1. Restart and enter BIOS (usually F2, F10, DEL, or ESC)
2. Find "Intel VT-x" or "AMD-V"
3. Enable it
4. Save and exit
</details>

<details>
<summary><b>❌ Configuration won't launch</b></summary>

**Problem:** Invalid .wsb file

**Solution:**
```powershell
.\sandman.ps1
# Press [4] Validate & Inspect
# Fix reported errors
```
</details>

---

## 🤝 Contributing

We love contributions! Here's how you can help:

- 🐛 **Found a bug?** [Open an issue](https://github.com/shadowdevnotreal/Sandman/issues)
- 💡 **Have an idea?** [Start a discussion](https://github.com/shadowdevnotreal/Sandman/discussions)
- 🔧 **Want to code?** Check out [CONTRIBUTING.md](docs/CONTRIBUTING.md)
- 📖 **Improve docs?** PRs for documentation are always welcome!
- ⭐ **Just like it?** Star the repo!

---

## 📜 License

MIT License - do whatever you want with this!

See [LICENSE](LICENSE) for the boring legal stuff.

---

## 🙏 Credits

**Built with:**
- ☕ Excessive amounts of coffee
- 🎵 Great music
- 💡 A systematic, quality-focused approach
- ❤️ Love for Windows Sandbox

**Technologies:**
- PowerShell 5.1+
- Python 3.6+ (Flask)
- HTML5/CSS3/JavaScript
- Windows Sandbox API

**Special thanks to:**
- Windows Sandbox team at Microsoft
- Flask framework contributors
- Everyone who uses and contributes to Sandman
- You, for reading this far! 🎉

## 🌟 Star History

If Sandman makes your life easier, give us a star! ⭐

Every star motivates us to add more features and improve the project!

---

## 🗺️ Roadmap

### ✅ Completed (v1.2.0)

**v1.2.0 Features:**
- ✅ **Usage Analytics** - Track launches, patterns, and generate reports
- ✅ **Configuration Version Control** - Full Git integration with history
- ✅ **Quick Launch Profiles** - One-click presets with desktop shortcuts
- ✅ **Desktop Notifications** - Windows toast notifications for all events

**v1.1.0 Features:**
- ✅ **Web-based UI** - Beautiful Flask interface
- ✅ **PowerShell Module** - Professional automation module
- ✅ **11 Specialized Templates** - Templates for every use case
- ✅ **Import/Export** - Share and backup configurations
- ✅ **5 Custom Themes** - Personalize your experience

### 🚀 Coming Soon (v1.3.0)

- [ ] 🤖 **CI/CD Integration Helpers** - GitHub Actions, Azure DevOps templates
- [ ] 🔍 **Advanced Search** - Search configs by content, tags, and attributes
- [ ] 📸 **Snapshot Management** - Save and restore sandbox states
- [ ] 🔗 **Configuration Chaining** - Link multiple configs together
- [ ] 📱 **Mobile-Responsive Web UI** - Better mobile experience

### 🌟 Future Ideas (v2.0.0+)

- [ ] 🌍 **Multi-Language Support** - UI translations
- [ ] 📱 **Mobile App** - Native mobile app for management
- [ ] 🤝 **Team Workspaces** - Shared configuration repositories
- [ ] 🔐 **Secrets Management** - Secure credential storage
- [ ] 📈 **Performance Monitoring** - Real-time resource usage tracking
- [ ] 🔌 **Plugin System** - Extend Sandman with custom plugins
- [ ] 🎥 **Session Recording** - Record and replay sandbox sessions

Got ideas? [Share them with us!](https://github.com/shadowdevnotreal/Sandman/discussions)

---

## 📞 Support

Need help?

- 📚 **Documentation:** Check the `docs/` folder
- 🐛 **Bug Reports:** [GitHub Issues](https://github.com/shadowdevnotreal/Sandman/issues)
- 💬 **Questions:** [GitHub Discussions](https://github.com/shadowdevnotreal/Sandman/discussions)
- ⚡ **Quick Start:** [docs/QUICK_START.md](docs/QUICK_START.md)

---

## 📊 Project Status

**🟢 Active Development** - Regularly maintained and updated!

### Version 1.2.0 (November 2024) - MAJOR UPDATE 🎉

**What's New in v1.2.0:**
- 📊 Usage Analytics - Track launches and patterns
- 🔄 Configuration Version Control - Full Git integration
- 🎯 Quick Launch Profiles - One-click presets
- 🔔 Desktop Notifications - Windows toast notifications

**v1.1.0 Features:**
- 🌐 Web-based UI (Flask)
- 🔌 PowerShell Module (7 cmdlets)
- 📦 11 Specialized Templates (7 new!)
- 📤 Import/Export Functionality
- 🎨 5 Custom Themes

**Core Features:**
- ✅ 3 Script versions (PowerShell, Python, Bash)
- ✅ Multi-modification mode with live preview
- ✅ Automated Windows Sandbox enablement
- ✅ Interactive menus with validation
- ✅ Automatic configuration backups
- ✅ Template system
- ✅ REST API
- ✅ Git integration
- ✅ Analytics tracking

**Statistics:**
- 📁 31+ files added (v1.1.0: 23 files, v1.2.0: 8 files)
- 💻 5,500+ lines of code
- 📚 7 new documentation guides
- 🎯 8 REST API endpoints
- 🔧 7 PowerShell cmdlets
- 📊 4 new major features (v1.2.0)

---

<div align="center">

## 🌟 Star History

If you like Sandman, give it a star! ⭐

---

### Made with 💙 for Windows Sandbox users

**Sandman** - *Because untrusted code shouldn't keep you up at night* 😴

---

[⬆ Back to Top](#-sandman---windows-sandbox-manager)

</div>
