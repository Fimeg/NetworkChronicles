#!/bin/bash
#
# context-manager.sh - Utility for managing context for LLM interactions
#
# Gathers player state, progress, and game information to provide
# context for LLM-based interactions.
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/json-helpers.sh"
source "${SCRIPT_DIR}/directory-management.sh"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'
BOLD='\033[1m'

# Function to log messages
log_message() {
  local level="$1"
  local message="$2"
  
  case "$level" in
    "INFO")
      echo -e "[${CYAN}INFO${RESET}] $message"
      ;;
    "WARNING")
      echo -e "[${YELLOW}WARNING${RESET}] $message"
      ;;
    "ERROR")
      echo -e "[${RED}ERROR${RESET}] $message"
      ;;
    "SUCCESS")
      echo -e "[${GREEN}SUCCESS${RESET}] $message"
      ;;
    *)
      echo -e "$message"
      ;;
  esac
}

# Get player profile information
get_player_context() {
  local player_id="$1"
  local profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$profile" ]; then
    log_message "ERROR" "Player profile not found for $player_id"
    return 1
  fi
  
  # Extract key information from player profile
  local tier=$(json_get_value "$profile" '.tier')
  local xp=$(json_get_value "$profile" '.xp')
  local current_quest=$(json_get_value "$profile" '.quests.current')
  local completed_quests=$(json_get_value "$profile" '.quests.completed | join(", ")')
  local discoveries=$(json_get_value "$profile" '.discoveries | join(", ")')
  
  # Format as a JSON object for easy parsing later
  cat << EOF
{
  "player_info": {
    "id": "$player_id",
    "tier": $tier,
    "xp": $xp,
    "current_quest": "$current_quest",
    "completed_quests": [$completed_quests],
    "discoveries": [$discoveries]
  }
}
EOF
  
  return 0
}

# Get recent journal entries
get_journal_context() {
  local player_id="$1"
  local max_entries="${2:-3}"  # Default to 3 recent entries
  local player_state=$(get_player_state_dir "$player_id")
  local journal_file="${player_state}/journal.json"
  
  if [ ! -f "$journal_file" ]; then
    log_message "ERROR" "Journal file not found for $player_id"
    return 1
  fi
  
  # Get the most recent entries
  local entries=$(jq -c ".entries | sort_by(.timestamp) | reverse | .[0:$max_entries]" "$journal_file")
  
  # Format as JSON for easier parsing
  cat << EOF
{
  "recent_journal_entries": $entries
}
EOF
  
  return 0
}

# Get current game state information
get_game_state_context() {
  local player_id="$1"
  local quest_id=$(json_get_value "$(get_player_profile "$player_id")" '.quests.current')
  local quest_file="${NC_GAME_ROOT}/content/narrative/quests/${quest_id}.json"
  
  # Get quest information if file exists
  local quest_info="{}"
  if [ -f "$quest_file" ]; then
    quest_info=$(cat "$quest_file")
  fi
  
  # Format as JSON
  cat << EOF
{
  "current_game_state": {
    "quest_info": $quest_info,
    "game_time": "$(date '+%Y-%m-%d %H:%M:%S')"
  }
}
EOF
  
  return 0
}

# Get context about recent discoveries
get_discovery_context() {
  local player_id="$1"
  local profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$profile" ]; then
    log_message "ERROR" "Player profile not found for $player_id"
    return 1
  fi
  
  # Get recent discoveries (up to 5)
  local recent_discoveries=$(json_get_value "$profile" '.discoveries | sort | reverse | .[0:5] | join(", ")')
  
  # Get info about each discovery
  local discovery_info="[]"
  for discovery in $(json_get_value "$profile" '.discoveries[]' | tr -d '"'); do
    local discovery_file="${NC_GAME_ROOT}/content/discoveries/${discovery}.json"
    if [ -f "$discovery_file" ]; then
      # Get basic info about the discovery
      local name=$(json_get_value "$discovery_file" '.name')
      local description=$(json_get_value "$discovery_file" '.description')
      
      # Append to discovery info
      discovery_info=$(echo "$discovery_info" | jq ". += [{\"id\": \"$discovery\", \"name\": \"$name\", \"description\": \"$description\"}]")
    fi
  done
  
  # Format as JSON
  cat << EOF
{
  "discovery_context": {
    "recent_discoveries": [$recent_discoveries],
    "discovery_details": $discovery_info
  }
}
EOF
  
  return 0
}

