# Sandman Desktop Notifications

Get notified about sandbox events with Windows toast notifications.

## 🔔 Features

- **Launch Notifications**: Know when sandboxes start
- **Error Notifications**: Get alerted to problems immediately
- **Completion Notifications**: Track when operations finish
- **Warning Notifications**: Stay informed about issues
- **Custom Notifications**: Send your own notifications
- **Configurable**: Enable/disable sounds and notification types
- **History Tracking**: See all past notifications

## 🚀 Quick Start

### Test Notifications

```bash
python notifications/notifier.py test
```

If you see a toast notification, you're all set! 🎉

### Enable/Disable Notifications

```bash
# Enable
python notifications/notifier.py enable

# Disable
python notifications/notifier.py disable
```

### Control Sound

```bash
# Enable sound
python notifications/notifier.py sound-on

# Disable sound
python notifications/notifier.py sound-off
```

## 📋 Notification Types

### 1. Launch Notifications

Sent when a sandbox is launched:

```bash
python notifications/notifier.py launch "my-config" "my-profile"
```

### 2. Error Notifications

Sent when errors occur:

```bash
python notifications/notifier.py error "Failed to start sandbox" "my-config"
```

### 3. Completion Notifications

Sent when operations complete:

```bash
python notifications/notifier.py complete "my-config" 45
```

### 4. Custom Notifications

Send your own messages:

```bash
python notifications/notifier.py custom "Build Complete" "Your project built successfully!"
```

## 📈 Usage in Scripts

### Python

```python
from notifications.notifier import SandmanNotifier, NotificationType

notifier = SandmanNotifier()

# Test notification
notifier.test_notification()

# Launch notification
notifier.notify_launch("dev-environment", profile_name="daily-dev")

# Error notification
notifier.notify_error("Configuration file not found", "my-config")

# Completion notification
notifier.notify_completion("test-run", duration_minutes=30)

# Warning notification
notifier.notify_warning("Memory usage high", "large-config")

# Custom notification
notifier.notify_custom(
    "Deployment Complete",
    "Your application has been deployed to production",
    NotificationType.SUCCESS
)

# Check if enabled
if notifier.is_enabled():
    print("Notifications are enabled")

# Enable/disable
notifier.enable_notifications(True)
notifier.set_sound(False)

# Get configuration
config = notifier.get_config()
print(config)

# Update configuration
notifier.update_config(
    enabled=True,
    sound=True,
    launch_notifications=True,
    error_notifications=True
)
```

### PowerShell

```powershell
# Test notifications
python notifications\notifier.py test

# Launch notification
python notifications\notifier.py launch "my-config"

# Error notification
python notifications\notifier.py error "Something went wrong" "my-config"

# Custom notification
python notifications\notifier.py custom "Success" "Operation completed successfully"
```

## 🎨 Notification Examples

### Successful Launch

```python
notifier.notify_launch("development-sandbox", "daily-dev")
# 🚀 Sandbox Launched
# Profile: daily-dev
# Configuration: development-sandbox
```

### Error Alert

```python
notifier.notify_error("Insufficient memory", "large-config")
# ❌ Sandbox Error
# Configuration: large-config
# Insufficient memory
```

### Completion Notice

```python
notifier.notify_completion("test-suite", duration_minutes=45)
# ✅ Sandbox Complete
# Configuration: test-suite
# Duration: 45 minutes
```

### Warning

```python
notifier.notify_warning("Running low on disk space", "backup-config")
# ⚠️ Sandbox Warning
# Configuration: backup-config
# Running low on disk space
```

## 🔧 Configuration

Notifications are configured in `%USERPROFILE%\Documents\wsb-files\notifications-config.json`:

```json
{
  "enabled": true,
  "sound": true,
  "launch_notifications": true,
  "error_notifications": true,
  "completion_notifications": true,
  "duration": "short"
}
```

### Configuration Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `enabled` | boolean | Master enable/disable | `true` |
| `sound` | boolean | Play notification sound | `true` |
| `launch_notifications` | boolean | Show launch notifications | `true` |
| `error_notifications` | boolean | Show error notifications | `true` |
| `completion_notifications` | boolean | Show completion notifications | `true` |
| `duration` | string | Toast duration (short/long) | `"short"` |

## 📊 Notification History

Track all notifications sent:

```python
from notifications.notifier import NotificationHistory

history = NotificationHistory()

# Record a notification
history.record_notification(
    notification_type="launch",
    title="Sandbox Launched",
    message="Configuration: dev-env",
    config_name="dev-env"
)

# Get recent notifications
recent = history.get_recent(limit=20)
for notification in recent:
    print(f"{notification['timestamp']}: {notification['title']}")

# Get statistics
stats = history.get_statistics()
print(f"Total notifications sent: {stats['total_sent']}")
print(f"Launch notifications: {stats['by_type']['launch']}")
print(f"Error notifications: {stats['by_type']['error']}")
```

## 🎯 Use Cases

