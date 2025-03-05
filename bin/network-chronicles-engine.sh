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
BOLD='\033[1m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'

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

# Source utility scripts
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/directory-management.sh"
source "${SCRIPT_DIR}/utils/json-helpers.sh"

# Initialize player
initialize_player() {
  local player_id="$1"
  local player_state=$(get_player_state_dir "$player_id")
  
  if [ ! -d "$player_state" ]; then
    # Create directories with proper permissions
    mkdir -p "$player_state"
    chmod 777 "$player_state"
    
    # Ensure Documents directory exists (using utility function)
    ensure_player_documents "$player_id"
    chmod -R 777 "$(get_player_docs_dir "$player_id")"
    
    # Also ensure home Documents directory exists with proper permissions
    if [ -d "/home/${player_id}" ]; then
      mkdir -p "/home/${player_id}/Documents" 2>/dev/null
      chown -R "${player_id}:${player_id}" "/home/${player_id}/Documents" 2>/dev/null || true
      chmod 755 "/home/${player_id}/Documents" 2>/dev/null || true
    fi
    
    # Create initial player profile
    cat > "${player_state}/profile.json" << PROFILE
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
    # Ensure profile.json has the right permissions (world readable/writable)
    chmod 666 "${player_state}/profile.json"
    
    # Create empty journal
    cat > "${player_state}/journal.json" << JOURNAL
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
    # Ensure journal.json has the right permissions (world readable/writable)
    chmod 666 "${player_state}/journal.json"
    
    log "INFO" "Initialized new player: ${player_id}"
    return 0
  else
    # Even if player exists, ensure Documents directory exists (using utility function)
    ensure_player_documents "$player_id"
    
    # Also ensure home Documents directory exists if possible
    mkdir -p "/home/${player_id}/Documents" 2>/dev/null
    
    log "INFO" "Player already initialized: ${player_id}"
    return 1
  fi
}

# Get player state
get_player_state() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  
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
  local player_profile=$(get_player_profile "$player_id")
  
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
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Check if discovery already exists using json-helpers
  local has_discovery=$(json_get_value "$player_profile" ".discoveries | index(\"$discovery_id\") != null")
  if [ "$has_discovery" == "true" ]; then
    log "INFO" "Discovery already exists: ${discovery_id}"
    return 0
  fi
  
  # Add discovery to player profile using json-helpers
  json_add_to_array "$player_profile" ".discoveries" "\"$discovery_id\""
  
  log "INFO" "Added discovery: ${discovery_id} for player: ${player_id}"
  return 0
}

# Check and upgrade tier if needed
check_and_upgrade_tier() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Get current tier and XP
  local current_tier=$(json_get_value "$player_profile" ".tier")
  local current_xp=$(json_get_value "$player_profile" ".xp")
  
  # Calculate XP required for next tier
  local next_tier_xp=$((current_tier * 500))
  
  # Check if player has enough XP to level up
  if [ "$current_xp" -ge "$next_tier_xp" ]; then
    # Increase tier
    local new_tier=$((current_tier + 1))
    json_update_field "$player_profile" ".tier" "$new_tier"
    
    log "INFO" "Player ${player_id} upgraded to tier ${new_tier}"
    
    # Trigger tier up event
    trigger_event "$player_id" "tier_up" "true"
    
    return 0
  fi
  
  return 1
}

# Complete quest
complete_quest() {
  local player_id="$1"
  local quest_id="$2"
  local player_profile=$(get_player_profile "$player_id")
  
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
  
  # Get next quest and XP using json-helpers
  local next_quest=$(json_get_value "$quest_file" ".next_quest")
  local xp=$(json_get_value "$quest_file" ".xp")
  
  # Add to completed quests
  json_add_to_array "$player_profile" ".quests.completed" "\"$quest_id\""
  
  # Update current quest and XP
  json_update_field "$player_profile" ".quests.current" "\"$next_quest\""
  json_update_field "$player_profile" ".xp" "(.xp + $xp)"
  
  # Check if player can upgrade tier
  check_and_upgrade_tier "$player_id"
  
  log "INFO" "Completed quest: ${quest_id} for player: ${player_id}"
  return 0
}

# Check quest requirements
check_quest_requirements() {
  local player_id="$1"
  local quest_id="$2"
  local player_profile=$(get_player_profile "$player_id")
  local quest_file="${CONTENT_DIR}/narrative/quests/${quest_id}.json"
  
  if [ ! -f "$player_profile" ] || [ ! -f "$quest_file" ]; then
    return 1
  fi
  
  # Get required discoveries using json-helpers
  local required_discoveries=$(json_get_value "$quest_file" '.required_discoveries[]')
  
  # Check if player has all required discoveries
  for discovery in $required_discoveries; do
    # Use json-helpers to check if discovery exists in player profile
    local has_discovery=$(json_get_value "$player_profile" ".discoveries | index(\"$discovery\") != null")
    if [ "$has_discovery" != "true" ]; then
      return 1
    fi
  done
  
  return 0
}

# Draw a styled box around content
draw_styled_box() {
  local title="$1"
  local content="$2"
  local width=$(tput cols)
  local box_width=$((width - 4))
  
  # Create a horizontal line of appropriate width
  local line=""
  for ((i=0; i<box_width; i++)); do line+="━"; done
  
  # Get terminal width for padding
  local title_len=${#title}
  local padding_len=$(( (box_width - title_len - 2) / 2 ))
  local title_padding=""
  for ((i=0; i<padding_len; i++)); do title_padding+="━"; done
  
  # Format and draw box with content
  echo -e "${CYAN}┏━${title_padding} ${GREEN}${title}${RESET} ${CYAN}${title_padding}┓${RESET}"
  
  echo -e "${content}"
  
  echo -e "${CYAN}┗${line}┛${RESET}"
}

# Function to create a progress bar
progress_bar() {
  local value=$1
  local max=$2
  local width=$3
  local percent=$((value * 100 / max))
  local filled=$((width * percent / 100))
  
  local bar=""
  for ((i=0; i<filled; i++)); do bar+="█"; done
  for ((i=filled; i<width; i++)); do bar+="□"; done
  
  echo "$bar"
}

# Display status with enhanced visuals
display_status() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  
  echo "Set permissions on player directory"
  # Make sure player Document directories exist using utility function
  ensure_player_documents "$player_id" 2>/dev/null
  
  # Also ensure home Documents directory exists if possible
  mkdir -p "/home/${player_id}/Documents" 2>/dev/null
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # Use json-helpers to get values
  local name=$(json_get_value "$player_profile" '.name')
  local tier=$(json_get_value "$player_profile" '.tier')
  local xp=$(json_get_value "$player_profile" '.xp')
  local current_quest=$(json_get_value "$player_profile" '.quests.current')
  local completed_quests=$(json_get_value "$player_profile" '.quests.completed | length')
  local discoveries=$(json_get_value "$player_profile" '.discoveries | length')
  
  # Calculate XP Progress
  local xp_for_next_tier=$((tier * 500))
  local xp_percent=$((xp * 100 / xp_for_next_tier))
  
  # Select tier color
  local tier_color=${GREEN}
  case "$tier" in
    1) tier_color=${GREEN} ;;
    2) tier_color=${CYAN} ;;
    3) tier_color=${YELLOW} ;;
    4|5) tier_color=${RED} ;;
  esac
  
  # Create ASCII art header 
  echo -e "${GREEN}  _   _      _                      _      ___ _                  _      _         "
  echo -e " | \\ | | ___| |___      _____  _ __| | __ / __| |__  _ __ ___  _ __ (_) ___| | ___ "
  echo -e " |  \\| |/ _ \\ __\\ \\ /\\ / / _ \\| '__| |/ / | |_ | '_ \\| '__/ _ \\| '_ \\| |/ __| |/ _ \\"
  echo -e " | |\\  |  __/ |_ \\ V  V / (_) | |  |   <  | __|| | | | | | (_) | | | | | (__| |  __/"
  echo -e " |_| \\_|\\___|\\__| \\_/\\_/ \\___/|_|  |_|\\_\\ |_|  |_| |_|_|  \\___/|_| |_|_|\\___|_|\\___| ${RESET}"
  echo  

  # Get terminal width
  local width=$(tput cols)
  
  # Create status box header
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ${YELLOW}PLAYER STATUS${CYAN} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
  
  # Format status info with proper styling and alignment
  local progress=$(progress_bar "$xp" "$xp_for_next_tier" 20)
  
  # Status content with proper new lines
  echo -e "${CYAN}┃${RESET} ${YELLOW}Name:${RESET} ${GREEN}${name}${RESET}"
  echo -e "${CYAN}┃${RESET} ${YELLOW}Access Tier:${RESET} ${tier_color}${tier}${RESET}"
  echo -e "${CYAN}┃${RESET} ${YELLOW}XP:${RESET} ${CYAN}${xp}${RESET}/${xp_for_next_tier}"
  echo -e "${CYAN}┃${RESET} ${YELLOW}XP Progress:${RESET} ${GREEN}[${progress}]${RESET} ${xp_percent}%"
  echo -e "${CYAN}┃${RESET} ${YELLOW}Completed Quests:${RESET} ${CYAN}${completed_quests}${RESET}"
  echo -e "${CYAN}┃${RESET} ${YELLOW}Discoveries:${RESET} ${CYAN}${discoveries}${RESET}"
  
  # Close status box
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
  
  # Display current quest details
  local quest_file="${CONTENT_DIR}/narrative/quests/${current_quest}.json"
  if [ -f "$quest_file" ]; then
    local quest_name=$(json_get_value "$quest_file" '.name')
    local quest_desc=$(json_get_value "$quest_file" '.description')
    
    # Start quest box
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ ${YELLOW}CURRENT QUEST${CYAN} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET}"
    
    # Quest details
    echo -e "${CYAN}┃${RESET} ${GREEN}${quest_name}${RESET}"
    echo -e "${CYAN}┃${RESET} ${quest_desc}"
    
    # Add requirements status
    if check_quest_requirements "$player_id" "$current_quest"; then
      echo -e "${CYAN}┃${RESET} "
      echo -e "${CYAN}┃${RESET} ${GREEN}✓ You have met the requirements for this quest!${RESET}"
      echo -e "${CYAN}┃${RESET} Use '${CYAN}nc-complete-quest${RESET}' to complete it."
    else
      # Get required discoveries to show specific missing requirements
      local req_discoveries=$(json_get_value "$quest_file" '.required_discoveries | join(", ")')
      echo -e "${CYAN}┃${RESET} "
      echo -e "${CYAN}┃${RESET} ${YELLOW}⚠ Quest requirements not yet met.${RESET}"
      echo -e "${CYAN}┃${RESET} Required discoveries: ${CYAN}${req_discoveries}${RESET}"
    fi
    
    # Close quest box
    echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET}"
  fi
  
  return 0
}

