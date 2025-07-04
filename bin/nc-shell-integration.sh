#!/bin/bash
#
# nc-shell-integration.sh - Shell integration for Network Chronicles
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"
source "${SCRIPT_DIR}/utils/json-helpers.sh"

# Set up variables using configuration
PLAYER_ID=$(whoami)
ENGINE="${NC_GAME_ROOT}/bin/network-chronicles-engine.sh"

# Colors - define two sets, one for prompt (with \[ \]) and one for echo statements
# For echo statements (regular ANSI color codes)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# For use in PS1 prompt (needs the \[ \] markers for correct cursor positioning)
PS1_GREEN='\[\033[0;32m\]'
PS1_CYAN='\[\033[0;36m\]'
PS1_YELLOW='\[\033[1;33m\]'
PS1_RED='\[\033[0;31m\]'
PS1_RESET='\[\033[0m\]'

# Check if the engine exists
if [ ! -f "$ENGINE" ]; then
  echo "Network Chronicles engine not found at ${ENGINE}"
  return 1
fi

# Initialize player if needed
$ENGINE init "$PLAYER_ID" > /dev/null 2>&1

# Function to truncate text to fit within a given width
truncate_text() {
  local text="$1"
  local max_width="$2"
  
  if [ ${#text} -gt $max_width ]; then
    echo "${text:0:$((max_width-3))}..."
  else
    echo "$text"
  fi
}

# Custom prompt with enhanced UI and terminal size adaptation
nc_prompt() {
  # Get terminal size
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # Skip drawing status bar if terminal is too small
  if [ "$term_width" -lt 60 ] || [ "$term_height" -lt 10 ]; then
    # Simple prompt for small terminals
    PS1="${GREEN}[NC]${RESET} \u@\h:\w\$ "
    return 0
  fi
  
  # Get player data using json-helpers
  local player_profile=$(get_player_profile "$PLAYER_ID")
  local tier=$(json_get_value "$player_profile" '.tier' 2>/dev/null || echo "1")
  local xp=$(json_get_value "$player_profile" '.xp' 2>/dev/null || echo "0")
  local current_quest=$(json_get_value "$player_profile" '.quests.current' 2>/dev/null || echo "unknown")
  local discoveries=$(json_get_value "$player_profile" '.discoveries | length' 2>/dev/null || echo "0")
  
  # Get quest name from quest file
  local quest_name="Unknown Quest"
  local quest_file="${NC_GAME_ROOT}/content/narrative/quests/${current_quest}.json"
  if [ -f "$quest_file" ]; then
    quest_name=$(jq -r '.name // "Unknown Quest"' "$quest_file" 2>/dev/null)
  fi
  
  # Calculate progress indicators
  local xp_for_next_tier=$((tier * 500))
  local xp_percent=$((xp * 100 / xp_for_next_tier))
  if [ "$xp_percent" -gt 100 ]; then xp_percent=100; fi
  
  # Adapt progress bar size based on terminal width
  local progress_size=10
  if [ "$term_width" -lt 80 ]; then
    progress_size=5
  fi
  
  local xp_bars=$((xp_percent * progress_size / 100))
  local xp_bar_filled=""
  local xp_bar_empty=""
  for ((i=0; i<xp_bars; i++)); do xp_bar_filled+="■"; done
  for ((i=xp_bars; i<progress_size; i++)); do xp_bar_empty+="□"; done
  
  # Adapt quest name length based on terminal width
  local quest_display_width=$((term_width / 4))
  local quest_display=$(truncate_text "$quest_name" $quest_display_width)
  
  # Save cursor position
  echo -en "\033[s" # Save cursor
  echo -en "\033[0;0H" # Go to top left
  echo -en "\033[K" # Clear line
  
  # Create horizontal bar
  local bar_width=$((term_width - 2))
  local bar_line=""
  for ((i=0; i<bar_width; i++)); do bar_line+="━"; done
  
  # Set color based on tier
  local tier_color=${GREEN}
  case "$tier" in
    1) tier_color=${GREEN} ;;
    2) tier_color=${CYAN} ;;
    3) tier_color=${YELLOW} ;;
    4|5) tier_color=${RED} ;;
  esac
  
  # Draw top bar, adapting content based on terminal width
  echo -en "${tier_color}┏${bar_line}┓${RESET}\n"
  
  if [ "$term_width" -lt 100 ]; then
    # Compact display for smaller terminals
    echo -en "${tier_color}┃${RESET} ${CYAN}T:${RESET}${tier} ${YELLOW}|${RESET} ${CYAN}XP:${RESET}${xp}/${xp_for_next_tier} [${GREEN}${xp_bar_filled}${RESET}${xp_bar_empty}] ${YELLOW}|${RESET} ${CYAN}Q:${RESET}${quest_display} ${tier_color}┃${RESET}\n"
  else 
    # Full display for larger terminals
    echo -en "${tier_color}┃${RESET} ${CYAN}TIER:${RESET} ${tier_color}${tier}${RESET} ${YELLOW}|${RESET} ${CYAN}XP:${RESET} ${xp}/${xp_for_next_tier} [${GREEN}${xp_bar_filled}${RESET}${xp_bar_empty}] ${YELLOW}|${RESET} ${CYAN}QUEST:${RESET} ${quest_display} ${YELLOW}|${RESET} ${CYAN}DISCOVERIES:${RESET} ${discoveries} ${tier_color}┃${RESET}\n"
  fi
  
  echo -en "${tier_color}┗${bar_line}┛${RESET}\n"
  
  # Restore cursor position
  echo -en "\033[u" # Restore cursor
  
  # Set prompt based on tier with enhanced styling
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

