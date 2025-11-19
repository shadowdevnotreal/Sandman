# Sandman Web UI Guide

Beautiful browser-based interface for managing Windows Sandbox configurations.

## 🌐 Quick Start

### Installation

The web UI uses Python Flask. Install requirements:

```powershell
# Install Flask
pip install flask

# Or using requirements.txt
pip install -r web/requirements.txt
```

### Launch

```powershell
# From the Sandman root directory
python web/app.py
```

Then open your browser to: **http://localhost:5000**

## ✨ Features

### 📋 Configuration Management

- **List Configurations**: View all your .wsb files with metadata
- **Create New**: Interactive form with real-time validation
- **View Details**: See all settings at a glance
- **Download**: Export configurations as .wsb files
- **Delete**: Remove unwanted configurations

### 📦 Template System

- Browse available templates
- Apply templates with custom names
- Visual template cards with descriptions

### 🎨 Beautiful Interface

- Modern, responsive design
- Tab-based navigation
- Real-time updates
- Toast notifications
- Collapsible sections

## 📸 Screenshots

### Main Dashboard
View and manage all your configurations in a grid layout.

### Create New Configuration
Interactive form with:
- Memory slider (256MB - 128GB)
- Network toggle
- vGPU settings
- Audio/Video controls
- Mapped folders
- Protection options

### Templates Gallery
Pre-configured templates for common use cases.

## 🔧 Configuration

The web UI reads from the same workspace as other Sandman versions:

- **Workspace**: `%USERPROFILE%\Documents\wsb-files`
- **Templates**: `templates/` directory

## 🎯 Use Cases

### Quick Testing
1. Open web UI
2. Select a template
3. Apply with new name
4. Download and launch

### Team Sharing
1. Create configuration in web UI
2. Download .wsb file
3. Share via email/chat
4. Team members import it

### Batch Management
1. View all configurations
2. Delete old ones
3. Create new variants
4. Export favorites

## 🔐 Security

- **Local Only**: Runs on localhost by default
- **No Auth**: Designed for single-user local use
- **File System**: Only accesses workspace directory

## 🚀 Advanced Usage

### Custom Port

```python
# Edit web/app.py
app.run(host='0.0.0.0', port=8080, debug=True)
```

### Network Access

To access from other devices on your network:

```python
# Edit web/app.py
app.run(host='0.0.0.0', port=5000, debug=True)
```

Then access from other devices: `http://<your-ip>:5000`

**Warning**: Only do this on trusted networks!

### Production Deployment

For production use with gunicorn:

```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 web.app:app
```

## 📝 API Endpoints

The web UI exposes a REST API:

### GET /api/configs
List all configurations

### GET /api/config/<name>
Get configuration details

### POST /api/config
Create new configuration

### PUT /api/config/<name>
Update configuration

### DELETE /api/config/<name>
Delete configuration

### GET /api/config/<name>/download
Download configuration file

### GET /api/templates
List available templates

### POST /api/template/<name>/apply
Apply template

## 🎨 Customization

### Change Colors

Edit `web/static/css/styles.css`:

```css
:root {
    --primary-color: #4a90e2;  /* Change to your color */
    --secondary-color: #50c878;
}
```

### Add Custom Features

The web UI is built with Flask and vanilla JavaScript - easy to extend!

## 🐛 Troubleshooting

### Port Already in Use

```powershell
# Change port in web/app.py
app.run(host='0.0.0.0', port=8080)
```

### Flask Not Found

```powershell
pip install flask
```

### Configurations Not Showing

Check workspace path:
- Default: `%USERPROFILE%\Documents\wsb-files`
- Ensure .wsb files are in this directory

### CORS Errors

If accessing from different origin:

```python
# Install flask-cors
pip install flask-cors

# Add to web/app.py
from flask_cors import CORS
CORS(app)
```

## 💡 Tips

1. **Bookmark It**: Add http://localhost:5000 to your browser favorites
2. **Keep It Running**: Leave the server running for quick access
3. **Use Templates**: Start with templates and modify
4. **Export Often**: Download important configurations as backups

## 🔗 Related Documentation

- [Quick Start Guide](QUICK_START.md)
- [Script Versions](SCRIPT_VERSIONS.md)
- [PowerShell Module](POWERSHELL_MODULE.md)
