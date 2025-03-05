#!/bin/bash
#
# architect-contact-demo.sh - Test the Architect contact functionality
#
# A tool to test and demonstrate The Architect agent contact feature
# for development and testing purposes.
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"

# Get player ID (default to current user)
PLAYER_ID="${1:-$(whoami)}"

# Run the architect contact event script directly
echo "Triggering Architect contact event for player: $PLAYER_ID"
"${SCRIPT_DIR}/../content/events/architect_contact.sh" "$PLAYER_ID"

echo ""
echo "Event triggered. You can now run 'nc-contact-architect' to initiate contact with The Architect."
echo ""
echo "Note: This is a development tool. In the actual game, this event is triggered"
echo "      automatically when the player meets certain requirements."

exit 0