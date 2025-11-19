<#
Windows Sandbox .wsb Manager (v3 - Enhanced)
- Create / List / Edit / Validate / Modify / Launch
- Multi-modification mode with preview
- Improved error handling
#>

#region Helpers & Globals
$ErrorActionPreference = "Stop"

function Ensure-Dir { param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { New-Item -ItemType Directory -Path $Path -Force | Out-Null }
}

function Confirm-Y { param([string]$Prompt="Proceed? (y/N)")
  $a = Read-Host $Prompt
  return $a -match '^(y|yes)$'
}

function Prompt-Choice($msg, [string[]]$choices) {
  Write-Host $msg
  for ($i=0; $i -lt $choices.Length; $i++) { Write-Host ("  [{0}] {1}" -f ($i+1), $choices[$i]) }
  $sel = Read-Host "Choose (number)"
  if ($sel -match '^\d+$' -and $sel -ge 1 -and $sel -le $choices.Length) { return $choices[$sel-1] }
  return $null
}

$Workspace = Join-Path $env:USERPROFILE "Documents\wsb-files"
Ensure-Dir $Workspace

# Allowed values (casing matters)
$Allowed = @{
  Networking            = @("Default","Disable")
  VGpu                  = @("Default","Disable")
  AudioInput            = @("Default","Enable","Disable")
  VideoInput            = @("Default","Enable","Disable")
  PrinterRedirection    = @("Enable","Disable")
  ClipboardRedirection  = @("Enable","Disable")
  ProtectedClient       = @("Enable","Disable")
  ReadOnly              = @("true","false")
}
$MinMemoryMB = 256
$MaxMemoryMB = 131072  # 128 GiB upper bound
#endregion

#region XML Template/IO
function New-WsbTemplate {
  param(
    [int]$MemoryMB = 4096,
    [string]$Networking = "Default",
    [string]$VGpu = "Default",
    [string]$AudioInput = "Default",
    [string]$VideoInput = "Default",
    [string]$PrinterRedirection = "Enable",
    [string]$ClipboardRedirection = "Enable",
    [string]$ProtectedClient = "Enable",
    [string]$HostFolder = "",
    [bool]$HostFolderReadOnly = $true
  )
  $doc = New-Object System.Xml.XmlDocument
  $null = $doc.AppendChild($doc.CreateXmlDeclaration("1.0","utf-8",$null))
  $root = $doc.CreateElement("Configuration")
  $null = $doc.AppendChild($root)

  foreach ($kv in @{
    Networking           = $Networking
    VGpu                 = $VGpu
    MemoryInMB           = $MemoryMB
    AudioInput           = $AudioInput
    VideoInput           = $VideoInput
    PrinterRedirection   = $PrinterRedirection
    ClipboardRedirection = $ClipboardRedirection
    ProtectedClient      = $ProtectedClient
  }.GetEnumerator()) {
    $e = $doc.CreateElement($kv.Key); $e.InnerText = [string]$kv.Value
    $null = $root.AppendChild($e)
  }

  if ($HostFolder) {
    $mapped = $doc.CreateElement("MappedFolders")
    $mf = $doc.CreateElement("MappedFolder")
    $hf = $doc.CreateElement("HostFolder"); $hf.InnerText = $HostFolder
    $ro = $doc.CreateElement("ReadOnly");   $ro.InnerText = $(if ($HostFolderReadOnly) {"true"} else {"false"})
    $null = $mf.AppendChild($hf)
    $null = $mf.AppendChild($ro)
    $null = $mapped.AppendChild($mf)
    $null = $root.AppendChild($mapped)
  }
  Format-Xml -Doc $doc
}

function Format-Xml { param([xml]$Doc)
  $ms = New-Object System.IO.MemoryStream
  $xw = New-Object System.Xml.XmlTextWriter($ms,[Text.Encoding]::UTF8)
  $xw.Formatting = "Indented"; $xw.Indentation = 2
  $Doc.WriteContentTo($xw); $xw.Flush(); $ms.Position = 0
  $sr = New-Object System.IO.StreamReader($ms,[Text.Encoding]::UTF8)
  [xml]$pretty = $sr.ReadToEnd()
  return $pretty
}