# Fix permissions for player files
fix_permissions() {
  local player_id="$1"
  local player_state=$(get_player_state_dir "$player_id")
  
  # Make sure all the directories have the right permissions
  if [ -d "$player_state" ]; then
    # Make the directory accessible to all
    chmod 777 "$player_state"
    
    # Make all subdirectories accessible
    find "$player_state" -type d -exec chmod 777 {} \;
    
    # Make all JSON files readable and writable by all
    find "$player_state" -name "*.json" -exec chmod 666 {} \;
    
    # Make all other files readable by all
    find "$player_state" -type f -not -name "*.json" -exec chmod 644 {} \;
    
    # Ensure Documents directory has correct permissions
    local docs_dir=$(get_player_docs_dir "$player_id")
    if [ -d "$docs_dir" ]; then
      chmod -R 777 "$docs_dir"
    fi
    
    log "INFO" "Fixed permissions for player $player_id"
  else
    log "ERROR" "Player state directory not found for $player_id"
    return 1
  fi
  
  return 0
}

# Display help
display_help() {
  # Get terminal dimensions
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # ASCII art header
  echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║${RESET}  _   _      _                      _      ___ _                  _      _   ${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET} | \\ | | ___| |___      _____  _ __| | __ / __| |__  _ __ ___  _ __ (_) ___| |${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET} |  \\| |/ _ \\ __\\ \\ /\\ / / _ \\| '__| |/ / | |_ | '_ \\| '__/ _ \\| '_ \\| |/ __| |${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET} | |\\  |  __/ |_ \\ V  V / (_) | |  |   <  | __|| | | | | | (_) | | | | | (__| |${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET} |_| \\_|\\___|\\__| \\_/\\_/ \\___/|_|  |_|\\_\\ |_|  |_| |_|_|  \\___/|_| |_|_|\\___|_|${CYAN}║${RESET}"
  echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${RESET}"
  echo
  
  # Helper function to create styled box
  create_help_box() {
    local title="$1"
    local content="$2"
    
    echo -e "${YELLOW}╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮${RESET}"
    echo -e "${YELLOW}│${RESET} ${CYAN}${title}${RESET}${YELLOW}                                                                                                          │${RESET}"
    echo -e "${YELLOW}├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤${RESET}"
    echo -e "$content"
    echo -e "${YELLOW}╰─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╯${RESET}"
    echo
  }

  # Player commands section
  player_commands_content="${YELLOW}│${RESET}  ${GREEN}nc-status${RESET}         Display your current status and quest information                                                        ${YELLOW}│${RESET}\n"
  player_commands_content+="${YELLOW}│${RESET}  ${GREEN}nc-journal${RESET}        View your journal entries                                                               ${YELLOW}│${RESET}\n"
  player_commands_content+="${YELLOW}│${RESET}  ${GREEN}nc-help${RESET}           Show this help message                                                                 ${YELLOW}│${RESET}"
  create_help_box "PLAYER COMMANDS" "$player_commands_content"
  
  # Quest commands section
  quest_commands_content="${YELLOW}│${RESET}  ${GREEN}nc-add-discovery${RESET}  Record a discovery (usage: nc-add-discovery <discovery_id>)                                                   ${YELLOW}│${RESET}\n"
  quest_commands_content+="${YELLOW}│${RESET}  ${GREEN}nc-complete-quest${RESET} Complete your current quest when requirements are met                                                      ${YELLOW}│${RESET}"
  create_help_box "QUEST COMMANDS" "$quest_commands_content"
  
  # System commands
  system_commands_content="${YELLOW}│${RESET}  ${CYAN}ls -la${RESET}          List all files in current directory, including hidden files                                                ${YELLOW}│${RESET}\n"
  system_commands_content+="${YELLOW}│${RESET}  ${CYAN}cd <directory>${RESET}  Change to specified directory                                                                             ${YELLOW}│${RESET}\n"
  system_commands_content+="${YELLOW}│${RESET}  ${CYAN}cat <file>${RESET}      Display contents of a file                                                                               ${YELLOW}│${RESET}\n"
  system_commands_content+="${YELLOW}│${RESET}  ${CYAN}grep <pattern>${RESET}  Search for text in files                                                                               ${YELLOW}│${RESET}"
  create_help_box "USEFUL SYSTEM COMMANDS" "$system_commands_content"
  
  # Current quest hints
  # Get current quest of the player
  local player_id=$(whoami)
  local player_profile=$(get_player_profile "$player_id")
  local current_quest="unknown"
  if [ -f "$player_profile" ]; then
    current_quest=$(json_get_value "$player_profile" '.quests.current')
  fi
  
  # Show different hints based on current quest
  hints_content=""
  case "$current_quest" in
    initial_access)
      hints_content="${YELLOW}│${RESET}  ${RED}▶${RESET} Hidden files and directories start with a dot (.)                                                                ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} Try looking in the .local/share directory in your home folder                                                      ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} Use 'nc-add-discovery welcome_message' when you find the message                                                   ${YELLOW}│${RESET}"
      ;;
    map_network)
      hints_content="${YELLOW}│${RESET}  ${RED}▶${RESET} Use commands like 'ip route' and 'ip addr' to discover network information                                     ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} Look for gateway addresses and subnet assignments                                                                ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} The discoveries will be automatically recorded when you run the right commands                                   ${YELLOW}│${RESET}"
      ;;
    *)
      hints_content="${YELLOW}│${RESET}  ${RED}▶${RESET} Use 'nc-status' to see details about your current quest                                                        ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} Check your journal with 'nc-journal' for clues about your next steps                                             ${YELLOW}│${RESET}\n"
      hints_content+="${YELLOW}│${RESET}  ${RED}▶${RESET} Make sure to document your discoveries and complete quests to advance                                           ${YELLOW}│${RESET}"
      ;;
  esac
  
  # Display quest hints
  create_help_box "CURRENT QUEST HINTS" "$hints_content"
  
  # Footer
  echo -e "${CYAN}〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓 Network Chronicles 〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓${RESET}"
  echo -e "${YELLOW}                    The Vanishing Admin - v1.0.0${RESET}"
}

