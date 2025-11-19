@{
    # Module metadata
    RootModule = 'Sandman.psm1'
    ModuleVersion = '1.1.0'
    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
    Author = 'Sandman Contributors'
    CompanyName = 'Sandman'
    Copyright = '(c) 2025 Sandman Contributors. All rights reserved.'
    Description = 'PowerShell module for managing Windows Sandbox configurations. Create, modify, and launch sandbox environments with ease.'

    # Minimum PowerShell version
    PowerShellVersion = '5.1'

    # Functions to export
    FunctionsToExport = @(
        'New-SandmanConfig',
        'Get-SandmanConfig',
        'Remove-SandmanConfig',
        'Start-Sandman',
        'Export-SandmanConfig',
        'Import-SandmanConfig',
        'Get-SandmanTemplate'
    )

    # Cmdlets to export
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = @()

    # Aliases to export
    AliasesToExport = @()

    # Private data
    PrivateData = @{
        PSData = @{
            Tags = @('Windows', 'Sandbox', 'Security', 'Virtualization', 'Testing')
            LicenseUri = 'https://github.com/shadowdevnotreal/Sandman/blob/main/LICENSE'
            ProjectUri = 'https://github.com/shadowdevnotreal/Sandman'
            ReleaseNotes = 'Initial release of Sandman PowerShell module with configuration management cmdlets.'
        }
    }
}
