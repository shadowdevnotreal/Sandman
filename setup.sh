#!/bin/bash
# Sandman Setup Script for Linux/macOS
# Version 1.0.0

set -e

# Colors
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

# Print colored message
print_msg() {
    local color="$1"
    local symbol="$2"
    local message="$3"
    echo -e "${color}[${symbol}]${NC} ${message}"
}

echo "========================================"
echo "Sandman - Setup for $OS_TYPE"
echo "========================================"
echo ""

# ====================================
# CUSTOMIZABLE PATHS
# Edit these paths for your local system
# ====================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Installation directory
export SANDMAN_HOME="$SCRIPT_DIR"

# Workspace directory
if [[ "$OS_TYPE" == "macos" ]]; then
    export WORKSPACE="$HOME/Library/Application Support/Sandman"
else
    export WORKSPACE="$HOME/.local/share/sandman"
fi

print_msg "$CYAN" "*" "Installation directory: $SANDMAN_HOME"
print_msg "$CYAN" "*" "Workspace directory: $WORKSPACE"
echo ""

# ====================================
# CREATE WORKSPACE DIRECTORY
# ====================================

print_msg "$CYAN" "*" "Creating workspace directory..."

if [[ ! -d "$WORKSPACE" ]]; then
    mkdir -p "$WORKSPACE"
    print_msg "$GREEN" "+" "Created: $WORKSPACE"
else
    print_msg "$YELLOW" "i" "Workspace already exists: $WORKSPACE"
fi

# Create subdirectories
mkdir -p "$WORKSPACE/templates"
mkdir -p "$WORKSPACE/backups"
mkdir -p "$WORKSPACE/logs"

print_msg "$GREEN" "+" "Subdirectories created."
echo ""

# ====================================
# CHECK DEPENDENCIES
# ====================================

print_msg "$CYAN" "*" "Checking dependencies..."

# Check for jq (JSON processor)
if command -v jq >/dev/null 2>&1; then
    print_msg "$GREEN" "+" "jq is installed"
else
    print_msg "$YELLOW" "!" "jq is not installed (optional but recommended)"
    print_msg "$YELLOW" "i" "To install jq:"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "    brew install jq"
    else
        echo "    sudo apt-get install jq  (Debian/Ubuntu)"
        echo "    sudo dnf install jq      (Fedora)"
        echo "    sudo pacman -S jq        (Arch)"
    fi
fi

# Check for Docker
if command -v docker >/dev/null 2>&1; then
    if docker ps >/dev/null 2>&1; then
        print_msg "$GREEN" "+" "Docker is installed and running"
    else
        print_msg "$YELLOW" "!" "Docker is installed but not running"
        print_msg "$YELLOW" "i" "Start Docker to use container sandboxes"
    fi
else
    print_msg "$YELLOW" "!" "Docker is not installed"
    print_msg "$YELLOW" "i" "To install Docker:"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "    Visit: https://docs.docker.com/desktop/install/mac-install/"
    else
        echo "    Visit: https://docs.docker.com/engine/install/"
        echo "    Or: sudo apt-get install docker.io (Debian/Ubuntu)"
    fi
fi

# Check for systemd-nspawn (Linux only)
if [[ "$OS_TYPE" == "linux" ]]; then
    if command -v systemd-nspawn >/dev/null 2>&1; then
        print_msg "$GREEN" "+" "systemd-nspawn is available"
    else
        print_msg "$YELLOW" "i" "systemd-nspawn not found (alternative to Docker)"
    fi
fi

echo ""

# ====================================
# PRE-INSTALL PACKAGES
# ====================================

read -p "Install recommended packages? (y/N): " install_packages