# Get conversation history with The Architect
get_conversation_history() {
  local player_id="$1"
  local max_history="${2:-5}"  # Default to 5 recent messages
  local player_state=$(get_player_state_dir "$player_id")
  local history_file="${player_state}/architect_conversation.json"
  
  # Create empty history if it doesn't exist
  if [ ! -f "$history_file" ]; then
    echo '{"messages":[]}' > "$history_file"
    chmod 666 "$history_file"
  fi
  
  # Get the last N messages
  local messages=$(jq -c ".messages | sort_by(.timestamp) | reverse | .[0:$max_history] | reverse" "$history_file")
  
  # Format as JSON
  cat << EOF
{
  "conversation_history": $messages
}
EOF
  
  return 0
}

# Add a message to conversation history
add_to_conversation_history() {
  local player_id="$1"
  local role="$2"      # "user" or "assistant"
  local content="$3"
  local player_state=$(get_player_state_dir "$player_id")
  local history_file="${player_state}/architect_conversation.json"
  
  # Create player state directory if it doesn't exist
  if [ ! -d "$player_state" ]; then
    mkdir -p "$player_state"
    chmod 777 "$player_state"
  fi
  
  # Create empty history if it doesn't exist
  if [ ! -f "$history_file" ]; then
    echo '{"messages":[]}' > "$history_file"
    chmod 666 "$history_file"
  fi
  
  # Add message to history
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)
  jq ".messages += [{\"role\": \"$role\", \"content\": \"$content\", \"timestamp\": \"$timestamp\"}]" "$history_file" > "$tmp" && mv "$tmp" "$history_file"
  chmod 666 "$history_file"
  
  return 0
}

# Get full context for The Architect
get_architect_context() {
  local player_id="$1"
  
  # Get all context components
  local player_context=$(get_player_context "$player_id")
  local journal_context=$(get_journal_context "$player_id")
  local game_state_context=$(get_game_state_context "$player_id")
  local discovery_context=$(get_discovery_context "$player_id")
  local conversation_history=$(get_conversation_history "$player_id")
  
  # Combine all context elements
  jq -s 'reduce .[] as $item ({}; . * $item)' \
    <(echo "$player_context") \
    <(echo "$journal_context") \
    <(echo "$game_state_context") \
    <(echo "$discovery_context") \
    <(echo "$conversation_history")
  
  return 0
}

# Main function for direct testing
main() {
  local command="$1"
  shift
  
  case "$command" in
    player-context)
      get_player_context "$@"
      ;;
    journal-context)
      get_journal_context "$@"
      ;;
    game-state)
      get_game_state_context "$@"
      ;;
    discovery-context)
      get_discovery_context "$@"
      ;;
    conversation-history)
      get_conversation_history "$@"
      ;;
    add-message)
      add_to_conversation_history "$@"
      ;;
    full-context)
      get_architect_context "$@"
      ;;
    *)
      echo "Usage: context-manager.sh <command> [arguments]"
      echo "Commands:"
      echo "  player-context <player-id> - Get basic player information"
      echo "  journal-context <player-id> [max-entries] - Get recent journal entries"
      echo "  game-state <player-id> - Get current game state"
      echo "  discovery-context <player-id> - Get information about discoveries"
      echo "  conversation-history <player-id> [max-history] - Get conversation history"
      echo "  add-message <player-id> <role> <content> - Add message to conversation history"
      echo "  full-context <player-id> - Get complete context for The Architect"
      return 1
      ;;
  esac
  
  return $?
}

# If the script is being run directly, execute main with arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi