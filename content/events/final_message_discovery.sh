#!/bin/bash
# final_message_discovery.sh - Event handler for discovering The Architect's final message

GAME_ROOT="/opt/network-chronicles"
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

echo -e "\033[1;36m[NEW CHALLENGE]\033[0m Find The Architect's Final Message"
echo "The breach timeline analysis suggests The Architect left a final message before disappearing."
echo "Look for hidden files or encrypted content that may contain their final communication."

# Create the necessary files for the challenge
mkdir -p /home/player/.architect
cat > /home/player/.architect/final_message.txt << EOF
To my successor,

If you're reading this, you've successfully followed my breadcrumbs. I had to disappear quickly after discovering a sophisticated attack targeting our infrastructure. The breach originated from 45.33.22.156, but I suspect this is just a proxy - the real attacker is someone with inside knowledge of our systems.

I've gone offline to investigate the source without alerting them. I'm working with authorities to track down who's behind this. For security reasons, I can't disclose my location.

You've proven yourself capable. The network is now yours to protect. I've left comprehensive documentation through the challenges you've solved.

Your next task is to map the entire network infrastructure and identify any other potential vulnerabilities. I've laid the groundwork in Tier 2.

Stay vigilant,
The Architect
EOF

chmod 644 /home/player/.architect/final_message.txt

# Create a trigger for finding the message
cat > "${GAME_ROOT}/content/triggers/found_final_message.json" << EOF
{
  "pattern": ".*cat.*\\/home\\/player\\/\\.architect\\/final_message\\.txt.*|.*ls -la.*\\/home\\/player\\/\\.architect.*|.*find.*\\.architect.*",
  "event": "found_final_message",
  "one_time": true
}
EOF

# Create the event handler
cat > "${GAME_ROOT}/content/events/found_final_message.sh" << EOF
#!/bin/bash
PLAYER_ID="\$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="\${GAME_ROOT}/data/players/\${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.found_final_message' "\${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Update player state
tmp=\$(mktemp)
jq '.story_flags.found_final_message = true | .xp += 200 | .discoveries += ["architects_final_message"]' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;35m[MAJOR DISCOVERY]\033[0m The Architect's Final Message (+200 XP)"
echo -e "You've found the hidden message left by The Architect!"
echo -e "This explains their disappearance and provides guidance for your next steps.\n"

# Add journal entry
TIMESTAMP=\$(date +%Y-%m-%d)
cat > "\${PLAYER_STATE}/journal/\${TIMESTAMP}_architects_message.md" << 'EOJ'
# Discovery: The Architect's Final Message

I've located a hidden directory (.architect) in the home directory that contains a final message from The Architect. The message explains that they disappeared intentionally after discovering the sophisticated attack on our infrastructure.

Key points from the message:
- The attack came from 45.33.22.156, but this is believed to be just a proxy
- The Architect suspects someone with inside knowledge is behind the attack
- They've gone offline deliberately to investigate without alerting the attacker
- They're working with authorities to track down the source
- I'm instructed to continue mapping and securing the network infrastructure
- Tier 2 will focus on complete network cartography

This confirms my timeline analysis - the connection between the attack and The Architect's disappearance was intentional, not malicious. They're still investigating the incident but had to go dark for security reasons.

With this discovery, I've completed Tier 1 and am ready to proceed to Tier 2: Network Cartography as instructed.
EOJ

# Check for quest updates
"\${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"

# Potentially trigger tier-up if appropriate
if jq -e '.tier == 1' "\${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  # Update to Tier 2
  tmp=\$(mktemp)
  jq '.tier = 2 | .xp = 0' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"
  
  # Add tier-up notification
  echo -e "\n\033[1;33m✨ TIER UP! You are now at Tier 2: Network Cartography! ✨\033[0m"
  echo -e "You've completed the Digital Footprints tier and earned access to advanced network mapping tools.\n"
fi

exit 0
EOF

chmod +x "${GAME_ROOT}/content/events/found_final_message.sh"

echo "Challenge initialized. Look for hidden files in the home directory."