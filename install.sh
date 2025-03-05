#!/bin/bash
# Network Chronicles - Main Installation Script

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Set up variables
INSTALL_DIR="/opt/network-chronicles"
BIN_DIR="${INSTALL_DIR}/bin"
SRC_DIR="${INSTALL_DIR}/src"
DATA_DIR="${INSTALL_DIR}/data"
CONTENT_DIR="${INSTALL_DIR}/content"
CONFIG_DIR="${INSTALL_DIR}/config"
LOGS_DIR="${INSTALL_DIR}/logs"

# Print banner
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   NETWORK CHRONICLES: THE VANISHING ADMIN                               ║"
echo "║   Installation Script                                                   ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${RESET}"
    exit 1
fi

# Check if the installation directory exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${CYAN}Creating installation directory at ${INSTALL_DIR}...${RESET}"
    mkdir -p "$INSTALL_DIR"
else
    echo -e "${YELLOW}Installation directory already exists at ${INSTALL_DIR}${RESET}"
fi

# Create required directories
echo -e "${CYAN}Creating required directories...${RESET}"
mkdir -p "$BIN_DIR" "$SRC_DIR" "$DATA_DIR" "$CONTENT_DIR" "$CONFIG_DIR" "$LOGS_DIR"
mkdir -p "${DATA_DIR}/players" "${DATA_DIR}/global"
mkdir -p "${CONTENT_DIR}/narrative/quests" "${CONTENT_DIR}/narrative/messages"
mkdir -p "${CONTENT_DIR}/challenges" "${CONTENT_DIR}/discoveries" "${CONTENT_DIR}/events"

# Set permissions
echo -e "${CYAN}Setting permissions...${RESET}"
chown -R root:root "$INSTALL_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod -R 777 "$LOGS_DIR" # Writable by all users for logging
chmod -R 777 "${DATA_DIR}/players" # Writable by all users for player data

# Create core engine script
echo -e "${CYAN}Creating core engine script...${RESET}"
cat > "${BIN_DIR}/network-chronicles-engine.sh" << 'EOF'
#!/bin/bash
# Network Chronicles - Core Engine

VERSION="1.0.0"
GAME_ROOT="/opt/network-chronicles"
DATA_DIR="${GAME_ROOT}/data"
CONTENT_DIR="${GAME_ROOT}/content"
LOGS_DIR="${GAME_ROOT}/logs"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Log function
log() {
  local level="$1"
  local message="$2"
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  echo -e "[${timestamp}] [${level}] ${message}" >> "${LOGS_DIR}/engine.log"
  
  if [ "$level" == "ERROR" ]; then
    echo -e "${RED}Error: ${message}${RESET}" >&2
  elif [ "$level" == "WARNING" ]; then
    echo -e "${YELLOW}Warning: ${message}${RESET}" >&2
  elif [ "$level" == "INFO" ] && [ "${NC_DEBUG}" == "true" ]; then
    echo -e "${CYAN}${message}${RESET}"
  fi
}

