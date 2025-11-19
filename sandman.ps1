<#
.SYNOPSIS
    Sandman - Windows Sandbox Manager (Main Launcher)

.DESCRIPTION
    Unified launcher for Sandman. Launches the enhanced PowerShell version.

.NOTES
    Version: 1.0.0
    For other versions, see: scripts/sandman.py or scripts/sandman.sh
#>

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Launch enhanced version
$EnhancedScript = Join-Path $ScriptDir "scripts\wsb-manager-enhanced.ps1"

if (Test-Path $EnhancedScript) {
    & $EnhancedScript
} else {
    Write-Host "Error: Enhanced script not found at: $EnhancedScript" -ForegroundColor Red
    Write-Host "Please ensure all files are in the correct location." -ForegroundColor Yellow
    pause
}
