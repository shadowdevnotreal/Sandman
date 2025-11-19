# Cross-Platform Guide

Sandman is designed to work across Windows, Linux, and macOS with platform-specific sandbox backends.

## Platform Support Matrix

| Feature | Windows | Linux | macOS |
|---------|---------|-------|-------|
| **Script** | `sandman.ps1` (PowerShell) | `sandman.sh` (Bash) | `sandman.sh` (Bash) |
| **Setup** | `setup.cmd` | `setup.sh` | `setup.sh` |
| **Sandbox Backend** | Windows Sandbox (.wsb) | Docker / systemd-nspawn | Docker |
| **Config Format** | XML (.wsb) | INI-style (.sandbox) | INI-style (.sandbox) |
| **Default Workspace** | `%USERPROFILE%\Documents\wsb-files` | `~/.local/share/sandman` | `~/Library/Application Support/Sandman` |

---

## Windows

### Requirements

- **OS**: Windows 10 Pro/Enterprise (build 18305+) or Windows 11
- **Feature**: Windows Sandbox must be enabled
- **PowerShell**: Version 5.1 or later

### Enable Windows Sandbox

1. Open **Settings**
2. Go to **Apps** > **Optional Features**
3. Click **More Windows features**
4. Check **Windows Sandbox**
5. Restart your computer

Or via PowerShell (as Administrator):

```powershell
Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All
```

### Installation

```powershell
# Run setup
.\setup.cmd

# Start Sandman
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1
```

### Configuration Format

Windows uses `.wsb` (XML) format:

```xml
<Configuration>
  <Networking>Default</Networking>
  <VGpu>Default</VGpu>
  <MemoryInMB>4096</MemoryInMB>
  <MappedFolders>
    <MappedFolder>
      <HostFolder>C:\myshare</HostFolder>
      <ReadOnly>true</ReadOnly>
    </MappedFolder>
  </MappedFolders>
</Configuration>
```

### Troubleshooting

**Error: "Windows Sandbox is not available"**
- Ensure you're running Windows 10 Pro/Enterprise or Windows 11
- Enable Windows Sandbox feature (see above)
- Restart your computer

**Error: "Execution Policy"**
- Run: `PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1`
- Or: `Unblock-File -Path .\sandman.ps1`

---

## Linux

### Requirements

- **OS**: Any modern Linux distribution
- **Backend**: Docker or systemd-nspawn
- **Dependencies**: `bash`, `jq` (optional)

### Installation

```bash
# Make scripts executable
chmod +x setup.sh sandman.sh

# Run setup
./setup.sh

# Start Sandman
./sandman.sh
```

### Sandbox Backends

#### Docker (Recommended)

**Install Docker:**

```bash
# Debian/Ubuntu
sudo apt-get update
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Fedora
sudo dnf install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Arch
sudo pacman -S docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (optional)
sudo usermod -aG docker $USER
# Log out and back in for changes to take effect
```

**Verify Docker:**

```bash
docker --version
docker ps
```

#### systemd-nspawn (Alternative)

systemd-nspawn is a lightweight container manager included with systemd.

**Check availability:**

```bash
which systemd-nspawn
```

**Create a container:**

```bash
# Debian/Ubuntu example
sudo debootstrap --arch=amd64 stable /var/lib/machines/debian-stable

# Run container
sudo systemd-nspawn -M debian-stable
```

### Configuration Format

Linux uses `.sandbox` (INI-style) format:

```ini
# Sandman Sandbox Configuration

[general]
name=my-sandbox
memory_mb=4096
networking=enabled

[shared_folders]
folder_1=/home/user/shared:readonly=false
```

### Troubleshooting

**Error: "Docker not found"**
- Install Docker (see above)
- Ensure Docker service is running: `sudo systemctl status docker`

**Error: "Permission denied" when running Docker**
- Add user to docker group: `sudo usermod -aG docker $USER`
- Log out and back in
- Or run with sudo: `sudo ./sandman.sh`

**jq not found warning**
- Install jq: `sudo apt-get install jq` (Debian/Ubuntu)
- jq is optional but recommended for JSON parsing

---

## macOS

### Requirements

- **OS**: macOS 10.14 (Mojave) or later
- **Backend**: Docker Desktop for Mac
- **Dependencies**: `bash`, `jq` (optional)

### Installation

```bash
# Make scripts executable
chmod +x setup.sh sandman.sh

# Run setup
./setup.sh

# Start Sandman
./sandman.sh
```

### Install Docker Desktop

1. Download Docker Desktop from: https://docs.docker.com/desktop/install/mac-install/
2. Install the .dmg file
3. Launch Docker Desktop
4. Wait for Docker to start (whale icon in menu bar)

**Verify Docker:**

```bash
docker --version
docker ps
```

### Install Homebrew (Recommended)

Homebrew makes it easy to install dependencies:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install jq git
```

### Configuration Format

macOS uses the same `.sandbox` format as Linux:

```ini
# Sandman Sandbox Configuration

[general]
name=my-sandbox
memory_mb=4096
networking=enabled