# Initialize player
initialize_player() {
  local player_id="$1"
  local player_dir="${DATA_DIR}/players/${player_id}"
  
  if [ ! -d "$player_dir" ]; then
    mkdir -p "$player_dir"
    
    # Create initial player profile
    cat > "${player_dir}/profile.json" << PROFILE
{
  "id": "${player_id}",
  "name": "${player_id}",
  "tier": 1,
  "xp": 0,
  "discoveries": [],
  "quests": {
    "current": "initial_access",
    "completed": []
  },
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_login": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
PROFILE
    
    # Create empty journal
    cat > "${player_dir}/journal.json" << JOURNAL
{
  "entries": [
    {
      "id": "welcome",
      "title": "First Day",
      "content": "Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    }
  ]
}
JOURNAL
    
    log "INFO" "Initialized new player: ${player_id}"
    return 0
  else
    log "INFO" "Player already initialized: ${player_id}"
    return 1
  fi
}

# Get player state
get_player_state() {
  local player_id="$1"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  cat "$player_profile"
  return 0
}

# Update player state
update_player_state() {
  local player_id="$1"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Read from stdin and write to profile
  cat > "$player_profile"
  log "INFO" "Updated player state: ${player_id}"
  return 0
}

# Add discovery
add_discovery() {
  local player_id="$1"
  local discovery_id="$2"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Check if discovery already exists
  if grep -q "\"$discovery_id\"" "$player_profile"; then
    log "INFO" "Discovery already exists: ${discovery_id}"
    return 0
  fi
  
  # Add discovery to player profile
  local temp_file=$(mktemp)
  jq ".discoveries += [\"$discovery_id\"]" "$player_profile" > "$temp_file"
  mv "$temp_file" "$player_profile"
  
  log "INFO" "Added discovery: ${discovery_id} for player: ${player_id}"
  return 0
}

# Complete quest
complete_quest() {
  local player_id="$1"
  local quest_id="$2"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Get quest data
  local quest_file="${CONTENT_DIR}/narrative/quests/${quest_id}.json"
  if [ ! -f "$quest_file" ]; then
    log "ERROR" "Quest not found: ${quest_id}"
    return 1
  fi
  
  # Get next quest and XP
  local next_quest=$(jq -r '.next_quest' "$quest_file")
  local xp=$(jq -r '.xp' "$quest_file")
  
  # Update player profile
  local temp_file=$(mktemp)
  jq ".quests.completed += [\"$quest_id\"] | .quests.current = \"$next_quest\" | .xp += $xp" "$player_profile" > "$temp_file"
  mv "$temp_file" "$player_profile"
  
  log "INFO" "Completed quest: ${quest_id} for player: ${player_id}"
  return 0
}

# Check quest requirements
check_quest_requirements() {
  local player_id="$1"
  local quest_id="$2"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  local quest_file="${CONTENT_DIR}/narrative/quests/${quest_id}.json"
  
  if [ ! -f "$player_profile" ] || [ ! -f "$quest_file" ]; then
    return 1
  fi
  
  # Get required discoveries
  local required_discoveries=$(jq -r '.required_discoveries[]' "$quest_file")
  
  # Check if player has all required discoveries
  for discovery in $required_discoveries; do
    if ! grep -q "\"$discovery\"" "$player_profile"; then
      return 1
    fi
  done
  
  return 0
}

# Display status
display_status() {
  local player_id="$1"
  local player_profile="${DATA_DIR}/players/${player_id}/profile.json"
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  local name=$(jq -r '.name' "$player_profile")
  local tier=$(jq -r '.tier' "$player_profile")
  local xp=$(jq -r '.xp' "$player_profile")
  local current_quest=$(jq -r '.quests.current' "$player_profile")
  local completed_quests=$(jq -r '.quests.completed | length' "$player_profile")
  local discoveries=$(jq -r '.discoveries | length' "$player_profile")
  
  echo -e "${GREEN}=== Network Chronicles: Player Status ===${RESET}"
  echo -e "Name: ${CYAN}${name}${RESET}"
  echo -e "Access Tier: ${CYAN}${tier}${RESET}"
  echo -e "XP: ${CYAN}${xp}${RESET}"
  echo -e "Current Quest: ${CYAN}${current_quest}${RESET}"
  echo -e "Completed Quests: ${CYAN}${completed_quests}${RESET}"
  echo -e "Discoveries: ${CYAN}${discoveries}${RESET}"
  
  # Display current quest details
  local quest_file="${CONTENT_DIR}/narrative/quests/${current_quest}.json"
  if [ -f "$quest_file" ]; then
    local quest_name=$(jq -r '.name' "$quest_file")
    local quest_desc=$(jq -r '.description' "$quest_file")
    
    echo -e "\n${GREEN}Current Quest: ${quest_name}${RESET}"
    echo -e "${quest_desc}"
    
    # Check if quest requirements are met
    if check_quest_requirements "$player_id" "$current_quest"; then
      echo -e "\n${GREEN}You have met the requirements for this quest!${RESET}"
      echo -e "Use 'nc-complete-quest' to complete it."
    else
      echo -e "\n${YELLOW}Quest requirements not yet met.${RESET}"
    fi
  fi
  
  return 0
}

# Display help
display_help() {
  echo -e "${GREEN}Network Chronicles Engine v${VERSION}${RESET}"
  echo -e "Usage: network-chronicles-engine.sh <command> [args...]"
  echo -e ""
  echo -e "Commands:"
  echo -e "  init <player_id>           Initialize a new player"
  echo -e "  status <player_id>         Display player status"
  echo -e "  get-state <player_id>      Get player state (JSON)"
  echo -e "  update-state <player_id>   Update player state (read from stdin)"
  echo -e "  add-discovery <player_id> <discovery_id>  Add a discovery"
  echo -e "  complete-quest <player_id> <quest_id>     Complete a quest"
  echo -e "  help                       Display this help message"
  echo -e "  version                    Display version information"
  echo -e ""
  echo -e "Environment Variables:"
  echo -e "  NC_DEBUG=true              Enable debug output"
  echo -e ""
}

# Main function
main() {
  local command="$1"
  shift
  
  case "$command" in
    init)
      initialize_player "$1"
      ;;
    status)
      display_status "$1"
      ;;
    get-state)
      get_player_state "$1"
      ;;
    update-state)
      update_player_state "$1"
      ;;
    add-discovery)
      add_discovery "$1" "$2"
      ;;
    complete-quest)
      complete_quest "$1" "$2"
      ;;
    help)
      display_help
      ;;
    version)
      echo "Network Chronicles Engine v${VERSION}"
      ;;
    *)
      echo -e "${RED}Error: Unknown command: ${command}${RESET}" >&2
      display_help
      exit 1
      ;;
  esac
  
  exit $?
}

