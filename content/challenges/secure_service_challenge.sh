#!/bin/bash
# secure_service_challenge.sh - A challenge to teach security hardening

GAME_ROOT="/opt/network-chronicles"
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

echo -e "\033[1;36m[NEW CHALLENGE]\033[0m Secure the Vulnerable Service"
echo "After discovering the unusual traffic from 45.33.22.156, you need to secure the system against further attacks."
echo "Your task is to implement firewall rules to block the attacker's IP address."

# Create the challenge files if they don't exist
if [ ! -f "${PLAYER_STATE}/inventory/challenges/security_checklist.txt" ]; then
  # Create challenge directory
  mkdir -p "${PLAYER_STATE}/inventory/challenges"
  
  # Create hint file
  cat > "${PLAYER_STATE}/inventory/challenges/security_checklist.txt" << EOF
Security Checklist - CONFIDENTIAL
Last updated by The Architect

1. Firewall Rules
   - Block known malicious IP addresses
   - Recommended command: iptables -A INPUT -s <malicious_ip> -j DROP
   - Alternative for UFW: ufw deny from <malicious_ip>
   - Always document changes in /var/log/security_changes.log

2. SSH Hardening
   - Disable password authentication
   - Use key-based authentication only
   - Consider implementing 2FA for admin accounts
   - Restrict access to specific IP ranges

3. Service Isolation
   - Run critical services in containers or with reduced privileges
   - Implement network segmentation for sensitive services
   - Regular backup and integrity verification

Note: If you're reading this after March 2nd, please be aware that I've
detected suspicious activity from 45.33.22.156. This IP should be
IMMEDIATELY BLOCKED as it has been attempting to brute force our admin accounts.
EOF

  # Update player inventory
  tmp=$(mktemp)
  jq '.inventory += ["security_checklist"]' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"
  
  echo -e "\nA security checklist has been added to your inventory: challenges/security_checklist.txt"
  echo -e "Use 'cat ${PLAYER_STATE}/inventory/challenges/security_checklist.txt' to view it.\n"
}

# Create a trigger for when the player runs iptables or ufw
cat > "${GAME_ROOT}/content/triggers/firewall_rule_added.json" << EOF
{
  "pattern": ".*iptables.*-A INPUT -s 45\\.33\\.22\\.156.*DROP.*|.*ufw deny from 45\\.33\\.22\\.156.*",
  "event": "firewall_rule_added",
  "one_time": true
}
EOF

# Create the event handler
cat > "${GAME_ROOT}/content/events/firewall_rule_added.sh" << EOF
#!/bin/bash
PLAYER_ID="\$1"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="\${GAME_ROOT}/data/players/\${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.firewall_rule_added' "\${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Update player state
tmp=\$(mktemp)
jq '.story_flags.firewall_rule_added = true | .xp += 100 | .skill_points.security += 1 | .reputation.security += 10' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;32m[CHALLENGE COMPLETE]\033[0m Secured Vulnerable Service (+100 XP)"
echo -e "You successfully implemented a firewall rule to block the attacker's IP!"
echo -e "You gained +1 Security skill point and increased your Security department reputation.\n"

# Add journal entry
TIMESTAMP=\$(date +%Y-%m-%d)
cat > "\${PLAYER_STATE}/journal/\${TIMESTAMP}_secured_service.md" << 'EOJ'
# Security Update: Blocked Malicious IP

After discovering the repeated login attempts from 45.33.22.156, I've implemented a firewall rule to block all traffic from this IP address. This should prevent any further attacks from this source.

I used the command pattern recommended in The Architect's security checklist to block the IP at the firewall level. This is a basic security measure, but it should be effective against this specific attacker.

I should continue to monitor the logs for any unusual activity from other IP addresses, as the attacker might try from a different location.

Next steps:
1. Implement additional security measures like 2FA
2. Review user accounts for unauthorized changes
3. Continue investigating the timing of The Architect's disappearance relative to this attack
EOJ

# Check for quest updates
"\${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"

exit 0
EOF

chmod +x "${GAME_ROOT}/content/events/firewall_rule_added.sh"

echo "Challenge initialized. Check your inventory for the security checklist."