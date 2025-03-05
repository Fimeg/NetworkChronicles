#!/bin/bash
#
# architect_contact.sh - Event script for contacting The Architect
#
# This event is triggered when the player meets certain conditions
# and introduces them to the secure communication channel with The Architect.
#
# Part of Network Chronicles: The Vanishing Admin

# Get player ID from parameter
PLAYER_ID="$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Check if event already triggered
if jq -e '.story_flags.architect_contact' "${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Show cryptic message about connection
echo -e "\n\033[1;31m[SYSTEM ALERT]\033[0m Unusual encrypted signal detected on local network"
echo -e "\033[0;33mThe signal appears to be specifically directed to your terminal.\033[0m"
sleep 1
echo -e "\n\033[1;36m[INCOMING TRANSMISSION]\033[0m"
sleep 2

cat << EOF

\033[0;35m╭─────────────────────────────────────────────────────────────╮\033[0m
\033[0;35m│\033[0m \033[1;33m                     SECURE CHANNEL DETECTED                \033[0m \033[0;35m│\033[0m
\033[0;35m│\033[0m \033[0;36m                                                           \033[0m \033[0;35m│\033[0m
\033[0;35m│\033[0m                                                             \033[0;35m│\033[0m
\033[0;35m│\033[0m  A hidden communication channel has been detected.           \033[0;35m│\033[0m
\033[0;35m│\033[0m  This may be connected to The Architect's disappearance.     \033[0;35m│\033[0m
\033[0;35m│\033[0m                                                             \033[0;35m│\033[0m
\033[0;35m│\033[0m  To establish connection, run: \033[1;32mnc-contact-architect\033[0m         \033[0;35m│\033[0m
\033[0;35m│\033[0m                                                             \033[0;35m│\033[0m
\033[0;35m│\033[0m  \033[1;31mWARNING: Communications may be monitored\033[0m                  \033[0;35m│\033[0m
\033[0;35m│\033[0m  \033[1;31mProceed with caution\033[0m                                      \033[0;35m│\033[0m
\033[0;35m╰─────────────────────────────────────────────────────────────╯\033[0m

EOF

sleep 1
echo -e "\033[0;33mThe transmission appears to be using multiple layers of encryption...\033[0m"
echo -e "\033[0;33mIt could be The Architect reaching out from hiding.\033[0m"

# Mark event as triggered in player profile
tmp=$(mktemp)
jq '.story_flags.architect_contact = true' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"

# Add journal entry
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JOURNAL_FILE="${PLAYER_STATE}/journal.json"

tmp=$(mktemp)
jq ".entries += [{
  \"id\": \"architect_contact_discovered\",
  \"title\": \"Mysterious Communication Channel\",
  \"content\": \"I've detected an unusual encrypted communication channel on the network. The signal appears to be specifically targeting my terminal, suggesting it might be The Architect attempting to make contact from wherever they're hiding. The transmission mentioned a command I can use to establish a connection: nc-contact-architect. This could be my chance to learn directly from The Architect what happened and why they disappeared.\",
  \"timestamp\": \"${TIMESTAMP}\"
}]" "$JOURNAL_FILE" > "$tmp" && mv "$tmp" "$JOURNAL_FILE"

# Exit successfully
exit 0