# Run main function
main "$@"
EOF

# Create shell integration script
echo -e "${CYAN}Creating shell integration script...${RESET}"
cat > "${BIN_DIR}/nc-shell-integration.sh" << 'EOF'
#!/bin/bash
# Network Chronicles - Shell Integration

# Set up variables
GAME_ROOT="/opt/network-chronicles"
BIN_DIR="${GAME_ROOT}/bin"
ENGINE="${BIN_DIR}/network-chronicles-engine.sh"
PLAYER_ID=$(whoami)

# Colors
GREEN='\[\033[0;32m\]'
CYAN='\[\033[0;36m\]'
YELLOW='\[\033[1;33m\]'
RED='\[\033[0;31m\]'
RESET='\[\033[0m\]'

# Check if the engine exists
if [ ! -f "$ENGINE" ]; then
  echo "Network Chronicles engine not found at ${ENGINE}"
  return 1
fi

# Initialize player if needed
$ENGINE init "$PLAYER_ID" > /dev/null 2>&1

# Custom prompt
nc_prompt() {
  # Get player tier
  local tier=$(jq -r '.tier' "${GAME_ROOT}/data/players/${PLAYER_ID}/profile.json" 2>/dev/null || echo "1")
  
  # Set prompt based on tier
  case "$tier" in
    1)
      PS1="${GREEN}[NC:T1]${RESET} \u@\h:\w\$ "
      ;;
    2)
      PS1="${CYAN}[NC:T2]${RESET} \u@\h:\w\$ "
      ;;
    3)
      PS1="${YELLOW}[NC:T3]${RESET} \u@\h:\w\$ "
      ;;
    4|5)
      PS1="${RED}[NC:T${tier}]${RESET} \u@\h:\w\$ "
      ;;
    *)
      PS1="\u@\h:\w\$ "
      ;;
  esac
}

# Set up prompt
PROMPT_COMMAND="nc_prompt"

# Command wrappers
nc-status() {
  $ENGINE status "$PLAYER_ID"
}

nc-journal() {
  "${BIN_DIR}/journal.sh" "$PLAYER_ID"
}

nc-add-discovery() {
  if [ -z "$1" ]; then
    echo "Usage: nc-add-discovery <discovery_id>"
    return 1
  fi
  
  $ENGINE add-discovery "$PLAYER_ID" "$1"
  echo "Discovery added: $1"
}

nc-complete-quest() {
  local current_quest=$(jq -r '.quests.current' "${GAME_ROOT}/data/players/${PLAYER_ID}/profile.json")
  
  if [ -z "$current_quest" ] || [ "$current_quest" == "null" ]; then
    echo "No active quest to complete."
    return 1
  fi
  
  # Check if quest requirements are met
  if ! $ENGINE complete-quest "$PLAYER_ID" "$current_quest"; then
    echo "Cannot complete quest. Requirements not met."
    return 1
  fi
  
  echo "Quest completed: $current_quest"
  nc-status
}

nc-help() {
  echo -e "${GREEN}Network Chronicles Commands:${RESET}"
  echo -e "  nc-status         Display your current status"
  echo -e "  nc-journal        View your journal"
  echo -e "  nc-add-discovery  Add a discovery"
  echo -e "  nc-complete-quest Complete your current quest"
  echo -e "  nc-help           Display this help message"
}

