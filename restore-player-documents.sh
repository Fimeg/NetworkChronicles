#!/bin/bash
#
# restore-player-documents.sh - Restores the Documents folder for the player
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/bin"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Restoring player Documents folder...${RESET}"

# Use the utility function to ensure Documents directory exists
ensure_player_documents "player"

echo -e "${GREEN}Player Documents folder restored successfully!${RESET}"
echo -e "Location: $(get_player_docs_dir player)"