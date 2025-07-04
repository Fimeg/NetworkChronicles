#!/bin/bash
# Event handler for discovering the network gateway

PLAYER_ID="$1"
ENGINE="/opt/network-chronicles/bin/network-chronicles-engine.sh"
GREEN='\033[0;32m'
RESET='\033[0m'

# Add the 'network_gateway' discovery using the engine
# The engine's add-discovery function will handle XP and check for tier upgrades
"$ENGINE" add-discovery "$PLAYER_ID" "network_gateway"

# Check if the discovery was successfully added (optional, engine handles logging)
# We can add a notification here if desired, though add-discovery might handle it
# For now, let's assume add-discovery provides feedback or the prompt update is sufficient.

# Example notification (can be uncommented if needed):
# echo -e "\n${GREEN}[EVENT]${RESET} Network gateway discovery processed."

exit 0