# Process triggers
process_triggers() {
  local cmd="$1"
  local player_id="$2"
  
  # Skip processing if no command or player_id
  if [ -z "$cmd" ] || [ -z "$player_id" ]; then
    return 1
  fi
  
  # Check all trigger files in the content/triggers directory
  for trigger_file in "${CONTENT_DIR}/triggers/"*.json; do
    # Skip if no trigger files found
    [ -e "$trigger_file" ] || continue
    
    # Get the pattern to match and event to trigger
    local pattern=$(json_get_value "$trigger_file" ".pattern")
    local event=$(json_get_value "$trigger_file" ".event")
    local one_time=$(json_get_value "$trigger_file" ".one_time")
    
    # Skip if pattern or event is missing
    [ -z "$pattern" ] || [ -z "$event" ] && continue
    
    # Remove quotes from values
    pattern=$(echo "$pattern" | tr -d '"')
    event=$(echo "$event" | tr -d '"')
    one_time=$(echo "$one_time" | tr -d '"')
    
    # Check if command matches the pattern
    if echo "$cmd" | grep -E "$pattern" > /dev/null 2>&1; then
      log "INFO" "Command '$cmd' matched trigger pattern '$pattern'"
      
      # If one-time trigger, check if already triggered
      if [ "$one_time" = "true" ] && check_event_triggered "$player_id" "$event"; then
        log "INFO" "Skipping one-time trigger '$event' that has already been triggered"
        continue
      fi
      
      # Check if requirements are met
      if check_trigger_requirements "$player_id" "$trigger_file"; then
        log "INFO" "Trigger requirements met for '$event'"
        # Trigger the event
        trigger_event "$player_id" "$event"
      else
        log "INFO" "Trigger requirements not met for '$event'"
      fi
    fi
  done
  
  return 0
}