if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    print_msg "$CYAN" "*" "Installing packages..."

    if [[ "$OS_TYPE" == "macos" ]]; then
        # Check for Homebrew
        if ! command -v brew >/dev/null 2>&1; then
            print_msg "$RED" "!" "Homebrew not found. Please install Homebrew first:"
            echo "    /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        else
            # Install packages via Homebrew
            print_msg "$CYAN" "*" "Installing via Homebrew..."

            # Git
            if ! command -v git >/dev/null 2>&1; then
                brew install git
            fi

            # Uncomment to install additional packages
            # brew install node
            # brew install python3
            # brew install --cask visual-studio-code
            # brew install --cask docker

            print_msg "$GREEN" "+" "Package installation complete!"
        fi

    elif [[ "$OS_TYPE" == "linux" ]]; then
        # Detect package manager
        if command -v apt-get >/dev/null 2>&1; then
            PKG_MGR="apt-get"
            PKG_INSTALL="sudo apt-get install -y"
        elif command -v dnf >/dev/null 2>&1; then
            PKG_MGR="dnf"
            PKG_INSTALL="sudo dnf install -y"
        elif command -v pacman >/dev/null 2>&1; then
            PKG_MGR="pacman"
            PKG_INSTALL="sudo pacman -S --noconfirm"
        else
            print_msg "$RED" "!" "No supported package manager found"
            PKG_MGR=""
        fi

        if [[ -n "$PKG_MGR" ]]; then
            print_msg "$CYAN" "*" "Installing via $PKG_MGR..."

            # Update package lists (apt-get only)
            if [[ "$PKG_MGR" == "apt-get" ]]; then
                sudo apt-get update
            fi

            # Git
            if ! command -v git >/dev/null 2>&1; then
                $PKG_INSTALL git
            fi

            # Uncomment to install additional packages
            # $PKG_INSTALL nodejs
            # $PKG_INSTALL python3
            # $PKG_INSTALL docker.io
            # $PKG_INSTALL build-essential

            print_msg "$GREEN" "+" "Package installation complete!"
        fi
    fi
else
    print_msg "$YELLOW" "*" "Skipping package installation."
fi

echo ""

# ====================================
# MAKE SCRIPTS EXECUTABLE
# ====================================

print_msg "$CYAN" "*" "Making scripts executable..."

if [[ -f "$SANDMAN_HOME/sandman.sh" ]]; then
    chmod +x "$SANDMAN_HOME/sandman.sh"
    print_msg "$GREEN" "+" "sandman.sh is now executable"
fi

if [[ -f "$SANDMAN_HOME/setup.sh" ]]; then
    chmod +x "$SANDMAN_HOME/setup.sh"
fi

echo ""

# ====================================
# CREATE LAUNCHER SCRIPT
# ====================================

read -p "Create launcher script? (y/N): " create_launcher

if [[ "$create_launcher" =~ ^[Yy]$ ]]; then
    LAUNCHER="$WORKSPACE/launch-sandman.sh"

    cat > "$LAUNCHER" <<EOF
#!/bin/bash
# Sandman Launcher
cd "$SANDMAN_HOME"
./sandman.sh
EOF

    chmod +x "$LAUNCHER"
    print_msg "$GREEN" "+" "Launcher created: $LAUNCHER"
    echo ""
    print_msg "$YELLOW" "i" "You can run Sandman with: $LAUNCHER"
fi

echo ""

# ====================================
# UPDATE CONFIG.JSON
# ====================================

print_msg "$CYAN" "*" "Checking configuration file..."

if [[ -f "$SANDMAN_HOME/config.json" ]]; then
    print_msg "$GREEN" "+" "Configuration file found: config.json"
    print_msg "$YELLOW" "i" "You can edit config.json to customize settings."
else
    print_msg "$YELLOW" "!" "Configuration file not found."
    print_msg "$YELLOW" "i" "A default config.json should be created."
fi

echo ""

# ====================================
# SETUP COMPLETE
# ====================================

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Run Sandman:"
echo "     cd $SANDMAN_HOME"
echo "     ./sandman.sh"
echo ""
echo "  2. Create your first sandbox configuration:"
echo "     Press [1] in the menu"
echo ""
echo "  3. Edit config.json to customize settings:"
echo "     nano $SANDMAN_HOME/config.json"
echo ""
echo "Workspace: $WORKSPACE"
echo ""

# Optional: Add to PATH
echo ""
read -p "Add Sandman to PATH? (y/N): " add_to_path

if [[ "$add_to_path" =~ ^[Yy]$ ]]; then
    # Detect shell
    if [[ -n "$BASH_VERSION" ]]; then
        SHELL_RC="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        SHELL_RC="$HOME/.zshrc"
    else
        SHELL_RC="$HOME/.profile"
    fi

    # Add to shell RC
    if ! grep -q "SANDMAN_HOME" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# Sandman" >> "$SHELL_RC"
        echo "export SANDMAN_HOME=\"$SANDMAN_HOME\"" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:\$SANDMAN_HOME\"" >> "$SHELL_RC"

        print_msg "$GREEN" "+" "Added to $SHELL_RC"
        print_msg "$YELLOW" "i" "Restart your shell or run: source $SHELL_RC"
    else
        print_msg "$YELLOW" "i" "SANDMAN_HOME already in $SHELL_RC"
    fi
fi

echo ""
print_msg "$GREEN" "✓" "Setup complete! Enjoy using Sandman."
