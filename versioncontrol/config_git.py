#!/usr/bin/env python3
"""
Sandman Configuration Version Control

Git integration for tracking configuration changes, viewing history, and reverting.
"""

import os
import subprocess
import json
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Optional, Tuple


class ConfigVersionControl:
    """Manage configuration version control using Git"""

    def __init__(self, workspace: Optional[str] = None):
        """Initialize version control manager"""
        if workspace:
            self.workspace = Path(workspace)
        else:
            self.workspace = Path(os.path.expandvars("%USERPROFILE%\\Documents\\wsb-files"))

        self.git_dir = self.workspace / ".git"
        self.gitignore_file = self.workspace / ".gitignore"
        self.vcs_config = self.workspace / ".sandman-vcs.json"

    def _run_git_command(self, *args, capture_output=True) -> Tuple[bool, str]:
        """Run a git command in the workspace"""
        try:
            result = subprocess.run(
                ["git", "-C", str(self.workspace)] + list(args),
                capture_output=capture_output,
                text=True,
                check=False
            )
            success = result.returncode == 0
            output = result.stdout if success else result.stderr
            return success, output.strip()
        except FileNotFoundError:
            return False, "Git is not installed or not in PATH"
        except Exception as e:
            return False, str(e)

    def is_initialized(self) -> bool:
        """Check if Git is initialized in the workspace"""
        return self.git_dir.exists() and self.git_dir.is_dir()

    def initialize(self, author_name: Optional[str] = None,
                   author_email: Optional[str] = None) -> Tuple[bool, str]:
        """Initialize Git repository for configurations"""
        if self.is_initialized():
            return True, "Git repository already initialized"

        # Create workspace if it doesn't exist
        self.workspace.mkdir(parents=True, exist_ok=True)

        # Initialize git
        success, output = self._run_git_command("init")
        if not success:
            return False, f"Failed to initialize Git: {output}"

        # Set up .gitignore
        gitignore_content = """# Sandman Git Ignore
*.bak
*.tmp
*.log
.sandman-vcs.json
analytics.json
"""
        with open(self.gitignore_file, 'w') as f:
            f.write(gitignore_content)

        # Configure git user if provided
        if author_name:
            self._run_git_command("config", "user.name", author_name)
        if author_email:
            self._run_git_command("config", "user.email", author_email)

        # Create initial commit
        self._run_git_command("add", ".gitignore")
        self._run_git_command("commit", "-m", "Initial commit: Sandman configuration repository")

        # Save VCS metadata
        vcs_data = {
            "initialized": datetime.now().isoformat(),
            "version": "1.0",
            "auto_commit": False
        }
        with open(self.vcs_config, 'w') as f:
            json.dump(vcs_data, f, indent=2)

        return True, "Git repository initialized successfully"

    def get_vcs_config(self) -> Dict:
        """Get VCS configuration"""
        if self.vcs_config.exists():
            with open(self.vcs_config, 'r') as f:
                return json.load(f)
        return {"auto_commit": False}

    def set_auto_commit(self, enabled: bool) -> Tuple[bool, str]:
        """Enable or disable auto-commit"""
        config = self.get_vcs_config()
        config["auto_commit"] = enabled
        with open(self.vcs_config, 'w') as f:
            json.dump(config, f, indent=2)
        return True, f"Auto-commit {'enabled' if enabled else 'disabled'}"

    def commit_config(self, config_name: str, message: Optional[str] = None) -> Tuple[bool, str]:
        """Commit changes to a configuration"""
        if not self.is_initialized():
            return False, "Git repository not initialized. Run initialize() first."

        config_file = self.workspace / f"{config_name}.wsb"
        if not config_file.exists():
            return False, f"Configuration '{config_name}' not found"

        # Stage the file
        success, output = self._run_git_command("add", config_file.name)
        if not success:
            return False, f"Failed to stage file: {output}"

        # Check if there are changes to commit
        success, status = self._run_git_command("status", "--porcelain")
        if not status:
            return True, "No changes to commit"

        # Create commit message
        if not message:
            message = f"Update configuration: {config_name}"

        # Commit
        success, output = self._run_git_command(
            "commit", "-m", message, "--author", "Sandman <sandman@local>"
        )
        if not success:
            return False, f"Failed to commit: {output}"

        return True, f"Configuration '{config_name}' committed successfully"

    def commit_all(self, message: Optional[str] = None) -> Tuple[bool, str]:
        """Commit all configuration changes"""
        if not self.is_initialized():
            return False, "Git repository not initialized"

        # Stage all .wsb files
        success, output = self._run_git_command("add", "*.wsb")
        if not success:
            return False, f"Failed to stage files: {output}"

        # Check for changes
        success, status = self._run_git_command("status", "--porcelain")
        if not status:
            return True, "No changes to commit"

        # Commit
        if not message:
            message = f"Update configurations - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"

        success, output = self._run_git_command(
            "commit", "-m", message, "--author", "Sandman <sandman@local>"
        )
        if not success:
            return False, f"Failed to commit: {output}"

        return True, "All configurations committed successfully"

    def get_history(self, config_name: Optional[str] = None, limit: int = 20) -> List[Dict]:
        """Get commit history for a configuration or all configurations"""
        if not self.is_initialized():
            return []

        # Build git log command
        args = ["log", f"--max-count={limit}", "--pretty=format:%H|%an|%ae|%at|%s"]

        if config_name:
            args.append(f"{config_name}.wsb")

        success, output = self._run_git_command(*args)
        if not success or not output:
            return []

        # Parse log output
        commits = []
        for line in output.split('\n'):
            if not line:
                continue

            parts = line.split('|')
            if len(parts) >= 5:
                commits.append({
                    "hash": parts[0],
                    "author": parts[1],
                    "email": parts[2],
                    "timestamp": int(parts[3]),
                    "date": datetime.fromtimestamp(int(parts[3])).strftime("%Y-%m-%d %H:%M:%S"),
                    "message": '|'.join(parts[4:])  # In case message contains |
                })

        return commits

    def get_diff(self, config_name: str, commit_hash: Optional[str] = None) -> Tuple[bool, str]:
        """Get diff for a configuration"""
        if not self.is_initialized():
            return False, "Git repository not initialized"

        config_file = f"{config_name}.wsb"

        if commit_hash:
            # Diff between specific commit and current
            success, output = self._run_git_command("diff", commit_hash, "--", config_file)
        else:
            # Diff between last commit and current
            success, output = self._run_git_command("diff", "HEAD", "--", config_file)

        if not success:
            return False, output

        return True, output if output else "No differences"

    def revert_config(self, config_name: str, commit_hash: str) -> Tuple[bool, str]:
        """Revert a configuration to a specific commit"""
        if not self.is_initialized():
            return False, "Git repository not initialized"

        config_file = f"{config_name}.wsb"

        # Check if commit exists
        success, _ = self._run_git_command("cat-file", "-e", f"{commit_hash}:{config_file}")
        if not success:
            return False, f"Commit {commit_hash[:8]} does not contain {config_file}"

        # Check for uncommitted changes
        success, status = self._run_git_command("status", "--porcelain", config_file)
        if status:
            return False, f"Uncommitted changes in {config_file}. Commit or stash them first."

        # Revert to specific commit
        success, output = self._run_git_command("checkout", commit_hash, "--", config_file)
        if not success:
            return False, f"Failed to revert: {output}"

        # Commit the reversion
        message = f"Revert {config_name} to commit {commit_hash[:8]}"
        success, output = self._run_git_command("add", config_file)
        success, output = self._run_git_command(
            "commit", "-m", message, "--author", "Sandman <sandman@local>"
        )

        return True, f"Configuration reverted to commit {commit_hash[:8]}"

    def get_status(self) -> Dict:
        """Get Git repository status"""
        if not self.is_initialized():
            return {
                "initialized": False,
                "modified": [],
                "untracked": [],
                "total_commits": 0
            }

        # Get status
        success, output = self._run_git_command("status", "--porcelain")
        modified = []
        untracked = []

        if output:
            for line in output.split('\n'):
                if not line:
                    continue
                status = line[:2]
                filename = line[3:]

                if 'M' in status or 'A' in status:
                    modified.append(filename)
                elif '?' in status:
                    untracked.append(filename)

        # Get commit count
        success, count = self._run_git_command("rev-list", "--count", "HEAD")
        total_commits = int(count) if success and count else 0

        # Get last commit
        success, last_commit = self._run_git_command(
            "log", "-1", "--pretty=format:%H|%at|%s"
        )
        last_commit_data = None
        if success and last_commit:
            parts = last_commit.split('|')
            if len(parts) >= 3:
                last_commit_data = {
                    "hash": parts[0],
                    "timestamp": int(parts[1]),
                    "date": datetime.fromtimestamp(int(parts[1])).strftime("%Y-%m-%d %H:%M:%S"),
                    "message": '|'.join(parts[2:])
                }

        return {
            "initialized": True,
            "modified": modified,
            "untracked": untracked,
            "total_commits": total_commits,
            "last_commit": last_commit_data
        }

    def create_tag(self, tag_name: str, message: Optional[str] = None) -> Tuple[bool, str]:
        """Create a tag for the current state"""
        if not self.is_initialized():
            return False, "Git repository not initialized"

        if not message:
            message = f"Tag: {tag_name}"

        success, output = self._run_git_command("tag", "-a", tag_name, "-m", message)
        if not success:
            return False, f"Failed to create tag: {output}"

        return True, f"Tag '{tag_name}' created successfully"

    def list_tags(self) -> List[str]:
        """List all tags"""
        if not self.is_initialized():
            return []

        success, output = self._run_git_command("tag", "-l")
        if not success or not output:
            return []

        return output.split('\n')

    def export_config_at_commit(self, config_name: str, commit_hash: str,
                                output_path: str) -> Tuple[bool, str]:
        """Export a configuration from a specific commit"""
        if not self.is_initialized():
            return False, "Git repository not initialized"

        config_file = f"{config_name}.wsb"

        # Get file content at commit
        success, content = self._run_git_command("show", f"{commit_hash}:{config_file}")
        if not success:
            return False, f"Failed to get file at commit: {content}"

        # Write to output file
        try:
            output_file = Path(output_path)
            output_file.parent.mkdir(parents=True, exist_ok=True)
            with open(output_file, 'w') as f:
                f.write(content)
            return True, f"Configuration exported to {output_path}"
        except IOError as e:
            return False, f"Failed to write file: {e}"