# Welcome message
echo -e "${GREEN}Welcome to Network Chronicles: The Vanishing Admin${RESET}"
echo -e "Type ${CYAN}nc-help${RESET} for available commands"
EOF

# Create journal script
echo -e "${CYAN}Creating journal script...${RESET}"
cat > "${BIN_DIR}/journal.sh" << 'EOF'
#!/bin/bash
# Network Chronicles - Journal System

# Set up variables
GAME_ROOT="/opt/network-chronicles"
DATA_DIR="${GAME_ROOT}/data"

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Check arguments
if [ $# -lt 1 ]; then
  echo -e "${RED}Error: Player ID required${RESET}"
  echo "Usage: journal.sh <player_id> [entry_id]"
  exit 1
fi

PLAYER_ID="$1"
ENTRY_ID="$2"
JOURNAL_FILE="${DATA_DIR}/players/${PLAYER_ID}/journal.json"

# Check if journal exists
if [ ! -f "$JOURNAL_FILE" ]; then
  echo -e "${RED}Error: Journal not found for player ${PLAYER_ID}${RESET}"
  exit 1
fi

# Display a specific entry
display_entry() {
  local entry_id="$1"
  local entry=$(jq -r ".entries[] | select(.id == \"$entry_id\")" "$JOURNAL_FILE")
  
  if [ -z "$entry" ] || [ "$entry" == "null" ]; then
    echo -e "${RED}Error: Entry not found: ${entry_id}${RESET}"
    return 1
  fi
  
  local title=$(echo "$entry" | jq -r '.title')
  local content=$(echo "$entry" | jq -r '.content')
  local timestamp=$(echo "$entry" | jq -r '.timestamp')
  
  echo -e "${GREEN}=== ${title} ===${RESET}"
  echo -e "Date: ${CYAN}$(date -d "$timestamp" "+%Y-%m-%d %H:%M:%S")${RESET}"
  echo -e "\n${content}\n"
  
  return 0
}

# Display all entries
display_all_entries() {
  local entries=$(jq -r '.entries | length' "$JOURNAL_FILE")
  
  echo -e "${GREEN}=== Journal Entries (${entries}) ===${RESET}"
  
  jq -r '.entries | sort_by(.timestamp) | reverse | .[] | "\(.timestamp) - \(.title) [\(.id)]"' "$JOURNAL_FILE" | \
    while read line; do
      local timestamp=$(echo "$line" | cut -d' ' -f1)
      local title=$(echo "$line" | cut -d' ' -f3- | sed 's/ \[.*\]$//')
      local id=$(echo "$line" | grep -o '\[.*\]' | tr -d '[]')
      
      echo -e "${CYAN}$(date -d "$timestamp" "+%Y-%m-%d %H:%M:%S")${RESET} - ${title} ${YELLOW}[${id}]${RESET}"
    done
  
  echo -e "\nUse 'nc-journal <entry_id>' to view a specific entry"
  
  return 0
}

# Add a new entry
add_entry() {
  local title="$1"
  local content="$2"
  
  if [ -z "$title" ] || [ -z "$content" ]; then
    echo -e "${RED}Error: Title and content required${RESET}"
    echo "Usage: journal.sh <player_id> add \"Title\" \"Content\""
    return 1
  fi
  
  local id=$(date +%s)
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  
  # Add entry to journal
  local temp_file=$(mktemp)
  jq ".entries += [{\"id\": \"$id\", \"title\": \"$title\", \"content\": \"$content\", \"timestamp\": \"$timestamp\"}]" "$JOURNAL_FILE" > "$temp_file"
  mv "$temp_file" "$JOURNAL_FILE"
  
  echo -e "${GREEN}Entry added: ${title}${RESET}"
  
  return 0
}

# Main function
main() {
  if [ -z "$ENTRY_ID" ]; then
    display_all_entries
  elif [ "$ENTRY_ID" == "add" ]; then
    add_entry "$3" "$4"
  else
    display_entry "$ENTRY_ID"
  fi
  
  exit $?
}

# Run main function
main "$@"
EOF

# Make scripts executable
echo -e "${CYAN}Making scripts executable...${RESET}"
chmod +x "${BIN_DIR}/network-chronicles-engine.sh"
chmod +x "${BIN_DIR}/nc-shell-integration.sh"
chmod +x "${BIN_DIR}/journal.sh"

# Create example quest
echo -e "${CYAN}Creating example quest...${RESET}"
mkdir -p "${CONTENT_DIR}/narrative/quests"

cat > "${CONTENT_DIR}/narrative/quests/initial_access.json" << 'EOF'
{
  "id": "initial_access",
  "name": "Initial System Access",
  "description": "Gain access to the system and locate The Architect's first message",
  "tier": 1,
  "xp": 100,
  "required_discoveries": ["welcome_message"],
  "next_quest": "map_network"
}
EOF

cat > "${CONTENT_DIR}/narrative/quests/initial_access.md" << 'EOF'
# Initial System Access

You've been assigned as the new system administrator after the mysterious disappearance of your predecessor, known only as "The Architect."

## Objectives

1. Explore the system to get familiar with it
2. Locate The Architect's welcome message
3. Document your findings in your journal

## Hints

- Look for files in your home directory
- The Architect was known for leaving cryptic notes
- Use standard terminal commands to explore

## Rewards

- Access to basic system tools
- XP towards Tier 2 access
EOF

# Create example discovery
echo -e "${CYAN}Creating example discovery...${RESET}"
mkdir -p "${CONTENT_DIR}/discoveries"

cat > "${CONTENT_DIR}/discoveries/welcome_message.json" << 'EOF'
{
  "id": "welcome_message",
  "name": "The Architect's Welcome Message",
  "description": "A message left by the previous administrator",
  "tier": 1,
  "xp": 50,
  "content": "Welcome to the system. I've been expecting you. The network holds many secrets - some I've hidden intentionally, others that emerged on their own. Trust nothing, verify everything. Your journey begins now. - The Architect"
}
EOF

# Create .env file
echo -e "${CYAN}Creating .env file...${RESET}"
cat > "${INSTALL_DIR}/.env" << 'EOF'
# Network Chronicles Environment Variables

# Server Configuration
PORT=3000
NODE_ENV=development

# Game Configuration
GAME_ROOT=/opt/network-chronicles
LOG_LEVEL=info

# Feature Flags
API_ENABLED=true
WEB_UI_ENABLED=true
MULTIPLAYER_ENABLED=false

# Security
JWT_SECRET=your-secret-key-change-in-production
EOF

# Create example config
echo -e "${CYAN}Creating example config...${RESET}"
mkdir -p "${CONFIG_DIR}"

cat > "${CONFIG_DIR}/settings.example.json" << 'EOF'
{
  "game": {
    "name": "Network Chronicles: The Vanishing Admin",
    "version": "1.0.0",
    "difficulty": "normal"
  },
  "tiers": {
    "1": {
      "name": "Novice",
      "xp_required": 0,
      "description": "Basic system access"
    },
    "2": {
      "name": "User",
      "xp_required": 500,
      "description": "Standard user privileges"
    },
    "3": {
      "name": "Power User",
      "xp_required": 1500,
      "description": "Advanced user privileges"
    },
    "4": {
      "name": "Administrator",
      "xp_required": 3000,
      "description": "Administrative access"
    },
    "5": {
      "name": "Architect",
      "xp_required": 5000,
      "description": "Full system access"
    }
  },
  "features": {
    "journal": true,
    "discoveries": true,
    "challenges": true,
    "multiplayer": false
  },
  "ui": {
    "theme": "terminal",
    "colors": {
      "primary": "cyan",
      "secondary": "green",
      "accent": "yellow",
      "error": "red"
    }
  }
}
EOF

# Final message
echo -e "${GREEN}Network Chronicles installation complete!${RESET}"
echo -e "To start using Network Chronicles:"
echo -e "1. Log in as a regular user"
echo -e "2. Add the following line to your .bashrc or .zshrc:"
echo -e "   ${CYAN}source /opt/network-chronicles/bin/nc-shell-integration.sh${RESET}"
echo -e "3. Start a new shell session or run:"
echo -e "   ${CYAN}source /opt/network-chronicles/bin/nc-shell-integration.sh${RESET}"
echo -e "4. Type ${CYAN}nc-help${RESET} to see available commands"
echo -e ""
echo -e "For more information, see the documentation in ${CYAN}/opt/network-chronicles/docs${RESET}"
