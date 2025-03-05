#!/bin/bash
#
# install-commands.sh - Install command links for Network Chronicles
#
# This script creates symbolic links for the Network Chronicles commands
# in a location accessible in the player's PATH
#
# Part of Network Chronicles: The Vanishing Admin

GAME_ROOT="${1:-/opt/network-chronicles}"
BIN_DIR="/usr/local/bin"

# Terminal colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${RESET}"
    exit 1
fi

# Check if game root exists
if [ ! -d "$GAME_ROOT" ]; then
    echo -e "${RED}Error: Game root directory not found: $GAME_ROOT${RESET}"
    exit 1
fi

# Create bin directory if it doesn't exist
if [ ! -d "$BIN_DIR" ]; then
    echo -e "${YELLOW}Creating bin directory: $BIN_DIR${RESET}"
    mkdir -p "$BIN_DIR"
fi

# Install commands
install_command() {
    local src="$1"
    local cmd="$2"
    
    if [ -f "$src" ]; then
        # Remove existing link if it exists
        if [ -e "$BIN_DIR/$cmd" ]; then
            rm -f "$BIN_DIR/$cmd"
        fi
        
        # Create symbolic link
        ln -sf "$src" "$BIN_DIR/$cmd"
        chmod +x "$src"
        echo -e "${GREEN}Installed command: $cmd${RESET}"
    else
        echo -e "${RED}Source file not found: $src${RESET}"
    fi
}

# Install Network Chronicles commands
echo -e "${YELLOW}Installing Network Chronicles commands...${RESET}"

# Game core commands
install_command "$GAME_ROOT/bin/journal.sh" "nc-journal"
install_command "$GAME_ROOT/bin/network-chronicles-engine.sh" "nc-status"
install_command "$GAME_ROOT/bin/utils/script-template.sh" "nc-help"
install_command "$GAME_ROOT/bin/check-add-documents.sh" "nc-add-discovery"
install_command "$GAME_ROOT/bin/network-chronicles-engine.sh" "nc-complete-quest"

# The Architect integration
install_command "$GAME_ROOT/nc-contact-architect.sh" "nc-contact-architect"

echo -e "${GREEN}Command installation complete!${RESET}"
exit 0