# Get a contextual hint based on current quest
get_hint_message() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  local current_quest=$(json_get_value "$player_profile" '.quests.current' 2>/dev/null || echo "unknown")
  local discoveries=$(json_get_value "$player_profile" '.discoveries' 2>/dev/null || echo "[]")
  
  # Determine hint message based on quest
  local hint_message=""
  
  case "$current_quest" in
    initial_access)
      if ! echo "$discoveries" | grep -q "welcome_message"; then
        hint_message="${YELLOW}▶ HINT:${RESET} Look in hidden directories like ${CYAN}.local/share${RESET} for The Architect's message."
      fi
      ;;
    map_network)
      local has_gateway=$(echo "$discoveries" | grep -q '"network_gateway"' && echo "true" || echo "false")
      local has_local=$(echo "$discoveries" | grep -q '"local_network"' && echo "true" || echo "false")
      
      if [ "$has_gateway" = "false" ]; then
        hint_message="${YELLOW}▶ HINT:${RESET} Try command ${CYAN}ip route${RESET} to discover the network gateway."
      elif [ "$has_local" = "false" ]; then
        hint_message="${YELLOW}▶ HINT:${RESET} Try command ${CYAN}ip addr${RESET} to analyze local network interfaces."
      else
        hint_message="${YELLOW}▶ HINT:${RESET} Use ${CYAN}nc-complete-quest${RESET} to finish your current quest."
      fi
      ;;
  esac
  
  echo "$hint_message"
}

# Get compact hint for smaller terminals
get_compact_hint() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  local current_quest=$(json_get_value "$player_profile" '.quests.current' 2>/dev/null || echo "unknown")
  local discoveries=$(json_get_value "$player_profile" '.discoveries' 2>/dev/null || echo "[]")
  
  # Determine compact hint
  case "$current_quest" in
    initial_access)
      if ! echo "$discoveries" | grep -q "welcome_message"; then
        echo "${PS1_YELLOW}▶${PS1_RESET} Check ${PS1_CYAN}.local/share${PS1_RESET}"
      fi
      ;;
    map_network)
      local has_gateway=$(echo "$discoveries" | grep -q '"network_gateway"' && echo "true" || echo "false")
      local has_local=$(echo "$discoveries" | grep -q '"local_network"' && echo "true" || echo "false")
      
      if [ "$has_gateway" = "false" ]; then
        echo "${PS1_YELLOW}▶${PS1_RESET} Try ${PS1_CYAN}ip route${PS1_RESET}"
      elif [ "$has_local" = "false" ]; then
        echo "${PS1_YELLOW}▶${PS1_RESET} Try ${PS1_CYAN}ip addr${PS1_RESET}"
      else
        echo "${PS1_YELLOW}▶${PS1_RESET} Use ${PS1_CYAN}nc-complete-quest${PS1_RESET}"
      fi
      ;;
  esac
}

