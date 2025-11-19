# Sandman Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2024-11-19

### 🎉 Major Release - Advanced Management Features

This release adds powerful new capabilities for tracking, managing, and organizing your Windows Sandbox configurations!

### Added

#### 📊 Usage Analytics
Track and analyze your sandbox usage patterns with comprehensive analytics:

- **Launch Tracking**: Automatically track every sandbox launch
- **Statistics Dashboard**: View total launches, runtime, and averages
- **Configuration Analytics**: See which configs are used most
- **Template Analytics**: Track template popularity
- **Time-Based Analysis**: Usage by date, hour, and time periods
- **Export Capabilities**: Export data to CSV for external analysis
- **Summary Reports**: Human-readable usage reports

**Features:**
- Launch frequency tracking
- Runtime statistics
- Usage trends visualization
- Top configurations and templates
- Historical data retention (last 1000 launches)

**Files Added:**
- `analytics/analytics.py` - Analytics tracking system (400+ lines)
- `analytics/README.md` - Analytics documentation

#### 🔄 Configuration Version Control
Full Git integration for tracking configuration changes:

- **Git Integration**: Complete Git version control system
- **Commit History**: Track all changes with timestamps and messages
- **Revert Capability**: Roll back to any previous version
- **Diff Viewing**: See what changed between versions
- **Auto-Commit**: Optionally auto-commit on configuration changes
- **Tags**: Create milestone tags for important configurations
- **Export History**: Export configurations from any commit

**Features:**
- Initialize Git repository in workspace
- Commit individual or all configurations
- View commit history
- Compare versions with diff
- Revert to previous commits
- Create and manage tags
- Auto-commit support

**Files Added:**
- `versioncontrol/config_git.py` - Git integration system (500+ lines)
- `versioncontrol/README.md` - Version control documentation

#### 🎯 Quick Launch Profiles
One-click preset environments for common scenarios:

- **Quick Launch**: Launch sandboxes with a single command
- **Profile Management**: Create, update, and delete profiles
- **Desktop Shortcuts**: Create clickable desktop shortcuts
- **Default Profile**: Set a default for instant launching
- **Tags**: Organize profiles by category
- **Usage Tracking**: See which profiles you use most
- **Import/Export**: Share profiles with your team

**Features:**
- One-command launching
- Desktop shortcut creation (.lnk files)
- Tag-based organization
- Profile statistics
- Default profile support
- Import/export capabilities

**Files Added:**
- `profiles/profiles.py` - Profile management system (400+ lines)
- `profiles/README.md` - Profiles documentation

#### 🔔 Desktop Notifications
Windows toast notifications for sandbox events:

- **Launch Notifications**: Know when sandboxes start
- **Error Notifications**: Get alerted to problems immediately
- **Completion Notifications**: Track when operations finish
- **Warning Notifications**: Stay informed about issues
- **Custom Notifications**: Send your own notifications
- **Configurable**: Enable/disable sounds and notification types
- **History Tracking**: See all past notifications

**Features:**
- Windows 10/11 toast notifications
- PowerShell-based notification system
- Configurable sound settings
- Notification type filtering
- History tracking (last 1000 notifications)
- Notification statistics

**Files Added:**
- `notifications/notifier.py` - Notification system (500+ lines)
- `notifications/README.md` - Notifications documentation

### Changed

- README updated to highlight v1.2.0 features
- Version badge updated to 1.2.0
- Project structure expanded to show new directories
- Feature table expanded with 4 new features
- Roadmap reorganized to show v1.2.0 as completed
- Project Status section updated with v1.2.0 statistics

### Statistics

- **Files Added:** 8
- **Lines of Code:** 2,800+
  - Python: ~2,200 lines
  - Documentation: ~600 lines
- **New Features:** 4 major features
- **Documentation Guides:** 4 new comprehensive guides

### Technical Details

**Usage Analytics:**
- Tracks launch events with timestamps
- Stores data in JSON format
- Generates CSV exports for analysis
- Maintains configuration and template statistics

**Version Control:**
- Uses Git for version tracking
- Supports all standard Git operations
- Auto-creates .gitignore for workspace
- Integrates with existing Git workflows

**Quick Launch Profiles:**
- JSON-based profile storage
- Windows shortcut creation via PowerShell
- Tag-based organization system
- Usage statistics tracking

