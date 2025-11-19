#!/usr/bin/env python3
"""
Sandman Usage Analytics Tracker

Tracks sandbox usage statistics, launch frequency, and usage patterns.
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional
import uuid


class AnalyticsTracker:
    """Track and analyze Sandman usage statistics"""

    def __init__(self, analytics_file: Optional[str] = None):
        """Initialize analytics tracker"""
        if analytics_file:
            self.analytics_file = Path(analytics_file)
        else:
            # Default to workspace analytics file
            workspace = os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files")
            self.analytics_file = Path(workspace) / "analytics.json"

        self.data = self._load_data()

    def _load_data(self) -> Dict:
        """Load analytics data from file"""
        if self.analytics_file.exists():
            try:
                with open(self.analytics_file, 'r') as f:
                    return json.load(f)
            except (json.JSONDecodeError, IOError):
                pass

        # Initialize new analytics data structure
        return {
            "version": "1.0",
            "created": datetime.now().isoformat(),
            "launches": [],
            "configurations": {},
            "templates": {},
            "statistics": {
                "total_launches": 0,
                "total_runtime_minutes": 0,
                "most_used_config": None,
                "most_used_template": None
            }
        }

    def _save_data(self):
        """Save analytics data to file"""
        self.analytics_file.parent.mkdir(parents=True, exist_ok=True)
        with open(self.analytics_file, 'w') as f:
            json.dump(self.data, f, indent=2)

    def track_launch(self, config_name: str, template: Optional[str] = None,
                     memory_mb: int = 4096, duration_minutes: Optional[int] = None):
        """Track a sandbox launch event"""
        launch_event = {
            "id": str(uuid.uuid4()),
            "config_name": config_name,
            "template": template,
            "memory_mb": memory_mb,
            "timestamp": datetime.now().isoformat(),
            "duration_minutes": duration_minutes,
            "date": datetime.now().strftime("%Y-%m-%d"),
            "hour": datetime.now().hour
        }

        # Add to launches list
        self.data["launches"].append(launch_event)

        # Update configuration stats
        if config_name not in self.data["configurations"]:
            self.data["configurations"][config_name] = {
                "launch_count": 0,
                "total_runtime_minutes": 0,
                "first_used": launch_event["timestamp"],
                "last_used": launch_event["timestamp"]
            }

        config_stats = self.data["configurations"][config_name]
        config_stats["launch_count"] += 1
        config_stats["last_used"] = launch_event["timestamp"]
        if duration_minutes:
            config_stats["total_runtime_minutes"] += duration_minutes

        # Update template stats
        if template:
            if template not in self.data["templates"]:
                self.data["templates"][template] = {
                    "usage_count": 0,
                    "first_used": launch_event["timestamp"],
                    "last_used": launch_event["timestamp"]
                }

            template_stats = self.data["templates"][template]
            template_stats["usage_count"] += 1
            template_stats["last_used"] = launch_event["timestamp"]

        # Update global statistics
        self.data["statistics"]["total_launches"] += 1
        if duration_minutes:
            self.data["statistics"]["total_runtime_minutes"] += duration_minutes

        # Update most used
        self._update_most_used()

        # Keep only last 1000 launches to prevent file bloat
        if len(self.data["launches"]) > 1000:
            self.data["launches"] = self.data["launches"][-1000:]

        self._save_data()

    def _update_most_used(self):
        """Update most used configuration and template"""
        if self.data["configurations"]:
            most_used_config = max(
                self.data["configurations"].items(),
                key=lambda x: x[1]["launch_count"]
            )
            self.data["statistics"]["most_used_config"] = most_used_config[0]

        if self.data["templates"]:
            most_used_template = max(
                self.data["templates"].items(),
                key=lambda x: x[1]["usage_count"]
            )
            self.data["statistics"]["most_used_template"] = most_used_template[0]

    def get_statistics(self) -> Dict:
        """Get overall statistics"""
        stats = self.data["statistics"].copy()

        # Calculate average session duration
        if stats["total_launches"] > 0 and stats["total_runtime_minutes"] > 0:
            stats["average_session_minutes"] = round(
                stats["total_runtime_minutes"] / stats["total_launches"], 2
            )
        else:
            stats["average_session_minutes"] = 0

        # Add recent activity
        stats["last_7_days"] = self._get_recent_launches(7)
        stats["last_30_days"] = self._get_recent_launches(30)

        return stats

    def _get_recent_launches(self, days: int) -> int:
        """Count launches in the last N days"""
        cutoff = datetime.now() - timedelta(days=days)
        count = 0

        for launch in self.data["launches"]:
            try:
                launch_time = datetime.fromisoformat(launch["timestamp"])
                if launch_time >= cutoff:
                    count += 1
            except (ValueError, KeyError):
                continue

        return count

    def get_config_stats(self, config_name: str) -> Optional[Dict]:
        """Get statistics for a specific configuration"""
        return self.data["configurations"].get(config_name)

    def get_top_configurations(self, limit: int = 10) -> List[Dict]:
        """Get top N most used configurations"""
        configs = [
            {"name": name, **stats}
            for name, stats in self.data["configurations"].items()
        ]
        configs.sort(key=lambda x: x["launch_count"], reverse=True)
        return configs[:limit]

    def get_top_templates(self, limit: int = 10) -> List[Dict]:
        """Get top N most used templates"""
        templates = [
            {"name": name, **stats}
            for name, stats in self.data["templates"].items()
        ]
        templates.sort(key=lambda x: x["usage_count"], reverse=True)
        return templates[:limit]

    def get_usage_by_date(self, days: int = 30) -> Dict[str, int]:
        """Get launch counts by date for the last N days"""
        cutoff = datetime.now() - timedelta(days=days)
        usage_by_date = {}

        for launch in self.data["launches"]:
            try:
                launch_time = datetime.fromisoformat(launch["timestamp"])
                if launch_time >= cutoff:
                    date = launch["date"]
                    usage_by_date[date] = usage_by_date.get(date, 0) + 1
            except (ValueError, KeyError):
                continue

        return dict(sorted(usage_by_date.items()))

    def get_usage_by_hour(self) -> Dict[int, int]:
        """Get launch counts by hour of day"""
        usage_by_hour = {hour: 0 for hour in range(24)}

        for launch in self.data["launches"]:
            try:
                hour = launch.get("hour")
                if hour is not None:
                    usage_by_hour[hour] += 1
            except (ValueError, KeyError):
                continue

        return usage_by_hour

    def get_summary_report(self) -> str:
        """Generate a human-readable summary report"""
        stats = self.get_statistics()
        top_configs = self.get_top_configurations(5)
        top_templates = self.get_top_templates(5)

        report = []
        report.append("=" * 60)
        report.append("SANDMAN USAGE ANALYTICS REPORT")
        report.append("=" * 60)
        report.append("")

        # Overall Statistics
        report.append("📊 OVERALL STATISTICS")
        report.append("-" * 60)
        report.append(f"Total Launches:          {stats['total_launches']}")
        report.append(f"Total Runtime:           {stats['total_runtime_minutes']} minutes")
        report.append(f"Average Session:         {stats['average_session_minutes']} minutes")
        report.append(f"Last 7 Days:             {stats['last_7_days']} launches")
        report.append(f"Last 30 Days:            {stats['last_30_days']} launches")
        report.append("")

        # Top Configurations
        report.append("🏆 TOP CONFIGURATIONS")
        report.append("-" * 60)
        if top_configs:
            for i, config in enumerate(top_configs, 1):
                report.append(f"{i}. {config['name']}")
                report.append(f"   Launches: {config['launch_count']} | "
                            f"Runtime: {config['total_runtime_minutes']} min")
        else:
            report.append("No configurations used yet")
        report.append("")

        # Top Templates
        report.append("📦 TOP TEMPLATES")
        report.append("-" * 60)
        if top_templates:
            for i, template in enumerate(top_templates, 1):
                report.append(f"{i}. {template['name']}")
                report.append(f"   Usage: {template['usage_count']} times")
        else:
            report.append("No templates used yet")
        report.append("")

        report.append("=" * 60)
        return "\n".join(report)

    def export_to_csv(self, output_file: str):
        """Export launch data to CSV"""
        import csv

        with open(output_file, 'w', newline='') as csvfile:
            fieldnames = ['timestamp', 'config_name', 'template', 'memory_mb',
                         'duration_minutes', 'date', 'hour']
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)

            writer.writeheader()
            for launch in self.data["launches"]:
                writer.writerow({
                    'timestamp': launch.get('timestamp', ''),
                    'config_name': launch.get('config_name', ''),
                    'template': launch.get('template', ''),
                    'memory_mb': launch.get('memory_mb', ''),
                    'duration_minutes': launch.get('duration_minutes', ''),
                    'date': launch.get('date', ''),
                    'hour': launch.get('hour', '')
                })

    def clear_data(self, confirm: bool = False):
        """Clear all analytics data (requires confirmation)"""
        if not confirm:
            raise ValueError("Must pass confirm=True to clear analytics data")

        self.data = {
            "version": "1.0",
            "created": datetime.now().isoformat(),
            "launches": [],
            "configurations": {},
            "templates": {},
            "statistics": {
                "total_launches": 0,
                "total_runtime_minutes": 0,
                "most_used_config": None,
                "most_used_template": None
            }
        }
        self._save_data()


# CLI interface
if __name__ == "__main__":
    import sys

    tracker = AnalyticsTracker()

    if len(sys.argv) > 1:
        command = sys.argv[1].lower()

        if command == "report":
            print(tracker.get_summary_report())

        elif command == "stats":
            stats = tracker.get_statistics()
            print(json.dumps(stats, indent=2))

        elif command == "track" and len(sys.argv) >= 3:
            config_name = sys.argv[2]
            template = sys.argv[3] if len(sys.argv) > 3 else None
            tracker.track_launch(config_name, template=template)
            print(f"✓ Tracked launch of '{config_name}'")

        elif command == "export" and len(sys.argv) >= 3:
            output_file = sys.argv[2]
            tracker.export_to_csv(output_file)
            print(f"✓ Exported to '{output_file}'")

        else:
            print("Usage:")
            print("  python analytics.py report          - Show summary report")
            print("  python analytics.py stats           - Show statistics JSON")
            print("  python analytics.py track <name>    - Track a launch")
            print("  python analytics.py export <file>   - Export to CSV")
    else:
        print(tracker.get_summary_report())