# CLI Interface
if __name__ == "__main__":
    import sys

    vcs = ConfigVersionControl()

    if len(sys.argv) > 1:
        command = sys.argv[1].lower()

        if command == "init":
            success, message = vcs.initialize()
            print(f"{'✓' if success else '✗'} {message}")

        elif command == "status":
            status = vcs.get_status()
            if not status["initialized"]:
                print("✗ Git repository not initialized")
            else:
                print(f"📊 Repository Status")
                print(f"Total Commits: {status['total_commits']}")
                if status['last_commit']:
                    print(f"Last Commit: {status['last_commit']['date']}")
                    print(f"             {status['last_commit']['message']}")
                if status['modified']:
                    print(f"\nModified: {len(status['modified'])} files")
                    for file in status['modified']:
                        print(f"  - {file}")
                if status['untracked']:
                    print(f"\nUntracked: {len(status['untracked'])} files")
                    for file in status['untracked']:
                        print(f"  - {file}")

        elif command == "commit" and len(sys.argv) >= 3:
            config_name = sys.argv[2]
            message = sys.argv[3] if len(sys.argv) > 3 else None
            success, output = vcs.commit_config(config_name, message)
            print(f"{'✓' if success else '✗'} {output}")

        elif command == "commit-all":
            message = sys.argv[2] if len(sys.argv) > 2 else None
            success, output = vcs.commit_all(message)
            print(f"{'✓' if success else '✗'} {output}")

        elif command == "history" and len(sys.argv) >= 2:
            config_name = sys.argv[2] if len(sys.argv) > 2 else None
            limit = int(sys.argv[3]) if len(sys.argv) > 3 else 20
            commits = vcs.get_history(config_name, limit)

            if not commits:
                print("No commit history found")
            else:
                print(f"📜 Commit History ({len(commits)} commits)")
                print("-" * 80)
                for commit in commits:
                    print(f"{commit['hash'][:8]} - {commit['date']}")
                    print(f"  {commit['message']}")
                    print()

        elif command == "revert" and len(sys.argv) >= 4:
            config_name = sys.argv[2]
            commit_hash = sys.argv[3]
            success, output = vcs.revert_config(config_name, commit_hash)
            print(f"{'✓' if success else '✗'} {output}")

        elif command == "diff" and len(sys.argv) >= 3:
            config_name = sys.argv[2]
            commit_hash = sys.argv[3] if len(sys.argv) > 3 else None
            success, output = vcs.get_diff(config_name, commit_hash)
            if success:
                print(output)
            else:
                print(f"✗ {output}")

        else:
            print("Usage:")
            print("  python config_git.py init                      - Initialize Git repository")
            print("  python config_git.py status                    - Show repository status")
            print("  python config_git.py commit <name> [message]   - Commit a configuration")
            print("  python config_git.py commit-all [message]      - Commit all changes")
            print("  python config_git.py history [name] [limit]    - View commit history")
            print("  python config_git.py diff <name> [commit]      - Show differences")
            print("  python config_git.py revert <name> <commit>    - Revert to a commit")
    else:
        status = vcs.get_status()
        if not status["initialized"]:
            print("Git version control not initialized.")
            print("Run: python config_git.py init")
        else:
            print(f"✓ Git initialized - {status['total_commits']} commits")
            if status['modified']:
                print(f"  Modified: {len(status['modified'])} files")
            if status['untracked']:
                print(f"  Untracked: {len(status['untracked'])} files")
