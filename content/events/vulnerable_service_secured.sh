#!/bin/bash
# Event handler for securing the vulnerable service

PLAYER_ID="$1"
ENGINE="/opt/network-chronicles/bin/network-chronicles-engine.sh"
GREEN='\033[0;32m'
RESET='\033[0m'

# Add the 'vulnerable_service_secured' discovery using the engine
# This discovery completes the 'secure_vulnerable_service' quest.
# The engine's add-discovery function handles XP based on the discovery definition.
"$ENGINE" add-discovery "$PLAYER_ID" "vulnerable_service_secured"

# Notify the player
echo -e "\n${GREEN}[SECURED]${RESET} Vulnerable service 'old_web_service' has been addressed."
echo -e "This action fulfills the requirements for the 'Secure Vulnerable Service' quest."
echo -e "Use 'nc-complete-quest' to mark the quest as complete and receive your reward."

# We also need a discovery definition for vulnerable_service_secured for XP
# Create content/discoveries/vulnerable_service_secured.json if it doesn't exist

DISCOVERY_FILE="/opt/network-chronicles/content/discoveries/vulnerable_service_secured.json"
if [ ! -f "$DISCOVERY_FILE" ]; then
  echo '{
    "id": "vulnerable_service_secured",
    "name": "Vulnerable Service Secured",
    "description": "Successfully addressed the vulnerability in the old web service.",
    "type": "action",
    "xp": 50 
  }' > "$DISCOVERY_FILE"
  chmod 664 "$DISCOVERY_FILE" # Ensure readable by game/engine
fi


exit 0
