# Sandman Quick Launch Profiles

One-click preset environments for common sandbox scenarios.

## 🎯 Features

- **Quick Launch**: Launch sandboxes with a single command
- **Profile Management**: Create, update, and delete profiles
- **Desktop Shortcuts**: Create clickable desktop shortcuts
- **Default Profile**: Set a default for instant launching
- **Tags**: Organize profiles by category
- **Usage Tracking**: See which profiles you use most
- **Import/Export**: Share profiles with your team

## 🚀 Quick Start

### Create a Profile

```bash
python profiles/profiles.py create "daily-dev" "development-sandbox" "My daily development environment"
```

### List All Profiles

```bash
python profiles/profiles.py list
```

### Launch a Profile

```bash
python profiles/profiles.py launch "daily-dev"
```

### Set Default Profile

```bash
python profiles/profiles.py default "daily-dev"
```

### Create Desktop Shortcut

```bash
python profiles/profiles.py shortcut "daily-dev"
```

## 📋 Profile Structure

Profiles are stored in `%USERPROFILE%\Documents\wsb-files\profiles.json`:

```json
{
  "version": "1.0",
  "profiles": {
    "daily-dev": {
      "config_name": "development-sandbox",
      "description": "My daily development environment",
      "hotkey": "Ctrl+Alt+D",
      "icon": "💻",
      "tags": ["development", "work"],
      "created": "2024-11-19T10:00:00",
      "last_used": "2024-11-19T14:30:00",
      "launch_count": 42
    }
  },
  "default_profile": "daily-dev"
}
```

## 📈 Usage in Scripts

### Python

```python
from profiles.profiles import ProfileManager

pm = ProfileManager()

# Create a profile
pm.create_profile(
    name="daily-dev",
    config_name="development-sandbox",
    description="My daily development environment",
    hotkey="Ctrl+Alt+D",
    icon="💻",
    tags=["development", "work"]
)

# Launch a profile
success, message = pm.launch_profile("daily-dev")
print(message)

# List all profiles
profiles = pm.list_profiles()
for profile in profiles:
    print(f"{profile['icon']} {profile['name']}: {profile['description']}")

# Set default profile
pm.set_default_profile("daily-dev")

# Launch default
pm.launch_default()

# Get statistics
stats = pm.get_statistics()
print(f"Total launches: {stats['total_launches']}")
```

### PowerShell

```powershell
# Create profile
python profiles\profiles.py create "quick-test" "minimal-sandbox" "Quick testing environment"

# Launch profile
python profiles\profiles.py launch "quick-test"

# List profiles
python profiles\profiles.py list

# Create desktop shortcut
python profiles\profiles.py shortcut "quick-test"
```

## 🎨 Profile Examples

### Development Profile

```python
pm.create_profile(
    name="web-dev",
    config_name="nodejs-development-sandbox",
    description="Full-stack web development",
    icon="🌐",
    tags=["development", "nodejs", "web"]
)
```

### Security Testing Profile

```python
pm.create_profile(
    name="security-lab",
    config_name="malware-analysis-sandbox",
    description="Isolated malware analysis",
    icon="🔒",
    tags=["security", "analysis"]
)
```

### Gaming Profile

```python
pm.create_profile(
    name="game-test",
    config_name="gaming-test-sandbox",
    description="Test games safely",
    icon="🎮",
    tags=["gaming", "testing"]
)
```

### Quick Browser Profile

```python
pm.create_profile(
    name="safe-browse",
    config_name="web-browsing-sandbox",
    description="Safe web browsing",
    icon="🌍",
    tags=["browsing", "security"]
)
```

## 🔧 Advanced Features

### Filtering by Tags

```python
# Get all development profiles
dev_profiles = pm.get_profiles_by_tag("development")

# List profiles with specific tag
pm.list_profiles(tag="security")
```

### Profile Statistics

```python
stats = pm.get_statistics()
print(f"Total profiles: {stats['total_profiles']}")
print(f"Total launches: {stats['total_launches']}")
print(f"Most used: {stats['most_used_profile']['name']}")
```

### Export/Import Profiles

```python
# Export a profile
pm.export_profile("daily-dev", "C:\\Backups\\daily-dev.json")

# Import a profile
pm.import_profile("C:\\Shared\\team-dev.json", name="team-profile")
```

### Update Profile

```python
pm.update_profile(
    "daily-dev",
    description="Updated description",
    icon="🚀",
    tags=["development", "python", "nodejs"]
)
```

## 🎯 Use Cases

### 1. Daily Workflow

```python
# Set up morning routine
pm.create_profile("morning-dev", "development-sandbox", icon="☕")
pm.set_default_profile("morning-dev")

# One command to start your day
pm.launch_default()
```

### 2. Team Collaboration