function Save-WsbXml { param([xml]$XmlText, [string]$Path)
  # backup, atomic write with error handling
  if (Test-Path -LiteralPath $Path) {
    try {
      Copy-Item -LiteralPath $Path -Destination ($Path + ".bak") -Force -ErrorAction Stop
    } catch {
      Write-Host "Warning: Could not create backup: $($_.Exception.Message)" -ForegroundColor Yellow
    }
  }
  $tmp = [System.IO.Path]::GetTempFileName()
  Set-Content -LiteralPath $tmp -Value $XmlText -Encoding UTF8
  Move-Item -LiteralPath $tmp -Destination $Path -Force
  Write-Host "Saved: $Path" -ForegroundColor Green
}

function Load-WsbXml { param([string]$Path)
  $raw = Get-Content -LiteralPath $Path -Raw
  try { [xml]$doc = $raw; return @{Ok=$true; Doc=$doc} }
  catch { return @{Ok=$false; Error=$_.Exception.Message} }
}
#endregion

#region Validation
function Validate-Values { param([xml]$Doc)
  $errs = @()
  foreach ($k in $Allowed.Keys) {
    if ($k -eq "ReadOnly") { continue } # handled per mapped folder
    $node = $Doc.Configuration.$k
    if ($null -ne $node) {
      $val = $node.'#text'
      if ($Allowed[$k] -notcontains $val) {
        $errs += "Invalid value for <$k>: '$val' (allowed: $($Allowed[$k] -join '|'))"
      }
    }
  }
  $mem = $Doc.Configuration.MemoryInMB.'#text'
  if ($mem -and -not ($mem -as [int])) { $errs += "MemoryInMB is not an integer: '$mem'" }
  elseif ($mem) {
    $m = [int]$mem
    if ($m -lt $MinMemoryMB -or $m -gt $MaxMemoryMB) {
      $errs += "MemoryInMB out of range ($MinMemoryMB-$MaxMemoryMB): $m"
    }
  }
  # mapped folders
  if ($Doc.Configuration.MappedFolders) {
    foreach ($mf in $Doc.Configuration.MappedFolders.MappedFolder) {
      $hf = $mf.HostFolder.'#text'
      $ro = $mf.ReadOnly.'#text'
      if (-not $hf) { $errs += "MappedFolder missing <HostFolder>" }
      elseif (-not (Test-Path -LiteralPath $hf)) {
        $errs += "HostFolder does not exist: $hf"
      }
      if ($ro -and $Allowed.ReadOnly -notcontains $ro) {
        $errs += "Invalid <ReadOnly> value '$ro' (allowed: true|false)"
      }
    }
  }
  return $errs
}
#endregion

#region Listing/Editing
function List-WsbFiles { param([string]$Dir=$Workspace)
  Get-ChildItem -LiteralPath $Dir -Filter *.wsb -File -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending |
    Select-Object Name, FullName, LastWriteTime
}

function Open-In-Editor { param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { Write-Host "Not found: $Path" -ForegroundColor Red; return }
  Start-Process notepad.exe -ArgumentList $Path -Wait
}

function Show-CurrentConfig {
  param([xml]$Doc)
  Write-Host "`n=== Current Configuration ===" -ForegroundColor Cyan
  Write-Host "Memory: $($Doc.Configuration.MemoryInMB.'#text') MB"
  Write-Host "Networking: $($Doc.Configuration.Networking.'#text')"
  Write-Host "VGpu: $($Doc.Configuration.VGpu.'#text')"
  Write-Host "AudioInput: $($Doc.Configuration.AudioInput.'#text')"
  Write-Host "VideoInput: $($Doc.Configuration.VideoInput.'#text')"
  Write-Host "PrinterRedirection: $($Doc.Configuration.PrinterRedirection.'#text')"
  Write-Host "ClipboardRedirection: $($Doc.Configuration.ClipboardRedirection.'#text')"
  Write-Host "ProtectedClient: $($Doc.Configuration.ProtectedClient.'#text')"
  if ($Doc.Configuration.MappedFolders) {
    Write-Host "Mapped Folders:"
    $i = 1
    foreach ($mf in $Doc.Configuration.MappedFolders.MappedFolder) {
      Write-Host "  [$i] $($mf.HostFolder.'#text') (ReadOnly: $($mf.ReadOnly.'#text'))"
      $i++
    }
  } else {
    Write-Host "Mapped Folders: None"
  }
  Write-Host "==============================`n" -ForegroundColor Cyan
}
#endregion

