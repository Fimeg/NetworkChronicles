#!/bin/bash
# network_scan_challenge.sh - A challenge to teach network scanning

GAME_ROOT="/opt/network-chronicles"
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# ASCII art and styling
echo -e "\033[1;36m╭────────────────────────────────────────────────────────────╮\033[0m"
echo -e "\033[1;36m│\033[0m               \033[1;93mNEW CHALLENGE DETECTED\033[0m                  \033[1;36m│\033[0m"
echo -e "\033[1;36m│\033[0m               \033[1;31m[ ANOMALOUS SIGNALS ]\033[0m                   \033[1;36m│\033[0m"
echo -e "\033[1;36m╰────────────────────────────────────────────────────────────╯\033[0m"

# Create the challenge files if they don't exist
if [ ! -f "${PLAYER_STATE}/inventory/challenges/network_scan.txt" ]; then
  # Create challenge directory
  mkdir -p "${PLAYER_STATE}/inventory/challenges"
  
  # Create terminal recording file - looks like a system log
  cat > "${PLAYER_STATE}/inventory/challenges/network_scan.txt" << EOF
────────────────────────────────────────────
      ARCHITECT'S TERMINAL • SESSION 47
────────────────────────────────────────────

[03:27:42] $ sudo grep "anomalous" /var/log/syslog
Apr 15 02:14:22 server-01 custom-monitor[12345]: WARNING: Anomalous traffic pattern detected from 192.168.1.42:8080
Apr 15 02:14:30 server-01 custom-monitor[12345]: WARNING: Anomalous traffic pattern continues - data exfiltration suspected
Apr 15 02:17:33 server-01 custom-monitor[12345]: ERROR: Anomalous service detected on port 8080

[03:28:03] $ nmap -p 8080 192.168.1.42
Starting Nmap 7.80 ( https://nmap.org )
Nmap scan report for 192.168.1.42
Host is up (0.00042s latency).

PORT     STATE SERVICE
8080/tcp open  http-proxy

[03:28:35] $ curl 192.168.1.42:8080
<!DOCTYPE html>
<html>
<head><title>Monitoring System</title></head>
<body>
<h1>Internal Monitoring System</h1>
<p>Unauthorized access detected. Connection logged.</p>
</body>
</html>

[03:28:50] $ echo "I need to scan the entire subnet to find all instances of this service"

────────────────────────────────────────────
    END OF SESSION • SIGNAL INTERRUPTED
────────────────────────────────────────────

>> NOTE TO SELF: Something's running on port 8080 across our subnet.
>> Need to map all instances before they notice my investigation.
>> Use full subnet scan: nmap -p 8080 192.168.1.0/24
EOF

  # Update player inventory
  tmp=$(mktemp)
  jq '.inventory += ["network_scan_log"]' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"
  
  echo -e "\033[1;32m>> RECOVERED DATA:\033[0m The Architect's terminal session has been found."
  echo -e "A log file has been saved to your inventory: \033[1;33mchallenges/network_scan.txt\033[0m"
  echo -e "\033[1;97mExamine the log file with: cat ${PLAYER_STATE}/inventory/challenges/network_scan.txt\033[0m"
  echo ""
  echo -e "\033[0;36mThe log appears to show The Architect investigating an anomalous"
  echo -e "service running on port 8080. They were planning to scan the entire subnet"
  echo -e "before their session was mysteriously interrupted.\033[0m"
  echo ""
  echo -e "\033[0;93m>> SYSTEM SUGGESTION: Complete The Architect's interrupted scan.\033[0m"
}

# Create a trigger for when the player runs nmap
cat > "${GAME_ROOT}/triggers/network_scan.json" << EOF
{
  "pattern": ".*nmap.*-p.*8080.*192\\.168\\.1\\.0\\/24.*|.*nmap.*192\\.168\\.1\\.0\\/24.*",
  "event": "network_scan_complete",
  "one_time": true
}
EOF