# Process a shell command to detect network discoveries
process_command() {
  local cmd="$1"
  local player_id="$2"
  
  # Check if player_id is provided, use whoami if not
  if [ -z "$player_id" ]; then
    player_id=$(whoami)
  fi

  # Debug output for troubleshooting
  echo "[DEBUG] Processing command: '$cmd' for player: '$player_id'" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
  
  # Process triggers based on command
  process_triggers "$cmd" "$player_id"
  
  # Make sure player directory exists
  local player_state="${DATA_DIR}/players/${player_id}"
  mkdir -p "$player_state" 2>/dev/null
  chmod 777 "$player_state" 2>/dev/null
  
  # Make sure player profile exists
  local player_profile="${player_state}/profile.json"
  if [ ! -f "$player_profile" ]; then
    initialize_player "$player_id" > /dev/null 2>&1
  fi
  
  # Make sure profile is readable/writable
  chmod 666 "$player_profile" 2>/dev/null
  
  # Log command for analysis (with timestamp)
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] CMD: $cmd" >> "${LOGS_DIR}/commands_${player_id}.log" 2>/dev/null
  
  # NETWORK GATEWAY DETECTION
  # Use simple grep patterns that are more likely to match in various shells
  if echo "$cmd" | grep -E 'ip[[:space:]]*route|route[[:space:]]*-n|netstat[[:space:]]*-rn|ip[[:space:]]*r' > /dev/null 2>&1; then
    echo "[DEBUG] Detected network gateway command: $cmd" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
    
    # Check if discovery already exists
    if ! grep -q '"network_gateway"' "$player_profile" 2>/dev/null; then
      echo "[DEBUG] Adding network_gateway discovery" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
      
      # Create a backup of the profile
      cp "$player_profile" "${player_profile}.bak" 2>/dev/null
      
      # Try to add discovery using jq
      local tmp_file=$(mktemp)
      jq '.discoveries += ["network_gateway"] | .xp += 25' "$player_profile" > "$tmp_file" 2>/dev/null
      
      # Check if jq succeeded
      if [ $? -eq 0 ] && [ -s "$tmp_file" ]; then
        # Replace profile with updated version
        cat "$tmp_file" > "$player_profile"
        chmod 666 "$player_profile"
        
        # Notify player
        echo -e "\n${GREEN}[DISCOVERY]${RESET} You've mapped the network gateway! (+25 XP)"
        echo "[DEBUG] Successfully added network_gateway discovery" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
      else
        # Fallback method if jq fails
        echo "[DEBUG] jq failed, using fallback method" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
        
        # Restore from backup if jq failed
        if [ -f "${player_profile}.bak" ]; then
          cp "${player_profile}.bak" "$player_profile"
          
          # Manual JSON editing as last resort
          sed -i 's/"discoveries":\[/"discoveries":\["network_gateway",/g' "$player_profile" 2>/dev/null
          sed -i 's/"xp":[0-9]*/"xp":$(($(grep -o '"xp":[0-9]*' "$player_profile" | cut -d':' -f2) + 25))/g' "$player_profile" 2>/dev/null
          
          echo -e "\n${GREEN}[DISCOVERY]${RESET} You've mapped the network gateway! (+25 XP)"
        fi
      fi
      
      # Clean up
      rm -f "$tmp_file" "${player_profile}.bak" 2>/dev/null
    fi
  fi
  
  # LOCAL NETWORK DETECTION
  # Use simple grep patterns that are more likely to match in various shells  
  if echo "$cmd" | grep -E 'ip[[:space:]]*addr|ifconfig|ip[[:space:]]*a' > /dev/null 2>&1; then
    echo "[DEBUG] Detected local network command: $cmd" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
    
    # Check if discovery already exists
    if ! grep -q '"local_network"' "$player_profile" 2>/dev/null; then
      echo "[DEBUG] Adding local_network discovery" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
      
      # Create a backup of the profile
      cp "$player_profile" "${player_profile}.bak" 2>/dev/null
      
      # Try to add discovery using jq
      local tmp_file=$(mktemp)
      jq '.discoveries += ["local_network"] | .xp += 25' "$player_profile" > "$tmp_file" 2>/dev/null
      
      # Check if jq succeeded
      if [ $? -eq 0 ] && [ -s "$tmp_file" ]; then
        # Replace profile with updated version
        cat "$tmp_file" > "$player_profile"
        chmod 666 "$player_profile"
        
        # Notify player
        echo -e "\n${GREEN}[DISCOVERY]${RESET} You've mapped the local network configuration! (+25 XP)"
        echo "[DEBUG] Successfully added local_network discovery" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
      else
        # Fallback method if jq fails
        echo "[DEBUG] jq failed, using fallback method" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
        
        # Restore from backup if jq failed
        if [ -f "${player_profile}.bak" ]; then
          cp "${player_profile}.bak" "$player_profile"
          
          # Manual JSON editing as last resort
          sed -i 's/"discoveries":\[/"discoveries":\["local_network",/g' "$player_profile" 2>/dev/null
          sed -i 's/"xp":[0-9]*/"xp":$(($(grep -o '"xp":[0-9]*' "$player_profile" | cut -d':' -f2) + 25))/g' "$player_profile" 2>/dev/null
          
          echo -e "\n${GREEN}[DISCOVERY]${RESET} You've mapped the local network configuration! (+25 XP)"
        fi
      fi
      
      # Clean up
      rm -f "$tmp_file" "${player_profile}.bak" 2>/dev/null
    fi
  fi
  
  # SERVICE DISCOVERY TRIGGERS
  # Look for commands that might be checking for services
  if echo "$cmd" | grep -E 'ss[[:space:]]*-tuln|netstat[[:space:]]*-tuln|lsof[[:space:]]*-i|nmap|nc-discover-services' > /dev/null 2>&1; then
    echo "[DEBUG] Detected service discovery command: $cmd" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
    
    # Check if we should run service discovery based on if the player has the basic network mapped
    local has_network=$(json_get_value "$player_profile" '.discoveries | contains(["local_network", "network_gateway"]) | length == 2')
    
    if [ "$has_network" = "true" ]; then
      # Player has mapped basic network, trigger service discovery
      if [ ! -f "${player_state}/flags/service_discovery_triggered" ]; then
        mkdir -p "${player_state}/flags"
        touch "${player_state}/flags/service_discovery_triggered"
        
        # Add a notification suggesting service discovery
        echo -e "\n${CYAN}[HINT]${RESET} Now that you've mapped the basic network, you might want to discover what services are running."
        echo -e "${CYAN}[HINT]${RESET} Try running ${GREEN}nc-discover-services.sh${RESET} to scan for active services."
        
        # Mark in profile that service discovery is available
        json_update_field "$player_profile" ".service_discovery_available" "true"
      fi
      
      # For direct nc-discover-services command, run the service discovery script
      if echo "$cmd" | grep -E 'nc-discover-services' > /dev/null 2>&1; then
        echo "[DEBUG] Automatically triggering service discovery script" >> "${LOGS_DIR}/engine_debug.log" 2>/dev/null
        
        # Instead of running here, we'll let the command run naturally, as that's more reliable
        # The separate script will handle the service discovery process
      fi
    else
      # Player hasn't mapped the network yet, give a hint
      echo -e "\n${YELLOW}[HINT]${RESET} Before discovering services, you need to map the basic network structure."
      echo -e "${YELLOW}[HINT]${RESET} Try commands like ${GREEN}ip route${RESET} and ${GREEN}ip addr${RESET} to map the network."
    fi
  fi
  
  # Fix permissions to ensure changes are accessible
  chmod 666 "$player_profile" 2>/dev/null
  chmod -R 777 "$player_state" 2>/dev/null
  
  return 0
}

