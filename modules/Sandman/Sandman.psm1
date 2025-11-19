<#
.SYNOPSIS
    Sandman PowerShell Module - Windows Sandbox Manager

.DESCRIPTION
    PowerShell module for managing Windows Sandbox configurations programmatically.
    Provides cmdlets for creating, modifying, and launching sandbox configurations.

.NOTES
    Version: 1.1.0
    Author: Sandman Contributors
    License: MIT
#>

#region Configuration
$script:DefaultWorkspace = Join-Path $env:USERPROFILE "Documents\wsb-files"
$script:TemplatesDir = Join-Path $PSScriptRoot "..\..\templates"

# Ensure workspace exists
if (-not (Test-Path $script:DefaultWorkspace)) {
    New-Item -ItemType Directory -Path $script:DefaultWorkspace -Force | Out-Null
}
#endregion

#region Helper Functions
function New-WsbConfiguration {
    <#
    .SYNOPSIS
        Creates a new WSB XML configuration object

    .PARAMETER MemoryMB
        Memory allocation in MB (256-131072)

    .PARAMETER Networking
        Network access (Default, Disable)

    .PARAMETER VGpu
        Virtual GPU (Default, Disable)

    .PARAMETER ProtectedClient
        Protected client mode (Enable, Disable)

    .EXAMPLE
        New-WsbConfiguration -MemoryMB 4096 -Networking Default
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateRange(256, 131072)]
        [int]$MemoryMB = 4096,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Disable")]
        [string]$Networking = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Disable")]
        [string]$VGpu = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Enable", "Disable")]
        [string]$AudioInput = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Enable", "Disable")]
        [string]$VideoInput = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Enable", "Disable")]
        [string]$PrinterRedirection = "Enable",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Enable", "Disable")]
        [string]$ClipboardRedirection = "Enable",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Enable", "Disable")]
        [string]$ProtectedClient = "Enable",

        [Parameter(Mandatory=$false)]
        [hashtable[]]$MappedFolders = @()
    )

    $doc = New-Object System.Xml.XmlDocument
    $null = $doc.AppendChild($doc.CreateXmlDeclaration("1.0", "utf-8", $null))
    $root = $doc.CreateElement("Configuration")
    $null = $doc.AppendChild($root)

    # Add configuration elements
    $elements = @{
        Networking = $Networking
        VGpu = $VGpu
        MemoryInMB = $MemoryMB
        AudioInput = $AudioInput
        VideoInput = $VideoInput
        PrinterRedirection = $PrinterRedirection
        ClipboardRedirection = $ClipboardRedirection
        ProtectedClient = $ProtectedClient
    }

    foreach ($key in $elements.Keys) {
        $elem = $doc.CreateElement($key)
        $elem.InnerText = $elements[$key].ToString()
        $null = $root.AppendChild($elem)
    }

    # Add mapped folders
    if ($MappedFolders.Count -gt 0) {
        $mappedFoldersElem = $doc.CreateElement("MappedFolders")

        foreach ($folder in $MappedFolders) {
            $folderElem = $doc.CreateElement("MappedFolder")

            $hostFolderElem = $doc.CreateElement("HostFolder")
            $hostFolderElem.InnerText = $folder.Path
            $null = $folderElem.AppendChild($hostFolderElem)

            $readOnlyElem = $doc.CreateElement("ReadOnly")
            $readOnlyElem.InnerText = if ($folder.ReadOnly) { "true" } else { "false" }
            $null = $folderElem.AppendChild($readOnlyElem)

            $null = $mappedFoldersElem.AppendChild($folderElem)
        }

        $null = $root.AppendChild($mappedFoldersElem)
    }

    return $doc
}
#endregion