**Desktop Notifications:**
- Windows.UI.Notifications API
- PowerShell toast notification implementation
- Fallback notification methods
- Configurable notification preferences

---

## [1.1.0] - 2024-11-19

### 🎉 Major Release - Comprehensive Feature Expansion

This is a massive update that transforms Sandman from a script tool into a comprehensive, professional-grade Windows Sandbox management platform!

### Added

#### 🌐 Web-Based UI
- Beautiful Flask-based web interface at `http://localhost:5000`
- Tab-based navigation (Configurations, Create, Templates, About)
- Real-time configuration validation
- Configuration CRUD operations (Create, Read, Update, Delete)
- Template application and management
- Download configurations as .wsb files
- Toast notifications for user feedback
- Responsive design for different screen sizes
- Modern gradient UI with smooth animations
- REST API with 8 endpoints

**Files Added:**
- `web/app.py` - Flask server implementation
- `web/templates/index.html` - Main HTML interface
- `web/static/css/styles.css` - Styling and animations
- `web/static/js/app.js` - Interactive JavaScript
- `web/requirements.txt` - Python dependencies

#### 📦 Specialized Templates (7 New!)
Expanded from 4 to 11 templates for specific use cases:

**New Templates:**
- `gaming-test-sandbox.wsb` - 16GB RAM, vGPU enabled for game testing
- `malware-analysis-sandbox.wsb` - Maximum isolation, no network, for threat analysis
- `web-browsing-sandbox.wsb` - 4GB RAM, protected browsing environment
- `nodejs-development-sandbox.wsb` - 8GB RAM, optimized for Node.js development
- `office-documents-sandbox.wsb` - 4GB RAM, safe environment for testing documents
- `python-data-science-sandbox.wsb` - 16GB RAM, for ML and data analysis
- `software-testing-sandbox.wsb` - 6GB RAM, general purpose testing

**Existing Templates:**
- `minimal-sandbox.wsb`
- `secure-sandbox.wsb`
- `development-sandbox.wsb`
- `Full-Sandbox.wsb`

All templates include:
- Detailed comments explaining configuration
- Optimized settings for specific use cases
- Commented examples of folder mappings
- Security-appropriate defaults

#### 🔌 PowerShell Module
Professional PowerShell module for scripting and automation:

**Cmdlets:**
- `New-SandmanConfig` - Create new configurations
- `Get-SandmanConfig` - List or get configuration details
- `Remove-SandmanConfig` - Delete configurations (with confirmation)
- `Start-Sandman` - Launch Windows Sandbox with configuration
- `Export-SandmanConfig` - Export configurations to any location
- `Import-SandmanConfig` - Import configurations from files
- `Get-SandmanTemplate` - List available templates

**Features:**
- Proper parameter validation
- Pipeline support
- ShouldProcess for destructive operations
- Template-based configuration creation
- Mapped folder support
- Comprehensive help documentation
- Professional module manifest

**Files Added:**
- `modules/Sandman/Sandman.psm1` - Module implementation (500+ lines)
- `modules/Sandman/Sandman.psd1` - Module manifest

#### 📤 Import/Export Functionality
Share and backup configurations easily:

**PowerShell Module:**
- `Export-SandmanConfig` - Export to any destination
- `Import-SandmanConfig` - Import with original or custom name

**Web UI:**
- Download button for each configuration
- API endpoint: `GET /api/config/<name>/download`

**Use Cases:**
- Team configuration sharing
- Backup and restore workflows
- Configuration migration
- Version control integration

#### 🎨 Custom Terminal Themes
5 beautiful themes to personalize your experience:

**Themes:**
- `default.json` - Professional balanced theme
- `cyberpunk.json` - Neon-lit futuristic theme with ASCII art
- `matrix.json` - Green-on-black hacker theme
- `minimalist.json` - Clean black and white
- `ocean.json` - Calming ocean blue theme

**Features:**
- Custom color schemes
- Custom prompt symbols
- Optional ASCII art headers
- Easy JSON format
- Theme creation guide

**Files Added:**
- `themes/default.json`
- `themes/cyberpunk.json`
- `themes/matrix.json`
- `themes/minimalist.json`
- `themes/ocean.json`
- `themes/README.md` - Theme creation guide

### 📚 Documentation

