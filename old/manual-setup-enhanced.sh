#!/bin/bash
# Enhanced manual setup for a better demo experience

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}Setting up enhanced Network Chronicles demo...${RESET}"

# Create a bin/utils directory first
mkdir -p /opt/network-chronicles/bin/utils

# Copy utility scripts from current directory
echo -e "${CYAN}Installing utility scripts...${RESET}"
cp utils/config.sh /opt/network-chronicles/bin/utils/
cp utils/directory-management.sh /opt/network-chronicles/bin/utils/
cp utils/json-helpers.sh /opt/network-chronicles/bin/utils/
cp utils/script-template.sh /opt/network-chronicles/bin/utils/

# Source utility scripts
source /opt/network-chronicles/bin/utils/config.sh
source /opt/network-chronicles/bin/utils/directory-management.sh

# Create all required directories using utility function
echo -e "${CYAN}Creating required directories...${RESET}"
NC_GAME_ROOT="/opt/network-chronicles"
ensure_game_directories

# Ensure player documents directory exists
echo -e "${CYAN}Setting up player documents...${RESET}"
ensure_player_documents "player"

# Set permissions
chmod -R 777 /opt/network-chronicles/data

# Create the welcome_message discovery in content
cat > /opt/network-chronicles/content/discoveries/welcome_message.json << 'EOF2'
{
  "id": "welcome_message",
  "name": "The Architect's Welcome Message",
  "description": "A message left by the previous administrator",
  "tier": 1,
  "xp": 50,
  "content": "Welcome to the system. I've been expecting you. The network holds many secrets - some I've hidden intentionally, others that emerged on their own. Trust nothing, verify everything. Your journey begins now. - The Architect"
}
EOF2

# Create shell integration with actual functionality
cat > /opt/network-chronicles/bin/nc-shell-integration.sh << 'EOF2'
#!/bin/bash
# Network Chronicles - Enhanced Shell Integration

# Set up variables
GAME_ROOT="/opt/network-chronicles"
BIN_DIR="${GAME_ROOT}/bin"
PLAYER_ID=$(whoami)
PLAYER_DIR="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Colors for prompt
GREEN='\[\033[0;32m\]'
CYAN='\[\033[0;36m\]'
YELLOW='\[\033[1;33m\]'
RED='\[\033[0;31m\]'
RESET='\[\033[0m\]'

# Colors for echo
GREEN_ECHO='\033[0;32m'
CYAN_ECHO='\033[0;36m'
YELLOW_ECHO='\033[1;33m'
RED_ECHO='\033[0;31m'
RESET_ECHO='\033[0m'

# Prepare paths
mkdir -p "${PLAYER_DIR}" 2>/dev/null
mkdir -p "${PLAYER_DIR}/Documents" 2>/dev/null

# Custom prompt
nc_prompt() {
  # Check for tier in profile
  if [ -f "${PLAYER_DIR}/profile.json" ]; then
    TIER=$(grep -o '"tier": *[0-9]' "${PLAYER_DIR}/profile.json" | cut -d: -f2 | tr -d ' ' || echo "1")
  else
    TIER=1
  fi
  
  case "$TIER" in
    1) PS1="${GREEN}[NC:T1]${RESET} \u@\h:\w\$ " ;;
    2) PS1="${CYAN}[NC:T2]${RESET} \u@\h:\w\$ " ;;
    3) PS1="${YELLOW}[NC:T3]${RESET} \u@\h:\w\$ " ;;
    *) PS1="${RED}[NC:T${TIER}]${RESET} \u@\h:\w\$ " ;;
  esac
}

# Set up prompt
PROMPT_COMMAND="nc_prompt"

# Get current quest
function get_current_quest() {
  if [ -f "${PLAYER_DIR}/profile.json" ]; then
    QUEST=$(grep -o '"current_quest": *"[^"]*"' "${PLAYER_DIR}/profile.json" | cut -d: -f2 | tr -d ' "' || echo "initial_access")
  else
    QUEST="initial_access"
  fi
  echo "$QUEST"
}