#region Actions
function Action-Create {
  Clear-Host; Write-Host "Create new .wsb" -ForegroundColor Cyan
  $name = Read-Host "Filename (no extension)"; if ([string]::IsNullOrWhiteSpace($name)) { return }
  $out = Join-Path $Workspace ($name + ".wsb")
  if (Test-Path -LiteralPath $out -and -not (Confirm-Y "File exists. Overwrite? (y/N)")) { return }

  $mem = Read-Host "Memory MB [4096]"
  $mem = if ($mem -as [int]) { [int]$mem } else { 4096 }
  $hf  = Read-Host "Host folder to map (blank = none) e.g. C:\myshare"
  $ro  = $true
  if ($hf) { $ro = -not (Confirm-Y "Read/Write? Set ReadOnly=false? (y=RW, N=RO)") }

  $doc = New-WsbTemplate -MemoryMB $mem -HostFolder $hf -HostFolderReadOnly:$ro
  Save-WsbXml -XmlText $doc.OuterXml -Path $out

  if ($hf -and -not (Test-Path -LiteralPath $hf)) {
    if (Confirm-Y "Create missing host folder '$hf'? (y/N)") {
      New-Item -ItemType Directory -Path $hf -Force | Out-Null
      Write-Host "Created $hf"
    } else {
      Write-Host "Note: launching will fail until the folder exists."
    }
  }
  if (Confirm-Y "Open now in Notepad? (y/N)") { Open-In-Editor -Path $out }
}

