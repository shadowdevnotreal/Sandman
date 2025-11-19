#!/usr/bin/env python3
"""
Sandman Web UI - Flask-based web interface for Windows Sandbox Manager
Run with: python web/app.py
Access at: http://localhost:5000
"""

from flask import Flask, render_template, request, jsonify, send_file
import os
import sys
import json
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
from pathlib import Path
from datetime import datetime

# Add parent directory to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

app = Flask(__name__)

# Configuration
WORKSPACE = Path(os.environ.get("USERPROFILE", ""), "Documents", "wsb-files")
TEMPLATES_DIR = Path(__file__).parent.parent / "templates"

# Ensure workspace exists
WORKSPACE.mkdir(parents=True, exist_ok=True)

# Allowed values
ALLOWED_VALUES = {
    "Networking": ["Default", "Disable"],
    "VGpu": ["Default", "Disable"],
    "AudioInput": ["Default", "Enable", "Disable"],
    "VideoInput": ["Default", "Enable", "Disable"],
    "PrinterRedirection": ["Enable", "Disable"],
    "ClipboardRedirection": ["Enable", "Disable"],
    "ProtectedClient": ["Enable", "Disable"],
}

MIN_MEMORY_MB = 256
MAX_MEMORY_MB = 131072


def create_wsb_xml(**kwargs):
    """Create Windows Sandbox XML configuration"""
    doc = ET.Element("Configuration")

    # Add basic elements
    elements = {
        "Networking": kwargs.get("networking", "Default"),
        "VGpu": kwargs.get("vgpu", "Default"),
        "MemoryInMB": str(kwargs.get("memory_mb", 4096)),
        "AudioInput": kwargs.get("audio_input", "Default"),
        "VideoInput": kwargs.get("video_input", "Default"),
        "PrinterRedirection": kwargs.get("printer_redirection", "Enable"),
        "ClipboardRedirection": kwargs.get("clipboard_redirection", "Enable"),
        "ProtectedClient": kwargs.get("protected_client", "Enable")
    }

    for key, value in elements.items():
        elem = ET.SubElement(doc, key)
        elem.text = value

    # Add mapped folders if specified
    folders = kwargs.get("mapped_folders", [])
    if folders:
        mapped_folders = ET.SubElement(doc, "MappedFolders")
        for folder_info in folders:
            folder = ET.SubElement(mapped_folders, "MappedFolder")

            host_folder = ET.SubElement(folder, "HostFolder")
            host_folder.text = folder_info["path"]

            read_only = ET.SubElement(folder, "ReadOnly")
            read_only.text = "true" if folder_info.get("readonly", True) else "false"

    # Pretty print
    rough_string = ET.tostring(doc, encoding='unicode')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="  ")


def parse_wsb_file(file_path):
    """Parse .wsb file and return configuration as dict"""
    try:
        tree = ET.parse(file_path)
        root = tree.getroot()

        config = {
            "name": Path(file_path).stem,
            "memory_mb": int(root.find("MemoryInMB").text) if root.find("MemoryInMB") is not None else 4096,
            "networking": root.find("Networking").text if root.find("Networking") is not None else "Default",
            "vgpu": root.find("VGpu").text if root.find("VGpu") is not None else "Default",
            "audio_input": root.find("AudioInput").text if root.find("AudioInput") is not None else "Default",
            "video_input": root.find("VideoInput").text if root.find("VideoInput") is not None else "Default",
            "printer_redirection": root.find("PrinterRedirection").text if root.find("PrinterRedirection") is not None else "Enable",
            "clipboard_redirection": root.find("ClipboardRedirection").text if root.find("ClipboardRedirection") is not None else "Enable",
            "protected_client": root.find("ProtectedClient").text if root.find("ProtectedClient") is not None else "Enable",
            "mapped_folders": []
        }

        # Parse mapped folders
        mapped_folders_elem = root.find("MappedFolders")
        if mapped_folders_elem is not None:
            for folder in mapped_folders_elem.findall("MappedFolder"):
                host_folder = folder.find("HostFolder")
                read_only = folder.find("ReadOnly")

                if host_folder is not None:
                    config["mapped_folders"].append({
                        "path": host_folder.text,
                        "readonly": read_only.text.lower() == "true" if read_only is not None else True
                    })

        return config
    except Exception as e:
        return {"error": str(e)}


@app.route('/')
def index():
    """Main page"""
    return render_template('index.html')


@app.route('/api/configs', methods=['GET'])
def list_configs():
    """List all .wsb files"""
    try:
        files = []
        for file_path in sorted(WORKSPACE.glob("*.wsb"), key=lambda p: p.stat().st_mtime, reverse=True):
            stat = file_path.stat()
            files.append({
                "name": file_path.stem,
                "filename": file_path.name,
                "size": stat.st_size,
                "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
            })
        return jsonify({"success": True, "files": files})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/config/<name>', methods=['GET'])
def get_config(name):
    """Get configuration details"""
    try:
        file_path = WORKSPACE / f"{name}.wsb"
        if not file_path.exists():
            return jsonify({"success": False, "error": "Configuration not found"}), 404

        config = parse_wsb_file(file_path)
        if "error" in config:
            return jsonify({"success": False, "error": config["error"]}), 500

        return jsonify({"success": True, "config": config})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/config', methods=['POST'])
