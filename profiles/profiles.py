#!/usr/bin/env python3
"""
Sandman Quick Launch Profiles

Create and manage one-click preset environments for common scenarios.
"""

import json
import os
import subprocess
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime


class ProfileManager:
    """Manage quick launch profiles"""

    def __init__(self, profiles_file: Optional[str] = None):
        """Initialize profile manager"""
        if profiles_file:
            self.profiles_file = Path(profiles_file)
        else:
            workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
            self.profiles_file = Path(workspace) / "profiles.json"

        self.data = self._load_data()

    def _load_data(self) -> Dict:
        """Load profiles data from file"""
        if self.profiles_file.exists():
            try:
                with open(self.profiles_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass

        # Initialize new profiles structure
        return {
            "version": "1.0",
            "profiles": {},
            "default_profile": None
        }

    def _save_data(self):
        """Save profiles data to file"""
        self.profiles_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.profiles_file, 'w') as f:
            json.dump(self.data, f, indent=2)

    def create_profile(self, name: str, config_name: str, description: str = "",
                      hotkey: Optional[str] = None, icon: Optional[str] = None,
                      tags: Optional[List[str]] = None) -> Tuple[bool, str]:
        """Create a new quick launch profile"""
        if name in self.data["profiles"]:
            return False, f"Profile '{name}' already exists"

        # Verify config exists
        workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
        config_path = Path(workspace) / f"{config_name}.wsb"
        if not config_path.exists():
            return False, f"Configuration '{config_name}' not found"

        profile = {
            "config_name": config_name,
            "description": description or f"Quick launch for {config_name}",
            "hotkey": hotkey,
            "icon": icon or "⚡",
            "tags": tags or [],
            "created": datetime.now().isoformat(),
            "last_used": None,
            "launch_count": 0
        }

        self.data["profiles"][name] = profile
        self._save_data()

        return True, f"Profile '{name}' created successfully"

    def get_profile(self, name: str) -> Optional[Dict]:
        """Get a specific profile"""
        profile = self.data["profiles"].get(name)
        if profile:
            profile["name"] = name
        return profile

    def list_profiles(self, tag: Optional[str] = None) -> List[Dict]:
        """List all profiles, optionally filtered by tag"""
        profiles = []
        for name, profile in self.data["profiles"].items():
            if tag and tag not in profile.get("tags", []):
                continue

            profile_data = profile.copy()
            profile_data["name"] = name
            profiles.append(profile_data)

        # Sort by launch count (most used first)
        profiles.sort(key=lambda x: x.get("launch_count", 0), reverse=True)
        return profiles

    def update_profile(self, name: str, **kwargs) -> Tuple[bool, str]:
        """Update profile properties"""
        if name not in self.data["profiles"]:
            return False, f"Profile '{name}' not found"

        profile = self.data["profiles"][name]

        # Update allowed fields
        allowed_fields = ["description", "hotkey", "icon", "tags", "config_name"]
        for key, value in kwargs.items():
            if key in allowed_fields and value is not None:
                profile[key] = value

        self._save_data()
        return True, f"Profile '{name}' updated successfully"

    def delete_profile(self, name: str) -> Tuple[bool, str]:
        """Delete a profile"""
        if name not in self.data["profiles"]:
            return False, f"Profile '{name}' not found"

        del self.data["profiles"][name]

        # Clear default if this was it
        if self.data["default_profile"] == name:
            self.data["default_profile"] = None

        self._save_data()
        return True, f"Profile '{name}' deleted successfully"

    def launch_profile(self, name: str) -> Tuple[bool, str]:
        """Launch a sandbox using a profile"""
        if name not in self.data["profiles"]:
            return False, f"Profile '{name}' not found"

        profile = self.data["profiles"][name]
        config_name = profile["config_name"]

        # Build path to config
        workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
        config_path = Path(workspace) / f"{config_name}.wsb"

        if not config_path.exists():
            return False, f"Configuration '{config_name}' not found at {config_path}"

        # Launch Windows Sandbox
        try:
            subprocess.Popen(
                ["WindowsSandbox.exe", str(config_path)],
                shell=True
            )

            # Update usage statistics
            profile["last_used"] = datetime.now().isoformat()
            profile["launch_count"] = profile.get("launch_count", 0) + 1
            self._save_data()

            return True, f"Launched profile '{name}' with configuration '{config_name}'"
        except Exception as e:
            return False, f"Failed to launch sandbox: {e}"

    def set_default_profile(self, name: str) -> Tuple[bool, str]:
        """Set a profile as the default"""
        if name not in self.data["profiles"]:
            return False, f"Profile '{name}' not found"

        self.data["default_profile"] = name
        self._save_data()
        return True, f"Profile '{name}' set as default"

    def get_default_profile(self) -> Optional[Dict]:
        """Get the default profile"""
        default_name = self.data.get("default_profile")
        if default_name:
            return self.get_profile(default_name)
        return None

    def launch_default(self) -> Tuple[bool, str]:
        """Launch the default profile"""
        default_name = self.data.get("default_profile")
        if not default_name:
            return False, "No default profile set"

        return self.launch_profile(default_name)

    def get_profiles_by_tag(self, tag: str) -> List[Dict]:
        """Get all profiles with a specific tag"""
        return self.list_profiles(tag=tag)

    def get_all_tags(self) -> List[str]:
        """Get all unique tags"""
        tags = set()
        for profile in self.data["profiles"].values():
            tags.update(profile.get("tags", []))
        return sorted(list(tags))

    def get_statistics(self) -> Dict:
        """Get profile usage statistics"""
        total_profiles = len(self.data["profiles"])
        total_launches = sum(
            p.get("launch_count", 0) for p in self.data["profiles"].values()
        )

        most_used = None
        if self.data["profiles"]:
            most_used_name = max(
                self.data["profiles"].items(),
                key=lambda x: x[1].get("launch_count", 0)
            )[0]
            most_used = self.get_profile(most_used_name)

        return {
            "total_profiles": total_profiles,
            "total_launches": total_launches,
            "most_used_profile": most_used,
            "default_profile": self.data.get("default_profile"),
            "unique_tags": len(self.get_all_tags())
        }

    def export_profile(self, name: str, output_path: str) -> Tuple[bool, str]:
        """Export a profile to a JSON file"""
        if name not in self.data["profiles"]:
            return False, f"Profile '{name}' not found"

        profile = self.get_profile(name)

        try:
            output_file = Path(output_path)
            output_file.parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, 'w') as f:
                json.dump(profile, f, indent=2)
            return True, f"Profile exported to {output_path}"
        except IOError as e:
            return False, f"Failed to export profile: {e}"

    def import_profile(self, input_path: str, name: Optional[str] = None) -> Tuple[bool, str]:
        """Import a profile from a JSON file"""
        try:
            with open(input_path, 'r') as f:
                profile_data = json.load(f)

            # Use provided name or original name
            profile_name = name or profile_data.get("name", Path(input_path).stem)

            # Remove name from profile data if present
            profile_data.pop("name", None)

            # Verify required fields
            if "config_name" not in profile_data:
                return False, "Invalid profile: missing 'config_name' field"

            # Check if profile already exists
            if profile_name in self.data["profiles"]:
                return False, f"Profile '{profile_name}' already exists"

            self.data["profiles"][profile_name] = profile_data
            self._save_data()

            return True, f"Profile '{profile_name}' imported successfully"
        except (IOError, json.JSONDecodeError) as e:
            return False, f"Failed to import profile: {e}"

    def create_desktop_shortcut(self, profile_name: str, desktop_path: Optional[str] = None) -> Tuple[bool, str]:
        """Create a desktop shortcut for a profile"""
        if profile_name not in self.data["profiles"]:
            return False, f"Profile '{profile_name}' not found"

        if not desktop_path:
            desktop_path = os.path.join(
                os.path.expandvars("%USERPROFILE%"),
                "Desktop",
                f"Sandman - {profile_name}.lnk"
            )

        profile = self.data["profiles"][profile_name]
        config_name = profile["config_name"]
        workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
        config_path = Path(workspace) / f"{config_name}.wsb"

        # Create PowerShell script to create shortcut
        ps_script = f'''
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("{desktop_path}")
$Shortcut.TargetPath = "WindowsSandbox.exe"
$Shortcut.Arguments = '"{config_path}"'
$Shortcut.Description = "{profile['description']}"
$Shortcut.Save()
'''

        try:
            subprocess.run(
                ["powershell", "-Command", ps_script],
                check=True,
                capture_output=True
            )
            return True, f"Desktop shortcut created: {desktop_path}"
        except subprocess.CalledProcessError as e:
            return False, f"Failed to create shortcut: {e}"


