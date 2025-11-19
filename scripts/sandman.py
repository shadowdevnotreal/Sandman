#!/usr/bin/env python3
"""
Sandman - Windows Sandbox Manager (Python Edition)
Version 1.0.0

Manages Windows Sandbox .wsb configuration files
Works on Windows with Python 3.6+
"""

import os
import sys
import json
import shutil
import subprocess
import xml.etree.ElementTree as ET
import xml.dom.minidom as minidom
from pathlib import Path
from datetime import datetime
from typing import Optional, Dict, List

# Configuration defaults
DEFAULT_CONFIG = {
    "workspace": os.path.join(os.environ.get("USERPROFILE", ""), "Documents", "wsb-files"),
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": True,
    "backupSuffix": ".bak",
    "editor": "notepad.exe"
}

# Allowed values (Windows Sandbox specification)
ALLOWED_VALUES = {
    "Networking": ["Default", "Disable"],
    "VGpu": ["Default", "Disable"],
    "AudioInput": ["Default", "Enable", "Disable"],
    "VideoInput": ["Default", "Enable", "Disable"],
    "PrinterRedirection": ["Enable", "Disable"],
    "ClipboardRedirection": ["Enable", "Disable"],
    "ProtectedClient": ["Enable", "Disable"],
    "ReadOnly": ["true", "false"]
}

MIN_MEMORY_MB = 256
MAX_MEMORY_MB = 131072  # 128 GB


class Colors:
    """ANSI color codes for terminal output"""
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    CYAN = '\033[96m'
    RESET = '\033[0m'

    @staticmethod
    def colorize(text: str, color: str) -> str:
        return f"{color}{text}{Colors.RESET}"


class SandmanConfig:
    """Load and manage Sandman configuration"""

    def __init__(self, config_path: str = "config.json"):
        self.config_path = config_path
        self.config = self.load()

    def load(self) -> Dict:
        """Load configuration from JSON file"""
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, 'r') as f:
                    user_config = json.load(f)

                # Merge with defaults
                config = DEFAULT_CONFIG.copy()
                if "workspace" in user_config:
                    config["workspace"] = user_config["workspace"].get("windows", config["workspace"])
                if "sandbox" in user_config:
                    config.update(user_config["sandbox"])
                if "editor" in user_config:
                    config["editor"] = user_config["editor"].get("windows", config["editor"])

                # Expand environment variables
                config["workspace"] = os.path.expandvars(config["workspace"])

                return config
            except Exception as e:
                print(Colors.colorize(f"Warning: Could not load config: {e}", Colors.YELLOW))
                return DEFAULT_CONFIG
        return DEFAULT_CONFIG

    def get(self, key: str, default=None):
        return self.config.get(key, default)


