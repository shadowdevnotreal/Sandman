#!/usr/bin/env python3
"""
Sandman Desktop Notifications

Send desktop notifications for sandbox events using Windows toast notifications.
"""

import os
import subprocess
import json
from pathlib import Path
from typing import Optional, Dict
from datetime import datetime
from enum import Enum


class NotificationType(Enum):
    """Types of notifications"""
    INFO = "info"
    SUCCESS = "success"
    WARNING = "warning"
    ERROR = "error"


class SandmanNotifier:
    """Send desktop notifications for Sandman events"""

    def __init__(self, config_file: Optional[str] = None):
        """Initialize notifier"""
        if config_file:
            self.config_file = Path(config_file)
        else:
            workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
            self.config_file = Path(workspace) / "notifications-config.json"

        self.config = self._load_config()

    def _load_config(self) -> Dict:
        """Load notification configuration"""
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass

        # Default configuration
        return {
            "enabled": True,
            "sound": True,
            "launch_notifications": True,
            "error_notifications": True,
            "completion_notifications": True,
            "duration": "short"  # short, long
        }

    def _save_config(self):
        """Save notification configuration"""
        self.config_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=2)

    def is_enabled(self) -> bool:
        """Check if notifications are enabled"""
        return self.config.get("enabled", True)

    def enable_notifications(self, enabled: bool = True):
        """Enable or disable notifications"""
        self.config["enabled"] = enabled
        self._save_config()

    def set_sound(self, enabled: bool = True):
        """Enable or disable notification sounds"""
        self.config["sound"] = enabled
        self._save_config()

    def _send_windows_toast(self, title: str, message: str,
                           notification_type: NotificationType = NotificationType.INFO):
        """Send Windows toast notification using PowerShell"""
        if not self.is_enabled():
            return False, "Notifications are disabled"

        # Map notification types to Windows icons
        icon_map = {
            NotificationType.INFO: "Info",
            NotificationType.SUCCESS: "Success",
            NotificationType.WARNING: "Warning",
            NotificationType.ERROR: "Error"
        }

        # Escape single quotes in strings
        title = title.replace("'", "''")
        message = message.replace("'", "''")

        # Build PowerShell script for toast notification
        ps_script = f"""
$ErrorActionPreference = 'SilentlyContinue'

# Try using Windows.UI.Notifications (Windows 10/11)
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$APP_ID = 'Sandman'

$template = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>{title}</text>
            <text>{message}</text>
        </binding>
    </visual>
    {"<audio silent='true'/>" if not self.config.get('sound', True) else ""}
</toast>
"@

$xml = New-Object Windows.Data.Xml.Dom.XmlDocument
$xml.LoadXml($template)
$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
"""

        try:
            result = subprocess.run(
                ["powershell", "-NoProfile", "-Command", ps_script],
                capture_output=True,
                text=True,
                timeout=5
            )
            return True, "Notification sent"
        except subprocess.TimeoutExpired:
            return False, "Notification timed out"
        except Exception as e:
            # Fallback: Try using BurntToast module or msg command
            return self._send_fallback_notification(title, message)

    def _send_fallback_notification(self, title: str, message: str):
        """Fallback notification method using msg command"""
        try:
            # Use msg command as last resort (only works on some Windows versions)
            full_message = f"{title}\n\n{message}"
            subprocess.run(
                ["msg", "*", full_message],
                check=False,
                capture_output=True,
                timeout=2
            )
            return True, "Notification sent (fallback)"
        except:
            # If all methods fail, silently continue
            return False, "Could not send notification"

    def notify_launch(self, config_name: str, profile_name: Optional[str] = None):
        """Notify when sandbox is launched"""
        if not self.config.get("launch_notifications", True):
            return

        title = "🚀 Sandbox Launched"
        if profile_name:
            message = f"Profile: {profile_name}\nConfiguration: {config_name}"
        else:
            message = f"Configuration: {config_name}"

        self._send_windows_toast(title, message, NotificationType.SUCCESS)

    def notify_error(self, error_message: str, config_name: Optional[str] = None):
        """Notify when an error occurs"""
        if not self.config.get("error_notifications", True):
            return

        title = "❌ Sandbox Error"
        if config_name:
            message = f"Configuration: {config_name}\n{error_message}"
        else:
            message = error_message

        self._send_windows_toast(title, message, NotificationType.ERROR)

    def notify_completion(self, config_name: str, duration_minutes: Optional[int] = None):
        """Notify when sandbox operation completes"""
        if not self.config.get("completion_notifications", True):
            return

        title = "✅ Sandbox Complete"
        message = f"Configuration: {config_name}"
        if duration_minutes:
            message += f"\nDuration: {duration_minutes} minutes"

        self._send_windows_toast(title, message, NotificationType.SUCCESS)

    def notify_warning(self, warning_message: str, config_name: Optional[str] = None):
        """Notify about a warning"""
        title = "⚠️ Sandbox Warning"
        if config_name:
            message = f"Configuration: {config_name}\n{warning_message}"
        else:
            message = warning_message

        self._send_windows_toast(title, message, NotificationType.WARNING)

    def notify_custom(self, title: str, message: str,
                     notification_type: NotificationType = NotificationType.INFO):
        """Send a custom notification"""
        self._send_windows_toast(title, message, notification_type)

    def test_notification(self):
        """Send a test notification"""
        return self._send_windows_toast(
            "Sandman Test Notification",
            "If you see this, notifications are working! 🎉",
            NotificationType.INFO
        )

    def get_config(self) -> Dict:
        """Get current notification configuration"""
        return self.config.copy()

    def update_config(self, **kwargs):
        """Update notification configuration"""
        allowed_keys = ["enabled", "sound", "launch_notifications",
                       "error_notifications", "completion_notifications", "duration"]

        for key, value in kwargs.items():
            if key in allowed_keys:
                self.config[key] = value

        self._save_config()


