#!/bin/bash
#
# nc-discover-services.sh - Command to run service discovery manually
#
# Part of Network Chronicles: The Vanishing Admin

# Get the current player ID
PLAYER_ID=$(whoami)

# Run the service discovery script
/home/memory/Desktop/Projects/Network\ Chronical/bin/service-discovery.sh "$PLAYER_ID"

exit $?