# Create or update player profile
function update_profile() {
  local key="$1"
  local value="$2"
  
  if [ ! -f "${PLAYER_DIR}/profile.json" ]; then
    # Create default profile
    cat > "${PLAYER_DIR}/profile.json" << EOPROFILE
{
  "player_id": "${PLAYER_ID}",
  "tier": 1,
  "xp": 0,
  "discoveries": [],
  "current_quest": "initial_access",
  "completed_quests": []
}
EOPROFILE
  fi
  
  # Update the key with value
  if [[ "$key" == "discoveries" ]]; then
    # Add to array
    sed -i "s/\"discoveries\": *\[[^]]*\]/\"discoveries\": [\"$value\"]/" "${PLAYER_DIR}/profile.json"
  else
    # Update simple key
    sed -i "s/\"${key}\": *[^,}]*/\"${key}\": \"${value}\"/" "${PLAYER_DIR}/profile.json"
  fi
}

# Command wrappers
nc-status() {
  echo -e "${GREEN_ECHO}Network Chronicles Status${RESET_ECHO}"
  echo -e "-------------------------"
  echo -e "Player: $PLAYER_ID"
  
  # Get current quest
  QUEST=$(get_current_quest)
  
  # Display different status based on quest
  case "$QUEST" in
    initial_access)
      echo -e "\n${CYAN_ECHO}Current Quest: Initial System Access${RESET_ECHO}"
      echo -e "You've been assigned as the new system administrator after the mysterious disappearance of your predecessor, known only as 'The Architect'."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Explore the system to get familiar with it"
      echo -e "2. Locate The Architect's welcome message (hint: check ~/.local/share/network-chronicles/)"
      echo -e "3. Document your findings using 'nc-add-discovery welcome_message'"
      
      # Check if welcome message was discovered
      if grep -q "welcome_message" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
        echo -e "\n${GREEN_ECHO}✓ The Architect's welcome message found!${RESET_ECHO}"
        echo -e "Your next quest is: Map Network. Type 'nc-help' for available commands."
        # Update current quest
        update_profile "current_quest" "map_network"
      fi
      ;;
      
    map_network)
      echo -e "\n${CYAN_ECHO}Current Quest: Map the Network${RESET_ECHO}"
      echo -e "Now that you've found The Architect's welcome message, you need to map the network infrastructure."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Discover the network gateway ('nc-add-discovery network_gateway')"
      echo -e "2. Identify the local network configuration ('nc-add-discovery local_network')"
      echo -e "3. Document your findings in your journal"
      
      # Check for discoveries
      FOUND_GW=$(grep -q "network_gateway" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
      FOUND_NET=$(grep -q "local_network" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
      
      if [ "$FOUND_GW" = "true" ]; then
        echo -e "\n${GREEN_ECHO}✓ Network gateway discovered!${RESET_ECHO}"
      fi
      
      if [ "$FOUND_NET" = "true" ]; then
        echo -e "\n${GREEN_ECHO}✓ Local network configuration discovered!${RESET_ECHO}"
      fi
      
      if [ "$FOUND_GW" = "true" ] && [ "$FOUND_NET" = "true" ]; then
        echo -e "\n${GREEN_ECHO}✓ Quest complete! You can now investigate unusual traffic patterns${RESET_ECHO}"
        update_profile "current_quest" "investigate_unusual_traffic"
      fi
      ;;
      
    investigate_unusual_traffic)
      echo -e "\n${CYAN_ECHO}Current Quest: Investigate Unusual Traffic${RESET_ECHO}"
      echo -e "You need to investigate unusual traffic patterns that The Architect was monitoring before disappearing."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Find the monitoring service ('nc-add-discovery monitoring_service')"
      echo -e "2. Analyze the logs for suspicious patterns"
      echo -e "3. Document your findings"
      
      # Check for discoveries
      if grep -q "monitoring_service" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
        echo -e "\n${GREEN_ECHO}✓ Monitoring service discovered!${RESET_ECHO}"
        echo -e "Your next step is to analyze the auth.log file."
        
        if grep -q "unusual_traffic" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
          echo -e "\n${GREEN_ECHO}✓ Unusual traffic patterns found!${RESET_ECHO}"
          echo -e "You've identified suspicious login attempts from IP 45.33.22.156."
          echo -e "\nYour next quest is to secure the vulnerable service."
          update_profile "current_quest" "secure_vulnerable_service"
        fi
      fi
      ;;
      
    secure_vulnerable_service)
      echo -e "\n${CYAN_ECHO}Current Quest: Secure Vulnerable Service${RESET_ECHO}"
      echo -e "After discovering the unusual traffic, you need to secure the system against further attacks."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Implement firewall rules to block the attacker's IP (45.33.22.156)"
      echo -e "2. Add the secured_service discovery ('nc-add-discovery secured_service')"
      
      if grep -q "secured_service" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
        echo -e "\n${GREEN_ECHO}✓ Vulnerable service secured!${RESET_ECHO}"
        echo -e "You've successfully secured the system against the attacker."
        echo -e "\nYour next quest is to analyze the breach timeline."
        update_profile "current_quest" "analyze_breach_timeline"
      fi
      ;;
      
    analyze_breach_timeline)
      echo -e "\n${CYAN_ECHO}Current Quest: Analyze Breach Timeline${RESET_ECHO}"
      echo -e "Create a timeline of events to understand what happened to The Architect."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Analyze the logs to establish when the attack began"
      echo -e "2. Compare attack timestamps with The Architect's last login times"
      echo -e "3. Create a timeline ('nc-add-discovery breach_timeline')"
      
      if grep -q "breach_timeline" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
        echo -e "\n${GREEN_ECHO}✓ Breach timeline created!${RESET_ECHO}"
        echo -e "You've analyzed the attack pattern and identified a suspicious login."
        echo -e "\nYour next quest is to find The Architect's final message."
        update_profile "current_quest" "discover_architects_message"
      fi
      ;;
      
    discover_architects_message)
      echo -e "\n${CYAN_ECHO}Current Quest: Discover The Architect's Final Message${RESET_ECHO}"
      echo -e "Find the hidden message system The Architect used to document their investigation."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Search for hidden files that may contain The Architect's final message"
      echo -e "2. Discover the message ('nc-add-discovery architects_final_message')"
      
      if grep -q "architects_final_message" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
        echo -e "\n${GREEN_ECHO}✓ The Architect's final message found!${RESET_ECHO}"
        echo -e "You've discovered that The Architect went offline deliberately to investigate the attack."
        echo -e "\n${YELLOW_ECHO}Congratulations! You've completed Tier 1: Digital Footprints${RESET_ECHO}"
        echo -e "You are now ready to begin Tier 2: Network Cartography"
        # Update tier and quest
        sed -i 's/"tier": *[0-9]/"tier": 2/' "${PLAYER_DIR}/profile.json"
        update_profile "current_quest" "begin_tier2_journey"
      fi
      ;;
      
    begin_tier2_journey)
      echo -e "\n${CYAN_ECHO}Current Quest: Begin Tier 2 Journey${RESET_ECHO}"
      echo -e "With Tier 1 complete, you are now ready to map the broader network infrastructure."
      echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
      echo -e "1. Review your current network map and documentation"
      echo -e "2. Prepare for comprehensive network mapping"
      echo -e "\n${YELLOW_ECHO}✨ TIER 2 UNLOCKED: NETWORK CARTOGRAPHY ✨${RESET_ECHO}"
      ;;
      
    *)
      echo -e "\n${CYAN_ECHO}Current Quest: $QUEST${RESET_ECHO}"
      echo -e "Quest details not available in demo mode."
      ;;
  esac
}

