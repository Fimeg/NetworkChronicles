#!/bin/bash
# Manual setup script for Network Chronicles in Docker

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}Setting up Network Chronicles manually...${RESET}"

# Create shell integration script
echo -e "${CYAN}Creating shell integration script...${RESET}"
cat > /opt/network-chronicles/bin/nc-shell-integration.sh << 'EOF'
#!/bin/bash
# Network Chronicles - Shell Integration

# Set up variables
GAME_ROOT="/opt/network-chronicles"
BIN_DIR="${GAME_ROOT}/bin"
ENGINE="${BIN_DIR}/network-chronicles-engine.sh"
PLAYER_ID=$(whoami)

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
mkdir -p "${GAME_ROOT}/data/players/${PLAYER_ID}" 2>/dev/null

# Custom prompt
nc_prompt() {
  PS1="${GREEN}[NC:T1]${RESET} \u@\h:\w\$ "
}

# Set up prompt
PROMPT_COMMAND="nc_prompt"

# Command wrappers
nc-status() {
  echo -e "${GREEN_ECHO}Network Chronicles Status${RESET_ECHO}"
  echo -e "-------------------------"
  echo -e "Player: $PLAYER_ID"
  
  # Display current quest
  echo -e "\n${CYAN_ECHO}Current Quest: Initial System Access${RESET_ECHO}"
  echo -e "You've been assigned as the new system administrator after the mysterious disappearance of your predecessor, known only as 'The Architect'."
  echo -e "\n${CYAN_ECHO}Objectives:${RESET_ECHO}"
  echo -e "1. Explore the system to get familiar with it"
  echo -e "2. Locate The Architect's welcome message"
  echo -e "3. Document your findings in your journal"
}

nc-journal() {
  echo -e "${GREEN_ECHO}Network Chronicles Journal${RESET_ECHO}"
  echo -e "-------------------------"
  
  if [ -f "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt" ]; then
    cat "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt"
  else
    echo -e "No journal entries yet. Try exploring the system and using nc-add-discovery."
  fi
}

nc-map() {
  echo -e "${GREEN_ECHO}Network Map${RESET_ECHO}"
  echo -e "-------------------------"
  echo -e "Network map not yet available. First discover network components."
}

nc-add-discovery() {
  if [ -z "$1" ]; then
    echo -e "${RED_ECHO}Usage: nc-add-discovery <discovery_id>${RESET_ECHO}"
    return 1
  fi
  
  echo -e "Adding discovery: $1"
  
  # Basic discovery tracking
  mkdir -p "${GAME_ROOT}/data/players/${PLAYER_ID}"
  echo "$1" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/discoveries.txt"
  
  # Add to journal
  if [ ! -f "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt" ]; then
    echo -e "# Network Administrator's Journal\n" > "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt"
  fi
  
  if [ "$1" == "welcome_message" ]; then
    echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: The Architect's Welcome Message\n" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt"
    echo -e "I found a message from The Architect hidden in ~/.local/share/network-chronicles/. The message instructs me to map the network and understand its structure. This is my first clue about what happened.\n" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt"
    echo -e "${GREEN_ECHO}Discovery recorded: The Architect's Welcome Message${RESET_ECHO}"
    echo -e "Journal updated with your findings."
  else
    echo -e "\n## $(date '+%Y-%m-%d %H:%M') - Discovery: $1\n" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt"
    echo -e "I discovered $1 while exploring the system.\n" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/journal.txt" 
    echo -e "${GREEN_ECHO}Discovery recorded: $1${RESET_ECHO}"
  fi
}

nc-help() {
  echo -e "${GREEN_ECHO}Network Chronicles Commands:${RESET_ECHO}"
  echo -e "  nc-status         Display your current status"
  echo -e "  nc-journal        View your journal"
  echo -e "  nc-map            View network map (when available)"
  echo -e "  nc-add-discovery  Add a discovery (e.g., welcome_message)"
  echo -e "  nc-help           Display this help message"
}

# Welcome message
echo -e "${GREEN_ECHO}Welcome to Network Chronicles: The Vanishing Admin${RESET_ECHO}"
echo -e "Type ${CYAN_ECHO}nc-help${RESET_ECHO} for available commands"
EOF

# Make sure script is executable
chmod 755 /opt/network-chronicles/bin/nc-shell-integration.sh

# Create minimal engine script
echo -e "${CYAN}Creating minimal engine script...${RESET}"
cat > /opt/network-chronicles/bin/network-chronicles-engine.sh << 'EOF'
#!/bin/bash
# Minimal engine script for demonstration
echo "Network Chronicles Engine"
echo "Processing: $@"
exit 0
EOF
chmod 755 /opt/network-chronicles/bin/network-chronicles-engine.sh

# Create necessary directories
mkdir -p /opt/network-chronicles/data/players
mkdir -p /opt/network-chronicles/content/narrative/quests
mkdir -p /opt/network-chronicles/content/discoveries
chmod -R 777 /opt/network-chronicles/data

# Modify player's bashrc to load the shell integration
if ! grep -q "nc-shell-integration.sh" /home/player/.bashrc; then
  echo -e "${CYAN}Adding shell integration to player's .bashrc...${RESET}"
  cat >> /home/player/.bashrc << 'EOF'

# Direct Network Chronicles Integration
source /opt/network-chronicles/bin/nc-shell-integration.sh
EOF
fi

echo -e "${GREEN}Manual setup complete!${RESET}"
echo -e "Now you can run: su - player"
echo -e "The network chronicles commands (nc-status, nc-help, etc.) should work."