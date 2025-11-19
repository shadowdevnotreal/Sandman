#!/bin/bash
# Sandman - Cross-Platform Sandbox Manager
# Version 1.0.0
# Supports: Linux (systemd-nspawn, Docker), macOS (Docker)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

OS_TYPE=$(detect_os)

# Load configuration
load_config() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local config_file="$script_dir/config.json"

    if [[ -f "$config_file" ]]; then
        # Extract workspace path based on OS
        if command -v jq >/dev/null 2>&1; then
            WORKSPACE=$(jq -r ".workspace.$OS_TYPE" "$config_file" | envsubst)
            DEFAULT_MEMORY=$(jq -r ".sandbox.defaultMemoryMB" "$config_file")
            DEFAULT_NETWORKING=$(jq -r ".sandbox.defaultNetworking" "$config_file")
            AUTO_BACKUP=$(jq -r ".sandbox.autoBackup" "$config_file")

            # Editor
            EDITOR_CMD=$(jq -r ".editor.$OS_TYPE" "$config_file")
        else
            # Fallback if jq not available
            WORKSPACE="$HOME/.local/share/sandman"
            DEFAULT_MEMORY=4096
            DEFAULT_NETWORKING="Default"
            AUTO_BACKUP=true
            EDITOR_CMD="nano"
        fi
    else
        # Default values
        if [[ "$OS_TYPE" == "macos" ]]; then
            WORKSPACE="$HOME/Library/Application Support/Sandman"
        else
            WORKSPACE="$HOME/.local/share/sandman"
        fi
        DEFAULT_MEMORY=4096
        DEFAULT_NETWORKING="Default"
        AUTO_BACKUP=true
        EDITOR_CMD="nano"
    fi

    # Expand tilde
    WORKSPACE="${WORKSPACE/#\~/$HOME}"
}

# Initialize
load_config

# Ensure workspace directory exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

ensure_dir "$WORKSPACE"

# Confirmation prompt
confirm_y() {
    local prompt="${1:-Proceed? (y/N)}"
    read -p "$prompt " response
    [[ "$response" =~ ^[Yy](es)?$ ]]
}

