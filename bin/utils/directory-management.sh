#!/bin/bash
# Utility script to manage common directory operations

# Configuration
GAME_ROOT="/opt/network-chronicles"
DATA_DIR="${GAME_ROOT}/data"
PLAYER_DIR="${DATA_DIR}/players"
DEFAULT_PLAYER="player"

# Ensure player documents directory exists and is properly configured
ensure_player_documents() {
  local player_id="${1:-${DEFAULT_PLAYER}}"
  local player_state="${PLAYER_DIR}/${player_id}"
  local docs_dir="${player_state}/Documents"
  
  # Create directories if they don't exist
  if [ ! -d "$player_state" ]; then
    mkdir -p "$player_state"
    # Set directory permissions to be fully accessible
    chmod 777 "$player_state"
    echo "Created player directory at $player_state"
  fi
  
  if [ ! -d "$docs_dir" ]; then
    mkdir -p "$docs_dir"
    # Set Documents directory to be fully accessible
    chmod 777 "$docs_dir"
    echo "Created Documents folder at $docs_dir"
    
    # Create a README file in the Documents folder
    cat > "${docs_dir}/README.txt" << EOF
This is your Documents folder where you can store important files and notes.
Feel free to use this space to organize your findings as you explore the Network Chronicles.
EOF
    # Make README readable by all
    chmod 644 "${docs_dir}/README.txt"
    
    echo "Added README.txt to Documents folder"
  fi
  
  # Ensure proper permissions on all files and directories
  find "$player_state" -type d -exec chmod 777 {} \; 2>/dev/null
  find "$player_state" -name "*.json" -exec chmod 666 {} \; 2>/dev/null
  find "$player_state" -type f -not -name "*.json" -exec chmod 644 {} \; 2>/dev/null
  
  echo "Set permissions on player directory"
  
  # Try to setup home Documents directory if it exists
  if [ -d "/home/${player_id}" ]; then
    mkdir -p "/home/${player_id}/Documents" 2>/dev/null
    chown -R "${player_id}:${player_id}" "/home/${player_id}/Documents" 2>/dev/null || true
    chmod 755 "/home/${player_id}/Documents" 2>/dev/null || true
  fi
  
  return 0
}

# Function to ensure all required game directories exist
ensure_game_directories() {
  # Core directories
  mkdir -p "${GAME_ROOT}/bin"
  mkdir -p "${GAME_ROOT}/data/players"
  mkdir -p "${GAME_ROOT}/logs"
  
  # Content directories
  mkdir -p "${GAME_ROOT}/content/artifacts"
  mkdir -p "${GAME_ROOT}/content/challenges"
  mkdir -p "${GAME_ROOT}/content/discoveries"
  mkdir -p "${GAME_ROOT}/content/events"
  mkdir -p "${GAME_ROOT}/content/triggers"
  mkdir -p "${GAME_ROOT}/content/narrative/quests"
  
  # Set proper permissions on critical directories
  chmod -R 777 "${GAME_ROOT}/data"
  chmod -R 777 "${GAME_ROOT}/logs"
  chmod -R 755 "${GAME_ROOT}/bin"
  chmod -R 755 "${GAME_ROOT}/content"
  
  echo "Created required game directories with proper permissions"
  
  return 0
}

# If script is executed directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Network Chronicles Directory Management Utility"
  echo "Usage: source $(basename ${BASH_SOURCE[0]}) - then use the functions"
  echo "Functions:"
  echo "  ensure_player_documents [player_id] - Ensure player documents directory exists"
  echo "  ensure_game_directories - Ensure all required game directories exist"
  exit 0
fi