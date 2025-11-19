# Quick Reference Card - WSB Manager v3 Enhanced

## 🚀 Quick Start

```powershell
# Run the script
PowerShell -ExecutionPolicy Bypass -File .\wsb-manager-enhanced.ps1

# OR unblock once and run normally
Unblock-File -Path .\wsb-manager-enhanced.ps1
.\wsb-manager-enhanced.ps1
```

---

## 📋 Main Menu

| Option | Action | Description |
|--------|--------|-------------|
| **[1]** | Create | Create new .wsb configuration |
| **[2]** | List | Show all .wsb files in workspace |
| **[3]** | Edit | Open file in Notepad |
| **[4]** | Validate | Check file for errors |
| **[5]** | Modify | **⭐ Multi-change mode** |
| **[6]** | Export | Create sample templates |
| **[7]** | Launch | Validate & launch sandbox |
| **[q]** | Quit | Exit program |

---

## 🔧 Modify Menu (Multi-Change Mode)

### Configuration Options
| # | Action | Effect |
|---|--------|--------|
| 1 | Add mapped folder | Add host folder share |
| 2 | Remove mapped folder(s) | Remove folder(s) |
| 3 | Set Memory | Change RAM allocation |
| 4 | Set Networking | Enable/Disable network |
| 5 | Set vGPU | Enable/Disable GPU virtualization |
| 6 | Set AudioInput | Control microphone |
| 7 | Set VideoInput | Control camera |
| 8 | Toggle PrinterRedirection | On/Off |
| 9 | Toggle ClipboardRedirection | On/Off |
| 10 | Toggle ProtectedClient | On/Off |

### Control Options
| # | Action | Effect |
|---|--------|--------|
| **11** | **SAVE & EXIT** | Save all changes and return |
| **12** | **DISCARD & EXIT** | Abandon changes (with confirmation) |
| 13 | Open in Notepad | Direct XML editing |

---

## 💡 Workflow Tips

### ✅ Making Multiple Changes (FAST!)
```
[5] Modify → Select file
  → Toggle ProtectedClient ✓
  → Set Memory to 8192 ✓
  → Add mapped folder ✓
  → [11] SAVE & EXIT
```

### ⚠️ Check Before You Save
```
After each change:
=== Current Configuration ===
Memory: 8192 MB  ← See your change immediately!
...
```

### 🔄 Changed Your Mind?
```
Made mistakes?
  → [12] DISCARD & EXIT
  → Confirm: y
  → Start fresh!
```

### 📝 Manual XML Editing
```
[13] Open in Notepad
  → Edit XML
  → Save & close
  → "Reload? (y/N)": y
  → Continue in UI
```

---

## 🎯 Allowed Values Reference

### Memory
- Range: `256` - `131072` MB (256 MB to 128 GB)
- Common: 2048, 4096, 8192

### Networking
- `Default` - Network enabled
- `Disable` - No network access

### vGPU
- `Default` - GPU acceleration on
- `Disable` - Software rendering only

### Audio/Video Input
- `Default` - System default
- `Enable` - Force on
- `Disable` - Force off

### Redirection (Printer/Clipboard)
- `Enable` - Allow access
- `Disable` - Block access

### ProtectedClient
- `Enable` - Enhanced security
- `Disable` - Normal mode

### ReadOnly (Mapped Folders)
- `true` - Read-only access
- `false` - Read-write access

---

## 📍 File Locations

```
Workspace: C:\Users\YourName\Documents\wsb-files\
  ├── your-config.wsb
  ├── your-config.wsb.bak  ← Automatic backup
  ├── sample-full.wsb
  ├── sample-secure.wsb
  └── sample-minimal.wsb
```

---

## 🐛 Troubleshooting

### Script Won't Run
```powershell
# Solution 1: Bypass once
PowerShell -ExecutionPolicy Bypass -File .\wsb-manager-enhanced.ps1

# Solution 2: Unblock permanently
Unblock-File -Path .\wsb-manager-enhanced.ps1
```

### Parse Errors
- File must be UTF-8 encoded
- No Unicode special characters
- Check for extra parentheses

### Backup Errors
- Non-critical warning (script continues)
- Usually file lock or permission issue
- Changes still save successfully

### Validation Errors
Common issues:
- Invalid values (use reference above)
- Host folder doesn't exist
- Memory out of range
- Fix in Modify mode or use option [4] to see details

---

## 🎨 Color Guide

| Color | Meaning |
|-------|---------|
| 🟢 Green | Success / Saved |
| 🟡 Yellow | Warning / Info |
| 🔴 Red | Error / Failed |
| 🔵 Cyan | Headers / Sections |

---

## ⌨️ Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `1-7` | Main menu options |
| `1-13` | Modify menu options |
| `q` or `Q` | Quit program |
| `y` or `yes` | Confirm action |
| `N` or anything else | Decline action |

---

## 🏆 Pro Tips

1. **Use Multi-Change Mode** - Do all your changes at once, not one-by-one
2. **Check the Preview** - Review configuration before saving
3. **Create Backups** - .bak files are created automatically
4. **Use Templates** - Option [6] creates sample configurations
5. **Validate Before Launch** - Option [7] validates automatically
6. **Name Descriptively** - Use clear names like "dev-secure.wsb"
7. **Test Configurations** - Launch and verify before relying on them

---

## 🔗 Common Use Cases

### Secure Development Environment
```
Memory: 4096 MB
Networking: Disable
VGpu: Default
Mapped Folder: C:\dev-projects (ReadOnly: false)
```

### Internet Testing
```
Memory: 2048 MB
Networking: Default
Clipboard: Disable
Protected: Enable
```

### File Review (Secure)
```
Memory: 2048 MB
Networking: Disable
Mapped Folder: C:\untrusted (ReadOnly: true)
Protected: Enable
```

---

## 📞 Need Help?

- Check validation errors with option [4]
- Review this reference card
- Check ENHANCEMENT_CHANGELOG.md for details
- Make sure Windows Sandbox feature is enabled

---

**Happy sandboxing! 🏖️**

Version: 3.0 Enhanced | Updated: 2025