# Update prompt to include hint in PS1
nc_prompt() {
  # Get terminal dimensions
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # Skip status bar if terminal is too small
  if [ "$term_width" -lt 60 ] || [ "$term_height" -lt 10 ]; then
    # Simple prompt for small terminals
    PS1="${PS1_GREEN}[NC]${PS1_RESET} \u@\h:\w\$ "
    return 0
  fi
  
  # Get player data using json-helpers
  local player_profile=$(get_player_profile "$PLAYER_ID")
  local tier=$(json_get_value "$player_profile" '.tier' 2>/dev/null || echo "1")
  local xp=$(json_get_value "$player_profile" '.xp' 2>/dev/null || echo "0")
  local current_quest=$(json_get_value "$player_profile" '.quests.current' 2>/dev/null || echo "unknown")
  local discoveries=$(json_get_value "$player_profile" '.discoveries | length' 2>/dev/null || echo "0")
  
  # Get quest name from quest file
  local quest_name="Unknown Quest"
  local quest_file="${NC_GAME_ROOT}/content/narrative/quests/${current_quest}.json"
  if [ -f "$quest_file" ]; then
    quest_name=$(jq -r '.name // "Unknown Quest"' "$quest_file" 2>/dev/null)
  fi
  
  # Calculate progress indicators
  local xp_for_next_tier=$((tier * 500))
  local xp_percent=$((xp * 100 / xp_for_next_tier))
  if [ "$xp_percent" -gt 100 ]; then xp_percent=100; fi
  
  # Adapt progress bar size based on terminal width
  local progress_size=10
  if [ "$term_width" -lt 80 ]; then
    progress_size=5
  fi
  
  local xp_bars=$((xp_percent * progress_size / 100))
  local xp_bar_filled=""
  local xp_bar_empty=""
  for ((i=0; i<xp_bars; i++)); do xp_bar_filled+="■"; done
  for ((i=xp_bars; i<progress_size; i++)); do xp_bar_empty+="□"; done
  
  # Adapt quest name length based on terminal width
  local quest_display_width=$((term_width / 4))
  local quest_display=$(truncate_text "$quest_name" $quest_display_width)
  
  # Get a hint for the current quest
  local hint="$(get_compact_hint "$PLAYER_ID")"
  
  # Set color based on tier
  local tier_color=${GREEN}
  case "$tier" in
    1) tier_color=${GREEN} ;;
    2) tier_color=${CYAN} ;;
    3) tier_color=${YELLOW} ;;
    4|5) tier_color=${RED} ;;
  esac
  
  # Select PS1 color based on tier
  local ps1_tier_color=$PS1_GREEN
  case "$tier" in
    1) ps1_tier_color=$PS1_GREEN ;;
    2) ps1_tier_color=$PS1_CYAN ;;
    3) ps1_tier_color=$PS1_YELLOW ;;
    4|5) ps1_tier_color=$PS1_RED ;;
  esac

  # Convert hint to use PS1 color codes if present
  local ps1_hint=""
  if [ -n "$hint" ]; then
    # Just use the hint directly - simpler approach
    ps1_hint="$hint"
  fi

  # Set up a multi-line prompt that includes the status info at the bottom
  if [ "$term_width" -lt 100 ]; then
    # Compact display for smaller terminals 
    PS1="\n${ps1_tier_color}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${PS1_RESET}\n"
    PS1+="${ps1_tier_color}┃${PS1_RESET} ${PS1_CYAN}T:${PS1_RESET}${tier} ${PS1_YELLOW}|${PS1_RESET} ${PS1_CYAN}XP:${PS1_RESET}${xp}/${xp_for_next_tier} [${PS1_GREEN}${xp_bar_filled}${PS1_RESET}${xp_bar_empty}] ${PS1_YELLOW}|${PS1_RESET} ${PS1_CYAN}Q:${PS1_RESET}${quest_display} ${ps1_tier_color}┃${PS1_RESET}\n"
    PS1+="${ps1_tier_color}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${PS1_RESET}\n"
    if [ -n "$ps1_hint" ]; then
      PS1+="${ps1_hint}\n"
    fi
    PS1+="${ps1_tier_color}[NC:T${tier}]${PS1_RESET} \u@\h:\w\$ "
  else
    # Full display for larger terminals
    PS1="\n${ps1_tier_color}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${PS1_RESET}\n"
    PS1+="${ps1_tier_color}┃${PS1_RESET} ${PS1_CYAN}TIER:${PS1_RESET} ${ps1_tier_color}${tier}${PS1_RESET} ${PS1_YELLOW}|${PS1_RESET} ${PS1_CYAN}XP:${PS1_RESET} ${xp}/${xp_for_next_tier} [${PS1_GREEN}${xp_bar_filled}${PS1_RESET}${xp_bar_empty}] ${PS1_YELLOW}|${PS1_RESET} ${PS1_CYAN}QUEST:${PS1_RESET} ${quest_display} ${PS1_YELLOW}|${PS1_RESET} ${PS1_CYAN}DISCOVERIES:${PS1_RESET} ${discoveries} ${ps1_tier_color}┃${PS1_RESET}\n"
    PS1+="${ps1_tier_color}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${PS1_RESET}\n"
    if [ -n "$ps1_hint" ]; then
      PS1+="${ps1_hint}\n"
    fi
    PS1+="${ps1_tier_color}[NC:T${tier}]${PS1_RESET} \u@\h:\w\$ "
  fi
}