class WsbManager:
    """Windows Sandbox .wsb file manager"""

    def __init__(self, config: SandmanConfig):
        self.config = config
        self.workspace = Path(config.get("workspace"))
        self.ensure_workspace()

    def ensure_workspace(self):
        """Create workspace directory if it doesn't exist"""
        self.workspace.mkdir(parents=True, exist_ok=True)
        (self.workspace / "backups").mkdir(exist_ok=True)

    def list_files(self) -> List[Path]:
        """List all .wsb files in workspace"""
        return sorted(self.workspace.glob("*.wsb"), key=lambda p: p.stat().st_mtime, reverse=True)

    def create_xml(self, **kwargs) -> str:
        """Create Windows Sandbox XML configuration"""
        root = ET.Element("Configuration")

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
            elem = ET.SubElement(root, key)
            elem.text = value

        # Add mapped folders if specified
        folders = kwargs.get("mapped_folders", [])
        if folders:
            mapped_folders = ET.SubElement(root, "MappedFolders")
            for folder_info in folders:
                folder = ET.SubElement(mapped_folders, "MappedFolder")

                host_folder = ET.SubElement(folder, "HostFolder")
                host_folder.text = folder_info["path"]

                read_only = ET.SubElement(folder, "ReadOnly")
                read_only.text = "true" if folder_info.get("readonly", True) else "false"

        # Pretty print XML
        rough_string = ET.tostring(root, encoding='unicode')
        reparsed = minidom.parseString(rough_string)
        return reparsed.toprettyxml(indent="  ")

    def save_wsb(self, path: Path, xml_content: str, backup: bool = True):
        """Save .wsb file with optional backup"""
        if backup and path.exists():
            backup_path = path.with_suffix(path.suffix + self.config.get("backupSuffix", ".bak"))
            shutil.copy2(path, backup_path)

        with open(path, 'w', encoding='utf-8') as f:
            f.write(xml_content)

        print(Colors.colorize(f"✓ Saved: {path}", Colors.GREEN))

    def validate_wsb(self, path: Path) -> tuple:
        """Validate .wsb file and return (is_valid, errors)"""
        errors = []

        try:
            tree = ET.parse(path)
            root = tree.getroot()

            # Validate memory
            memory_elem = root.find("MemoryInMB")
            if memory_elem is not None:
                try:
                    memory = int(memory_elem.text)
                    if memory < MIN_MEMORY_MB or memory > MAX_MEMORY_MB:
                        errors.append(f"Memory out of range ({MIN_MEMORY_MB}-{MAX_MEMORY_MB}): {memory}")
                except ValueError:
                    errors.append(f"Invalid memory value: {memory_elem.text}")

            # Validate allowed values
            for key, allowed in ALLOWED_VALUES.items():
                if key == "ReadOnly":
                    continue  # Handled separately for mapped folders

                elem = root.find(key)
                if elem is not None and elem.text not in allowed:
                    errors.append(f"Invalid {key} value: '{elem.text}' (allowed: {', '.join(allowed)})")

            # Validate mapped folders
            mapped_folders = root.find("MappedFolders")
            if mapped_folders is not None:
                for folder in mapped_folders.findall("MappedFolder"):
                    host_folder = folder.find("HostFolder")
                    if host_folder is None or not host_folder.text:
                        errors.append("MappedFolder missing HostFolder")
                    elif not os.path.exists(host_folder.text):
                        errors.append(f"HostFolder does not exist: {host_folder.text}")

                    read_only = folder.find("ReadOnly")
                    if read_only is not None and read_only.text not in ALLOWED_VALUES["ReadOnly"]:
                        errors.append(f"Invalid ReadOnly value: {read_only.text}")

        except ET.ParseError as e:
            errors.append(f"XML parsing error: {e}")

        return (len(errors) == 0, errors)

    def launch_sandbox(self, path: Path):
        """Launch Windows Sandbox with configuration file"""
        # Validate first
        is_valid, errors = self.validate_wsb(path)

        if not is_valid:
            print(Colors.colorize("✗ Cannot launch: Validation failed", Colors.RED))
            for error in errors:
                print(Colors.colorize(f"  - {error}", Colors.RED))
            return False

        try:
            subprocess.Popen([str(path)], shell=True)
            print(Colors.colorize("✓ Windows Sandbox launched", Colors.GREEN))
            return True
        except Exception as e:
            print(Colors.colorize(f"✗ Failed to launch: {e}", Colors.RED))
            return False


