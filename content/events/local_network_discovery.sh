#!/bin/bash
# Event handler for discovering the local network

PLAYER_ID="$1"
ENGINE="/opt/network-chronicles/bin/network-chronicles-engine.sh"
GREEN='\033[0;32m'
RESET='\033[0m'

# Add the 'local_network' discovery using the engine
# The engine's add-discovery function will handle XP and check for tier upgrades
"$ENGINE" add-discovery "$PLAYER_ID" "local_network"

# Example notification (can be uncommented if needed):
# echo -e "\n${GREEN}[EVENT]${RESET} Local network discovery processed."

exit 0