```python
# Export your setup
pm.export_profile("team-standard", "team-standard.json")

# Team members import it
pm.import_profile("team-standard.json")
pm.set_default_profile("team-standard")
```

### 3. Multiple Contexts

```python
# Create profiles for different projects
pm.create_profile("project-a", "nodejs-dev", tags=["projectA"])
pm.create_profile("project-b", "python-dev", tags=["projectB"])
pm.create_profile("testing", "test-env", tags=["qa"])

# Quick switch between contexts
pm.launch_profile("project-a")
```

### 4. Desktop Shortcuts

```python
# Create shortcuts for frequent profiles
for profile_name in ["daily-dev", "quick-test", "security-lab"]:
    pm.create_desktop_shortcut(profile_name)

# Now double-click to launch!
```

## 🎨 Icons Reference

Popular icons for profiles:

- 💻 Development
- 🌐 Web Development
- 🐍 Python
- 📦 Node.js
- 🔒 Security
- 🎮 Gaming
- 🌍 Browsing
- 📊 Data Science
- 🧪 Testing
- 🚀 Production
- ☕ Daily Work
- 🔧 Configuration
- 📝 Documentation
- 🎨 Design
- 🔬 Research

## 🔍 CLI Commands Reference

### Create Profile

```bash
python profiles/profiles.py create <name> <config> [description]
```

### List Profiles

```bash
# List all
python profiles/profiles.py list

# Filter by tag
python profiles/profiles.py list development
```

### Launch Profile

```bash
python profiles/profiles.py launch <name>
```

### Delete Profile

```bash
python profiles/profiles.py delete <name>
```

### Set Default

```bash
python profiles/profiles.py default <name>
```

### View Statistics

```bash
python profiles/profiles.py stats
```

### Create Desktop Shortcut

```bash
python profiles/profiles.py shortcut <name>
```

## 🔒 Best Practices

### 1. Use Descriptive Names

```python
# ❌ Bad
pm.create_profile("p1", "config1")

# ✅ Good
pm.create_profile("nodejs-api-dev", "nodejs-development-sandbox",
                  "Node.js API development with hot reload")
```

### 2. Organize with Tags

```python
# Tag by purpose, technology, or project
tags=["development", "nodejs", "project-alpha"]
```

### 3. Set a Default

```python
# Set your most-used profile as default
pm.set_default_profile("daily-dev")
```

### 4. Create Desktop Shortcuts

```python
# For profiles you use multiple times per day
pm.create_desktop_shortcut("daily-dev")
```

## 🐛 Troubleshooting

### Profile Not Found

**Error**: `Profile 'xyz' not found`

**Solution**: List all profiles to see available names:
```bash
python profiles\profiles.py list
```

### Configuration Not Found

**Error**: `Configuration 'xyz' not found`

**Solution**: Ensure the referenced configuration exists:
```powershell
# List configurations
ls %USERPROFILE%\Documents\wsb-files\*.wsb
```

### Launch Failed

**Error**: `Failed to launch sandbox`

**Solutions**:
1. Verify Windows Sandbox is enabled
2. Ensure configuration file is valid
3. Check if another sandbox is already running

### Shortcut Creation Failed

**Error**: `Failed to create shortcut`

**Solution**: Run as Administrator:
```bash
# Right-click PowerShell → Run as Administrator
```

## 🔗 Integration

### Web UI Integration

Quick Launch profiles are integrated into the Sandman Web UI:

1. **Profiles Tab**: View all profiles in a grid
2. **One-Click Launch**: Click icon to launch
3. **Edit Profiles**: Update details inline
4. **Usage Stats**: See launch counts and last used

### PowerShell Module Integration

```powershell
Import-Module Sandman

# Create profile
New-SandmanProfile -Name "daily" -ConfigName "dev-env"

# Launch profile
Start-SandmanProfile -Name "daily"

# List profiles
Get-SandmanProfile

# Set default
Set-DefaultSandmanProfile -Name "daily"

# Launch default
Start-SandmanProfile -Default
```

### Keyboard Shortcuts

Assign hotkeys for ultra-fast launching:

```python
pm.create_profile(
    "daily-dev",
    "development-sandbox",
    hotkey="Ctrl+Alt+S"
)
```

Then use AutoHotkey or similar to bind the hotkey:
```autohotkey
^!s::  ; Ctrl+Alt+S
    Run, python C:\path\to\profiles\profiles.py launch daily-dev
return
```

## 📖 See Also

- [Usage Analytics](../analytics/README.md)
- [Configuration Version Control](../versioncontrol/README.md)
- [Web UI Documentation](../docs/WEB_UI.md)
- [PowerShell Module Guide](../docs/POWERSHELL_MODULE.md)
- [Main README](../README.md)