# CLI Interface
if __name__ == "__main__":
    import sys

    pm = ProfileManager()

    if len(sys.argv) > 1:
        command = sys.argv[1].lower()

        if command == "create" and len(sys.argv) >= 4:
            name = sys.argv[2]
            config_name = sys.argv[3]
            description = sys.argv[4] if len(sys.argv) > 4 else ""
            success, message = pm.create_profile(name, config_name, description)
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "list":
            tag = sys.argv[2] if len(sys.argv) > 2 else None
            profiles = pm.list_profiles(tag=tag)
            if not profiles:
                print("No profiles found")
            else:
                print(f"📋 Quick Launch Profiles ({len(profiles)})")
                print("-" * 80)
                for profile in profiles:
                    icon = profile.get("icon", "⚡")
                    name = profile["name"]
                    desc = profile.get("description", "")
                    launches = profile.get("launch_count", 0)
                    print(f"{icon} {name}")
                    print(f"  {desc}")
                    print(f"  Config: {profile['config_name']} | Launches: {launches}")
                    if profile.get("tags"):
                        print(f"  Tags: {', '.join(profile['tags'])}")
                    print()

        elif command == "launch" and len(sys.argv) >= 3:
            name = sys.argv[2]
            success, message = pm.launch_profile(name)
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "delete" and len(sys.argv) >= 3:
            name = sys.argv[2]
            success, message = pm.delete_profile(name)
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "default" and len(sys.argv) >= 3:
            name = sys.argv[2]
            success, message = pm.set_default_profile(name)
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "stats":
            stats = pm.get_statistics()
            print("📊 Profile Statistics")
            print("-" * 80)
            print(f"Total Profiles:     {stats['total_profiles']}")
            print(f"Total Launches:     {stats['total_launches']}")
            print(f"Default Profile:    {stats['default_profile'] or 'None'}")
            print(f"Unique Tags:        {stats['unique_tags']}")
            if stats['most_used_profile']:
                profile = stats['most_used_profile']
                print(f"\nMost Used Profile:  {profile['name']}")
                print(f"  Launches:         {profile['launch_count']}")

        elif command == "shortcut" and len(sys.argv) >= 3:
            name = sys.argv[2]
            success, message = pm.create_desktop_shortcut(name)
            print(f"{'✓' if success else '✗'} {message}")

        else:
            print("Usage:")
            print("  python profiles.py create <name> <config> [description]  - Create profile")
            print("  python profiles.py list [tag]                            - List profiles")
            print("  python profiles.py launch <name>                         - Launch profile")
            print("  python profiles.py delete <name>                         - Delete profile")
            print("  python profiles.py default <name>                        - Set default")
            print("  python profiles.py stats                                 - Show statistics")
            print("  python profiles.py shortcut <name>                       - Create desktop shortcut")
    else:
        profiles = pm.list_profiles()
        if not profiles:
            print("No quick launch profiles configured.")
            print("Create one with: python profiles.py create <name> <config>")
        else:
            print(f"✓ {len(profiles)} quick launch profiles")
            for profile in profiles[:5]:
                print(f"  {profile.get('icon', '⚡')} {profile['name']} → {profile['config_name']}")
