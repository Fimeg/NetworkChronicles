#!/bin/bash
#
# journal.sh - Interactive journal for Network Chronicles
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"
source "${SCRIPT_DIR}/utils/json-helpers.sh"

# Check for player ID parameter
PLAYER_ID="$1"
if [ -z "$PLAYER_ID" ]; then
  PLAYER_ID=$(whoami)
fi

# Ensure player directory exists
# Get the player's state directory
PLAYER_STATE_DIR="${NC_GAME_ROOT}/data/players"
mkdir -p "${PLAYER_STATE_DIR}/${PLAYER_ID}"
chmod 777 "${PLAYER_STATE_DIR}/${PLAYER_ID}" 2>/dev/null

# Get player profile
PLAYER_PROFILE="${PLAYER_STATE_DIR}/${PLAYER_ID}/profile.json"
JOURNAL_FILE="${PLAYER_STATE_DIR}/${PLAYER_ID}/journal.json"

# Colors for styling
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'

# Function to create a styled header
create_header() {
  local title="$1"
  local width=$(tput cols)
  local padding="═"
  local header=""
  
  # Create top border with title
  header+="${CYAN}╭"
  for ((i=0; i<width-2; i++)); do header+="═"; done
  header+="╮${RESET}\n"
  
  # Add title centered in the header
  local title_padding=$(( (width - ${#title} - 2) / 2 ))
  header+="${CYAN}│${RESET}"
  for ((i=0; i<title_padding; i++)); do header+=" "; done
  header+="${YELLOW}${BOLD}${title}${RESET}"
  # Handle odd length titles
  local end_padding=$title_padding
  if (( (width - ${#title} - 2) % 2 != 0 )); then end_padding=$((title_padding + 1)); fi
  for ((i=0; i<end_padding; i++)); do header+=" "; done
  header+="${CYAN}│${RESET}\n"
  
  # Add bottom border
  header+="${CYAN}╰"
  for ((i=0; i<width-2; i++)); do header+="═"; done
  header+="╯${RESET}\n"
  
  echo -e "$header"
}

# Function to create a styled footer
create_footer() {
  local width=$(tput cols)
  local footer=""
  
  footer+="${CYAN}╭"
  for ((i=0; i<width-2; i++)); do footer+="═"; done
  footer+="╮${RESET}\n"
  
  footer+="${CYAN}│${GREEN} [n] Next page ${MAGENTA}[p] Previous page ${YELLOW}[b] Back to menu ${RED}[q] Quit ${RESET}${CYAN}$(printf '%*s' $((width - 46)) '')│${RESET}\n"
  
  footer+="${CYAN}╰"
  for ((i=0; i<width-2; i++)); do footer+="═"; done
  footer+="╯${RESET}\n"
  
  echo -e "$footer"
}

# Create a new journal entry
create_new_entry() {
  clear
  create_header "CREATE NEW JOURNAL ENTRY"
  
  # Check if we have a compatible editor
  local editor=""
  if command -v nano &> /dev/null; then
    editor="nano"
  elif command -v vim &> /dev/null; then
    editor="vim"
  else
    echo -e "${RED}No suitable text editor found (nano or vim).${RESET}"
    echo -e "${YELLOW}Press any key to return to the menu...${RESET}"
    read -n 1
    return 1
  fi
  
  # Get entry title
  echo -e "${CYAN}Entry title:${RESET} "
  read -r title
  
  if [ -z "$title" ]; then
    echo -e "${RED}Entry cancelled.${RESET}"
    sleep 1
    return 1
  fi
  
  # Create temporary file for content
  local tmp_file=$(mktemp)
  
  # Add header to the temp file
  echo "# $title" > "$tmp_file"
  echo "" >> "$tmp_file"
  echo "Date: $(date '+%Y-%m-%d %H:%M:%S')" >> "$tmp_file"
  echo "" >> "$tmp_file"
  echo "Write your journal entry here..." >> "$tmp_file"
  
  # Open editor with the temp file
  $editor "$tmp_file"
  
  # Check if user saved content (file has more than just the template)
  if [ $(wc -l < "$tmp_file") -le 5 ]; then
    echo -e "${RED}Entry cancelled or empty.${RESET}"
    rm "$tmp_file"
    sleep 1
    return 1
  fi
  
  # Get content from temp file (skip the first line which is the title)
  local content=$(tail -n +2 "$tmp_file")
  
  # Generate a unique ID for the entry
  local id="entry_$(date +%s)"
  
  # Add entry to journal
  if [ ! -f "$JOURNAL_FILE" ]; then
    # Create new journal file if it doesn't exist
    mkdir -p "$(dirname "$JOURNAL_FILE")"
    echo '{"entries":[]}' > "$JOURNAL_FILE"
  fi
  
  # Add the new entry to the journal
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)
  jq ".entries += [{\"id\": \"$id\", \"title\": \"$title\", \"content\": $(echo "$content" | jq -Rs .), \"timestamp\": \"$timestamp\"}]" "$JOURNAL_FILE" > "$tmp" && mv "$tmp" "$JOURNAL_FILE"
  
  # Clean up temp file
  rm -f "$tmp_file"
  
  echo -e "${GREEN}Entry added successfully!${RESET}"
  sleep 1
  return 0
}

# Display all journal entries
show_journal_entries() {
  clear
  create_header "JOURNAL ENTRIES"
  
  # Check if journal file exists
  if [ ! -f "$JOURNAL_FILE" ]; then
    echo -e "${YELLOW}No journal entries found.${RESET}"
    echo -e "${GREEN}Create your first entry using option 9 from the main menu.${RESET}"
    echo ""
    echo -e "${CYAN}Press any key to return to the menu...${RESET}"
    read -n 1
    return
  fi
  
  # Get entries from journal file
  local entries=$(jq -r '.entries | sort_by(.timestamp) | reverse | .[] | "\(.id)|\(.title)|\(.timestamp)"' "$JOURNAL_FILE")
  
  if [ -z "$entries" ]; then
    echo -e "${YELLOW}No journal entries found.${RESET}"
    echo -e "${GREEN}Create your first entry using option 9 from the main menu.${RESET}"
    echo ""
    echo -e "${CYAN}Press any key to return to the menu...${RESET}"
    read -n 1
    return
  fi
  
  # Display entries with styled formatting
  local count=1
  echo -e "${BOLD}${UNDERLINE}Your Journal Entries:${RESET}\n"
  
  echo -e "${WHITE}ID  DATE        TITLE${RESET}"
  echo -e "${CYAN}--- ---------- -----------------------------${RESET}"
  
  # Process and display each entry
  while IFS="|" read -r id title timestamp; do
    # Format the date nicely
    local date=$(date -d "$timestamp" '+%Y-%m-%d' 2>/dev/null || echo "$timestamp" | cut -d'T' -f1)
    
    # Use different colors for alternating rows
    if (( count % 2 == 0 )); then
      echo -e "${GREEN}${count}${RESET}  ${CYAN}${date}${RESET} ${WHITE}${title}${RESET}"
    else
      echo -e "${GREEN}${count}${RESET}  ${BLUE}${date}${RESET} ${WHITE}${title}${RESET}"
    fi
    
    # Store ID for later reference
    entry_ids[$count]=$id
    count=$((count + 1))
  done <<< "$entries"
  
  echo -e "\n${CYAN}Enter entry number to view, or 0 to return to menu:${RESET} "
  read -r choice
  
  if [ "$choice" = "0" ]; then
    return
  elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -gt 0 ] && [ "$choice" -lt "$count" ]; then
    view_entry "${entry_ids[$choice]}"
  else
    echo -e "${RED}Invalid choice.${RESET}"
    sleep 1
    show_journal_entries
  fi
}

# View a specific journal entry with paging support
view_entry() {
  local entry_id="$1"
  
  # Get entry content
  local entry=$(jq -r ".entries[] | select(.id == \"$entry_id\")" "$JOURNAL_FILE")
  local title=$(echo "$entry" | jq -r '.title')
  local content=$(echo "$entry" | jq -r '.content')
  local timestamp=$(echo "$entry" | jq -r '.timestamp')
  
  # Format the date
  local date=$(date -d "$timestamp" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo "$timestamp" | sed 's/T/ /g' | sed 's/Z//g')
  
  # Prepare content for display with styling
  # Add title and date at the top
  local styled_content="${YELLOW}${BOLD}# $title${RESET}\n"
  styled_content+="${CYAN}Date: $date${RESET}\n\n"
  
  # Process content for basic markdown styling
  # Headers
  content=$(echo "$content" | sed -E "s/^# (.*)/${YELLOW}${BOLD}# \\1${RESET}/g")
  content=$(echo "$content" | sed -E "s/^## (.*)/${GREEN}${BOLD}## \\1${RESET}/g")
  content=$(echo "$content" | sed -E "s/^### (.*)/${CYAN}${BOLD}### \\1${RESET}/g")
  
  # Code blocks - simplistic approach
  content=$(echo "$content" | sed -E "s/\`([^\`]+)\`/${MAGENTA}\\1${RESET}/g")
  
  # Add the processed content
  styled_content+="$content"
  
  # Display paged content
  display_paged_content "$styled_content" "$title"
}

# Display content with paging
display_paged_content() {
  local content="$1"
  local title="$2"
  local page=1
  local lines_per_page=$(( $(tput lines) - 10 )) # Adjust for header and footer
  
  # Split content into pages
  local IFS=$'\n'
  local content_lines=($content)
  local total_lines=${#content_lines[@]}
  local total_pages=$(( (total_lines + lines_per_page - 1) / lines_per_page ))
  
  # Display current page
  display_page "$page" "$total_pages" "$title" "${content_lines[@]}"
  
  # Handle navigation
  while true; do
    read -n 1 -s key
    case "$key" in
      n|N) # Next page
        if [ "$page" -lt "$total_pages" ]; then
          page=$((page + 1))
          display_page "$page" "$total_pages" "$title" "${content_lines[@]}"
        fi
        ;;
      p|P) # Previous page
        if [ "$page" -gt 1 ]; then
          page=$((page - 1))
          display_page "$page" "$total_pages" "$title" "${content_lines[@]}"
        fi
        ;;
      b|B) # Back to journal list
        show_journal_entries
        return
        ;;
      q|Q) # Quit to main menu
        return
        ;;
    esac
  done
}

# Display a single page of content
display_page() {
  local page="$1"
  local total_pages="$2"
  local title="$3"
  shift 3
  local content_lines=("$@")
  local lines_per_page=$(( $(tput lines) - 10 ))
  
  clear
  create_header "$title"
  
  # Calculate start and end lines for this page
  local start_line=$(( (page - 1) * lines_per_page ))
  local end_line=$(( start_line + lines_per_page - 1 ))
  
  # Display page content
  for ((i=start_line; i<=end_line && i<${#content_lines[@]}; i++)); do
    echo -e "${content_lines[$i]}"
  done
  
  # Fill remaining lines to maintain consistent page height
  local displayed_lines=$(( end_line - start_line + 1 ))
  if [ "$displayed_lines" -lt "$lines_per_page" ]; then
    local remaining=$(( lines_per_page - displayed_lines ))
    for ((i=0; i<remaining; i++)); do
      echo ""
    done
  fi
  
  # Show page indicator
  echo -e "${CYAN}Page ${page}/${total_pages}${RESET}"
  
  # Display navigation footer
  create_footer
}

# Function to update the journal interface - inspired by retro-futuristic terminal style
enhanced_journal_interface() {
  clear
  
  # Get terminal dimensions
  local term_width=$(tput cols)
  local term_height=$(tput lines)
  
  # Create retro-futuristic header with "glitch" effect
  echo -e "${CYAN}╔══${RED}═${CYAN}═══════════════════${RED}═${CYAN}═════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║ ${GREEN}N${YELLOW}E${GREEN}T${YELLOW}W${GREEN}O${YELLOW}R${GREEN}K ${YELLOW}C${GREEN}H${YELLOW}R${GREEN}O${YELLOW}N${GREEN}I${YELLOW}C${GREEN}L${YELLOW}E${GREEN}S ${RED}///${YELLOW} ${BOLD}S${RESET}${YELLOW}ECURE JOURNAL INTERFACE v2.4${RESET} ${CYAN}║${RESET}"
  echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
  
  # Show player stats - adapts to terminal width
  local tier=$(jq -r '.tier' "$PLAYER_PROFILE" 2>/dev/null || echo "1")
  local xp=$(jq -r '.xp' "$PLAYER_PROFILE" 2>/dev/null || echo "0")
  local discoveries=$(jq -r '.discoveries | length' "$PLAYER_PROFILE" 2>/dev/null || echo "0")
  
  if [ "$term_width" -gt 80 ]; then
    # Full stats display for larger terminals
    echo -e "${CYAN}║ ${YELLOW}USER:${RESET} ${GREEN}${PLAYER_ID}@$(hostname)${RESET}  ${YELLOW}TIER:${RESET} ${MAGENTA}${tier}${RESET}  ${YELLOW}XP:${RESET} ${CYAN}${xp}${RESET}  ${YELLOW}DISCOVERIES:${RESET} ${CYAN}${discoveries}${RESET}${CYAN} ║${RESET}"
  else
    # Compact stats for smaller terminals
    echo -e "${CYAN}║ ${YELLOW}USER:${RESET} ${GREEN}${PLAYER_ID}${RESET} ${YELLOW}T:${RESET}${MAGENTA}${tier}${RESET} ${YELLOW}XP:${RESET}${CYAN}${xp}${RESET} ${YELLOW}DISC:${RESET}${CYAN}${discoveries}${RESET}${CYAN} ║${RESET}"
  fi
  
  echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
  
  # Journal menu with blinking cursor effect
  echo -e "${CYAN}║ ${GREEN}${BOLD}JOURNAL SYSTEM OPTIONS:${RESET}                                          ${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET}                                                                  ${CYAN}║${RESET}"
  echo -e "${CYAN}║ ${YELLOW}[1]${RESET} View Journal Entries            ${YELLOW}[6]${RESET} Export Journal            ${CYAN}║${RESET}"
  echo -e "${CYAN}║ ${YELLOW}[2]${RESET} Create New Entry                ${YELLOW}[7]${RESET} Import Data               ${CYAN}║${RESET}"
  echo -e "${CYAN}║ ${YELLOW}[3]${RESET} View Network Map                ${YELLOW}[8]${RESET} System Diagnostics        ${CYAN}║${RESET}"
  echo -e "${CYAN}║ ${YELLOW}[4]${RESET} View Discoveries                ${YELLOW}[9]${RESET} Search Archives           ${CYAN}║${RESET}"
  echo -e "${CYAN}║ ${YELLOW}[5]${RESET} Security Logs                   ${YELLOW}[0]${RESET} Exit Journal              ${CYAN}║${RESET}"
  echo -e "${CYAN}║${RESET}                                                                  ${CYAN}║${RESET}"
  echo -e "${CYAN}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
  
  # Dynamic message based on tier level
  case "$tier" in
    1)
      echo -e "${CYAN}║ ${RED}${BOLD}SECURITY NOTICE:${RESET} Tier 1 access granted. Limited functionality.      ${CYAN}║${RESET}"
      ;;
    2)
      echo -e "${CYAN}║ ${YELLOW}${BOLD}ADVISORY:${RESET} Tier 2 clearance confirmed. Advanced features unlocked.  ${CYAN}║${RESET}"
      ;;
    3|4|5)
      echo -e "${CYAN}║ ${GREEN}${BOLD}SECURE CONNECTION:${RESET} High-level clearance verified. Full access.      ${CYAN}║${RESET}"
      ;;
  esac
  
  # Create mysterious message that changes based on the current minute
  local minute=$(date +%M)
  minute=$((10#$minute % 4))
  
  case "$minute" in
    0)
      echo -e "${CYAN}║ ${MAGENTA}\"The network patterns reveal more than they conceal.\"${RESET}               ${CYAN}║${RESET}"
      ;;
    1)
      echo -e "${CYAN}║ ${MAGENTA}\"What happened to The Architect is hidden in plain sight.\"${RESET}          ${CYAN}║${RESET}"
      ;;
    2)
      echo -e "${CYAN}║ ${MAGENTA}\"They're watching through the DNS queries. Be careful.\"${RESET}             ${CYAN}║${RESET}"
      ;;
    3)
      echo -e "${CYAN}║ ${MAGENTA}\"Trust the system logs, not the official explanation.\"${RESET}              ${CYAN}║${RESET}"
      ;;
  esac
  
  echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
  
  # Simulate terminal cursor
  echo -e "${GREEN}${BOLD}>${RESET} Enter option: ${GREEN}\e[5m_\e[0m${RESET}"
}

# Function to display network discoveries
show_discoveries() {
  clear
  create_header "NETWORK DISCOVERIES"
  
  # Get player discoveries
  local discoveries=$(jq -r '.discoveries | join(" ")' "$PLAYER_PROFILE" 2>/dev/null || echo "")
  
  if [ "$discoveries" = "[]" ] || [ -z "$discoveries" ]; then
    echo -e "${YELLOW}No discoveries recorded yet.${RESET}"
    echo -e "${GREEN}Explore the network to make discoveries.${RESET}"
    echo ""
    echo -e "${CYAN}Press any key to return to the menu...${RESET}"
    read -n 1
    return
  fi
  
  echo -e "${BOLD}${UNDERLINE}Discovered Network Components:${RESET}\n"
  
  # Process each discovery
  local count=0
  for discovery in $discoveries; do
    discovery="${discovery//\"/}"  # Remove quotes
    
    # Style based on discovery type
    case "$discovery" in
      *network*|*gateway*)
        echo -e "${CYAN}[NETWORK]${RESET} ${GREEN}${discovery//_/ }${RESET}"
        ;;
      *service*|*server*)
        echo -e "${MAGENTA}[SERVICE]${RESET} ${YELLOW}${discovery//_/ }${RESET}"
        ;;
      *message*|*artifact*)
        echo -e "${RED}[ARTIFACT]${RESET} ${WHITE}${discovery//_/ }${RESET}"
        ;;
      *)
        echo -e "${BLUE}[SYSTEM]${RESET} ${WHITE}${discovery//_/ }${RESET}"
        ;;
    esac
    
    count=$((count + 1))
  done
  
  echo -e "\n${GREEN}Total discoveries: $count${RESET}"
  echo -e "\n${CYAN}Press any key to return to the menu...${RESET}"
  read -n 1
}

