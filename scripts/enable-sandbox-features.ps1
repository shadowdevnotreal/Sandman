<#
.SYNOPSIS
    Enable Windows Sandbox and required features

.DESCRIPTION
    Checks Windows version compatibility and enables all necessary features
    for Windows Sandbox to function properly.

.NOTES
    Requires Administrator privileges
    Requires Windows 10 Pro/Enterprise (build 18305+) or Windows 11
#>

#Requires -RunAsAdministrator

# Colors for output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet('Success','Error','Warning','Info')]
        [string]$Type = 'Info'
    )

    switch ($Type) {
        'Success' { Write-Host "[+] $Message" -ForegroundColor Green }
        'Error'   { Write-Host "[!] $Message" -ForegroundColor Red }
        'Warning' { Write-Host "[!] $Message" -ForegroundColor Yellow }
        'Info'    { Write-Host "[*] $Message" -ForegroundColor Cyan }
    }
}

Write-Host "========================================" -ForegroundColor Yellow
Write-Host " Windows Sandbox Feature Enabler" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

# ====================================
# CHECK ADMINISTRATOR PRIVILEGES
# ====================================

$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-ColorOutput "This script must be run as Administrator!" -Type Error
    Write-ColorOutput "Right-click PowerShell and select 'Run as Administrator'" -Type Warning
    pause
    exit 1
}

Write-ColorOutput "Running with Administrator privileges" -Type Success

# ====================================
# CHECK WINDOWS VERSION
# ====================================

Write-Host ""
Write-ColorOutput "Checking Windows version..." -Type Info

$os = Get-WmiObject -Class Win32_OperatingSystem
$version = [System.Environment]::OSVersion.Version
$buildNumber = $version.Build

Write-Host "  OS: $($os.Caption)"
Write-Host "  Version: $($version.Major).$($version.Minor)"
Write-Host "  Build: $buildNumber"

# Check if Windows 10/11
if ($version.Major -ne 10) {
    Write-ColorOutput "Windows 10 or 11 required. Current version not supported." -Type Error
    pause
    exit 1
}

# Check edition
$edition = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").EditionID

Write-Host "  Edition: $edition"

# Supported editions
$supportedEditions = @(
    "Professional",
    "ProfessionalWorkstation",
    "Enterprise",
    "EnterpriseN",
    "Education",
    "EducationN",
    "Pro",
    "ProWorkstation"
)

if ($supportedEditions -contains $edition) {
    Write-ColorOutput "Windows edition is compatible with Windows Sandbox" -Type Success
} else {
    Write-ColorOutput "Windows Sandbox requires Pro, Enterprise, or Education edition" -Type Error
    Write-ColorOutput "Current edition: $edition" -Type Warning
    Write-Host ""
    Write-Host "Windows Sandbox is NOT available on Windows Home edition."
    Write-Host "You need to upgrade to Windows Pro, Enterprise, or Education."
    pause
    exit 1
}

# Check build number for Windows 10
if ($buildNumber -lt 18305) {
    Write-ColorOutput "Windows Sandbox requires build 18305 or later" -Type Error
    Write-ColorOutput "Current build: $buildNumber" -Type Warning
    Write-Host ""
    Write-Host "Please update Windows to the latest version:"
    Write-Host "  Settings > Update & Security > Windows Update"
    pause
    exit 1
}

Write-ColorOutput "Windows version is compatible!" -Type Success

# ====================================
# CHECK VIRTUALIZATION SUPPORT
# ====================================

Write-Host ""
Write-ColorOutput "Checking virtualization support..." -Type Info

# Check CPU virtualization
$hyperv = Get-WmiObject -Query "SELECT * FROM Win32_ComputerSystem"
$virtEnabled = $false

# Check if virtualization is enabled in BIOS
$virtCapable = (Get-CimInstance -ClassName Win32_Processor).VirtualizationFirmwareEnabled

if ($virtCapable -contains $true) {
    Write-ColorOutput "CPU virtualization is ENABLED in BIOS" -Type Success
    $virtEnabled = $true
} else {
    Write-ColorOutput "CPU virtualization may not be enabled in BIOS" -Type Warning
    Write-Host ""
    Write-Host "To enable virtualization:"
    Write-Host "  1. Restart your computer"
    Write-Host "  2. Enter BIOS/UEFI settings (usually F2, F10, or DEL key)"
    Write-Host "  3. Look for 'Intel VT-x' or 'AMD-V' and enable it"
    Write-Host "  4. Save and exit BIOS"
    Write-Host ""

    $continue = Read-Host "Continue anyway? (y/N)"
    if ($continue -notmatch '^[Yy]') {
        exit 1
    }
}