def create_config():
    """Create new configuration"""
    try:
        data = request.json
        name = data.get("name", "").strip()

        if not name:
            return jsonify({"success": False, "error": "Name is required"}), 400

        # Validate memory
        memory_mb = int(data.get("memory_mb", 4096))
        if memory_mb < MIN_MEMORY_MB or memory_mb > MAX_MEMORY_MB:
            return jsonify({"success": False, "error": f"Memory must be between {MIN_MEMORY_MB} and {MAX_MEMORY_MB} MB"}), 400

        # Create XML
        xml_content = create_wsb_xml(
            memory_mb=memory_mb,
            networking=data.get("networking", "Default"),
            vgpu=data.get("vgpu", "Default"),
            audio_input=data.get("audio_input", "Default"),
            video_input=data.get("video_input", "Default"),
            printer_redirection=data.get("printer_redirection", "Enable"),
            clipboard_redirection=data.get("clipboard_redirection", "Enable"),
            protected_client=data.get("protected_client", "Enable"),
            mapped_folders=data.get("mapped_folders", [])
        )

        # Save file
        file_path = WORKSPACE / f"{name}.wsb"
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(xml_content)

        return jsonify({"success": True, "message": f"Configuration '{name}' created successfully"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/config/<name>', methods=['PUT'])
def update_config(name):
    """Update existing configuration"""
    try:
        file_path = WORKSPACE / f"{name}.wsb"
        if not file_path.exists():
            return jsonify({"success": False, "error": "Configuration not found"}), 404

        data = request.json

        # Validate memory
        memory_mb = int(data.get("memory_mb", 4096))
        if memory_mb < MIN_MEMORY_MB or memory_mb > MAX_MEMORY_MB:
            return jsonify({"success": False, "error": f"Memory must be between {MIN_MEMORY_MB} and {MAX_MEMORY_MB} MB"}), 400

        # Create backup
        backup_path = file_path.with_suffix(".wsb.bak")
        if file_path.exists():
            import shutil
            shutil.copy2(file_path, backup_path)

        # Create XML
        xml_content = create_wsb_xml(
            memory_mb=memory_mb,
            networking=data.get("networking", "Default"),
            vgpu=data.get("vgpu", "Default"),
            audio_input=data.get("audio_input", "Default"),
            video_input=data.get("video_input", "Default"),
            printer_redirection=data.get("printer_redirection", "Enable"),
            clipboard_redirection=data.get("clipboard_redirection", "Enable"),
            protected_client=data.get("protected_client", "Enable"),
            mapped_folders=data.get("mapped_folders", [])
        )

        # Save file
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(xml_content)

        return jsonify({"success": True, "message": f"Configuration '{name}' updated successfully"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/config/<name>', methods=['DELETE'])
def delete_config(name):
    """Delete configuration"""
    try:
        file_path = WORKSPACE / f"{name}.wsb"
        if not file_path.exists():
            return jsonify({"success": False, "error": "Configuration not found"}), 404

        file_path.unlink()
        return jsonify({"success": True, "message": f"Configuration '{name}' deleted successfully"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/config/<name>/download', methods=['GET'])
def download_config(name):
    """Download configuration file"""
    try:
        file_path = WORKSPACE / f"{name}.wsb"
        if not file_path.exists():
            return jsonify({"success": False, "error": "Configuration not found"}), 404

        return send_file(file_path, as_attachment=True, download_name=f"{name}.wsb")
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/templates', methods=['GET'])
def list_templates():
    """List available templates"""
    try:
        templates = []
        for file_path in TEMPLATES_DIR.glob("*.wsb"):
            templates.append({
                "name": file_path.stem,
                "filename": file_path.name
            })
        return jsonify({"success": True, "templates": templates})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@app.route('/api/template/<name>/apply', methods=['POST'])
def apply_template(name):
    """Apply template to create new configuration"""
    try:
        template_path = TEMPLATES_DIR / f"{name}.wsb"
        if not template_path.exists():
            return jsonify({"success": False, "error": "Template not found"}), 404

        data = request.json
        new_name = data.get("new_name", "").strip()

        if not new_name:
            return jsonify({"success": False, "error": "New name is required"}), 400

        # Copy template to workspace
        dest_path = WORKSPACE / f"{new_name}.wsb"
        import shutil
        shutil.copy2(template_path, dest_path)

        return jsonify({"success": True, "message": f"Template '{name}' applied as '{new_name}'"})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


if __name__ == '__main__':
    print("╔════════════════════════════════════════════════════════════╗")
    print("║          Sandman Web UI - Starting Server...              ║")
    print("╚════════════════════════════════════════════════════════════╝")
    print()
    print(f"📁 Workspace: {WORKSPACE}")
    print(f"📋 Templates: {TEMPLATES_DIR}")
    print()
    print("🌐 Open your browser and navigate to:")
    print("   http://localhost:5000")
    print()
    print("Press Ctrl+C to stop the server")
    print()

    app.run(host='0.0.0.0', port=5000, debug=True)