# Check trigger requirements
check_trigger_requirements() {
  local player_id="$1"
  local trigger_file="$2"
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ] || [ ! -f "$trigger_file" ]; then
    return 1  # Missing required files
  fi
  
  # Check for tier requirements
  local tier_minimum=$(json_get_value "$trigger_file" ".requirements.tier_minimum" 2>/dev/null)
  if [ -n "$tier_minimum" ] && [ "$tier_minimum" != "null" ]; then
    local player_tier=$(json_get_value "$player_profile" ".tier")
    if [ "$player_tier" -lt "$tier_minimum" ]; then
      return 1  # Player tier not high enough
    fi
  fi
  
  # Check for discovery requirements
  local required_discoveries=$(json_get_value "$trigger_file" ".requirements.discoveries[]" 2>/dev/null)
  if [ -n "$required_discoveries" ]; then
    for discovery in $required_discoveries; do
      # Remove quotes if present
      discovery=$(echo "$discovery" | tr -d '"')
      # Check if player has this discovery
      local has_discovery=$(json_get_value "$player_profile" ".discoveries | index(\"$discovery\") != null")
      if [ "$has_discovery" != "true" ]; then
        return 1  # Missing required discovery
      fi
    done
  fi
  
  # Check for quest requirements
  local required_quests=$(json_get_value "$trigger_file" ".requirements.completed_quests[]" 2>/dev/null)
  if [ -n "$required_quests" ]; then
    for quest in $required_quests; do
      # Remove quotes if present
      quest=$(echo "$quest" | tr -d '"')
      # Check if player has completed this quest
      local has_completed=$(json_get_value "$player_profile" ".quests.completed | index(\"$quest\") != null")
      if [ "$has_completed" != "true" ]; then
        return 1  # Missing required completed quest
      fi
    done
  fi
  
  # All requirements met
  return 0
}