# Function to display a simulated network map
show_network_map() {
  clear
  create_header "NETWORK MAP"
  
  # Get player discoveries to determine what to show on the map
  local discoveries=$(jq -r '.discoveries | join(" ")' "$PLAYER_PROFILE" 2>/dev/null || echo "")
  
  # Base map - always visible
  echo -e "${CYAN}╭───────────────────────────────────────────────────────────────╮${RESET}"
  echo -e "${CYAN}│${RESET}                    ${YELLOW}NETWORK INFRASTRUCTURE${RESET}                    ${CYAN}│${RESET}"
  echo -e "${CYAN}├───────────────────────────────────────────────────────────────┤${RESET}"
  
  # Check what components to show based on discoveries
  if [[ "$discoveries" == *"network_gateway"* ]]; then
    # Show gateway
    echo -e "${CYAN}│${RESET}                           ┌──────────┐                           ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                           │ Internet  │                           ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                           └─────┬────┘                           ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                 │                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                          ┌──────┴───────┐                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                          │ ${GREEN}Gateway${RESET}      │                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                          └──────┬───────┘                        ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                 │                                 ${CYAN}│${RESET}"
    
    # Check for firewall discovery
    if [[ "$discoveries" == *"firewall"* ]]; then
      echo -e "${CYAN}│${RESET}                          ┌──────┴───────┐                        ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                          │ ${RED}Firewall${RESET}     │                        ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                          └──────┬───────┘                        ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                                 │                                 ${CYAN}│${RESET}"
    fi
    
    # Check for local network discovery
    if [[ "$discoveries" == *"local_network"* ]]; then
      echo -e "${CYAN}│${RESET}                           ┌────┴─────┐                          ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                           │ ${BLUE}Switch${RESET}    │                          ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                     ┌─────┴──┬──────┬─┴────┐                    ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                     │        │      │      │                    ${CYAN}│${RESET}"
      
      # Check for more specific discoveries
      if [[ "$discoveries" == *"monitoring_service"* ]]; then
        echo -e "${CYAN}│${RESET}                ┌────┴───┐   │      │      └───┐                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                │ ${MAGENTA}Admin${RESET}   │   │      │          │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                └────────┘   │      │      ┌───┴────┐           ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                             │      │      │ ${RED}Monitor${RESET} │           ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      ┌──────┴──┐   │      └────────┘           ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      │ ${GREEN}Servers${RESET} │   │                          ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      └─────────┘   │                          ${CYAN}│${RESET}"
      else
        # Simplified view if monitoring not discovered
        echo -e "${CYAN}│${RESET}                ┌────┴───┐   │      └──────────┐                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                │ ${MAGENTA}Admin${RESET}   │   │               │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                └────────┘   │               │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                             │               │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      ┌──────┴──┐            │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      │ ${GREEN}Servers${RESET} │            │                ${CYAN}│${RESET}"
        echo -e "${CYAN}│${RESET}                      └─────────┘            │                ${CYAN}│${RESET}"
      fi
    else
      # Very basic view if local network not discovered
      echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                [Further network mapping required]                ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
      echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    fi
  else
    # No network information discovered yet
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}            [No network information discovered yet]              ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}              Use commands like 'ip route' to begin              ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                mapping the network infrastructure                ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
    echo -e "${CYAN}│${RESET}                                                                 ${CYAN}│${RESET}"
  fi
  
  echo -e "${CYAN}╰───────────────────────────────────────────────────────────────╯${RESET}"
  
  echo -e "\n${CYAN}Press any key to return to the menu...${RESET}"
  read -n 1
}