#region Public Functions
function New-SandmanConfig {
    <#
    .SYNOPSIS
        Creates a new Windows Sandbox configuration file

    .DESCRIPTION
        Creates a new .wsb configuration file with specified settings

    .PARAMETER Name
        Name of the configuration (without .wsb extension)

    .PARAMETER Path
        Output path (optional, defaults to workspace)

    .PARAMETER MemoryMB
        Memory allocation in MB

    .PARAMETER Networking
        Network access (Default or Disable)

    .PARAMETER Template
        Base configuration on a template

    .EXAMPLE
        New-SandmanConfig -Name "my-sandbox" -MemoryMB 8192 -Networking Disable

    .EXAMPLE
        New-SandmanConfig -Name "dev-env" -Template "development-sandbox"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Path = $script:DefaultWorkspace,

        [Parameter(Mandatory=$false)]
        [ValidateRange(256, 131072)]
        [int]$MemoryMB = 4096,

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Disable")]
        [string]$Networking = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Default", "Disable")]
        [string]$VGpu = "Default",

        [Parameter(Mandatory=$false)]
        [ValidateSet("Enable", "Disable")]
        [string]$ProtectedClient = "Enable",

        [Parameter(Mandatory=$false)]
        [hashtable[]]$MappedFolders = @(),

        [Parameter(Mandatory=$false)]
        [string]$Template
    )

    $fileName = if ($Name.EndsWith(".wsb")) { $Name } else { "$Name.wsb" }
    $fullPath = Join-Path $Path $fileName

    if ($Template) {
        # Use template
        $templatePath = Join-Path $script:TemplatesDir "$Template.wsb"
        if (-not (Test-Path $templatePath)) {
            Write-Error "Template '$Template' not found at $templatePath"
            return
        }

        Copy-Item -Path $templatePath -Destination $fullPath -Force
        Write-Host "✓ Created '$Name' from template '$Template'" -ForegroundColor Green
    } else {
        # Create new configuration
        $doc = New-WsbConfiguration -MemoryMB $MemoryMB -Networking $Networking `
            -VGpu $VGpu -ProtectedClient $ProtectedClient -MappedFolders $MappedFolders

        # Format and save
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $settings.IndentChars = "  "
        $settings.Encoding = [System.Text.Encoding]::UTF8

        $writer = [System.Xml.XmlWriter]::Create($fullPath, $settings)
        $doc.Save($writer)
        $writer.Close()

        Write-Host "✓ Created configuration '$Name'" -ForegroundColor Green
    }

    return Get-Item $fullPath
}

function Get-SandmanConfig {
    <#
    .SYNOPSIS
        Lists or gets Windows Sandbox configurations

    .DESCRIPTION
        Lists all configurations in the workspace or gets details of a specific one

    .PARAMETER Name
        Name of specific configuration to get (optional)

    .PARAMETER Path
        Workspace path (optional)

    .EXAMPLE
        Get-SandmanConfig

    .EXAMPLE
        Get-SandmanConfig -Name "my-sandbox"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Path = $script:DefaultWorkspace
    )

    if ($Name) {
        $fileName = if ($Name.EndsWith(".wsb")) { $Name } else { "$Name.wsb" }
        $fullPath = Join-Path $Path $fileName

        if (-not (Test-Path $fullPath)) {
            Write-Error "Configuration '$Name' not found"
            return
        }

        $xml = [xml](Get-Content $fullPath)
        return [PSCustomObject]@{
            Name = [System.IO.Path]::GetFileNameWithoutExtension($fullPath)
            Path = $fullPath
            MemoryMB = [int]$xml.Configuration.MemoryInMB
            Networking = $xml.Configuration.Networking
            VGpu = $xml.Configuration.VGpu
            ProtectedClient = $xml.Configuration.ProtectedClient
            LastModified = (Get-Item $fullPath).LastWriteTime
        }
    } else {
        Get-ChildItem -Path $Path -Filter "*.wsb" | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.BaseName
                Path = $_.FullName
                Size = $_.Length
                LastModified = $_.LastWriteTime
            }
        } | Sort-Object LastModified -Descending
    }
}

function Remove-SandmanConfig {
    <#
    .SYNOPSIS
        Removes a Windows Sandbox configuration

    .PARAMETER Name
        Name of the configuration to remove

    .PARAMETER Path
        Workspace path (optional)

    .EXAMPLE
        Remove-SandmanConfig -Name "old-sandbox"
    #>
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Path = $script:DefaultWorkspace
    )

    $fileName = if ($Name.EndsWith(".wsb")) { $Name } else { "$Name.wsb" }
    $fullPath = Join-Path $Path $fileName

    if (-not (Test-Path $fullPath)) {
        Write-Error "Configuration '$Name' not found"
        return
    }

    if ($PSCmdlet.ShouldProcess($Name, "Remove configuration")) {
        Remove-Item -Path $fullPath -Force
        Write-Host "✓ Removed configuration '$Name'" -ForegroundColor Green
    }
}

function Start-Sandman {
    <#
    .SYNOPSIS
        Launches a Windows Sandbox with the specified configuration

    .PARAMETER Name
        Name of the configuration to launch

    .PARAMETER Path
        Configuration file path (optional if Name is provided)

    .EXAMPLE
        Start-Sandman -Name "my-sandbox"

    .EXAMPLE
        Start-Sandman -Path "C:\configs\test.wsb"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Name,

        [Parameter(Mandatory=$false)]
        [string]$Path
    )

    if ($Name) {
        $fileName = if ($Name.EndsWith(".wsb")) { $Name } else { "$Name.wsb" }
        $Path = Join-Path $script:DefaultWorkspace $fileName
    }

    if (-not $Path -or -not (Test-Path $Path)) {
        Write-Error "Configuration not found"
        return
    }

    Write-Host "🚀 Launching Windows Sandbox with configuration..." -ForegroundColor Cyan
    Start-Process -FilePath $Path
}

function Export-SandmanConfig {
    <#
    .SYNOPSIS
        Exports a configuration to a different location

    .PARAMETER Name
        Name of the configuration to export

    .PARAMETER Destination
        Destination path

    .EXAMPLE
        Export-SandmanConfig -Name "my-sandbox" -Destination "C:\backups\"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,

        [Parameter(Mandatory=$true)]
        [string]$Destination
    )

    $fileName = if ($Name.EndsWith(".wsb")) { $Name } else { "$Name.wsb" }
    $sourcePath = Join-Path $script:DefaultWorkspace $fileName

    if (-not (Test-Path $sourcePath)) {
        Write-Error "Configuration '$Name' not found"
        return
    }

    Copy-Item -Path $sourcePath -Destination $Destination -Force
    Write-Host "✓ Exported '$Name' to '$Destination'" -ForegroundColor Green
}

function Import-SandmanConfig {
    <#
    .SYNOPSIS
        Imports a configuration from a file

    .PARAMETER Path
        Path to the .wsb file to import

    .PARAMETER Name
        New name for the configuration (optional)

    .EXAMPLE
        Import-SandmanConfig -Path "C:\downloads\config.wsb"

    .EXAMPLE
        Import-SandmanConfig -Path "C:\downloads\config.wsb" -Name "imported-config"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path,

        [Parameter(Mandatory=$false)]
        [string]$Name
    )

    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        return
    }

    if (-not $Name) {
        $Name = [System.IO.Path]::GetFileNameWithoutExtension($Path)
    }

    $destPath = Join-Path $script:DefaultWorkspace "$Name.wsb"
    Copy-Item -Path $Path -Destination $destPath -Force

    Write-Host "✓ Imported configuration as '$Name'" -ForegroundColor Green
    return Get-Item $destPath
}

function Get-SandmanTemplate {
    <#
    .SYNOPSIS
        Lists available templates

    .EXAMPLE
        Get-SandmanTemplate
    #>
    [CmdletBinding()]
    param()

    Get-ChildItem -Path $script:TemplatesDir -Filter "*.wsb" | ForEach-Object {
        [PSCustomObject]@{
            Name = $_.BaseName
            Path = $_.FullName
            Description = "Template configuration"
        }
    }
}
#endregion

#region Module Initialization
Write-Host "🛡️  Sandman PowerShell Module loaded" -ForegroundColor Cyan
Write-Host "   Workspace: $script:DefaultWorkspace" -ForegroundColor Gray
Write-Host "   Use Get-Command -Module Sandman to see available commands" -ForegroundColor Gray
#endregion

# Export functions
Export-ModuleMember -Function @(
    'New-SandmanConfig',
    'Get-SandmanConfig',
    'Remove-SandmanConfig',
    'Start-Sandman',
    'Export-SandmanConfig',
    'Import-SandmanConfig',
    'Get-SandmanTemplate'
)