# ====================================
# CHECK CURRENT FEATURE STATUS
# ====================================

Write-Host ""
Write-ColorOutput "Checking Windows features..." -Type Info

$features = @(
    @{Name="Containers-DisposableClientVM"; DisplayName="Windows Sandbox"},
    @{Name="Microsoft-Hyper-V"; DisplayName="Hyper-V (Full)"},
    @{Name="Microsoft-Hyper-V-All"; DisplayName="Hyper-V Platform"},
    @{Name="Microsoft-Hyper-V-Management-PowerShell"; DisplayName="Hyper-V PowerShell"}
)

$featuresToEnable = @()

foreach ($feature in $features) {
    $state = Get-WindowsOptionalFeature -Online -FeatureName $feature.Name -ErrorAction SilentlyContinue

    if ($null -eq $state) {
        Write-Host "  [?] $($feature.DisplayName) - Not available on this system"
    } elseif ($state.State -eq "Enabled") {
        Write-ColorOutput "$($feature.DisplayName) is already enabled" -Type Success
    } else {
        Write-ColorOutput "$($feature.DisplayName) is disabled" -Type Warning
        $featuresToEnable += $feature
    }
}

# ====================================
# ENABLE FEATURES
# ====================================

if ($featuresToEnable.Count -eq 0) {
    Write-Host ""
    Write-ColorOutput "All required features are already enabled!" -Type Success
    Write-Host ""
    Write-Host "You can now use Windows Sandbox."
    pause
    exit 0
}

Write-Host ""
Write-Host "The following features will be enabled:"
foreach ($feature in $featuresToEnable) {
    Write-Host "  - $($feature.DisplayName)"
}
Write-Host ""

$confirm = Read-Host "Enable these features? This will require a restart. (y/N)"

if ($confirm -notmatch '^[Yy]') {
    Write-ColorOutput "Operation cancelled by user" -Type Warning
    pause
    exit 0
}

Write-Host ""
Write-ColorOutput "Enabling Windows features... This may take several minutes." -Type Info

$rebootRequired = $false

# Enable Windows Sandbox
try {
    Write-ColorOutput "Enabling Windows Sandbox..." -Type Info
    $result = Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart

    if ($result.RestartNeeded) {
        $rebootRequired = $true
    }

    Write-ColorOutput "Windows Sandbox feature enabled successfully" -Type Success
} catch {
    Write-ColorOutput "Failed to enable Windows Sandbox: $($_.Exception.Message)" -Type Error

    # Try alternative method using DISM
    Write-ColorOutput "Trying alternative method (DISM)..." -Type Info

    try {
        $dismResult = dism /online /Enable-Feature /FeatureName:Containers-DisposableClientVM /All /NoRestart

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "Windows Sandbox enabled via DISM" -Type Success
            $rebootRequired = $true
        } else {
            Write-ColorOutput "DISM also failed. Manual intervention required." -Type Error
        }
    } catch {
        Write-ColorOutput "Both methods failed: $($_.Exception.Message)" -Type Error
    }
}

# Optional: Enable Hyper-V components (some systems may need this)
if ($virtEnabled) {
    Write-Host ""
    $enableHyperV = Read-Host "Enable Hyper-V platform? (Recommended) (y/N)"

    if ($enableHyperV -match '^[Yy]') {
        try {
            Write-ColorOutput "Enabling Hyper-V platform..." -Type Info

            $hvResult = Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -All -NoRestart -ErrorAction SilentlyContinue

            if ($null -ne $hvResult -and $hvResult.RestartNeeded) {
                $rebootRequired = $true
            }

            Write-ColorOutput "Hyper-V platform enabled" -Type Success
        } catch {
            Write-ColorOutput "Hyper-V enablement skipped (may not be needed)" -Type Warning
        }
    }
}

# ====================================
# RESTART PROMPT
# ====================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Yellow
Write-Host " Feature Enablement Complete" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""

if ($rebootRequired) {
    Write-ColorOutput "A restart is REQUIRED for changes to take effect" -Type Warning
    Write-Host ""

    $restart = Read-Host "Restart now? (y/N)"

    if ($restart -match '^[Yy]') {
        Write-ColorOutput "Restarting computer in 10 seconds..." -Type Warning
        Write-Host "Save all your work!"
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } else {
        Write-ColorOutput "Please restart your computer manually to complete setup" -Type Warning
        Write-Host ""
        Write-Host "After restart, you can:"
        Write-Host "  1. Run sandman.ps1 to create sandbox configurations"
        Write-Host "  2. Launch Windows Sandbox from the Start Menu"
        Write-Host ""
    }
} else {
    Write-ColorOutput "No restart required. Windows Sandbox is ready to use!" -Type Success
}

pause