# Check if an event has been triggered
check_event_triggered() {
  local player_id="$1"
  local event_id="$2"
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ]; then
    return 1  # If profile doesn't exist, event hasn't been triggered
  fi
  
  # Check if the event flag exists in the profile
  local flag_exists=$(json_get_value "$player_profile" ".events.${event_id}" 2>/dev/null)
  if [ -n "$flag_exists" ] && [ "$flag_exists" != "null" ]; then
    return 0  # Event has been triggered
  fi
  
  return 1  # Event has not been triggered
}

# Mark an event as triggered
mark_event_triggered() {
  local player_id="$1"
  local event_id="$2"
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ]; then
    log "ERROR" "Player profile not found: ${player_id}"
    return 1
  fi
  
  # First make sure .events exists
  if ! json_get_value "$player_profile" ".events" >/dev/null 2>&1; then
    json_update_field "$player_profile" ".events" "{}"
  fi
  
  # Set the event flag
  json_update_field "$player_profile" ".events.${event_id}" "true"
  
  return 0
}

# Trigger an event
trigger_event() {
  local player_id="$1"
  local event_id="$2"
  local force="${3:-false}"  # Optional parameter to force triggering
  local event_script="${CONTENT_DIR}/events/${event_id}.sh"
  
  # Check if event has already been triggered (unless forced)
  if [ "$force" != "true" ] && check_event_triggered "$player_id" "$event_id"; then
    log "INFO" "Event already triggered: ${event_id} for player: ${player_id}"
    return 0
  fi
  
  if [ -f "$event_script" ] && [ -x "$event_script" ]; then
    log "INFO" "Triggering event: ${event_id} for player: ${player_id}"
    "$event_script" "$player_id"
    
    # Mark event as triggered
    mark_event_triggered "$player_id" "$event_id"
    
    log "INFO" "Event complete: ${event_id} for player: ${player_id}"
    return 0
  else
    log "ERROR" "Event script not found or not executable: ${event_id}"
    return 1
  fi
}