# Set up prompt (hints are now included in the prompt itself)
PROMPT_COMMAND="nc_prompt"

# Command wrappers
nc-status() {
  $ENGINE status "$PLAYER_ID"
}

nc-journal() {
  "${NC_GAME_ROOT}/bin/journal.sh" "$PLAYER_ID" "$@"
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
  # Use json-helpers to get current quest
  local player_profile=$(get_player_profile "$PLAYER_ID")
  local current_quest=$(json_get_value "$player_profile" '.quests.current')
  
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
  # Clear screen
  clear
  
  # Get terminal dimensions
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # Get player data for contextual help
  local player_profile=$(get_player_profile "$PLAYER_ID")
  local current_quest=$(json_get_value "$player_profile" '.quests.current' 2>/dev/null || echo "unknown")
  
  # Simple help display for very small terminals
  if [ "$term_width" -lt 60 ] || [ "$term_height" -lt 15 ]; then
    echo -e "${GREEN}=== NETWORK CHRONICLES HELP ===${RESET}"
    echo -e ""
    echo -e "${YELLOW}COMMANDS:${RESET}"
    echo -e "  ${GREEN}nc-status${RESET}         Show status"
    echo -e "  ${GREEN}nc-journal${RESET}        View journal"
    echo -e "  ${GREEN}nc-add-discovery${RESET}  Add discovery"
    echo -e "  ${GREEN}nc-complete-quest${RESET} Complete quest"
    echo -e ""
    echo -e "${YELLOW}USEFUL:${RESET}"
    echo -e "  ${CYAN}ls -la${RESET}           List files"
    echo -e "  ${CYAN}cd <directory>${RESET}   Change directory"
    echo -e "  ${CYAN}cat <file>${RESET}       View file"
    
    # Reset prompt
    nc_prompt
    return 0
  fi
  
  # Display appropriate header based on terminal size
  if [ "$term_width" -lt 80 ]; then
    # Medium-sized terminal - compact header
    echo -e "${CYAN}╔═══════════════ NETWORK CHRONICLES HELP ════════════════╗${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${RESET}"
  else
    # Large terminal - full ASCII art header
    echo -e "${CYAN}"
    echo -e "╔════════════════════════════════════════════════════════════════════════════╗"
    echo -e "║  _   _      _                      _      ___ _                  _      _   ║"
    echo -e "║ | \ | | ___| |___      _____  _ __| | __ / __| |__  _ __ ___  _ __ (_) ___| |║"
    echo -e "║ |  \| |/ _ \ __\ \ /\ / / _ \| '__| |/ / | |_ | '_ \| '__/ _ \| '_ \| |/ __| |║"
    echo -e "║ | |\  |  __/ |_ \ V  V / (_) | |  |   <  | __|| | | | | | (_) | | | | | (__| |║"
    echo -e "║ |_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ |_|  |_| |_|_|  \___/|_| |_|_|\___|_|║"
    echo -e "╚════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
  fi
  
  # Draw help categories
  local box_width=$((term_width - 4))
  local border_line=""
  for ((i=0; i<box_width; i++)); do border_line+="─"; done
  
  # Display command sections based on terminal width
  if [ "$term_width" -lt 80 ]; then
    # Compact display for medium terminal
    echo -e "${YELLOW}╭${border_line}╮${RESET}"
    echo -e "${YELLOW}│${CYAN} COMMANDS${RESET}${YELLOW}$(printf "%$((box_width - 9))s")│${RESET}"
    echo -e "${YELLOW}├${border_line}┤${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-status${RESET}         Display status${YELLOW}$(printf "%$((box_width - 33))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-journal${RESET}        View journal${YELLOW}$(printf "%$((box_width - 31))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-add-discovery${RESET}  Add discovery${YELLOW}$(printf "%$((box_width - 33))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-complete-quest${RESET} Complete quest${YELLOW}$(printf "%$((box_width - 33))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-help${RESET}           Show help${YELLOW}$(printf "%$((box_width - 30))s")│${RESET}"
    echo -e "${YELLOW}╰${border_line}╯${RESET}"
    
    # System commands
    echo -e "\n${CYAN}╭${border_line}╮${RESET}"
    echo -e "${CYAN}│${CYAN} SYSTEM COMMANDS${RESET}${CYAN}$(printf "%$((box_width - 15))s")│${RESET}"
    echo -e "${CYAN}├${border_line}┤${RESET}"
    echo -e "${CYAN}│${RESET}  ${CYAN}ls -la${RESET}          List files${CYAN}$(printf "%$((box_width - 30))s")│${RESET}"
    echo -e "${CYAN}│${RESET}  ${CYAN}cd <directory>${RESET}  Change directory${CYAN}$(printf "%$((box_width - 36))s")│${RESET}"
    echo -e "${CYAN}│${RESET}  ${CYAN}cat <file>${RESET}      View file${CYAN}$(printf "%$((box_width - 29))s")│${RESET}"
    echo -e "${CYAN}╰${border_line}╯${RESET}"
    
    # Show quest hints if there's room
    if [ "$term_height" -gt 25 ]; then
      echo -e "\n${RED}╭${border_line}╮${RESET}"
      echo -e "${RED}│${CYAN} CURRENT QUEST HINT${RESET}${RED}$(printf "%$((box_width - 17))s")│${RESET}"
      echo -e "${RED}├${border_line}┤${RESET}"
      
      case "$current_quest" in
        initial_access)
          echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Look in .local/share directory${RED}$(printf "%$((box_width - 39))s")│${RESET}"
          ;;
        map_network)
          echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Try ${CYAN}ip route${RESET} and ${CYAN}ip addr${RESET}${RED}$(printf "%$((box_width - 32))s")│${RESET}"
          ;;
        *)
          echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Check ${CYAN}nc-status${RESET} for details${RED}$(printf "%$((box_width - 37))s")│${RESET}"
          ;;
      esac
      
      echo -e "${RED}╰${border_line}╯${RESET}"
    fi
  else
    # Full display for large terminal
    echo -e "${YELLOW}╭${border_line}╮${RESET}"
    echo -e "${YELLOW}│${CYAN} PLAYER COMMANDS${RESET}${YELLOW}$(printf "%$((box_width - 15))s")│${RESET}"
    echo -e "${YELLOW}├${border_line}┤${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-status${RESET}         Display your current status and quest information${YELLOW}$(printf "%$((box_width - 65))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-journal${RESET}        View your journal entries${YELLOW}$(printf "%$((box_width - 42))s")│${RESET}"
    echo -e "${YELLOW}│${RESET}  ${GREEN}nc-help${RESET}           Show this help message${YELLOW}$(printf "%$((box_width - 40))s")│${RESET}"
    echo -e "${YELLOW}╰${border_line}╯${RESET}"
    
    echo -e "\n${CYAN}╭${border_line}╮${RESET}"
    echo -e "${CYAN}│${CYAN} QUEST COMMANDS${RESET}${CYAN}$(printf "%$((box_width - 14))s")│${RESET}"
    echo -e "${CYAN}├${border_line}┤${RESET}"
    echo -e "${CYAN}│${RESET}  ${GREEN}nc-add-discovery${RESET}  Record a discovery (usage: nc-add-discovery <discovery_id>)${CYAN}$(printf "%$((box_width - 70))s")│${RESET}"
    echo -e "${CYAN}│${RESET}  ${GREEN}nc-complete-quest${RESET} Complete your current quest when requirements are met${CYAN}$(printf "%$((box_width - 67))s")│${RESET}"
    echo -e "${CYAN}╰${border_line}╯${RESET}"
    
    echo -e "\n${GREEN}╭${border_line}╮${RESET}"
    echo -e "${GREEN}│${CYAN} USEFUL SYSTEM COMMANDS${RESET}${GREEN}$(printf "%$((box_width - 21))s")│${RESET}"
    echo -e "${GREEN}├${border_line}┤${RESET}"
    echo -e "${GREEN}│${RESET}  ${CYAN}ls -la${RESET}          List all files in current directory, including hidden files${GREEN}$(printf "%$((box_width - 73))s")│${RESET}"
    echo -e "${GREEN}│${RESET}  ${CYAN}cd <directory>${RESET}  Change to specified directory${GREEN}$(printf "%$((box_width - 44))s")│${RESET}"
    echo -e "${GREEN}│${RESET}  ${CYAN}cat <file>${RESET}      Display contents of a file${GREEN}$(printf "%$((box_width - 42))s")│${RESET}"
    echo -e "${GREEN}│${RESET}  ${CYAN}grep <pattern>${RESET}  Search for text in files${GREEN}$(printf "%$((box_width - 42))s")│${RESET}"
    echo -e "${GREEN}╰${border_line}╯${RESET}"
    
    # Display context-specific help based on current quest
    echo -e "\n${RED}╭${border_line}╮${RESET}"
    echo -e "${RED}│${CYAN} CURRENT QUEST HINTS${RESET}${RED}$(printf "%$((box_width - 19))s")│${RESET}"
    echo -e "${RED}├${border_line}┤${RESET}"
    
    case "$current_quest" in
      initial_access)
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Hidden files and directories start with a dot (.)${RED}$(printf "%$((box_width - 57))s")│${RESET}"
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Try looking in the .local/share directory in your home folder${RED}$(printf "%$((box_width - 67))s")│${RESET}"
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Use 'nc-add-discovery welcome_message' when you find the message${RED}$(printf "%$((box_width - 70))s")│${RESET}"
        ;;
      map_network)
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Use 'ip route' to discover the network gateway${RED}$(printf "%$((box_width - 53))s")│${RESET}"
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Use 'ip addr' to analyze local network interfaces${RED}$(printf "%$((box_width - 58))s")│${RESET}"
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Network commands will automatically register discoveries${RED}$(printf "%$((box_width - 63))s")│${RESET}"
        ;;
      *)
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Complete your current quest to progress the story${RED}$(printf "%$((box_width - 55))s")│${RESET}"
        echo -e "${RED}│${RESET}  ${YELLOW}▶${RESET} Check your status with 'nc-status' to see requirements${RED}$(printf "%$((box_width - 63))s")│${RESET}"
        ;;
    esac
    
    echo -e "${RED}╰${border_line}╯${RESET}"
    
    # Add signature if there's room
    echo -e "\n${CYAN}〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓 Network Chronicles 〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓〓${RESET}"
    echo -e "${YELLOW}                    The Vanishing Admin - v1.0.0${RESET}"
  fi
  
  # Reset prompt (to make sure status bar is drawn)
  nc_prompt
}