# Create the event handler
cat > "${GAME_ROOT}/events/network_scan_complete.sh" << EOF
#!/bin/bash
PLAYER_ID="\$1"
PLAYER_STATE="${GAME_ROOT}/data/players/\${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.network_scan_complete' "\${PLAYER_STATE}/profile.json" > /dev/null 2>&1; then
  exit 0
fi

# Generate simulated nmap output for immersion
echo ""
echo "Starting Nmap 7.80 ( https://nmap.org )"
echo "Scanning 192.168.1.0/24 [1 port]"
sleep 0.2
echo "Discovered open port 8080/tcp on 192.168.1.42"
sleep 0.1
echo "Discovered open port 8080/tcp on 192.168.1.137"
sleep 0.3
echo "Discovered open port 8080/tcp on 192.168.1.201"
sleep 0.2
echo "Nmap done: 256 IP addresses (243 hosts up) scanned in 3.34 seconds"
echo ""

# Update player state
tmp=\$(mktemp)
jq '.story_flags.network_scan_complete = true | .xp += 75 | .discoveries += ["monitoring_service"]' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add discovery artifact 
mkdir -p "\${PLAYER_STATE}/inventory/network-map"
cat > "\${PLAYER_STATE}/inventory/network-map/scan-results.txt" << 'SCAN'
NETWORK SCAN RESULTS
===================================
Date: $(date +"%Y-%m-%d %H:%M:%S")
Target: 192.168.1.0/24 (Port 8080)
-----------------------------------

OPEN PORTS:
• 192.168.1.42:8080   [Primary Monitor]
• 192.168.1.137:8080  [Unknown Service]
• 192.168.1.201:8080  [Unknown Service]

ANALYSIS:
These services appear to be running custom HTTP servers.
Based on response headers, they seem to be part of a
distributed monitoring system that was not in the 
official network documentation.

All three IP addresses respond with similar web pages
but with different access credentials. They appear to
be collecting system data at regular intervals.

SECURITY CONCERN:
Traffic from these services shows indications of data
exfiltration to an external IP. The destination is 
masked through multiple hops.

RECOMMENDATION:
Continue investigation of these monitoring services.
They may be related to The Architect's disappearance.
SCAN

# Add notification
echo -e "\n\033[1;32m[CHALLENGE COMPLETE]\033[0m Anomalous Signals (+75 XP)"
echo -e "\033[1;97mYou've discovered a hidden monitoring system spread across multiple IP addresses!\033[0m"
echo -e "\033[1;97mThe scan results have been saved to your inventory.\033[0m"
echo ""
echo -e "\033[1;31m>> ANOMALY DETECTED\033[0m"
echo -e "\033[0;36mThese monitoring services do not appear in any official network documentation."
echo -e "They seem to be collecting and exfiltrating data to an external destination."
echo -e "This could be connected to The Architect's disappearance.\033[0m"

# Add journal entry
TIMESTAMP=\$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JOURNAL_FILE="\${PLAYER_STATE}/journal.json"

# Create journal entry
tmp=\$(mktemp)
jq ".entries += [{
  \"id\": \"network_scan_complete\",
  \"title\": \"Hidden Monitoring System Discovered\",
  \"content\": \"Following The Architect's trail, I scanned the network for services running on port 8080. I discovered a distributed monitoring system running across three IP addresses (192.168.1.42, 192.168.1.137, 192.168.1.201). These services don't appear in any official documentation. More concerning, they appear to be exfiltrating data to an external destination. Could this be why The Architect disappeared? I need to investigate these services more closely.\",
  \"timestamp\": \"\${TIMESTAMP}\"
}]" "\$JOURNAL_FILE" > "\$tmp" && mv "\$tmp" "\$JOURNAL_FILE"

# Check for quest updates
"${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"

exit 0
EOF

chmod +x "${GAME_ROOT}/events/network_scan_complete.sh"

echo -e "\033[0;93m>> CHALLENGE INITIATED\033[0m"