**New Guides:**
- `docs/WEB_UI.md` - Complete web UI documentation (200+ lines)
- `docs/POWERSHELL_MODULE.md` - Module guide with examples (450+ lines)
- `themes/README.md` - Theme creation and customization guide

**Updated:**
- `README.md` - Major update highlighting new features
  - Added "What's New in v1.1.0" section
  - Expanded feature table to 12 features
  - Updated project structure showing new folders
  - Added templates comparison table (11 templates)
  - Updated Quick Start with web UI instructions
  - Updated version to 1.1.0
- `config.json` - Updated version to 1.1.0

### Changed

- README now prominently features new v1.1.0 capabilities
- Roadmap moved completed items to "Completed (v1.1.0)" section
- Added "Coming Soon (v1.2.0)" and "Future Ideas (v2.0.0+)" sections
- Project structure diagram expanded to show new directories
- Version badge added to README header

### Statistics

- **Files Added:** 23
- **Lines of Code:** 2,724+
  - Python (Flask): ~450 lines
  - HTML/CSS/JS: ~700 lines
  - PowerShell Module: ~500 lines
  - JSON/XML Templates: ~400 lines
  - Documentation: ~450 lines
- **New Templates:** 7 (total: 11)
- **New Themes:** 5
- **Documentation Guides:** 3
- **PowerShell Cmdlets:** 7
- **REST API Endpoints:** 8

### Technical Details

**Web UI REST API Endpoints:**
- `GET /api/configs` - List all configurations
- `GET /api/config/<name>` - Get configuration details
- `POST /api/config` - Create new configuration
- `PUT /api/config/<name>` - Update configuration
- `DELETE /api/config/<name>` - Delete configuration
- `GET /api/config/<name>/download` - Download configuration file
- `GET /api/templates` - List available templates
- `POST /api/template/<name>/apply` - Apply template

**PowerShell Module:**
- Module GUID: a1b2c3d4-e5f6-7890-abcd-ef1234567890
- Minimum PowerShell Version: 5.1
- Exports: 7 functions
- Supports: Pipeline, ShouldProcess, Parameter Validation

---

## [1.0.0] - 2024-11-18

### Initial Release

#### Added

- **Three Script Versions:**
  - PowerShell version (`sandman.ps1`, `scripts/wsb-manager-enhanced.ps1`)
  - Python version (`scripts/sandman.py`)
  - Bash version (`scripts/sandman.sh`) for WSL/Git Bash

- **Core Features:**
  - Interactive menu-driven interface
  - Multi-modification mode with live preview
  - Configuration validation
  - Automatic backup creation (.bak files)
  - Windows Sandbox feature enablement script

- **4 Initial Templates:**
  - Minimal Sandbox (2GB)
  - Secure Sandbox (2GB, no network)
  - Development Sandbox (8GB)
  - Full-Featured Sandbox (8GB)

- **Setup Scripts:**
  - `setup.cmd` - Windows installation
  - `setup.sh` - Linux/WSL installation

- **Documentation:**
  - `README.md` - Main documentation
  - `docs/QUICK_START.md` - 5-minute guide
  - `docs/SCRIPT_VERSIONS.md` - Version comparison
  - `docs/CONTRIBUTING.md` - Contribution guidelines
  - `LICENSE` - MIT License

- **Configuration Management:**
  - Create, list, edit, modify, validate, and launch configurations
  - XML-based .wsb file format
  - Workspace management at `%USERPROFILE%\Documents\wsb-files`
  - Memory allocation (256MB - 128GB)
  - Network control (enable/disable)
  - vGPU settings
  - Audio/Video input control
  - Clipboard and printer redirection
  - Protected client mode
  - Mapped folder support

#### Changed

- Repository restructured with proper folder organization
- Documentation moved to `docs/` directory
- Scripts moved to `scripts/` directory
- Templates moved to `templates/` directory

---

## Versioning

Sandman follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible changes
- **MINOR** version for new features (backwards-compatible)
- **PATCH** version for bug fixes (backwards-compatible)

## Links

- [GitHub Repository](https://github.com/shadowdevnotreal/Sandman)
- [Issue Tracker](https://github.com/shadowdevnotreal/Sandman/issues)
- [Discussions](https://github.com/shadowdevnotreal/Sandman/discussions)
