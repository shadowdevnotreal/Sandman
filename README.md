<div align="center">

# 🛡️ Sandman - Windows Sandbox Manager

### *Sleep easy while running sketchy code* 😴

**The ultimate Windows Sandbox configuration tool that makes isolation effortless**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-blue)](https://github.com/shadowdevnotreal/Sandman)
[![Made with PowerShell](https://img.shields.io/badge/Made%20with-PowerShell-blue)](https://github.com/PowerShell/PowerShell)

</div>

---

## 🎯 What is Sandman?

Ever wanted to test suspicious software without risking your main system? Need a clean environment for development? Want to run untrusted code safely?

**Sandman has you covered.** 🦸‍♂️

Sandman is your friendly neighborhood Windows Sandbox manager that makes creating isolated environments as easy as falling asleep. Whether you're a developer testing new code, a security researcher analyzing malware, or just someone who likes to play it safe, Sandman gives you powerful sandbox control with a ridiculously simple interface.

> **Windows-Only:** Sandman uses Windows Sandbox (Windows 10/11 Pro/Enterprise, build 18305+)

<div align="center">

<!-- Add your screenshot here! -->
<!-- ![Sandman in action](docs/images/screenshot.png) -->

</div>

---

## ✨ Why Sandman?

| Feature | What It Means For You |
|---------|---------------------|
| 🎨 **3 Script Flavors** | PowerShell, Python, or Bash - pick your poison! |
| 🎮 **Interactive Menus** | No command memorization needed |
| 🔄 **Multi-Change Mode** | Tweak multiple settings before saving |
| 👀 **Live Preview** | See exactly what you're creating in real-time |
| ✅ **Smart Validation** | Catches errors before you launch |
| 📦 **Template Library** | Pre-built configs for common scenarios |
| 🚀 **One-Click Setup** | Get running in under 2 minutes |
| 🛠️ **Auto Feature Enable** | Automatically sets up Windows Sandbox for you |

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

> All three versions manage the same Windows Sandbox - just different interfaces!

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

Sandman includes ready-to-go templates:

| Template | RAM | Network | Use Case | Security |
|----------|-----|---------|----------|----------|
| 🚀 **Minimal** | 2GB | ✅ On | Quick testing | ⚠️ Basic |
| 🔒 **Secure** | 2GB | ❌ Off | Malware analysis | 🔐 Maximum |
| 💻 **Development** | 8GB | ✅ On | Coding projects | ⚠️ Basic |
| 🌟 **Full-Featured** | 8GB | ✅ On | General purpose | ⚠️ Basic |

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
├── 📜 scripts/
│   ├── wsb-manager-enhanced.ps1   ← PowerShell version (full-featured)
│   ├── sandman.py                 ← Python version
│   ├── sandman.sh                 ← Bash version (WSL/Git Bash)
│   └── enable-sandbox-features.ps1 ← Feature enabler
│
├── 📋 templates/
│   ├── minimal-sandbox.wsb        ← 2GB, basic config
│   ├── secure-sandbox.wsb         ← 2GB, no network, max isolation
│   ├── development-sandbox.wsb    ← 8GB, shared folders
│   └── Full-Sandbox.wsb           ← 8GB, full-featured
│
└── 📚 docs/
    ├── QUICK_START.md             ← 5-minute guide
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

**Special thanks to:**
- Windows Sandbox team at Microsoft
- Everyone who uses and contributes to Sandman
- You, for reading this far! 🎉

---

## 🗺️ Roadmap

What's coming next:

- [ ] 🌐 Web-based configuration UI
- [ ] 📦 More templates for specific use cases
- [ ] 🔌 PowerShell module for easier integration
- [ ] 🤖 CI/CD integration helpers
- [ ] 📤 Configuration import/export tools
- [ ] 🎨 Custom themes for the terminal UI

Got ideas? [Let us know!](https://github.com/shadowdevnotreal/Sandman/discussions)

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

### Version 1.0.0

- ✅ PowerShell, Python, and Bash versions
- ✅ Multi-modification mode with live preview
- ✅ 4 pre-configured templates
- ✅ Automated Windows Sandbox enablement
- ✅ Interactive menus with validation
- ✅ Automatic configuration backups

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