# Print colored message
print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Check if Docker is available
check_docker() {
    if command -v docker >/dev/null 2>&1; then
        if docker ps >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

# Check if systemd-nspawn is available (Linux only)
check_nspawn() {
    if [[ "$OS_TYPE" == "linux" ]] && command -v systemd-nspawn >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Determine sandbox backend
get_sandbox_backend() {
    if check_docker; then
        echo "docker"
    elif check_nspawn; then
        echo "nspawn"
    else
        echo "none"
    fi
}

# Create new sandbox configuration
action_create() {
    clear
    print_color "$CYAN" "=== Create New Sandbox Configuration ==="

    read -p "Configuration name (no extension): " name
    if [[ -z "$name" ]]; then
        print_color "$RED" "Name cannot be empty"
        return
    fi

    local config_file="$WORKSPACE/${name}.sandbox"
    if [[ -f "$config_file" ]] && ! confirm_y "File exists. Overwrite? (y/N)"; then
        return
    fi

    read -p "Memory MB [$DEFAULT_MEMORY]: " memory
    memory=${memory:-$DEFAULT_MEMORY}

    read -p "Enable networking? (y/N): " networking
    if [[ "$networking" =~ ^[Yy]$ ]]; then
        networking="enabled"
    else
        networking="disabled"
    fi

    read -p "Shared folder path (leave empty for none): " shared_folder
    local readonly="true"
    if [[ -n "$shared_folder" ]]; then
        if confirm_y "Read/Write access? (y=RW, N=RO)"; then
            readonly="false"
        fi
    fi

    # Create configuration file
    cat > "$config_file" <<EOF
# Sandman Sandbox Configuration
# Created: $(date)
# OS: $OS_TYPE

[general]
name=$name
memory_mb=$memory
networking=$networking

[shared_folders]
EOF

    if [[ -n "$shared_folder" ]]; then
        echo "folder_1=$shared_folder:readonly=$readonly" >> "$config_file"

        # Create folder if it doesn't exist
        if [[ ! -d "$shared_folder" ]] && confirm_y "Create missing folder '$shared_folder'? (y/N)"; then
            mkdir -p "$shared_folder"
            print_color "$GREEN" "Created $shared_folder"
        fi
    fi

    print_color "$GREEN" "✓ Configuration saved: $config_file"

    if confirm_y "Open in editor? (y/N)"; then
        ${EDITOR_CMD} "$config_file"
    fi
}

# List all sandbox configurations
action_list() {
    clear
    print_color "$CYAN" "=== Sandbox Configurations in $WORKSPACE ==="

    local configs=($(find "$WORKSPACE" -maxdepth 1 -name "*.sandbox" -type f 2>/dev/null | sort))

    if [[ ${#configs[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No configurations found."
        return
    fi

    local i=1
    for config in "${configs[@]}"; do
        local basename=$(basename "$config")
        local modified=$(stat -c %y "$config" 2>/dev/null || stat -f "%Sm" "$config" 2>/dev/null)
        echo "[$i] $basename  (Modified: $modified)"
        ((i++))
    done
}

# Edit configuration
action_edit() {
    clear
    local configs=($(find "$WORKSPACE" -maxdepth 1 -name "*.sandbox" -type f 2>/dev/null | sort))

    if [[ ${#configs[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No configurations to edit."
        return
    fi

    local i=1
    for config in "${configs[@]}"; do
        echo "[$i] $(basename "$config")"
        ((i++))
    done

    read -p "Select configuration to edit (number): " sel
    if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -ge 1 ]] && [[ $sel -le ${#configs[@]} ]]; then
        local config="${configs[$((sel-1))]}"
        ${EDITOR_CMD} "$config"
        print_color "$GREEN" "✓ Configuration edited"
    else
        print_color "$RED" "Invalid selection"
    fi
}

# Validate configuration
action_validate() {
    clear
    local configs=($(find "$WORKSPACE" -maxdepth 1 -name "*.sandbox" -type f 2>/dev/null | sort))

    if [[ ${#configs[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No configurations to validate."
        return
    fi

    local i=1
    for config in "${configs[@]}"; do
        echo "[$i] $(basename "$config")"
        ((i++))
    done

    read -p "Select configuration to validate (number): " sel
    if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -ge 1 ]] && [[ $sel -le ${#configs[@]} ]]; then
        local config="${configs[$((sel-1))]}"
        print_color "$CYAN" "\n=== Validating $(basename "$config") ==="

        local errors=0

        # Check if file is readable
        if [[ ! -r "$config" ]]; then
            print_color "$RED" "✗ Configuration file is not readable"
            ((errors++))
        fi

        # Parse and validate configuration
        local memory=$(grep "^memory_mb=" "$config" | cut -d= -f2)
        local networking=$(grep "^networking=" "$config" | cut -d= -f2)

        # Validate memory
        if [[ -n "$memory" ]]; then
            if ! [[ "$memory" =~ ^[0-9]+$ ]]; then
                print_color "$RED" "✗ Invalid memory value: $memory"
                ((errors++))
            elif [[ $memory -lt 256 ]] || [[ $memory -gt 131072 ]]; then
                print_color "$RED" "✗ Memory out of range (256-131072): $memory"
                ((errors++))
            else
                echo "  Memory: $memory MB"
            fi
        fi

        # Validate networking
        if [[ -n "$networking" ]]; then
            if [[ "$networking" != "enabled" ]] && [[ "$networking" != "disabled" ]]; then
                print_color "$RED" "✗ Invalid networking value: $networking"
                ((errors++))
            else
                echo "  Networking: $networking"
            fi
        fi

        # Check shared folders exist
        while IFS= read -r line; do
            if [[ "$line" =~ ^folder_[0-9]+=(.+):readonly= ]]; then
                local folder_path="${BASH_REMATCH[1]}"
                if [[ ! -d "$folder_path" ]]; then
                    print_color "$RED" "✗ Shared folder does not exist: $folder_path"
                    ((errors++))

                    if confirm_y "Create missing folder? (y/N)"; then
                        mkdir -p "$folder_path"
                        print_color "$GREEN" "✓ Created $folder_path"
                        ((errors--))
                    fi
                else
                    echo "  Shared folder: $folder_path"
                fi
            fi
        done < "$config"

        if [[ $errors -eq 0 ]]; then
            print_color "$GREEN" "\n✓ VALID - Configuration is ready to use"
        else
            print_color "$RED" "\n✗ INVALID - $errors error(s) found"
        fi
    else
        print_color "$RED" "Invalid selection"
    fi
}

# Launch sandbox
action_launch() {
    clear
    local backend=$(get_sandbox_backend)

    if [[ "$backend" == "none" ]]; then
        print_color "$RED" "No sandbox backend available!"
        print_color "$YELLOW" "Please install Docker or systemd-nspawn (Linux only)"
        return
    fi

    print_color "$CYAN" "=== Launch Sandbox (Backend: $backend) ==="

    local configs=($(find "$WORKSPACE" -maxdepth 1 -name "*.sandbox" -type f 2>/dev/null | sort))

    if [[ ${#configs[@]} -eq 0 ]]; then
        print_color "$YELLOW" "No configurations available."
        return
    fi

    local i=1
    for config in "${configs[@]}"; do
        echo "[$i] $(basename "$config")"
        ((i++))
    done

    read -p "Select configuration to launch (number): " sel
    if [[ "$sel" =~ ^[0-9]+$ ]] && [[ $sel -ge 1 ]] && [[ $sel -le ${#configs[@]} ]]; then
        local config="${configs[$((sel-1))]}"

        # Parse configuration
        local name=$(grep "^name=" "$config" | cut -d= -f2)
        local memory=$(grep "^memory_mb=" "$config" | cut -d= -f2)
        local networking=$(grep "^networking=" "$config" | cut -d= -f2)

        if [[ "$backend" == "docker" ]]; then
            print_color "$CYAN" "Launching Docker container..."

            local docker_opts="-it --rm"
            docker_opts+=" --name sandman-$name"
            docker_opts+=" --memory=${memory}m"

            if [[ "$networking" == "disabled" ]]; then
                docker_opts+=" --network none"
            fi

            # Add shared folders
            while IFS= read -r line; do
                if [[ "$line" =~ ^folder_[0-9]+=(.+):readonly=(.+) ]]; then
                    local folder_path="${BASH_REMATCH[1]}"
                    local readonly="${BASH_REMATCH[2]}"
                    if [[ "$readonly" == "true" ]]; then
                        docker_opts+=" -v $folder_path:/mnt/$(basename "$folder_path"):ro"
                    else
                        docker_opts+=" -v $folder_path:/mnt/$(basename "$folder_path"):rw"
                    fi
                fi
            done < "$config"

            # Use Ubuntu as default base image
            print_color "$GREEN" "✓ Launching container..."
            docker run $docker_opts ubuntu:latest /bin/bash

        elif [[ "$backend" == "nspawn" ]]; then
            print_color "$CYAN" "Launching systemd-nspawn container..."
            print_color "$YELLOW" "Note: systemd-nspawn requires a prepared container image"
            print_color "$YELLOW" "See: https://wiki.archlinux.org/title/Systemd-nspawn"
        fi
    else
        print_color "$RED" "Invalid selection"
    fi
}

# Export sample configurations
action_export_samples() {
    clear
    print_color "$CYAN" "=== Export Sample Configurations ==="

    # Full-featured sample
    cat > "$WORKSPACE/sample-full.sandbox" <<EOF
# Sandman Sample Configuration - Full Featured
# Created: $(date)

[general]
name=sample-full
memory_mb=8192
networking=enabled

[shared_folders]
folder_1=$HOME/sandbox-share:readonly=false
EOF

    # Secure sample
    cat > "$WORKSPACE/sample-secure.sandbox" <<EOF
# Sandman Sample Configuration - Secure
# Created: $(date)

[general]
name=sample-secure
memory_mb=2048
networking=disabled

[shared_folders]
# No shared folders for maximum isolation
EOF

    # Minimal sample
    cat > "$WORKSPACE/sample-minimal.sandbox" <<EOF
# Sandman Sample Configuration - Minimal
# Created: $(date)

[general]
name=sample-minimal
memory_mb=2048
networking=enabled

[shared_folders]
# No shared folders
EOF

    print_color "$GREEN" "✓ Sample configurations exported:"
    echo "  - sample-full.sandbox"
    echo "  - sample-secure.sandbox"
    echo "  - sample-minimal.sandbox"
}

# Main menu
main_menu() {
    while true; do
        echo ""
        print_color "$YELLOW" "=== Sandman - Sandbox Manager ==="
        echo "Workspace: $WORKSPACE"
        echo "OS: $OS_TYPE"
        echo "Backend: $(get_sandbox_backend)"
        echo ""
        echo "[1] Create new configuration"
        echo "[2] List configurations"
        echo "[3] Edit configuration"
        echo "[4] Validate configuration"
        echo "[5] Export sample configurations"
        echo "[6] Launch sandbox"
        echo "[q] Quit"
        echo ""

        read -p "Select option: " choice

        case $choice in
            1) action_create ;;
            2) action_list ;;
            3) action_edit ;;
            4) action_validate ;;
            5) action_export_samples ;;
            6) action_launch ;;
            q|Q)
                print_color "$GREEN" "Goodbye!"
                exit 0
                ;;
            *) print_color "$RED" "Invalid option" ;;
        esac

        echo ""
        read -p "Press Enter to continue..." dummy
    done
}

# Entry point
main_menu
