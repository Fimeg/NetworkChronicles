#!/bin/bash
#
# check-add-documents.sh - Ensures player Documents directory exists
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"

echo "Checking for player Documents folder..."
# Simply call the utility function
ensure_player_documents "player"

echo "Done!"