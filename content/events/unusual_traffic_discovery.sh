#!/bin/bash
# unusual_traffic_discovery.sh - Event handler for discovering unusual traffic

PLAYER_ID="$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.unusual_traffic_discovered' "${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Update player state
tmp=$(mktemp)
jq '.story_flags.unusual_traffic_discovered = true | .discoveries += ["unusual_traffic"] | .xp += 75' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;31m[CRITICAL DISCOVERY]\033[0m Unusual Traffic Patterns Detected (+75 XP)"
echo -e "You've found evidence of repeated login attempts from IP 45.33.22.156."
echo -e "This appears to be a brute force attack that The Architect was investigating.\n"

# Add journal entry
TIMESTAMP=$(date +%Y-%m-%d)
cat > "${PLAYER_STATE}/journal/${TIMESTAMP}_unusual_traffic.md" << EOF
# Discovery: Unusual Traffic Patterns

Date: $(date "+%A, %B %d, %Y - %H:%M")

While examining the auth.log file, I discovered repeated failed login attempts from IP 45.33.22.156 targeting the admin account. This appears to be a brute force attack that was occurring around the time The Architect disappeared.

Key observations:
- Multiple failed login attempts from 45.33.22.156
- Targeting the admin account specifically
- The attack occurred on March 2, just before The Architect's last login
- There's a gap in the logs after this attack

This is a significant discovery and may be directly related to The Architect's disappearance. I need to investigate this IP address further and determine if the attacker gained access to the system.

I should also secure the system against further attacks from this IP address.
EOF

# Process quest updates
"${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"

exit 0