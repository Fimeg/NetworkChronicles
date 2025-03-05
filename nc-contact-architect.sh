#!/bin/bash
#
# nc-contact-architect.sh - Connect to The Architect's secure channel
#
# This wrapper script provides easy access to the Architect Agent
# for players to communicate with The Architect character.
#
# Part of Network Chronicles: The Vanishing Admin

# Get current player ID
PLAYER_ID=$(whoami)

# Get the script's directory and game root
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
GAME_ROOT="${SCRIPT_DIR}"

# Call the Architect Agent script with chat mode
"${GAME_ROOT}/bin/architect-agent.sh" chat "$PLAYER_ID"

exit $?