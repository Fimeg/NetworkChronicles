#!/bin/bash
#
# nc-secure-service.sh - Wrapper command for securing a service in Network Chronicles
#
# Part of Network Chronicles: The Vanishing Admin

SERVICE_ID="$1"
PLAYER_ID=$(whoami) # Assumes the script is run by the player

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

if [ -z "$SERVICE_ID" ]; then
  echo "Usage: nc-secure-service <service_id>"
  echo "Example: nc-secure-service old_web_service"
  exit 1
fi

# Simulate taking action - the actual game logic is handled by the engine trigger
echo -e "${YELLOW}[ACTION]${RESET} Attempting to apply security measures to service: ${GREEN}${SERVICE_ID}${RESET}..."
sleep 1 

# Provide feedback based on the specific service ID for this quest
if [ "$SERVICE_ID" == "old_web_service" ]; then
    echo -e "${GREEN}[SUCCESS]${RESET} Simulated disabling of potentially vulnerable service '${SERVICE_ID}'."
    echo -e "The associated port should no longer be active (in a real scenario)."
    echo -e "Check 'nc-status' to see if your objective is complete."
else
    echo -e "${YELLOW}[INFO]${RESET} Security protocols simulated for service '${SERVICE_ID}'. No specific vulnerability targeted by this action."
fi

# The engine will process this command via a trigger in nc-shell-integration.sh
# and grant the 'vulnerable_service_secured' discovery if applicable.

exit 0
