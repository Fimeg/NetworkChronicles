#!/bin/bash
# JSON helper utilities for Network Chronicles

# Import configuration
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

# Update a JSON field with a new value
# Usage: json_update_field [file] [jq_filter] [value]
json_update_field() {
  local file="$1"
  local filter="$2"
  local value="$3"
  
  if [ ! -f "$file" ]; then
    echo "Error: Cannot update JSON field - file does not exist: $file" >&2
    return 1
  fi
  
  tmp=$(mktemp)
  if ! jq "$filter = $value" "$file" > "$tmp"; then
    echo "Error: Failed to update JSON field with jq" >&2
    rm -f "$tmp"
    return 1
  fi
  
  mv "$tmp" "$file"
  # Ensure world readable/writable permissions for JSON files
  chmod 666 "$file"
  return 0
}

# Get a value from a JSON field
# Usage: json_get_value [file] [jq_filter]
json_get_value() {
  local file="$1"
  local filter="$2"
  
  if [ ! -f "$file" ]; then
    echo "Error: Cannot get JSON value - file does not exist: $file" >&2
    return 1
  fi
  
  local value
  value=$(jq -r "$filter" "$file")
  echo "$value"
  return 0
}

# Add an item to a JSON array
# Usage: json_add_to_array [file] [array_path] [value]
json_add_to_array() {
  local file="$1"
  local array_path="$2"
  local value="$3"
  
  if [ ! -f "$file" ]; then
    echo "Error: Cannot add to JSON array - file does not exist: $file" >&2
    return 1
  fi
  
  tmp=$(mktemp)
  if ! jq "$array_path += [$value]" "$file" > "$tmp"; then
    echo "Error: Failed to add to JSON array with jq" >&2
    rm -f "$tmp"
    return 1
  fi
  
  mv "$tmp" "$file"
  # Ensure world readable/writable permissions for JSON files
  chmod 666 "$file"
  return 0
}

# Create a player notification
# Usage: add_player_notification [player_id] [message]
add_player_notification() {
  local player_id="$1"
  local message="$2"
  local timestamp=$(date -Iseconds)
  local player_state=$(get_player_state_dir "$player_id")
  local notifications_file="${player_state}/notifications.json"
  
  # Initialize notifications file if it doesn't exist
  if [ ! -f "$notifications_file" ]; then
    echo '{"notifications":[]}' > "$notifications_file"
    # Ensure world readable/writable permissions
    chmod 666 "$notifications_file"
  fi
  
  # Add the notification
  tmp=$(mktemp)
  jq ".notifications += [{\"message\": \"$message\", \"timestamp\": \"$timestamp\", \"read\": false}]" \
    "$notifications_file" > "$tmp" && mv "$tmp" "$notifications_file"
  # Ensure world readable/writable permissions
  chmod 666 "$notifications_file"
    
  # Display notification immediately if terminal is interactive
  if [ -t 1 ]; then
    echo -e "\n$message"
  fi
  
  return 0
}

# If script is executed directly, show usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Network Chronicles JSON Helper Utilities"
  echo "Usage: source $(basename ${BASH_SOURCE[0]}) - then use the functions"
  exit 0
fi