[shared_folders]
folder_1=/Users/username/shared:readonly=false
```

### Troubleshooting

**Error: "Docker not found"**
- Install Docker Desktop for Mac
- Ensure Docker Desktop is running (check menu bar)

**Error: "Cannot connect to Docker daemon"**
- Start Docker Desktop application
- Wait for Docker to fully initialize

**jq not found warning**
- Install via Homebrew: `brew install jq`
- jq is optional but recommended

---

## Configuration File (config.json)

The `config.json` file provides platform-specific settings:

```json
{
  "version": "1.0.0",
  "workspace": {
    "windows": "%USERPROFILE%\\Documents\\wsb-files",
    "linux": "~/.local/share/sandman",
    "macos": "~/Library/Application Support/Sandman"
  },
  "git": {
    "includeCoAuthoredBy": false,
    "autoCommit": false,
    "commitTemplate": "feat: ${description}"
  },
  "editor": {
    "windows": "notepad.exe",
    "linux": "nano",
    "macos": "nano"
  },
  "sandbox": {
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": true
  }
}
```

### Customizing config.json

**Change workspace location:**

```json
"workspace": {
  "linux": "/opt/sandman/workspaces"
}
```

**Change default editor:**

```json
"editor": {
  "linux": "vim",
  "macos": "code"  // VS Code
}
```

**Disable Git co-authored-by:**

```json
"git": {
  "includeCoAuthoredBy": false
}
```

---

## Shared Folders

### Windows

```xml
<MappedFolders>
  <MappedFolder>
    <HostFolder>C:\Users\username\Documents\shared</HostFolder>
    <ReadOnly>false</ReadOnly>
  </MappedFolder>
</MappedFolders>
```

### Linux/macOS

```ini
[shared_folders]
folder_1=/home/username/shared:readonly=false
folder_2=/opt/data:readonly=true
```

**Path Requirements:**
- Use absolute paths
- Folder must exist before launching sandbox
- On macOS, some directories may require permissions

---

## Performance Tuning

### Memory Allocation

**Windows:**
- Minimum: 256 MB
- Maximum: 128 GB (131072 MB)
- Recommended: 4096 MB (4 GB)

**Linux/macOS (Docker):**
- Check Docker resource limits: Docker Desktop → Preferences → Resources
- Adjust memory allocation as needed

### Networking

**Disable for security:**
- Windows: `<Networking>Disable</Networking>`
- Linux/macOS: `networking=disabled`

**Enable for internet access:**
- Windows: `<Networking>Default</Networking>`
- Linux/macOS: `networking=enabled`

---

## Security Considerations

### Windows Sandbox
- Automatically isolated from host
- Data is ephemeral (lost on close)
- ProtectedClient mode available

### Docker Containers
- Use `--network none` to disable networking
- Mount folders as read-only: `:ro`
- Avoid running as root inside container

### Best Practices
1. **Disable networking** for untrusted code
2. **Use read-only mounts** when possible
3. **Limit memory** to prevent resource exhaustion
4. **Never share sensitive directories** like `~/.ssh`

---

## Migration Between Platforms

### From Windows to Linux/macOS

1. Export .wsb configuration
2. Extract settings (memory, networking, folders)
3. Create equivalent .sandbox file
4. Adjust paths for Unix-like systems

**Example conversion:**

Windows (.wsb):
```xml
<MemoryInMB>8192</MemoryInMB>
<Networking>Default</Networking>
<HostFolder>C:\data</HostFolder>
```

Linux (.sandbox):
```ini
memory_mb=8192
networking=enabled
folder_1=/home/user/data:readonly=false
```

### From Linux/macOS to Windows

1. Read .sandbox configuration
2. Create .wsb XML structure
3. Convert paths to Windows format
4. Use Sandman Windows script to generate

---

## Platform-Specific Features

### Windows Only
- **vGPU acceleration** (hardware acceleration)
- **Audio/Video input** redirection
- **Printer redirection**
- **Protected RDP client** mode

### Linux Only
- **systemd-nspawn** backend (lightweight containers)
- **cgroups** resource limiting
- **SELinux/AppArmor** integration

### macOS Only
- **Docker Desktop** integration
- **Apple Silicon** (M1/M2) support via Docker

---

## FAQ

### Can I use the same configuration across platforms?

No, but you can manually convert between formats. Windows uses XML (.wsb) while Linux/macOS use INI-style (.sandbox).

### Which backend is recommended for Linux?

Docker is recommended for its ease of use and broad compatibility. systemd-nspawn is lighter but requires more setup.

### Can I run Windows Sandbox on Windows 10 Home?

No, Windows Sandbox requires Windows 10 Pro/Enterprise or Windows 11.

### Do I need to install anything inside the sandbox?

No, but you can map folders with pre-installed tools or customize the sandbox environment.

### How do I make changes persist across sandbox sessions?

Use shared folders. Data inside the sandbox (not in shared folders) is ephemeral and lost when the sandbox closes.

---

## Getting Help

- Check the main [README.md](../README.md)
- Review [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- Open an issue on GitHub

---

**Platform-specific support channels:**
- Windows: Microsoft Docs - Windows Sandbox
- Linux: Docker Documentation, systemd-nspawn man pages
- macOS: Docker Desktop for Mac Documentation