# Command interception for game events
function nc_preexec() {
  # Get the command
  local cmd=$(history 1 | sed 's/^[ ]*[0-9]*[ ]*//')
  
  # Skip empty commands
  if [ -z "$cmd" ]; then
    return 0
  fi
  
  # NOTE: Removed direct discovery detection logic (ip route, ip addr) and 
  # the display_discovery function from this pre-execution hook.
  # Discoveries should be handled by the engine's trigger system 
  # after the command executes.
  
  # Pass the command to the engine for processing triggers/events
  # Run in background to avoid blocking the terminal prompt
  ("$ENGINE" process "$cmd" "$PLAYER_ID" &)
  
  return 0
}

# Set up trap for command execution
if [ -n "$ZSH_VERSION" ]; then
  # ZSH integration
  preexec_functions+=("nc_preexec")
else
  # Bash integration
  trap 'nc_preexec' DEBUG
fi

# Ensure Documents directory exists for the current player
ensure_player_documents "$PLAYER_ID" > /dev/null 2>&1

# Display welcome message with adaptive ASCII art
show_welcome_message() {
  # Clear the screen completely by filling with newlines
  clear
  
  # Reset cursor to top before drawing
  echo -e "\033[H"
  
  # Get terminal dimensions
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # Choose appropriate welcome display based on terminal size
  if [ "$term_width" -lt 60 ] || [ "$term_height" -lt 20 ]; then
    # Small terminal - simple text welcome
    echo -e "${GREEN}=== NETWORK CHRONICLES ===${RESET}"
    echo -e "${YELLOW}THE VANISHING ADMIN${RESET}"
    echo -e ""
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-help${RESET} for commands"
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-status${RESET} for status"
    echo -e ""
    echo -e "${RED}\"Trust nothing, verify everything.\"${RESET}"
  elif [ "$term_width" -lt 80 ]; then
    # Medium terminal - compact ASCII art
    echo -e "${GREEN}"
    echo -e "███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗"
    echo -e "████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝"
    echo -e "██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ "
    echo -e "██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗ "
    echo -e "██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗"
    echo -e "╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${RESET}"
    echo -e "${CYAN}=================================================================${RESET}"
    echo -e "${YELLOW}       THE VANISHING ADMIN - Where is The Architect?${RESET}"
    echo -e "${CYAN}=================================================================${RESET}"
    echo -e ""
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-help${RESET} for available commands"
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-status${RESET} to view your status"
    echo -e ""
    echo -e "${YELLOW}MISSION:${RESET} Investigate the mysterious disappearance"
    echo -e "of your predecessor, \"The Architect\"."
    echo -e ""
    echo -e "${RED}\"Trust nothing, verify everything.\"${RESET}"
  else
    # Large terminal - full ASCII art
    echo -e "${GREEN}"
    echo -e "███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗"
    echo -e "████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝"
    echo -e "██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ "
    echo -e "██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗ "
    echo -e "██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗"
    echo -e "╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "                                                              "
    echo -e "     ██████╗██╗  ██╗██████╗  ██████╗ ███╗   ██╗██╗ ██████╗██╗     ███████╗███████╗"
    echo -e "    ██╔════╝██║  ██║██╔══██╗██╔═══██╗████╗  ██║██║██╔════╝██║     ██╔════╝██╔════╝"
    echo -e "    ██║     ███████║██████╔╝██║   ██║██╔██╗ ██║██║██║     ██║     █████╗  ███████╗"
    echo -e "    ██║     ██╔══██║██╔══██╗██║   ██║██║╚██╗██║██║██║     ██║     ██╔══╝  ╚════██║"
    echo -e "    ╚██████╗██║  ██║██║  ██║╚██████╔╝██║ ╚████║██║╚██████╗███████╗███████╗███████║"
    echo -e "     ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝ ╚═════╝╚══════╝╚══════╝╚══════╝"
    echo -e "${RESET}"
    
    # Create border of appropriate width
    local border_line=""
    for ((i=0; i<term_width; i++)); do border_line+="="; done
    
    echo -e "${CYAN}${border_line}${RESET}"
    echo -e "${YELLOW}           THE VANISHING ADMIN - Find out what happened to The Architect${RESET}"
    echo -e "${CYAN}${border_line}${RESET}"
    echo -e ""
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-help${RESET} for available commands"
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-status${RESET} to view your current status"
    echo -e "  ${GREEN}•${RESET} Type ${CYAN}nc-journal${RESET} to read your log entries"
    echo -e ""
    echo -e "${YELLOW}MISSION:${RESET} As the new system administrator, investigate the mysterious"
    echo -e "disappearance of your predecessor, known only as \"The Architect\"."
    echo -e ""
    echo -e "${RED}\"Trust nothing, verify everything.\"${RESET}"
  fi
  
  echo -e ""
}

# Display welcome message
show_welcome_message