class SandmanUI:
    """Command-line user interface"""

    def __init__(self):
        self.config = SandmanConfig()
        self.manager = WsbManager(self.config)

    def clear_screen(self):
        os.system('cls' if os.name == 'nt' else 'clear')

    def prompt(self, message: str, default: str = "") -> str:
        """Prompt user for input"""
        if default:
            user_input = input(f"{message} [{default}]: ").strip()
            return user_input if user_input else default
        return input(f"{message}: ").strip()

    def confirm(self, message: str) -> bool:
        """Prompt for yes/no confirmation"""
        response = input(f"{message} (y/N): ").strip().lower()
        return response in ['y', 'yes']

    def select_file(self, prompt_msg: str = "Select file") -> Optional[Path]:
        """Show file list and let user select one"""
        files = self.manager.list_files()

        if not files:
            print(Colors.colorize("No .wsb files found.", Colors.YELLOW))
            return None

        print()
        for i, file in enumerate(files, 1):
            mtime = datetime.fromtimestamp(file.stat().st_mtime).strftime("%Y-%m-%d %H:%M")
            print(f"  [{i}] {file.name}  (Modified: {mtime})")

        print()
        try:
            choice = int(input(f"{prompt_msg} (number): ").strip())
            if 1 <= choice <= len(files):
                return files[choice - 1]
        except (ValueError, IndexError):
            pass

        print(Colors.colorize("Invalid selection", Colors.RED))
        return None

    def action_create(self):
        """Create new .wsb configuration"""
        self.clear_screen()
        print(Colors.colorize("=== Create New .wsb Configuration ===", Colors.CYAN))
        print()

        name = self.prompt("Filename (no extension)")
        if not name:
            return

        output_path = self.manager.workspace / f"{name}.wsb"

        if output_path.exists() and not self.confirm("File exists. Overwrite?"):
            return

        # Get configuration parameters
        memory = self.prompt("Memory MB", str(self.config.get("defaultMemoryMB", 4096)))
        try:
            memory = int(memory)
        except ValueError:
            memory = 4096

        networking = "Default" if self.confirm("Enable networking?") else "Disable"

        # Mapped folders
        mapped_folders = []
        if self.confirm("Add mapped folder?"):
            folder_path = self.prompt("Folder path (e.g., C:\\myshare)")
            if folder_path:
                readonly = not self.confirm("Read/Write access? (y=RW, N=RO)")
                mapped_folders.append({"path": folder_path, "readonly": readonly})

                # Create folder if it doesn't exist
                if not os.path.exists(folder_path) and self.confirm(f"Create folder '{folder_path}'?"):
                    os.makedirs(folder_path, exist_ok=True)
                    print(Colors.colorize(f"✓ Created {folder_path}", Colors.GREEN))

        # Generate XML
        xml_content = self.manager.create_xml(
            memory_mb=memory,
            networking=networking,
            mapped_folders=mapped_folders
        )

        # Save
        self.manager.save_wsb(output_path, xml_content)

        if self.confirm("Open in editor?"):
            subprocess.Popen([self.config.get("editor", "notepad.exe"), str(output_path)])

    def action_list(self):
        """List all .wsb files"""
        self.clear_screen()
        print(Colors.colorize(f"=== Files in {self.manager.workspace} ===", Colors.CYAN))

        files = self.manager.list_files()

        if not files:
            print(Colors.colorize("No .wsb files found.", Colors.YELLOW))
            return

        for i, file in enumerate(files, 1):
            mtime = datetime.fromtimestamp(file.stat().st_mtime).strftime("%Y-%m-%d %H:%M:%S")
            size = file.stat().st_size
            print(f"  [{i}] {file.name}")
            print(f"      Modified: {mtime}, Size: {size} bytes")

    def action_edit(self):
        """Edit .wsb file"""
        self.clear_screen()
        file_path = self.select_file("Edit file")

        if file_path:
            subprocess.Popen([self.config.get("editor", "notepad.exe"), str(file_path)])
            print(Colors.colorize("✓ Opened in editor", Colors.GREEN))

    def action_validate(self):
        """Validate .wsb file"""
        self.clear_screen()
        file_path = self.select_file("Validate file")

        if not file_path:
            return

        print()
        print(Colors.colorize(f"=== Validating {file_path.name} ===", Colors.CYAN))

        is_valid, errors = self.manager.validate_wsb(file_path)

        if is_valid:
            print(Colors.colorize("✓ VALID - Configuration is ready to use", Colors.GREEN))

            # Show summary
            try:
                tree = ET.parse(file_path)
                root = tree.getroot()

                print("\nConfiguration Summary:")
                for elem in root:
                    if elem.tag != "MappedFolders":
                        print(f"  {elem.tag}: {elem.text}")

                mapped_folders = root.find("MappedFolders")
                if mapped_folders is not None:
                    for folder in mapped_folders.findall("MappedFolder"):
                        host = folder.find("HostFolder").text
                        ro = folder.find("ReadOnly").text
                        print(f"  Mapped: {host} (ReadOnly={ro})")
            except Exception:
                pass
        else:
            print(Colors.colorize("✗ INVALID - Errors found:", Colors.RED))
            for error in errors:
                print(Colors.colorize(f"  - {error}", Colors.RED))

    def action_launch(self):
        """Launch Windows Sandbox"""
        self.clear_screen()
        file_path = self.select_file("Launch file")

        if file_path:
            print()
            self.manager.launch_sandbox(file_path)

    def main_menu(self):
        """Display main menu and handle user input"""
        while True:
            print()
            print(Colors.colorize("=== Sandman - Windows Sandbox Manager (Python) ===", Colors.YELLOW))
            print(f"Workspace: {self.manager.workspace}")
            print()
            print("[1] Create new .wsb")
            print("[2] List .wsb files")
            print("[3] Edit (open in editor)")
            print("[4] Validate & Inspect")
            print("[5] Launch Windows Sandbox")
            print("[q] Quit")
            print()

            choice = input("Select option: ").strip().lower()

            try:
                if choice == '1':
                    self.action_create()
                elif choice == '2':
                    self.action_list()
                elif choice == '3':
                    self.action_edit()
                elif choice == '4':
                    self.action_validate()
                elif choice == '5':
                    self.action_launch()
                elif choice in ['q', 'quit', 'exit']:
                    print(Colors.colorize("Goodbye!", Colors.GREEN))
                    break
                else:
                    print(Colors.colorize("Invalid option", Colors.RED))
            except KeyboardInterrupt:
                print()
                if self.confirm("Quit Sandman?"):
                    break
            except Exception as e:
                print(Colors.colorize(f"Error: {e}", Colors.RED))

            input("\nPress Enter to continue...")


def main():
    """Entry point"""
    if sys.platform != "win32":
        print("Warning: This tool is designed for Windows. Some features may not work.")

    ui = SandmanUI()
    ui.main_menu()


if __name__ == "__main__":
    main()