function Action-List {
  Clear-Host; Write-Host ".wsb files in workspace:" -ForegroundColor Cyan
  $list = List-WsbFiles
  if (-not $list) { Write-Host "No files found."; return }
  $list | Format-Table -Property Name, @{Name="Modified"; Expression={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")}} -AutoSize
}

function Action-Edit {
  Clear-Host; $list = List-WsbFiles
  if (-not $list) { Write-Host "No files."; return }
  $files = $list.FullName
  for ($i=0; $i -lt $files.Length; $i++) { Write-Host ("[{0}] {1}" -f ($i+1),(Split-Path $files[$i] -Leaf)) }
  $sel = Read-Host "Edit file #"; if ($sel -notmatch '^\d+$' -or $sel -lt 1 -or $sel -gt $files.Length) { return }
  Open-In-Editor -Path $files[$sel-1]
}

function Action-Validate {
  Clear-Host; $list = List-WsbFiles
  if (-not $list) { Write-Host "No files."; return }
  $files = $list.FullName
  for ($i=0; $i -lt $files.Length; $i++) { Write-Host ("[{0}] {1}" -f ($i+1),(Split-Path $files[$i] -Leaf)) }
  $sel = Read-Host "Validate file #"; if ($sel -notmatch '^\d+$' -or $sel -lt 1 -or $sel -gt $files.Length) { return }
  $path = $files[$sel-1]

  $res = Load-WsbXml -Path $path
  if (-not $res.Ok) { Write-Host "XML error: $($res.Error)" -ForegroundColor Red; return }
  $errs = Validate-Values -Doc $res.Doc

  if ($errs.Count -eq 0) {
    Write-Host "VALID ✅" -ForegroundColor Green
    Write-Host "File: $path"
  } else {
    Write-Host "INVALID ❌" -ForegroundColor Red
    $errs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  }

  # Check for missing host folders
  if ($res.Doc.Configuration.MappedFolders) {
    $missing = @()
    foreach ($mf in $res.Doc.Configuration.MappedFolders.MappedFolder) {
      $p = $mf.HostFolder.'#text'
      if ($p -and -not (Test-Path -LiteralPath $p)) { $missing += $p }
    }
    if ($missing.Count -gt 0) {
      Write-Host "`nMissing host folders:" -ForegroundColor Yellow
      $missing | ForEach-Object { Write-Host "  - $_" }
    }
    foreach ($p in $missing) {
      if (Confirm-Y "Create missing host folder '$p'? (y/N)") {
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        Write-Host "Created $p"
      }
    }
  }
}

function Action-Modify {
  Clear-Host; $list = List-WsbFiles
  if (-not $list) { Write-Host "No files."; return }
  $files = $list.FullName
  for ($i=0; $i -lt $files.Length; $i++) { Write-Host ("[{0}] {1}" -f ($i+1),(Split-Path $files[$i] -Leaf)) }
  $sel = Read-Host "Modify file #"; if ($sel -notmatch '^\d+$' -or $sel -lt 1 -or $sel -gt $files.Length) { return }
  $path = $files[$sel-1]

  $res = Load-WsbXml -Path $path
  if (-not $res.Ok) { Write-Host "XML error: $($res.Error)" -ForegroundColor Red; return }
  [xml]$doc = $res.Doc
  $changesMade = $false

  # Multi-modification loop
  while ($true) {
    Clear-Host
    Write-Host "Editing: $(Split-Path $path -Leaf)" -ForegroundColor Yellow
    if ($changesMade) { Write-Host "⚠ Unsaved changes" -ForegroundColor Yellow }
    Show-CurrentConfig -Doc $doc
    
    $choice = Prompt-Choice "Select modification" @(
      "Add mapped folder",
      "Remove mapped folder(s)",
      "Set Memory",
      "Set Networking",
      "Set vGPU",
      "Set AudioInput",
      "Set VideoInput",
      "Toggle PrinterRedirection",
      "Toggle ClipboardRedirection",
      "Toggle ProtectedClient",
      "--- SAVE & EXIT ---",
      "--- DISCARD & EXIT ---",
      "Open raw file in Notepad"
    )
    
    switch ($choice) {
      "Add mapped folder" {
        $hf = Read-Host "HostFolder path (e.g., C:\myshare)"; if (-not $hf) { continue }
        $ro = if (Confirm-Y "Read/Write? Set ReadOnly=false? (y/N)") {"false"} else {"true"}
        if ($null -eq $doc.Configuration.MappedFolders) {
          $mfNode = $doc.CreateElement("MappedFolders"); $null = $doc.Configuration.AppendChild($mfNode)
        } else { $mfNode = $doc.Configuration.MappedFolders }
        $newMf = $doc.CreateElement("MappedFolder")
        $hfe = $doc.CreateElement("HostFolder"); $hfe.InnerText = $hf
        $roe = $doc.CreateElement("ReadOnly");   $roe.InnerText = $ro
        $null = $newMf.AppendChild($hfe); $null = $newMf.AppendChild($roe)
        $null = $mfNode.AppendChild($newMf)
        $changesMade = $true
        Write-Host "✓ Added mapped folder" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Remove mapped folder(s)" {
        if ($null -eq $doc.Configuration.MappedFolders) { Write-Host "None."; Start-Sleep -Seconds 1; continue }
        $m = @($doc.Configuration.MappedFolders.MappedFolder)
        for ($i=0; $i -lt $m.Count; $i++) {
          Write-Host ("[{0}] {1} (RO={2})" -f ($i+1),$m[$i].HostFolder.'#text',$m[$i].ReadOnly.'#text')
        }
        $x = Read-Host "Enter # to remove or 'all'"
        if ($x -eq 'all') { 
          $null = $doc.Configuration.RemoveChild($doc.Configuration.MappedFolders)
          $changesMade = $true
          Write-Host "✓ Removed all mapped folders" -ForegroundColor Green
          Start-Sleep -Milliseconds 500
        }
        elseif ($x -match '^\d+$' -and $x -ge 1 -and $x -le $m.Count) {
          $null = $doc.Configuration.MappedFolders.RemoveChild($m[$x-1])
          $changesMade = $true
          Write-Host "✓ Removed mapped folder" -ForegroundColor Green
          Start-Sleep -Milliseconds 500
        }
      }
      "Set Memory" {
        $current = $doc.Configuration.MemoryInMB.'#text'
        $m = Read-Host "Memory MB (current: $current) [$MinMemoryMB-$MaxMemoryMB]"
        if (-not ($m -as [int])) { Write-Host "Invalid"; Start-Sleep -Seconds 1; continue }
        $m = [int]$m; if ($m -lt $MinMemoryMB -or $m -gt $MaxMemoryMB) { Write-Host "Out of range"; Start-Sleep -Seconds 1; continue }
        if ($null -eq $doc.Configuration.MemoryInMB) {
          $e = $doc.CreateElement("MemoryInMB"); $e.InnerText = "$m"; $null = $doc.Configuration.AppendChild($e)
        } else { $doc.Configuration.MemoryInMB = "$m" }
        $changesMade = $true
        Write-Host "✓ Memory set to $m MB" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Set Networking" {
        $current = $doc.Configuration.Networking.'#text'
        $v = Read-Host "Networking (current: $current) [Default/Disable]"
        if ($Allowed.Networking -notcontains $v) { Write-Host "Invalid"; Start-Sleep -Seconds 1; continue }
        if ($null -eq $doc.Configuration.Networking) { $e=$doc.CreateElement("Networking"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.Networking = $v
        $changesMade = $true
        Write-Host "✓ Networking=$v" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Set vGPU" {
        $current = $doc.Configuration.VGpu.'#text'
        $v = Read-Host "VGpu (current: $current) [Default/Disable]"
        if ($Allowed.VGpu -notcontains $v) { Write-Host "Invalid"; Start-Sleep -Seconds 1; continue }
        if ($null -eq $doc.Configuration.VGpu) { $e=$doc.CreateElement("VGpu"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.VGpu = $v
        $changesMade = $true
        Write-Host "✓ VGpu=$v" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Set AudioInput" {
        $current = $doc.Configuration.AudioInput.'#text'
        $v = Read-Host "AudioInput (current: $current) [Default/Enable/Disable]"
        if ($Allowed.AudioInput -notcontains $v) { Write-Host "Invalid"; Start-Sleep -Seconds 1; continue }
        if ($null -eq $doc.Configuration.AudioInput) { $e=$doc.CreateElement("AudioInput"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.AudioInput = $v
        $changesMade = $true
        Write-Host "✓ AudioInput=$v" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Set VideoInput" {
        $current = $doc.Configuration.VideoInput.'#text'
        $v = Read-Host "VideoInput (current: $current) [Default/Enable/Disable]"
        if ($Allowed.VideoInput -notcontains $v) { Write-Host "Invalid"; Start-Sleep -Seconds 1; continue }
        if ($null -eq $doc.Configuration.VideoInput) { $e=$doc.CreateElement("VideoInput"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.VideoInput = $v
        $changesMade = $true
        Write-Host "✓ VideoInput=$v" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Toggle PrinterRedirection" {
        $cur = $doc.Configuration.PrinterRedirection.'#text'; $new = $(if ($cur -eq "Enable") {"Disable"} else {"Enable"})
        if ($null -eq $doc.Configuration.PrinterRedirection) { $e=$doc.CreateElement("PrinterRedirection"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.PrinterRedirection = $new
        $changesMade = $true
        Write-Host "✓ PrinterRedirection=$new" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Toggle ClipboardRedirection" {
        $cur = $doc.Configuration.ClipboardRedirection.'#text'; $new = $(if ($cur -eq "Enable") {"Disable"} else {"Enable"})
        if ($null -eq $doc.Configuration.ClipboardRedirection) { $e=$doc.CreateElement("ClipboardRedirection"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.ClipboardRedirection = $new
        $changesMade = $true
        Write-Host "✓ ClipboardRedirection=$new" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "Toggle ProtectedClient" {
        $cur = $doc.Configuration.ProtectedClient.'#text'; $new = $(if ($cur -eq "Enable") {"Disable"} else {"Enable"})
        if ($null -eq $doc.Configuration.ProtectedClient) { $e=$doc.CreateElement("ProtectedClient"); $null=$doc.Configuration.AppendChild($e) }
        $doc.Configuration.ProtectedClient = $new
        $changesMade = $true
        Write-Host "✓ ProtectedClient=$new" -ForegroundColor Green
        Start-Sleep -Milliseconds 500
      }
      "--- SAVE & EXIT ---" {
        if ($changesMade) {
          Write-Host "`nSaving changes..." -ForegroundColor Yellow
          $pretty = Format-Xml -Doc $doc
          Save-WsbXml -XmlText $pretty.OuterXml -Path $path
          Write-Host "All changes saved successfully!`n" -ForegroundColor Green
          Start-Sleep -Seconds 1
        } else {
          Write-Host "No changes made." -ForegroundColor Yellow
          Start-Sleep -Seconds 1
        }
        return
      }
      "--- DISCARD & EXIT ---" {
        if ($changesMade -and -not (Confirm-Y "Discard all changes? (y/N)")) { continue }
        Write-Host "Changes discarded." -ForegroundColor Yellow
        Start-Sleep -Seconds 1
        return
      }
      "Open raw file in Notepad" {
        # Save current changes before opening
        if ($changesMade) {
          if (Confirm-Y "Save changes before opening in Notepad? (y/N)") {
            $pretty = Format-Xml -Doc $doc
            Save-WsbXml -XmlText $pretty.OuterXml -Path $path
            Write-Host "Changes saved." -ForegroundColor Green
            $changesMade = $false
          }
        }
        Open-In-Editor -Path $path
        # Reload after editing
        if (Confirm-Y "Reload file after editing? (y/N)") {
          $res = Load-WsbXml -Path $path
          if ($res.Ok) {
            $doc = $res.Doc
            $changesMade = $false
            Write-Host "File reloaded." -ForegroundColor Green
            Start-Sleep -Seconds 1
          } else {
            Write-Host "Failed to reload: $($res.Error)" -ForegroundColor Red
            Start-Sleep -Seconds 2
          }
        }
      }
      default { return }
    }
  }
}

function Action-Launch {
  Clear-Host; $list = List-WsbFiles
  if (-not $list) { Write-Host "No files."; return }
  $files = $list.FullName
  for ($i=0; $i -lt $files.Length; $i++) { Write-Host ("[{0}] {1}" -f ($i+1),(Split-Path $files[$i] -Leaf)) }
  $sel = Read-Host "Launch file #"; if ($sel -notmatch '^\d+$' -or $sel -lt 1 -or $sel -gt $files.Length) { return }
  $path = $files[$sel-1]

  # Validate first
  $res = Load-WsbXml -Path $path
  if (-not $res.Ok) { Write-Host "XML error: $($res.Error)" -ForegroundColor Red; return }
  $errs = Validate-Values -Doc $res.Doc
  if ($errs.Count -gt 0) {
    Write-Host "Cannot launch. Fix issues first:" -ForegroundColor Red
    $errs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    return
  }

  if (Confirm-Y "Validation passed. Launch Sandbox with this file? (y/N)") {
    try {
      Start-Process -FilePath $path | Out-Null
      Write-Host "Launched."
    } catch {
      Write-Host "Failed to launch: $($_.Exception.Message)" -ForegroundColor Red
    }
  }
}
#endregion

#region Samples & Menu
function Action-ExportSamples {
  Clear-Host
  Write-Host "Exporting sample templates to $Workspace" -ForegroundColor Cyan
  $full   = New-WsbTemplate -MemoryMB 8192 -HostFolder "C:\myshare" -HostFolderReadOnly:$true
  Save-WsbXml -XmlText $full.OuterXml -Path (Join-Path $Workspace "sample-full.wsb")

  $secure = New-WsbTemplate -MemoryMB 2048 -Networking "Disable" -VGpu "Disable" -AudioInput "Disable" -VideoInput "Disable" -HostFolder "" -ProtectedClient "Enable"
  Save-WsbXml -XmlText $secure.OuterXml -Path (Join-Path $Workspace "sample-secure.wsb")

  $minimal = New-WsbTemplate -MemoryMB 2048
  Save-WsbXml -XmlText $minimal.OuterXml -Path (Join-Path $Workspace "sample-minimal.wsb")
  Write-Host "Done."
}

function Main-Loop {
  while ($true) {
    Write-Host ""
    Write-Host "=== Windows Sandbox .wsb Manager (v3 Enhanced) ===" -ForegroundColor Yellow
    Write-Host "Workspace: $Workspace"
    Write-Host "[1] Create new .wsb"
    Write-Host "[2] List .wsb files"
    Write-Host "[3] Edit (open in Notepad)"
    Write-Host "[4] Validate & Inspect"
    Write-Host "[5] Modify (multi-change mode)"
    Write-Host "[6] Export sample templates"
    Write-Host "[7] Launch (validate first)"
    Write-Host "[q] Quit"
    $c = Read-Host "Select option"
    switch ($c) {
      '1' { Action-Create }
      '2' { Action-List }
      '3' { Action-Edit }
      '4' { Action-Validate }
      '5' { Action-Modify }
      '6' { Action-ExportSamples }
      '7' { Action-Launch }
      'q' { break }
      'Q' { break }
      default { Write-Host "Unknown option" }
    }
  }
  Write-Host "Goodbye."
}
#endregion

#region Aliases (session-scoped)
Set-Alias -Name New-Sandbox     -Value Action-Create     -Scope Local -ErrorAction SilentlyContinue
Set-Alias -Name Edit-Sandbox    -Value Action-Edit       -Scope Local -ErrorAction SilentlyContinue
Set-Alias -Name Launch-Sandbox  -Value Action-Launch     -Scope Local -ErrorAction SilentlyContinue
#endregion

# Entrypoint
if ($MyInvocation.InvocationName -ne '.') { Main-Loop }
