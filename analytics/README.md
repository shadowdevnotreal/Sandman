# Sandman Usage Analytics

Track and analyze your Windows Sandbox usage patterns.

## 📊 Features

- **Launch Tracking**: Automatically track every sandbox launch
- **Usage Statistics**: View total launches, runtime, and averages
- **Configuration Analytics**: See which configs are used most
- **Template Analytics**: Track template popularity
- **Time-Based Analysis**: Usage by date, hour, and time periods
- **Export Capabilities**: Export data to CSV for external analysis
- **Summary Reports**: Human-readable usage reports

## 🚀 Quick Start

### View Analytics Report

```bash
python analytics/analytics.py report
```

### Get Statistics JSON

```bash
python analytics/analytics.py stats
```

### Track a Launch Manually

```bash
python analytics/analytics.py track "my-config" "development-sandbox"
```

### Export to CSV

```bash
python analytics/analytics.py export analytics-export.csv
```

## 📈 Usage in Scripts

### Python

```python
from analytics.analytics import AnalyticsTracker

tracker = AnalyticsTracker()

# Track a launch
tracker.track_launch(
    config_name="dev-environment",
    template="development-sandbox",
    memory_mb=8192,
    duration_minutes=45
)

# Get statistics
stats = tracker.get_statistics()
print(f"Total launches: {stats['total_launches']}")

# Get top configurations
top_configs = tracker.get_top_configurations(5)
for config in top_configs:
    print(f"{config['name']}: {config['launch_count']} launches")
```

### PowerShell

```powershell
# Track a launch
python analytics\analytics.py track "test-sandbox"

# View report
python analytics\analytics.py report

# Export data
python analytics\analytics.py export "C:\Backups\analytics.csv"
```

## 📊 Analytics Data Structure

The analytics data is stored in `%USERPROFILE%\Documents\wsb-files\analytics.json`:

```json
{
  "version": "1.0",
  "created": "2024-11-19T10:00:00",
  "launches": [
    {
      "id": "uuid",
      "config_name": "dev-env",
      "template": "development-sandbox",
      "memory_mb": 8192,
      "timestamp": "2024-11-19T10:30:00",
      "duration_minutes": 45,
      "date": "2024-11-19",
      "hour": 10
    }
  ],
  "configurations": {
    "dev-env": {
      "launch_count": 10,
      "total_runtime_minutes": 450,
      "first_used": "2024-11-01T09:00:00",
      "last_used": "2024-11-19T10:30:00"
    }
  },
  "templates": {
    "development-sandbox": {
      "usage_count": 10,
      "first_used": "2024-11-01T09:00:00",
      "last_used": "2024-11-19T10:30:00"
    }
  },
  "statistics": {
    "total_launches": 50,
    "total_runtime_minutes": 2250,
    "most_used_config": "dev-env",
    "most_used_template": "development-sandbox"
  }
}
```

## 🔧 Integration

### Web UI Integration

The analytics are automatically integrated into the Sandman Web UI at `http://localhost:5000`. View the Analytics tab to see:

- Real-time usage statistics
- Charts and graphs
- Top configurations and templates
- Usage trends over time

### PowerShell Module Integration

```powershell
Import-Module Sandman

# Start sandbox (automatically tracked)
Start-Sandman -Name "dev-env"

# View analytics
Get-SandmanAnalytics

# Export analytics
Export-SandmanAnalytics -OutputPath "C:\Backups\analytics.csv"
```

## 📋 Available Metrics

### Overall Statistics
- Total launches
- Total runtime (minutes)
- Average session duration
- Launches in last 7/30 days

### Configuration Metrics
- Launch count per configuration
- Total runtime per configuration
- First/last used timestamps

### Template Metrics
- Usage count per template
- First/last used timestamps

### Time-Based Metrics
- Launches by date
- Launches by hour of day
- Usage trends over time

## 🎯 Use Cases

### 1. Identify Most Used Environments

```python
tracker = AnalyticsTracker()
top_configs = tracker.get_top_configurations(5)
# Focus optimization efforts on top configs
```

### 2. Track Resource Allocation

```python
stats = tracker.get_statistics()
avg_session = stats['average_session_minutes']
# Plan hardware allocation based on average session time
```

### 3. Usage Pattern Analysis

```python
usage_by_hour = tracker.get_usage_by_hour()
# Identify peak usage hours for maintenance scheduling
```

### 4. Compliance Reporting

```python
tracker.export_to_csv("monthly_report.csv")
# Generate compliance reports for audit purposes
```

## 🔒 Privacy

- All analytics data is stored **locally** on your machine
- No data is sent to external servers
- Data is stored in your user profile directory
- You can clear analytics data at any time

### Clear Analytics Data

```python
from analytics.analytics import AnalyticsTracker

tracker = AnalyticsTracker()
tracker.clear_data(confirm=True)
```

## 🐛 Troubleshooting

### Analytics File Not Found

```bash
# Check if analytics file exists
ls %USERPROFILE%\Documents\wsb-files\analytics.json

# Initialize new analytics (happens automatically on first launch)
python analytics/analytics.py report
```

### Permission Denied

```bash
# Run as Administrator
# Right-click PowerShell → Run as Administrator
```

### Corrupted Analytics File

```python
# Clear and reinitialize
from analytics.analytics import AnalyticsTracker
tracker = AnalyticsTracker()
tracker.clear_data(confirm=True)
```

## 📖 See Also

- [Web UI Documentation](../docs/WEB_UI.md)
- [PowerShell Module Guide](../docs/POWERSHELL_MODULE.md)
- [Main README](../README.md)