# Notification History Tracker
class NotificationHistory:
    """Track notification history for analytics"""

    def __init__(self, history_file: Optional[str] = None):
        """Initialize notification history"""
        if history_file:
            self.history_file = Path(history_file)
        else:
            workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
            self.history_file = Path(workspace) / "notifications-history.json"

        self.data = self._load_data()

    def _load_data(self) -> Dict:
        """Load notification history"""
        if self.history_file.exists():
            try:
                with open(self.history_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass

        return {
            "notifications": [],
            "statistics": {
                "total_sent": 0,
                "by_type": {
                    "launch": 0,
                    "error": 0,
                    "completion": 0,
                    "warning": 0,
                    "custom": 0
                }
            }
        }

    def _save_data(self):
        """Save notification history"""
        self.history_file.parent.mkdir(parents=True, exist_ok=True)

        # Keep only last 1000 notifications
        if len(self.data["notifications"]) > 1000:
            self.data["notifications"] = self.data["notifications"][-1000:]

        with open(self.history_file, 'w') as f:
            json.dump(self.data, f, indent=2)

    def record_notification(self, notification_type: str, title: str,
                          message: str, config_name: Optional[str] = None):
        """Record a notification in history"""
        notification = {
            "timestamp": datetime.now().isoformat(),
            "type": notification_type,
            "title": title,
            "message": message,
            "config_name": config_name
        }

        self.data["notifications"].append(notification)
        self.data["statistics"]["total_sent"] += 1
        self.data["statistics"]["by_type"][notification_type] = \
            self.data["statistics"]["by_type"].get(notification_type, 0) + 1

        self._save_data()

    def get_recent(self, limit: int = 20) -> list:
        """Get recent notifications"""
        return self.data["notifications"][-limit:]

    def get_statistics(self) -> Dict:
        """Get notification statistics"""
        return self.data["statistics"]


# CLI Interface
if __name__ == "__main__":
    import sys

    notifier = SandmanNotifier()

    if len(sys.argv) > 1:
        command = sys.argv[1].lower()

        if command == "test":
            success, message = notifier.test_notification()
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "enable":
            notifier.enable_notifications(True)
            print("✓ Notifications enabled")

        elif command == "disable":
            notifier.enable_notifications(False)
            print("✓ Notifications disabled")

        elif command == "sound-on":
            notifier.set_sound(True)
            print("✓ Notification sounds enabled")

        elif command == "sound-off":
            notifier.set_sound(False)
            print("✓ Notification sounds disabled")

        elif command == "launch" and len(sys.argv) >= 3:
            config_name = sys.argv[2]
            profile_name = sys.argv[3] if len(sys.argv) > 3 else None
            notifier.notify_launch(config_name, profile_name)
            print(f"✓ Launch notification sent for '{config_name}'")

        elif command == "error" and len(sys.argv) >= 3:
            error_msg = sys.argv[2]
            config_name = sys.argv[3] if len(sys.argv) > 3 else None
            notifier.notify_error(error_msg, config_name)
            print("✓ Error notification sent")

        elif command == "complete" and len(sys.argv) >= 3:
            config_name = sys.argv[2]
            duration = int(sys.argv[3]) if len(sys.argv) > 3 else None
            notifier.notify_completion(config_name, duration)
            print("✓ Completion notification sent")

        elif command == "custom" and len(sys.argv) >= 4:
            title = sys.argv[2]
            message = sys.argv[3]
            notifier.notify_custom(title, message)
            print("✓ Custom notification sent")

        elif command == "config":
            config = notifier.get_config()
            print("📋 Notification Configuration")
            print("-" * 60)
            for key, value in config.items():
                print(f"{key:25} : {value}")

        else:
            print("Usage:")
            print("  python notifier.py test                          - Test notifications")
            print("  python notifier.py enable                        - Enable notifications")
            print("  python notifier.py disable                       - Disable notifications")
            print("  python notifier.py sound-on                      - Enable sounds")
            print("  python notifier.py sound-off                     - Disable sounds")
            print("  python notifier.py launch <config> [profile]     - Launch notification")
            print("  python notifier.py error <message> [config]      - Error notification")
            print("  python notifier.py complete <config> [duration]  - Completion notification")
            print("  python notifier.py custom <title> <message>      - Custom notification")
            print("  python notifier.py config                        - Show configuration")
    else:
        config = notifier.get_config()
        status = "Enabled" if config["enabled"] else "Disabled"
        sound = "On" if config.get("sound", True) else "Off"
        print(f"📬 Notifications: {status}")
        print(f"🔊 Sound: {sound}")
        print("\nRun 'python notifier.py test' to test notifications")
