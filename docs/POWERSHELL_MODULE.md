# Sandman PowerShell Module

Use Sandman functionality in your own PowerShell scripts!

## 🔌 Installation

### Option 1: Manual Installation

```powershell
# Copy module to PowerShell modules directory
$dest = "$env:USERPROFILE\Documents\PowerShell\Modules\Sandman"
Copy-Item -Path ".\modules\Sandman" -Destination $dest -Recurse -Force
```

### Option 2: Import from Source

```powershell
# Import directly from the repo
Import-Module ".\modules\Sandman\Sandman.psm1"
```

## 📚 Available Cmdlets

### New-SandmanConfig
Create a new sandbox configuration

```powershell
# Basic usage
New-SandmanConfig -Name "test-sandbox"

# With custom settings
New-SandmanConfig -Name "dev-env" -MemoryMB 8192 -Networking Disable

# From a template
New-SandmanConfig -Name "my-secure" -Template "secure-sandbox"

# With mapped folders
$folders = @(
    @{ Path = "C:\Projects"; ReadOnly = $false },
    @{ Path = "C:\Data"; ReadOnly = $true }
)
New-SandmanConfig -Name "mapped" -MappedFolders $folders
```

### Get-SandmanConfig
List or get configuration details

```powershell
# List all configurations
Get-SandmanConfig

# Get specific configuration
Get-SandmanConfig -Name "test-sandbox"
```

### Remove-SandmanConfig
Delete a configuration

```powershell
# Remove with confirmation
Remove-SandmanConfig -Name "old-sandbox"

# Force remove without confirmation
Remove-SandmanConfig -Name "old-sandbox" -Confirm:$false
```

### Start-Sandman
Launch Windows Sandbox with a configuration

```powershell
# Launch by name
Start-Sandman -Name "test-sandbox"

# Launch by path
Start-Sandman -Path "C:\configs\custom.wsb"
```

### Export-SandmanConfig
Export configuration to a file

```powershell
# Export to backup location
Export-SandmanConfig -Name "important" -Destination "C:\Backups\"
```

### Import-SandmanConfig
Import configuration from a file

```powershell
# Import with original name
Import-SandmanConfig -Path "C:\Downloads\config.wsb"

# Import with new name
Import-SandmanConfig -Path "C:\Downloads\config.wsb" -Name "imported-config"
```

### Get-SandmanTemplate
List available templates

```powershell
# List all templates
Get-SandmanTemplate
```

## 💡 Usage Examples

### Example 1: Quick Test Environment

```powershell
Import-Module Sandman

# Create and launch minimal test sandbox
New-SandmanConfig -Name "quick-test" -MemoryMB 2048
Start-Sandman -Name "quick-test"
```

### Example 2: Secure Malware Analysis

```powershell
Import-Module Sandman

# Create isolated environment
New-SandmanConfig -Name "malware-lab" `
    -MemoryMB 4096 `
    -Networking Disable `
    -ProtectedClient Enable `
    -MappedFolders @(@{ Path = "C:\Samples"; ReadOnly = $true })

Start-Sandman -Name "malware-lab"
```

### Example 3: Development Environment

```powershell
Import-Module Sandman

# Create dev environment from template
New-SandmanConfig -Name "nodejs-dev" -Template "nodejs-development-sandbox"

# Launch it
Start-Sandman -Name "nodejs-dev"
```

### Example 4: Batch Operations

```powershell
Import-Module Sandman

# Create multiple test environments
1..5 | ForEach-Object {
    New-SandmanConfig -Name "test-env-$_" -MemoryMB (2048 * $_)
}

# List all
Get-SandmanConfig | Format-Table Name, MemoryMB, LastModified

# Clean up
Get-SandmanConfig | Where-Object { $_.Name -like "test-env-*" } |
    ForEach-Object { Remove-SandmanConfig -Name $_.Name -Confirm:$false }
```

### Example 5: Configuration Management

