#!/bin/bash
# Event handler for identifying the vulnerable service

PLAYER_ID="$1"
ENGINE="/opt/network-chronicles/bin/network-chronicles-engine.sh"
YELLOW='\033[1;33m'
RESET='\033[0m'

# Add the 'vulnerable_service_identified' discovery using the engine
# This discovery itself might not grant XP, but enables the next step.
"$ENGINE" add-discovery "$PLAYER_ID" "vulnerable_service_identified"

# Notify the player
echo -e "\n${YELLOW}[ALERT]${RESET} You've identified a potentially vulnerable service (Old Web Service on port 8088)."
echo -e "Based on the documentation, it seems outdated and insecure."
echo -e "You should take action to secure it. Try using 'nc-secure-service old_web_service'."

exit 0
