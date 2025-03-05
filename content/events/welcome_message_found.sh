#!/bin/bash
# welcome_message_found.sh - Event handler for finding The Architect's welcome message

PLAYER_ID="$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Check if already triggered
if grep -q "welcome_message" "${PLAYER_STATE}/discoveries.txt" 2>/dev/null; then
  exit 0
fi

# Add notification
echo -e "\n\033[1;32m[DISCOVERY]\033[0m The Architect's Welcome Message"
echo -e "You've found the welcome message left by The Architect."
echo -e "Use 'nc-add-discovery welcome_message' to record this finding in your journal.\n"

# Log the event
mkdir -p "${PLAYER_STATE}"
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ")|welcome_message_found" >> "${PLAYER_STATE}/events.log"

exit 0