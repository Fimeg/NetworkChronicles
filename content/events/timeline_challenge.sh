#!/bin/bash
# timeline_challenge.sh - Challenge for creating a timeline of the security breach

GAME_ROOT="/opt/network-chronicles"
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

echo -e "\033[1;36m[NEW CHALLENGE]\033[0m Breach Timeline Analysis"
echo "Now that you've discovered the unusual traffic, create a timeline of events to understand what happened to The Architect."
echo "Analyze the auth.log file to identify patterns in the attack and The Architect's last actions."

# Create the challenge files if they don't exist
if [ ! -f "${PLAYER_STATE}/inventory/challenges/timeline_template.txt" ]; then
  # Create challenge directory
  mkdir -p "${PLAYER_STATE}/inventory/challenges"
  
  # Create hint file
  cat > "${PLAYER_STATE}/inventory/challenges/timeline_template.txt" << EOF
BREACH TIMELINE TEMPLATE
------------------------

Instructions:
1. Review auth.log entries for March 2nd
2. Document key events with timestamps
3. Look for patterns in login attempts
4. Note The Architect's login/logout times
5. Identify suspicious activity

Example entry format:
[TIMESTAMP] - [EVENT] - [NOTES]

Key questions to answer:
- When did the attack begin?
- How did The Architect respond?
- What happened after the attack?
- When was The Architect's last activity?
- Is there a correlation between the attack and The Architect's disappearance?

Once you've created your timeline, save it or print it for reference.
EOF

  # Update player inventory
  tmp=$(mktemp)
  jq '.inventory += ["timeline_template"]' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"
  
  echo -e "\nA timeline template has been added to your inventory: challenges/timeline_template.txt"
  echo -e "Use 'cat ${PLAYER_STATE}/inventory/challenges/timeline_template.txt' to view it.\n"
}

# Create a trigger for when the player analyzes the timeline
cat > "${GAME_ROOT}/content/triggers/timeline_analyzed.json" << EOF
{
  "pattern": ".*grep.*\\<Mar.*2.*\\/var\\/log\\/auth\\.log.*|.*cat.*breach_timeline\\.txt.*|.*echo.*'Timeline Analysis'.*",
  "event": "timeline_analyzed",
  "one_time": true
}
EOF

# Create the event handler
cat > "${GAME_ROOT}/content/events/timeline_analyzed.sh" << EOF
#!/bin/bash
PLAYER_ID="\$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="\${GAME_ROOT}/data/players/\${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.timeline_analyzed' "\${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Update player state
tmp=\$(mktemp)
jq '.story_flags.timeline_analyzed = true | .xp += 150 | .discoveries += ["breach_timeline"]' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;32m[DISCOVERY]\033[0m Security Breach Timeline (+150 XP)"
echo -e "You've successfully analyzed the timeline of events surrounding The Architect's disappearance."
echo -e "The pattern suggests a connection between the attack and The Architect going offline.\n"

# Add journal entry
TIMESTAMP=\$(date +%Y-%m-%d)
cat > "\${PLAYER_STATE}/journal/\${TIMESTAMP}_breach_timeline.md" << 'EOJ'
# Security Breach Timeline Analysis

After carefully analyzing the auth.log entries, I've constructed a timeline of the security breach:

Mar 2, 01:17:33 - Initial attack begins from 45.33.22.156
Mar 2, 01:17:33-01:17:45 - Multiple failed login attempts targeting admin account
Mar 2, 01:18:01 - The Architect logs in (last normal login)
Mar 2, 01:18:45 - Attack intensifies (20 repeated attempts)
Mar 2, 01:20:12 - Attacker connection closes
Mar 2, 02:17:45 - The Architect logs in again (possible compromise)
Mar 2, 02:35:22 - The Architect's session disconnects

This timeline reveals a concerning pattern. The Architect appears to have logged in during the attack, presumably to investigate and implement countermeasures. However, the second login at 02:17:45 is suspicious - it could be The Architect returning to continue their investigation, or it could be the attacker gaining access with stolen credentials.

The final disconnect at 02:35:22 marks the last recorded activity before The Architect's disappearance. This strongly suggests a connection between the attack and their absence.

Next steps:
1. Look for any messages or notes The Architect may have left during those final 18 minutes
2. Check for any files created or modified during that time window
3. Search for any hidden communication channels The Architect might have used
EOJ

# Check for quest updates
"\${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"

exit 0
EOF

chmod +x "${GAME_ROOT}/content/events/timeline_analyzed.sh"

echo "Challenge initialized. Check your inventory for the timeline template."