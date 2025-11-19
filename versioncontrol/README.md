# Sandman Configuration Version Control

Git-based version control for your Windows Sandbox configurations.

## 🔄 Features

- **Git Integration**: Full Git version control for configurations
- **Commit History**: Track all changes with timestamps and messages
- **Revert Capability**: Roll back to any previous version
- **Diff Viewing**: See what changed between versions
- **Auto-Commit**: Optionally auto-commit on configuration changes
- **Tags**: Create milestone tags for important configurations
- **Export History**: Export configurations from any commit

## 🚀 Quick Start

### Initialize Version Control

```bash
python versioncontrol/config_git.py init
```

This will:
- Initialize a Git repository in your workspace
- Create a `.gitignore` file
- Make an initial commit

### View Status

```bash
python versioncontrol/config_git.py status
```

### Commit Changes

```bash
# Commit a specific configuration
python versioncontrol/config_git.py commit "my-config" "Added more memory"

# Commit all changes
python versioncontrol/config_git.py commit-all "Updated all configs"
```

### View History

```bash
# View all commits
python versioncontrol/config_git.py history

# View commits for specific config
python versioncontrol/config_git.py history "my-config"

# Limit number of commits shown
python versioncontrol/config_git.py history "my-config" 10
```

### View Differences

```bash
# Show uncommitted changes
python versioncontrol/config_git.py diff "my-config"

# Compare with specific commit
python versioncontrol/config_git.py diff "my-config" abc1234
```

### Revert to Previous Version

```bash
python versioncontrol/config_git.py revert "my-config" abc1234
```

## 📈 Usage in Scripts

### Python

```python
from versioncontrol.config_git import ConfigVersionControl

vcs = ConfigVersionControl()

# Initialize repository
success, message = vcs.initialize()
print(message)

# Check status
status = vcs.get_status()
print(f"Total commits: {status['total_commits']}")

# Commit a configuration
success, message = vcs.commit_config("dev-env", "Updated memory to 16GB")
if success:
    print("✓ Committed successfully")

# View history
commits = vcs.get_history("dev-env", limit=10)
for commit in commits:
    print(f"{commit['hash'][:8]} - {commit['date']}: {commit['message']}")

# Revert to previous version
success, message = vcs.revert_config("dev-env", "abc1234")
print(message)
```

### PowerShell

```powershell
# Initialize
python versioncontrol\config_git.py init

# Commit changes
python versioncontrol\config_git.py commit "my-config" "Added network isolation"

# View history
python versioncontrol\config_git.py history "my-config"

# Revert
python versioncontrol\config_git.py revert "my-config" abc1234
```

## 🔧 Advanced Features

### Auto-Commit

Enable automatic commits when configurations are modified:

```python
vcs = ConfigVersionControl()
vcs.set_auto_commit(True)
```

When enabled, Sandman will automatically commit changes whenever you:
- Create a new configuration
- Modify an existing configuration
- Delete a configuration

### Create Tags

Mark important milestones:

```python
# Create a tag
vcs.create_tag("v1.0-production", "Stable production configurations")

# List all tags
tags = vcs.list_tags()
for tag in tags:
    print(tag)
```

### Export from History

Export a configuration from any point in history:

```python
vcs.export_config_at_commit(
    config_name="dev-env",
    commit_hash="abc1234",
    output_path="C:\\Backups\\dev-env-old.wsb"
)
```

## 📊 Git Repository Structure

Your workspace will have this structure after initialization:

```
%USERPROFILE%\Documents\wsb-files\
├── .git/                    # Git repository data
├── .gitignore              # Git ignore rules
├── .sandman-vcs.json       # VCS configuration
├── my-config.wsb           # Your configurations
├── dev-env.wsb
└── ...
```

### .gitignore Contents

```
# Sandman Git Ignore
*.bak                       # Backup files
*.tmp                       # Temporary files
*.log                       # Log files
.sandman-vcs.json          # VCS config (not versioned)
analytics.json             # Analytics data (not versioned)
```

## 🎯 Use Cases

### 1. Experiment Safely

```python
# Before experimenting, note current commit
commits = vcs.get_history("production-env", limit=1)
safe_commit = commits[0]['hash']

# Make experimental changes
# ... modify configuration ...

# If experiment fails, revert
vcs.revert_config("production-env", safe_commit)
```

### 2. Team Collaboration

```bash
# Initialize repo with your details
python versioncontrol/config_git.py init

# Team members can clone and commit
git clone <repo-url> %USERPROFILE%\Documents\wsb-files

# Push changes to shared repository
cd %USERPROFILE%\Documents\wsb-files
git push origin main
```

### 3. Audit Trail

```python
# Generate audit report
commits = vcs.get_history(limit=100)
with open("audit_report.txt", "w") as f:
    for commit in commits:
        f.write(f"{commit['date']} - {commit['author']}: {commit['message']}\n")
```

### 4. Configuration Backup

```python
# Tag current state before major changes
vcs.commit_all("Pre-migration snapshot")
vcs.create_tag("pre-migration-2024", "Snapshot before Windows 11 migration")

# If migration fails, revert to tag
# git checkout pre-migration-2024
```

## 🔒 Best Practices

### 1. Commit Often

```python
# After each significant change
vcs.commit_config("my-config", "Increased memory for better performance")
```

### 2. Use Descriptive Messages

```python
# ❌ Bad
vcs.commit_config("dev-env", "update")

# ✅ Good
vcs.commit_config("dev-env", "Added Node.js folder mapping for development")
```

### 3. Tag Milestones

```python
# Before production deployment
vcs.create_tag("v1.0-prod", "Production-ready configurations")
```

### 4. Review Changes Before Committing

```python
# Check what changed
success, diff = vcs.get_diff("my-config")
print(diff)

# Commit if changes look good
vcs.commit_config("my-config", "Verified changes")
```

## 🔍 Troubleshooting

### Git Not Found

**Error**: `Git is not installed or not in PATH`

**Solution**:
```bash
# Install Git for Windows
# Download from: https://git-scm.com/download/win

# Or use winget
winget install Git.Git
```

### Permission Denied

**Error**: `Permission denied when accessing .git`

**Solution**:
```bash
# Run as Administrator
# Right-click PowerShell → Run as Administrator
```

### Repository Already Initialized

**Error**: `Git repository already initialized`

**Solution**: This is not an error! Your workspace already has version control enabled.

### Uncommitted Changes

**Error**: `Uncommitted changes in config.wsb`

**Solution**:
```bash
# Commit or stash changes first
python versioncontrol\config_git.py commit "my-config" "Save current changes"

# Then revert
python versioncontrol\config_git.py revert "my-config" abc1234
```

## 🔗 Integration

### Web UI Integration

The version control features are integrated into the Sandman Web UI:

1. View commit history for each configuration
2. Compare versions visually
3. Revert with one click
4. View diffs in a friendly format

### PowerShell Module Integration

```powershell
Import-Module Sandman

# Initialize version control
Initialize-SandmanVCS

# Get VCS status
Get-SandmanVCSStatus

# Commit configuration
Save-SandmanConfig -Name "dev-env" -Message "Updated settings"

# View history
Get-SandmanConfigHistory -Name "dev-env"

# Revert configuration
Restore-SandmanConfig -Name "dev-env" -Commit "abc1234"
```

## 📖 See Also

- [Usage Analytics](../analytics/README.md)
- [Web UI Documentation](../docs/WEB_UI.md)
- [PowerShell Module Guide](../docs/POWERSHELL_MODULE.md)
- [Main README](../README.md)
