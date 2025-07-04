#!/bin/bash
# Network Chronicles 2.0 - Uninstall Script

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Set up variables
INSTALL_DIR="/opt/network-chronicles"
USER_INSTALL_DIR="$HOME/.local/share/network-chronicles"
BIN_DIR="/usr/local/bin"

# Print banner
echo -e "${RED}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   NETWORK CHRONICLES 2.0: UNINSTALL                                     ║"
echo "║   Removing game files and configuration                                 ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Ask for confirmation
echo -e "${YELLOW}This will remove Network Chronicles 2.0 and all associated data.${RESET}"
echo -e "${YELLOW}This action CANNOT be undone!${RESET}"
echo ""
read -p "Are you sure you want to continue? (type 'YES' to confirm): " confirm

if [ "$confirm" != "YES" ]; then
    echo -e "${CYAN}Uninstall cancelled.${RESET}"
    exit 0
fi

# Function to remove directory safely
remove_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        echo -e "${CYAN}Removing ${description}...${RESET}"
        rm -rf "$dir"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Removed ${description}${RESET}"
        else
            echo -e "${RED}✗ Failed to remove ${description}${RESET}"
        fi
    else
        echo -e "${YELLOW}• ${description} not found (already removed)${RESET}"
    fi
}

# Function to remove file safely
remove_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        echo -e "${CYAN}Removing ${description}...${RESET}"
        rm -f "$file"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Removed ${description}${RESET}"
        else
            echo -e "${RED}✗ Failed to remove ${description}${RESET}"
        fi
    else
        echo -e "${YELLOW}• ${description} not found (already removed)${RESET}"
    fi
}

# Check if running as root (for system-wide uninstall)
if [ "$(id -u)" -eq 0 ]; then
    echo -e "${CYAN}Running as root - performing system-wide uninstall${RESET}"
    
    # Remove system installation
    remove_directory "$INSTALL_DIR" "system installation directory"
    
    # Remove global command links
    remove_file "$BIN_DIR/nc" "global nc command"
    remove_file "$BIN_DIR/network-chronicles" "global network-chronicles command"
    
    # Remove systemd service if it exists
    remove_file "/etc/systemd/system/network-chronicles.service" "systemd service"
    
    # Reload systemd if service was removed
    if systemctl list-unit-files | grep -q network-chronicles; then
        echo -e "${CYAN}Reloading systemd...${RESET}"
        systemctl daemon-reload
    fi
    
else
    echo -e "${CYAN}Running as user - performing user-space uninstall${RESET}"
    
    # Remove user installation
    remove_directory "$USER_INSTALL_DIR" "user installation directory"
    
    # Remove user bin files
    remove_file "$HOME/.local/bin/nc" "user nc command"
    remove_file "$HOME/.local/bin/network-chronicles" "user network-chronicles command"
fi

# Remove shell integration from common shell config files
echo -e "${CYAN}Checking for shell integration...${RESET}"

SHELL_CONFIGS=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.profile"
    "$HOME/.bash_profile"
)

NC_INTEGRATION_PATTERN="network-chronicles.*integration"

for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        if grep -q "$NC_INTEGRATION_PATTERN" "$config"; then
            echo -e "${CYAN}Removing shell integration from $(basename $config)...${RESET}"
            
            # Create backup
            cp "$config" "${config}.nc-backup.$(date +%s)"
            
            # Remove Network Chronicles lines
            sed -i '/network-chronicles.*integration/d' "$config"
            sed -i '/# Network Chronicles/d' "$config"
            sed -i '/source.*network-chronicles/d' "$config"
            
            echo -e "${GREEN}✓ Removed integration from $(basename $config)${RESET}"
            echo -e "${YELLOW}  Backup created: ${config}.nc-backup.*${RESET}"
        fi
    fi
done

# Remove Docker containers and images if they exist
echo -e "${CYAN}Checking for Docker containers...${RESET}"

if command -v docker &> /dev/null; then
    # Stop and remove containers
    NC_CONTAINERS=$(docker ps -a --filter="name=network-chronicles" --format="{{.Names}}" 2>/dev/null)
    if [ ! -z "$NC_CONTAINERS" ]; then
        echo -e "${CYAN}Stopping and removing Docker containers...${RESET}"
        echo "$NC_CONTAINERS" | xargs docker rm -f
        echo -e "${GREEN}✓ Removed Docker containers${RESET}"
    fi
    
    # Remove images
    NC_IMAGES=$(docker images --filter="reference=network-chronicles*" --format="{{.Repository}}:{{.Tag}}" 2>/dev/null)
    if [ ! -z "$NC_IMAGES" ]; then
        echo -e "${CYAN}Removing Docker images...${RESET}"
        echo "$NC_IMAGES" | xargs docker rmi -f
        echo -e "${GREEN}✓ Removed Docker images${RESET}"
    fi
    
    # Remove docker-compose files if they exist
    remove_file "$HOME/docker-compose.yml" "docker-compose.yml (if Network Chronicles)"
    remove_file "$HOME/network-chronicles-docker-compose.yml" "Network Chronicles docker-compose file"
else
    echo -e "${YELLOW}• Docker not found (skipping container cleanup)${RESET}"
fi

# Remove configuration directories from common locations
echo -e "${CYAN}Checking for configuration files...${RESET}"

CONFIG_DIRS=(
    "$HOME/.config/network-chronicles"
    "$HOME/.cache/network-chronicles"
    "/etc/network-chronicles"
)

for dir in "${CONFIG_DIRS[@]}"; do
    remove_directory "$dir" "configuration directory $(basename $dir)"
done

# Remove log files
echo -e "${CYAN}Checking for log files...${RESET}"

LOG_LOCATIONS=(
    "/var/log/network-chronicles"
    "$HOME/.local/share/network-chronicles/logs"
    "/tmp/network-chronicles*"
)

for location in "${LOG_LOCATIONS[@]}"; do
    if ls $location 2>/dev/null | head -1 | grep -q .; then
        echo -e "${CYAN}Removing logs from $location...${RESET}"
        rm -rf $location
        echo -e "${GREEN}✓ Removed logs${RESET}"
    fi
done

# Remove temporary files
echo -e "${CYAN}Cleaning temporary files...${RESET}"
find /tmp -name "*network-chronicles*" -type f -delete 2>/dev/null || true
echo -e "${GREEN}✓ Cleaned temporary files${RESET}"

# Final cleanup and recommendations
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════════════════╗"
echo -e "║                        UNINSTALL COMPLETE                               ║"
echo -e "╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}Network Chronicles 2.0 has been removed from your system.${RESET}"
echo ""
echo -e "${YELLOW}Manual cleanup recommendations:${RESET}"
echo -e "• Restart your terminal or source your shell config to remove any remaining functions"
echo -e "• Check for any remaining shell aliases: ${CYAN}alias | grep nc${RESET}"
echo -e "• Review shell history for any custom NC commands: ${CYAN}history | grep nc-${RESET}"
echo ""
echo -e "${YELLOW}If you backed up any game data:${RESET}"
echo -e "• Player data backups may exist in your home directory"
echo -e "• Check for *.nc-backup.* files in your shell config directories"
echo ""
echo -e "${GREEN}Thank you for trying Network Chronicles 2.0!${RESET}"
echo -e "If you have feedback about your experience, please share it at:"
echo -e "${CYAN}https://github.com/network-chronicles/network-chronicles/issues${RESET}"