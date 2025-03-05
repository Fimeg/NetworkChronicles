#!/bin/bash
# Central configuration for Network Chronicles

# Base paths
export NC_GAME_ROOT="/opt/network-chronicles"
export NC_DATA_DIR="${NC_GAME_ROOT}/data"
export NC_PLAYER_DIR="${NC_DATA_DIR}/players"
export NC_LOG_DIR="${NC_GAME_ROOT}/logs"
export NC_CONTENT_DIR="${NC_GAME_ROOT}/content"
export NC_STORY_DIR="${NC_CONTENT_DIR}/narrative"

# Player data functions
get_player_state_dir() {
  local player_id="${1:-player}"
  echo "${NC_PLAYER_DIR}/${player_id}"
}

get_player_docs_dir() {
  local player_id="${1:-player}"
  local player_state=$(get_player_state_dir "$player_id")
  echo "${player_state}/Documents"
}

get_player_journal_dir() {
  local player_id="${1:-player}"
  local player_state=$(get_player_state_dir "$player_id")
  echo "${player_state}/journal"
}

get_player_profile() {
  local player_id="${1:-player}"
  local player_state=$(get_player_state_dir "$player_id")
  echo "${player_state}/profile.json"
}

# If script is executed directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Network Chronicles Configuration Module"
  echo "Usage: source $(basename ${BASH_SOURCE[0]}) - then use the variables and functions"
  exit 0
fi