# Main function
main() {
  local command="$1"
  shift
  
  case "$command" in
    init)
      initialize_player "$1"
      fix_permissions "$1"  # Always fix permissions after initialization
      # Trigger onboarding event for new players
      trigger_event "$1" "onboarding"
      ;;
    status)
      # Try to fix permissions before showing status
      fix_permissions "$1" >/dev/null 2>&1
      display_status "$1"
      ;;
    get-state)
      fix_permissions "$1" >/dev/null 2>&1
      get_player_state "$1"
      ;;
    update-state)
      update_player_state "$1"
      fix_permissions "$1" >/dev/null 2>&1
      ;;
    add-discovery)
      add_discovery "$1" "$2"
      fix_permissions "$1" >/dev/null 2>&1
      ;;
    complete-quest)
      complete_quest "$1" "$2"
      fix_permissions "$1" >/dev/null 2>&1
      ;;
    fix-permissions)
      fix_permissions "$1"
      ;;
    trigger-event)
      # Manually trigger an event
      # Check if force option is provided
      if [ "$3" = "--force" ]; then
        trigger_event "$1" "$2" "true"
      else
        trigger_event "$1" "$2"
      fi
      ;;
    process)
      # Process shell commands for game mechanics
      shift  # Remove the "process" argument
      local cmd="$1"
      local player_id=""
      
      # Get player ID if provided as second argument
      if [ $# -ge 2 ]; then
        shift
        player_id="$1"
      else
        # Default to "player" if not provided
        player_id="player"
      fi
      
      # Debug output
      if [ "${NC_DEBUG}" == "true" ]; then
        echo "[DEBUG] Processing command: '$cmd' for player: '$player_id'" >> "${LOGS_DIR}/engine_debug.log"
      fi
      
      # Process the command with robust error handling
      if ! process_command "$cmd" "$player_id"; then
        log "ERROR" "Failed to process command: $cmd for player: $player_id"
      fi
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