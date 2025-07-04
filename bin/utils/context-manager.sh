#!/bin/bash
#
# context-manager.sh - Utility script for gathering context for LLM interactions
#
# Part of Network Chronicles: The Vanishing Admin

# Ensure json-helpers and directory-management are available
UTILS_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${UTILS_DIR}/config.sh" # Load NC_GAME_ROOT
source "${UTILS_DIR}/directory-management.sh"
source "${UTILS_DIR}/json-helpers.sh"

# Log function (simplified for utility script)
_cm_log() {
  # Basic logging, could be enhanced later if needed
  echo "[ContextManager] $1" >&2
}

# Get basic player stats (Tier, XP)
get_player_stats_context() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")
  
  if [ ! -f "$player_profile" ]; then
    _cm_log "ERROR: Player profile not found for context: $player_id"
    return 1
  fi
  
  local tier=$(json_get_value "$player_profile" ".tier // 1")
  local xp=$(json_get_value "$player_profile" ".xp // 0")
  
  echo "Player Tier: $tier"
  echo "Player XP: $xp"
}

# Get current quest context
get_current_quest_context() {
  local player_id="$1"
  local player_profile=$(get_player_profile "$player_id")

  if [ ! -f "$player_profile" ]; then
    _cm_log "ERROR: Player profile not found for context: $player_id"
    return 1
  fi

  local current_quest=$(json_get_value "$player_profile" ".quests.current // \"None\"")
  
  if [ "$current_quest" != "None" ] && [ "$current_quest" != "null" ]; then
    echo "Current Quest ID: $current_quest"
    # Optionally, fetch quest name/description from content files
    local quest_file="${NC_GAME_ROOT}/content/narrative/quests/${current_quest}.json"
    if [ -f "$quest_file" ]; then
       local quest_name=$(json_get_value "$quest_file" ".name // \"Unknown Quest\"")
       echo "Current Quest Name: $quest_name"
    fi
  else
    echo "Current Quest: None"
  fi
}

# Get recent discoveries context
get_discoveries_context() {
  local player_id="$1"
  local count=${2:-5} # Default to last 5 discoveries
  local player_profile=$(get_player_profile "$player_id")

  if [ ! -f "$player_profile" ]; then
    _cm_log "ERROR: Player profile not found for context: $player_id"
    return 1
  fi

  local discoveries=$(jq -r ".discoveries[-${count}:] | join(\", \")" "$player_profile")
  
  if [ -n "$discoveries" ] && [ "$discoveries" != "null" ]; then
     echo "Recent Discoveries (last $count): $discoveries"
  else
     echo "Recent Discoveries: None"
  fi
}

# Get story flags context
get_story_flags_context() {
    local player_id="$1"
    local player_profile=$(get_player_profile "$player_id")

    if [ ! -f "$player_profile" ]; then
        _cm_log "ERROR: Player profile not found for context: $player_id"
        return 1
    fi

    local flags=$(jq -r '.story_flags | to_entries | map(select(.value == true) | .key) | join(", ")' "$player_profile")

    if [ -n "$flags" ] && [ "$flags" != "null" ]; then
        echo "Triggered Story Flags: $flags"
    else
        echo "Triggered Story Flags: None"
    fi
}


# Main function to assemble context (Example usage)
assemble_full_context() {
  local player_id="$1"
  
  _cm_log "Assembling context for player: $player_id"
  
  echo "--- Player Context Start ---"
  get_player_stats_context "$player_id"
  get_current_quest_context "$player_id"
  get_discoveries_context "$player_id" 5 # Get last 5 discoveries
  get_story_flags_context "$player_id"
  # Add calls to other context functions here (e.g., recent journal entries, inventory)
  echo "--- Player Context End ---"
}

# Example of how this script might be called:
# ./bin/utils/context-manager.sh assemble_context <player_id>

# Allow calling functions directly if needed
if declare -f "$1" > /dev/null; then
  "$@"
fi
