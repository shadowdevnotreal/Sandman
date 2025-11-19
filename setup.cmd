@echo off
REM Sandman Setup Script for Windows
REM Version 1.0.0

setlocal enabledelayedexpansion

echo ========================================
echo Sandman - Windows Setup
echo ========================================
echo.

REM ====================================
REM CUSTOMIZABLE PATHS
REM Edit these paths for your local system
REM ====================================

REM Installation directory
SET "SANDMAN_HOME=%~dp0"

REM Workspace directory (where .wsb files will be stored)
SET "WORKSPACE=%USERPROFILE%\Documents\wsb-files"

REM ====================================
REM PRE-INSTALL PACKAGES
REM Edit this list to add tools you want
REM installed inside the sandbox
REM ====================================

REM Check if Chocolatey is installed
where choco >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [!] Chocolatey not found. Skipping package installation.
    echo [i] To install Chocolatey, visit: https://chocolatey.org/install
    goto :skip_packages
)

echo [*] Chocolatey found. Ready to install packages.
echo.
echo The following packages can be pre-installed:
echo   - git
echo   - nodejs
echo   - python
echo   - vscode
echo   - notepadplusplus
echo.

choice /C YN /M "Do you want to install recommended packages"
if !ERRORLEVEL! EQU 1 (
    echo [*] Installing packages...

    REM Install Git
    echo [*] Installing Git...
    choco install -y git

    REM Install Node.js (optional - uncomment if needed)
    REM echo [*] Installing Node.js...
    REM choco install -y nodejs

    REM Install Python (optional - uncomment if needed)
    REM echo [*] Installing Python...
    REM choco install -y python

    REM Install VS Code (optional - uncomment if needed)
    REM echo [*] Installing VS Code...
    REM choco install -y vscode

    REM Install Notepad++ (optional - uncomment if needed)
    REM echo [*] Installing Notepad++...
    REM choco install -y notepadplusplus

    echo [+] Package installation complete!
) else (
    echo [*] Skipping package installation.
)

:skip_packages

REM ====================================
REM CREATE WORKSPACE DIRECTORY
REM ====================================

echo.
echo [*] Creating workspace directory...

if not exist "%WORKSPACE%" (
    mkdir "%WORKSPACE%"
    echo [+] Created: %WORKSPACE%
) else (
    echo [i] Workspace already exists: %WORKSPACE%
)

REM ====================================
REM CREATE SUBDIRECTORIES
REM ====================================

if not exist "%WORKSPACE%\templates" mkdir "%WORKSPACE%\templates"
if not exist "%WORKSPACE%\backups" mkdir "%WORKSPACE%\backups"
if not exist "%WORKSPACE%\logs" mkdir "%WORKSPACE%\logs"

echo [+] Subdirectories created.

REM ====================================
REM CHECK WINDOWS SANDBOX AVAILABILITY
REM ====================================

echo.
echo [*] Checking Windows Sandbox availability...

REM Check if running on Windows 10 Pro/Enterprise or Windows 11
ver | findstr /i "10.0" >nul
if %ERRORLEVEL% EQU 0 (
    echo [i] Windows 10/11 detected.

    REM Check if Windows Sandbox is enabled
    dism /online /Get-Capability | findstr /i "WindowsSandbox" | findstr /i "State.*Installed" >nul
    if %ERRORLEVEL% EQU 0 (
        echo [+] Windows Sandbox is ENABLED.
    ) else (
        echo [!] Windows Sandbox is NOT enabled.
        echo [i] To enable Windows Sandbox:
        echo     1. Open Settings
        echo     2. Go to Apps ^> Optional Features
        echo     3. Click "More Windows features"
        echo     4. Check "Windows Sandbox"
        echo     5. Restart your computer
    )
) else (
    echo [!] Windows Sandbox requires Windows 10 Pro/Enterprise or Windows 11.
)

REM ====================================
REM COPY ENHANCED SCRIPT
REM ====================================

echo.
echo [*] Setting up Sandman scripts...

if exist "%SANDMAN_HOME%wsb-manager-enhanced.ps1" (
    copy /Y "%SANDMAN_HOME%wsb-manager-enhanced.ps1" "%SANDMAN_HOME%sandman.ps1" >nul
    echo [+] Enhanced script copied to sandman.ps1
) else if exist "%SANDMAN_HOME%wsb-manager-fixed.ps1" (
    copy /Y "%SANDMAN_HOME%wsb-manager-fixed.ps1" "%SANDMAN_HOME%sandman.ps1" >nul
    echo [+] Fixed script copied to sandman.ps1
) else (
    echo [!] No PowerShell script found. Please ensure scripts are in the correct location.
)

REM ====================================
REM CREATE START MENU SHORTCUT
REM ====================================

echo.
choice /C YN /M "Create Start Menu shortcut"
if !ERRORLEVEL! EQU 1 (
    REM Create a batch file launcher
    echo @echo off > "%WORKSPACE%\Launch-Sandman.cmd"
    echo PowerShell -ExecutionPolicy Bypass -File "%SANDMAN_HOME%sandman.ps1" >> "%WORKSPACE%\Launch-Sandman.cmd"

    echo [+] Launcher created: %WORKSPACE%\Launch-Sandman.cmd
    echo [i] You can pin this to your Start Menu or Taskbar.
)

REM ====================================
REM UPDATE CONFIG.JSON
REM ====================================

echo.
echo [*] Checking configuration file...

if exist "%SANDMAN_HOME%config.json" (
    echo [+] Configuration file found: config.json
    echo [i] You can edit config.json to customize settings.
) else (
    echo [!] Configuration file not found.
    echo [i] A default config.json will be created on first run.
)

REM ====================================
REM SETUP COMPLETE
REM ====================================

echo.
echo ========================================
echo Setup Complete!
echo ========================================
echo.
echo Next steps:
echo   1. Run sandman.ps1 to start the manager:
echo      PowerShell -ExecutionPolicy Bypass -File sandman.ps1
echo.
echo   2. Or use the launcher:
echo      %WORKSPACE%\Launch-Sandman.cmd
echo.
echo   3. Create your first sandbox configuration:
echo      Press [1] in the menu
echo.
echo Workspace: %WORKSPACE%
echo.

pause
endlocal