### 1. Long-Running Operations

```python
# Start a long operation
notifier.notify_launch("build-environment")

# ... operation runs for a while ...

# Notify when done
notifier.notify_completion("build-environment", duration_minutes=120)
```

### 2. Error Monitoring

```python
try:
    launch_sandbox("my-config")
except Exception as e:
    notifier.notify_error(str(e), "my-config")
```

### 3. CI/CD Pipeline

```python
# Pipeline starts
notifier.notify_launch("ci-pipeline")

# Build step
if build_failed:
    notifier.notify_error("Build failed", "ci-pipeline")
else:
    notifier.notify_custom("Build Success", "Build completed successfully")

# Tests
if tests_failed:
    notifier.notify_error("Tests failed", "ci-pipeline")
else:
    notifier.notify_completion("ci-pipeline", duration_minutes=30)
```

### 4. Background Tasks

```python
import threading

def background_task():
    notifier.notify_launch("background-job")
    # Do work...
    notifier.notify_completion("background-job")

thread = threading.Thread(target=background_task)
thread.start()
# Continue with other work, get notified when done
```

## 🔍 Troubleshooting

### No Notifications Appearing

**Issue**: Notifications don't show up

**Solutions**:
1. Check if notifications are enabled:
   ```bash
   python notifications\notifier.py config
   ```

2. Test notifications:
   ```bash
   python notifications\notifier.py test
   ```

3. Check Windows notification settings:
   - Open Settings → System → Notifications
   - Ensure "Get notifications from apps and other senders" is ON
   - Check Focus Assist settings

4. Try running as Administrator

### Notifications Disabled in Windows

**Issue**: Windows notifications are turned off

**Solution**:
```
1. Open Windows Settings (Win + I)
2. Go to System → Notifications
3. Enable "Get notifications from apps and other senders"
4. Scroll down and enable notifications for your apps
```

### Sound Not Playing

**Issue**: Notification appears but no sound

**Solutions**:
1. Check if sound is enabled:
   ```bash
   python notifications\notifier.py sound-on
   ```

2. Check Windows sound settings:
   - Settings → System → Sound
   - Ensure notification sounds are enabled

3. Check volume mixer:
   - Right-click volume icon → Open Volume Mixer
   - Ensure app volume is up

### Permission Errors

**Issue**: `Permission denied` errors

**Solution**: Run PowerShell as Administrator:
```
Right-click PowerShell → Run as Administrator
```

## 🔗 Integration

### Web UI Integration

Notifications are automatically integrated into the Sandman Web UI:

- Launch notifications when starting sandboxes
- Error notifications for failed operations
- Completion notifications for successful operations
- Settings panel to configure notification preferences

### PowerShell Module Integration

```powershell
Import-Module Sandman

# Notifications sent automatically by module functions
Start-Sandman -Name "dev-env"  # Sends launch notification

# Manual notifications
Send-SandmanNotification -Type Launch -ConfigName "dev-env"
Send-SandmanNotification -Type Error -Message "Something failed"
Send-SandmanNotification -Type Custom -Title "Build" -Message "Complete"
```

### Analytics Integration

Notifications are tracked in analytics:

```python
from analytics.analytics import AnalyticsTracker
from notifications.notifier import SandmanNotifier

tracker = AnalyticsTracker()
notifier = SandmanNotifier()

# Launch with notification
tracker.track_launch("dev-env")
notifier.notify_launch("dev-env")
```

### Profile Integration

Profiles automatically trigger notifications:

```python
from profiles.profiles import ProfileManager
from notifications.notifier import SandmanNotifier

pm = ProfileManager()
notifier = SandmanNotifier()

# Launch profile with notification
success, message = pm.launch_profile("daily-dev")
if success:
    notifier.notify_launch(
        pm.get_profile("daily-dev")["config_name"],
        profile_name="daily-dev"
    )
```

## 🎨 Custom Notification Types

Extend the notifier for your own notification types:

```python
from notifications.notifier import SandmanNotifier, NotificationType

class CustomNotifier(SandmanNotifier):
    def notify_backup_complete(self, backup_name: str):
        """Notify when backup completes"""
        self.notify_custom(
            "💾 Backup Complete",
            f"Backup '{backup_name}' completed successfully",
            NotificationType.SUCCESS
        )

    def notify_update_available(self, version: str):
        """Notify about available updates"""
        self.notify_custom(
            "🔄 Update Available",
            f"Sandman {version} is now available",
            NotificationType.INFO
        )

notifier = CustomNotifier()
notifier.notify_backup_complete("daily-backup-2024-11-19")
```

## 📖 See Also

- [Usage Analytics](../analytics/README.md)
- [Configuration Version Control](../versioncontrol/README.md)
- [Quick Launch Profiles](../profiles/README.md)
- [Web UI Documentation](../docs/WEB_UI.md)
- [PowerShell Module Guide](../docs/POWERSHELL_MODULE.md)
- [Main README](../README.md)