# Function to show security logs interface
show_security_logs() {
  clear
  create_header "SECURITY LOGS"
  
  # Get player tier to determine access level
  local tier=$(jq -r '.tier' "$PLAYER_PROFILE" 2>/dev/null || echo "1")
  
  if [ "$tier" -lt 2 ]; then
    echo -e "${RED}ACCESS DENIED${RESET}"
    echo -e "${YELLOW}Security logs require Tier 2 access or higher.${RESET}"
    echo -e "${GREEN}Complete more network mapping tasks to gain higher access.${RESET}"
    echo ""
    echo -e "${CYAN}Press any key to return to the menu...${RESET}"
    read -n 1
    return
  fi
  
  # Simulated security logs with blinking effect for "ANOMALY DETECTED"
  echo -e "${YELLOW}[SYSTEM] Accessing security logs... Please wait.${RESET}"
  sleep 1
  
  echo -e "\n${GREEN}=== Authentication Logs ===${RESET}"
  echo -e "${WHITE}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') LOGIN    admin       192.168.1.42    Successful${RESET}"
  echo -e "${WHITE}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') LOGOUT   admin       192.168.1.42    Successful${RESET}"
  echo -e "${RED}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') LOGIN    admin       45.33.22.156    Failed (3 attempts)${RESET}"
  echo -e "${WHITE}$(date -d "-12 hours" '+%Y-%m-%d %H:%M:%S') LOGIN    system      192.168.1.10    Successful${RESET}"
  echo -e "${WHITE}$(date -d "-6 hours" '+%Y-%m-%d %H:%M:%S') LOGIN    ${PLAYER_ID}     $(hostname -I | awk '{print $1}')    Successful${RESET}"
  
  echo -e "\n${GREEN}=== Network Events ===${RESET}"
  echo -e "${WHITE}$(date -d "-2 days" '+%Y-%m-%d %H:%M:%S') INFO     Port scan detected from 192.168.1.42${RESET}"
  echo -e "${YELLOW}$(date -d "-2 days" '+%Y-%m-%d %H:%M:%S') WARNING  Unusual outbound traffic on port 8080${RESET}"
  echo -e "${RED}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') \e[5mANOMALY DETECTED\e[0m${RESET}${RED} Data exfiltration attempt to 45.33.22.156${RESET}"
  echo -e "${YELLOW}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') WARNING  Connection from 192.168.1.42 to 45.33.22.156:443${RESET}"
  echo -e "${WHITE}$(date -d "-6 hours" '+%Y-%m-%d %H:%M:%S') INFO     System update completed${RESET}"
  
  echo -e "\n${GREEN}=== System Events ===${RESET}"
  echo -e "${WHITE}$(date -d "-3 days" '+%Y-%m-%d %H:%M:%S') INFO     Scheduled backup completed${RESET}"
  echo -e "${YELLOW}$(date -d "-2 days" '+%Y-%m-%d %H:%M:%S') WARNING  Monitoring service restarted${RESET}"
  echo -e "${RED}$(date -d "-2 days" '+%Y-%m-%d %H:%M:%S') ERROR    Missing system files detected${RESET}"
  echo -e "${WHITE}$(date -d "-1 day" '+%Y-%m-%d %H:%M:%S') INFO     File integrity check completed${RESET}"
  
  echo -e "\n${MAGENTA}NOTE:${RESET} The IP address 45.33.22.156 appears in multiple suspicious entries."
  echo -e "${MAGENTA}      This should be investigated further.${RESET}"
  
  echo -e "\n${CYAN}Press any key to return to the menu...${RESET}"
  read -n 1
}

# Main menu loop
main_menu() {
  local choice
  
  while true; do
    # Display enhanced retro-futuristic journal interface
    enhanced_journal_interface
    
    # Get user choice
    read -r choice
    
    case "$choice" in
      1) show_journal_entries ;;
      2) create_new_entry ;;
      3) show_network_map ;;
      4) show_discoveries ;;
      5) show_security_logs ;;
      6) 
        echo -e "${YELLOW}Export functionality coming soon...${RESET}"
        sleep 1
        ;;
      7)
        echo -e "${YELLOW}Import functionality coming soon...${RESET}"
        sleep 1
        ;;
      8)
        echo -e "${YELLOW}Diagnostics functionality coming soon...${RESET}"
        sleep 1
        ;;
      9)
        echo -e "${YELLOW}Search functionality coming soon...${RESET}"
        sleep 1
        ;;
      0) 
        clear
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid option.${RESET}"
        sleep 1
        ;;
    esac
  done
}

# Start the main menu
main_menu