```powershell
Import-Module Sandman

# Get all configs
$configs = Get-SandmanConfig

# Find large configs
$large = $configs | Where-Object { $_.Size -gt 5KB }

# Export important ones
$important = @("production-test", "client-demo")
$important | ForEach-Object {
    Export-SandmanConfig -Name $_ -Destination "C:\Backups\Sandman\"
}
```

### Example 6: Automated Testing

```powershell
Import-Module Sandman

# Create test configuration
New-SandmanConfig -Name "auto-test" `
    -MemoryMB 4096 `
    -Networking Default `
    -MappedFolders @(@{ Path = "C:\TestArtifacts"; ReadOnly = $false })

# Launch sandbox
Start-Sandman -Name "auto-test"

# Wait for manual testing
Read-Host "Press Enter when testing is complete"

# Cleanup
Remove-SandmanConfig -Name "auto-test" -Confirm:$false
```

## 🔧 Advanced Usage

### Custom Workspace

```powershell
# The module uses default workspace: %USERPROFILE%\Documents\wsb-files
# To use custom workspace, specify -Path parameter

New-SandmanConfig -Name "custom" -Path "D:\MyConfigs"
Get-SandmanConfig -Path "D:\MyConfigs"
```

### Pipeline Support

```powershell
# Get configs and export them
Get-SandmanConfig | Where-Object { $_.Name -like "prod-*" } |
    ForEach-Object {
        Export-SandmanConfig -Name $_.Name -Destination "C:\Prod-Backups\"
    }
```

### Error Handling

```powershell
try {
    New-SandmanConfig -Name "test" -MemoryMB 999999999  # Invalid
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
```

## 📋 Parameter Reference

### Common Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| **Name** | String | Configuration name | Required |
| **Path** | String | Workspace path | `%USERPROFILE%\Documents\wsb-files` |
| **MemoryMB** | Int | Memory in MB (256-131072) | 4096 |
| **Networking** | String | Default or Disable | Default |
| **VGpu** | String | Default or Disable | Default |
| **ProtectedClient** | String | Enable or Disable | Enable |
| **MappedFolders** | Hashtable[] | Array of folder mappings | Empty |
| **Template** | String | Template name to base on | None |

### MappedFolders Structure

```powershell
@{
    Path = "C:\Folder\Path"
    ReadOnly = $true  # or $false
}
```

## 🎯 Integration Examples

### With CI/CD

```powershell
# In your CI pipeline
Import-Module Sandman

# Create test environment
New-SandmanConfig -Name "ci-test-$env:BUILD_ID" `
    -MemoryMB 8192 `
    -MappedFolders @(@{ Path = $env:BUILD_SOURCESDIRECTORY; ReadOnly = $true })

# Tests would run here (manually or automated)

# Cleanup
Remove-SandmanConfig -Name "ci-test-$env:BUILD_ID" -Confirm:$false
```

### With Azure DevOps

```yaml
steps:
- task: PowerShell@2
  inputs:
    targetType: 'inline'
    script: |
      Import-Module .\modules\Sandman\Sandman.psm1
      New-SandmanConfig -Name "azure-test" -MemoryMB 8192
      Start-Sandman -Name "azure-test"
```

### With GitHub Actions

```yaml
- name: Create Sandbox
  shell: powershell
  run: |
    Import-Module .\modules\Sandman\Sandman.psm1
    New-SandmanConfig -Name "github-test" -MemoryMB 4096
```

## 🐛 Troubleshooting

### Module Not Found

```powershell
# Check module paths
$env:PSModulePath -split ';'

# Import with full path
Import-Module "C:\Path\To\Sandman\modules\Sandman\Sandman.psm1"
```

### Execution Policy Error

```powershell
# Temporarily bypass
PowerShell -ExecutionPolicy Bypass

# Or set for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Permission Denied

```powershell
# Run as Administrator
# Right-click PowerShell → Run as Administrator
```

## 📖 See Also

- [Quick Start Guide](QUICK_START.md)
- [Web UI Documentation](WEB_UI.md)
- [Script Versions](SCRIPT_VERSIONS.md)
- [Main README](../README.md)