nc-journal() {
  echo -e "${GREEN_ECHO}Network Chronicles Journal${RESET_ECHO}"
  echo -e "-------------------------"
  
  if [ -f "${PLAYER_DIR}/journal.txt" ]; then
    cat "${PLAYER_DIR}/journal.txt"
  else
    # Create initial journal entry
    cat > "${PLAYER_DIR}/journal.txt" << EOJOURNAL
# Network Administrator's Journal

## Initial Entry

I've been assigned to take over network administration duties after the sudden departure of the previous admin. Management was vague about the circumstances - something about "personal reasons" and "immediate effect."

The handover documentation is practically non-existent. All I've received is a sticky note with login credentials and a cryptic message: "Follow the breadcrumbs. -The Architect"

I need to:
1. Map out the network infrastructure
2. Identify critical services
3. Document everything I find
4. Figure out what happened to my predecessor

This journal will track my progress and findings.
EOJOURNAL
    cat "${PLAYER_DIR}/journal.txt"
  fi
}

nc-map() {
  echo -e "${GREEN_ECHO}Network Map${RESET_ECHO}"
  echo -e "-------------------------"
  
  # Check which components have been discovered
  FOUND_GW=$(grep -q "network_gateway" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
  FOUND_NET=$(grep -q "local_network" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
  FOUND_MON=$(grep -q "monitoring_service" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
  FOUND_UNUSUAL=$(grep -q "unusual_traffic" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null && echo "true" || echo "false")
  
  if [ "$FOUND_GW" = "false" ] && [ "$FOUND_NET" = "false" ]; then
    echo -e "Network map not yet available. First discover network components."
    return
  fi
  
  # Basic ASCII network map that grows with discoveries
  echo -e "┌─────────────────────────────────────────────────────────────────────────┐"
  echo -e "│                                                                         │"
  echo -e "│                        NETWORK INFRASTRUCTURE MAP                       │"
  echo -e "│                                                                         │"
  
  if [ "$FOUND_GW" = "true" ]; then
    echo -e "│                            ┌──────────────┐                           │"
    echo -e "│                            │   Internet    │                           │"
    echo -e "│                            └───────┬──────┘                           │"
    echo -e "│                                    │                                  │"
    echo -e "│                            ┌───────┴──────┐                           │"
    echo -e "│                            │   Gateway    │                           │"
    echo -e "│                            │  192.168.1.1  │                           │"
    echo -e "│                            └───────┬──────┘                           │"
  fi
  
  if [ "$FOUND_NET" = "true" ]; then
    echo -e "│                                    │                                  │"
    echo -e "│                            ┌───────┴──────┐                           │"
    echo -e "│                            │  Local Net   │                           │"
    echo -e "│                            │ 192.168.1.0/24│                           │"
    echo -e "│                            └──┬───┬───┬───┘                           │"
  fi
  
  if [ "$FOUND_MON" = "true" ]; then
    echo -e "│                               │   │   │                               │"
    echo -e "│                               │   │   └───────────────┐              │"
    echo -e "│                               │   │                   │              │"
    echo -e "│                               │   │                ┌──┴───────┐      │"
    echo -e "│                               │   │                │ Monitor  │      │"
    echo -e "│                               │   │                │192.168.1.42│      │"
    echo -e "│                               │   │                └──────────┘      │"
  fi
  
  if [ "$FOUND_UNUSUAL" = "true" ]; then
    echo -e "│                               │   │                       ↑          │"
    echo -e "│                               │   │                       :          │"
    echo -e "│                               │   │                       :          │"
    echo -e "│                               │   │         ┌─────────────┴─────┐    │"
    echo -e "│                               │   │         │  External Attacker │    │"
    echo -e "│                               │   │         │    45.33.22.156    │    │"
    echo -e "│                               │   │         └───────────────────┘    │"
  fi
  
  echo -e "│                                                                         │"
  echo -e "└─────────────────────────────────────────────────────────────────────────┘"
  
  # Display legend
  echo -e "\n${BOLD}LEGEND:${RESET_ECHO}"
  if [ "$FOUND_GW" = "true" ]; then
    echo -e "  Gateway: Main connection to external networks"
  fi
  if [ "$FOUND_NET" = "true" ]; then
    echo -e "  Local Network: Internal network segment (192.168.1.0/24)"
  fi
  if [ "$FOUND_MON" = "true" ]; then
    echo -e "  Monitoring Service: System monitoring and logging (192.168.1.42:8080)"
  fi
  if [ "$FOUND_UNUSUAL" = "true" ]; then
    echo -e "  ${RED_ECHO}Suspicious Traffic:${RESET_ECHO} Unauthorized access attempts from 45.33.22.156"
  fi
}

nc-add-discovery() {
  if [ -z "$1" ]; then
    echo -e "${RED_ECHO}Usage: nc-add-discovery <discovery_id>${RESET_ECHO}"
    return 1
  fi
  
  echo -e "Adding discovery: $1"
  
  # Create profile if it doesn't exist
  if [ ! -f "${PLAYER_DIR}/profile.json" ]; then
    mkdir -p "${PLAYER_DIR}"
    cat > "${PLAYER_DIR}/profile.json" << EOPROFILE
{
  "player_id": "${PLAYER_ID}",
  "tier": 1,
  "xp": 0,
  "discoveries": [],
  "current_quest": "initial_access",
  "completed_quests": []
}
EOPROFILE
  fi
  
  # Basic discovery tracking
  mkdir -p "${PLAYER_DIR}"
  touch "${PLAYER_DIR}/discoveries.txt"
  
  # Don't add duplicates
  if grep -q "^$1$" "${PLAYER_DIR}/discoveries.txt" 2>/dev/null; then
    echo -e "${YELLOW_ECHO}Discovery already recorded: $1${RESET_ECHO}"
    return 0
  fi
  
  # Add to discoveries file
  echo "$1" >> "${PLAYER_DIR}/discoveries.txt"
  
  # Add to journal
  if [ ! -f "${PLAYER_DIR}/journal.txt" ]; then
    echo -e "# Network Administrator's Journal\n" > "${PLAYER_DIR}/journal.txt"
  fi
  
  case "$1" in
    welcome_message)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: The Architect's Welcome Message\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I found a message from The Architect hidden in ~/.local/share/network-chronicles/. The message instructs me to map the network and understand its structure. This is my first clue about what happened.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: The Architect's Welcome Message${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      echo -e "Use 'nc-status' to check your quest progress."
      ;;
      
    network_gateway)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Network Gateway (192.168.1.1)\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've identified the main network gateway at 192.168.1.1. This is the primary connection point to external networks and will be critical for understanding network traffic patterns.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Network Gateway${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    local_network)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Local Network Configuration\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've mapped the local network configuration. The primary subnet is 192.168.1.0/24, which appears to host all the main services and systems.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Local Network Configuration${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    monitoring_service)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Monitoring Service\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've discovered a monitoring service running at 192.168.1.42:8080. This appears to be a system The Architect set up to track network activity. It might contain valuable information about what they were investigating before disappearing.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Monitoring Service${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    unusual_traffic)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Unusual Traffic Patterns\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "While examining the logs, I discovered repeated failed login attempts from IP 45.33.22.156 targeting the admin account. This appears to be a brute force attack that was occurring around the time The Architect disappeared.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "Key observations:\n- Multiple failed login attempts from 45.33.22.156\n- Targeting the admin account specifically\n- The attack occurred on March 2, just before The Architect's last login\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Unusual Traffic Patterns${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    secured_service)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Secured Vulnerable Service\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've secured the system by implementing firewall rules to block traffic from the malicious IP address (45.33.22.156). This follows The Architect's security recommendations and will prevent further attacks from this source.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Secured Vulnerable Service${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    breach_timeline)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: Security Breach Timeline\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've created a timeline of the security breach:\n\nMar 2, 01:17:33 - Initial attack begins from 45.33.22.156\nMar 2, 01:17:33-01:17:45 - Multiple failed login attempts targeting admin account\nMar 2, 01:18:01 - The Architect logs in (last normal login)\nMar 2, 01:18:45 - Attack intensifies (20 repeated attempts)\nMar 2, 01:20:12 - Attacker connection closes\nMar 2, 02:17:45 - The Architect logs in again (possible compromise)\nMar 2, 02:35:22 - The Architect's session disconnects\n\nThe pattern suggests The Architect detected the attack, implemented countermeasures, but may have been compromised during their investigation. The final login at 02:17:45 followed by a disconnect at 02:35:22 marks the last recorded activity before their disappearance.\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: Security Breach Timeline${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      ;;
      
    architects_final_message)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: The Architect's Final Message\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I've discovered The Architect's final message:\n\n\"To my successor,\n\nIf you're reading this, you've successfully followed my breadcrumbs. I had to disappear quickly after discovering a sophisticated attack targeting our infrastructure. The breach originated from 45.33.22.156, but I suspect this is just a proxy - the real attacker is someone with inside knowledge of our systems.\n\nI've gone offline to investigate the source without alerting them. I'm working with authorities to track down who's behind this. For security reasons, I can't disclose my location.\n\nYou've proven yourself capable. The network is now yours to protect. I've left comprehensive documentation through the challenges you've solved.\n\nYour next task is to map the entire network infrastructure and identify any other potential vulnerabilities. I've laid the groundwork in Tier 2.\n\nStay vigilant,\nThe Architect\"\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "${GREEN_ECHO}Discovery recorded: The Architect's Final Message${RESET_ECHO}"
      echo -e "Journal updated with your findings."
      echo -e "\n${YELLOW_ECHO}✨ CONGRATULATIONS! You've completed Tier 1! ✨${RESET_ECHO}"
      ;;
      
    *)
      echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: $1\n" >> "${PLAYER_DIR}/journal.txt"
      echo -e "I discovered $1 while exploring the system.\n" >> "${PLAYER_DIR}/journal.txt" 
      echo -e "${GREEN_ECHO}Discovery recorded: $1${RESET_ECHO}"
      ;;
  esac
}

nc-help() {
  echo -e "${GREEN_ECHO}Network Chronicles Commands:${RESET_ECHO}"
  echo -e "  nc-status         Display your current status"
  echo -e "  nc-journal        View your journal"
  echo -e "  nc-map            View network map (when available)"
  echo -e "  nc-add-discovery  Add a discovery (e.g., welcome_message)"
  echo -e "  nc-help           Display this help message"
  echo -e ""
  echo -e "Demo Mode Discoveries:"
  echo -e "  welcome_message        - The Architect's welcome message"
  echo -e "  network_gateway        - Network gateway discovery"
  echo -e "  local_network          - Local network configuration"
  echo -e "  monitoring_service     - Monitoring service discovery"
  echo -e "  unusual_traffic        - Unusual traffic patterns"
  echo -e "  secured_service        - Secured vulnerable service"
  echo -e "  breach_timeline        - Security breach timeline"
  echo -e "  architects_final_message - The Architect's final message"
}

# Welcome message
echo -e "${GREEN_ECHO}Welcome to Network Chronicles: The Vanishing Admin${RESET_ECHO}"
echo -e "Type ${CYAN_ECHO}nc-help${RESET_ECHO} for available commands"
EOF2
chmod 755 /opt/network-chronicles/bin/nc-shell-integration.sh

# Modify player's bashrc to ensure integration is loaded
if ! grep -q "nc-shell-integration.sh" /home/player/.bashrc; then
  echo -e "${CYAN}Adding shell integration to player's .bashrc...${RESET}"
  cat >> /home/player/.bashrc << 'EOF2'

# Direct Network Chronicles Integration
source /opt/network-chronicles/bin/nc-shell-integration.sh
EOF2
fi

echo -e "${GREEN}Enhanced setup complete!${RESET}"
echo -e "Now you can run: su - player"
echo -e "The full Network Chronicles demo experience should be available."