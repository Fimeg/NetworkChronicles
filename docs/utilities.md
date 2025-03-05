# Network Chronicles Utility Functions

This document provides detailed information about the utility functions available in Network Chronicles for managing player data, directories, and game state.

## Directory Management Utilities

Located in `/bin/utils/directory-management.sh`, these functions handle the creation and management of directories used by the game.

### ensure_player_documents

Ensures that the player's Documents directory exists and is properly configured.

```bash
# Usage
ensure_player_documents [player_id]

# Example
ensure_player_documents "player"
```

### ensure_game_directories

Creates all required game directories for a new installation.

```bash
# Usage
ensure_game_directories

# Example
ensure_game_directories
```

## Configuration Utilities

Located in `/bin/utils/config.sh`, these functions provide standardized paths and configuration values for the game.

### Path Variables

```bash
# Game root directory
NC_GAME_ROOT="/opt/network-chronicles"

# Data directories
NC_DATA_DIR="${NC_GAME_ROOT}/data"
NC_PLAYER_DIR="${NC_DATA_DIR}/players"
NC_LOG_DIR="${NC_GAME_ROOT}/logs"

# Content directories
NC_CONTENT_DIR="${NC_GAME_ROOT}/content"
NC_STORY_DIR="${NC_CONTENT_DIR}/narrative"
```

### Player Directory Functions

```bash
# Get the player state directory path
get_player_state_dir [player_id]

# Get the player Documents directory path
get_player_docs_dir [player_id]

# Get the player journal directory path
get_player_journal_dir [player_id]

# Get the player profile JSON file path
get_player_profile [player_id]

# Examples
player_dir=$(get_player_state_dir "player")
docs_dir=$(get_player_docs_dir "player")
journal_dir=$(get_player_journal_dir "player")
profile_path=$(get_player_profile "player")
```

## JSON Helper Utilities

Located in `/bin/utils/json-helpers.sh`, these functions provide standardized methods for working with JSON data.

### json_update_field

Updates a field in a JSON file with a new value.

```bash
# Usage
json_update_field [file_path] [jq_filter] [value]

# Example
json_update_field "$profile_path" ".tier" "2"
json_update_field "$profile_path" ".xp" "(.xp + 100)"
```

### json_get_value

Retrieves a value from a JSON file using a jq filter.

```bash
# Usage
json_get_value [file_path] [jq_filter]

# Example
tier=$(json_get_value "$profile_path" ".tier")
discoveries=$(json_get_value "$profile_path" ".discoveries[]")
```

### json_add_to_array

Adds an item to an array in a JSON file.

```bash
# Usage
json_add_to_array [file_path] [array_path] [value]

# Example
json_add_to_array "$profile_path" ".discoveries" "\"new_discovery\""
json_add_to_array "$journal_path" ".entries" "{\"id\": \"entry1\", \"title\": \"New Entry\", \"content\": \"Content here\", \"timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"}"
```

### add_player_notification

Adds a notification to the player's notification queue.

```bash
# Usage
add_player_notification [player_id] [message]

# Example
add_player_notification "player" "You discovered a new item!"
```

## Best Practices for Using Utilities

1. **Always use utility functions for directory operations**
   Instead of hardcoding paths or creating directories directly, use the provided utility functions:

   ```bash
   # Don't do this:
   mkdir -p "/opt/network-chronicles/data/players/player/Documents"

   # Do this instead:
   ensure_player_documents "player"
   ```

2. **Use configuration functions for path references**
   Instead of hardcoding paths, use the configuration functions:

   ```bash
   # Don't do this:
   profile_path="/opt/network-chronicles/data/players/${player_id}/profile.json"

   # Do this instead:
   profile_path=$(get_player_profile "$player_id")
   ```

3. **Use JSON helpers for all JSON operations**
   For consistency and error handling, use the JSON helper functions:

   ```bash
   # Don't do this:
   tier=$(jq -r '.tier' "$profile_path")
   tmp=$(mktemp)
   jq ".tier = 2" "$profile_path" > "$tmp" && mv "$tmp" "$profile_path"

   # Do this instead:
   tier=$(json_get_value "$profile_path" ".tier")
   json_update_field "$profile_path" ".tier" "2"
   ```

4. **Always source utility scripts in every script**
   Make sure to include the utility scripts at the beginning of each script:

   ```bash
   #!/bin/bash
   #
   # my-script.sh - Description
   #
   # Part of Network Chronicles: The Vanishing Admin

   # Import utilities
   SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
   source "${SCRIPT_DIR}/utils/config.sh"
   source "${SCRIPT_DIR}/utils/directory-management.sh"
   source "${SCRIPT_DIR}/utils/json-helpers.sh"
   ```

## Extending the Utilities

When adding new functionality, consider if it belongs in one of the existing utility files or if a new utility file is needed. If you create a new utility file, follow these guidelines:

1. Use the script template as a starting point
2. Add proper documentation and usage examples
3. Include error handling for all operations
4. Update this document with information about the new utilities

## Troubleshooting

If you encounter problems with the utility functions, check the following:

1. Ensure all utility scripts have execute permissions:
   ```bash
   chmod +x /opt/network-chronicles/bin/utils/*.sh
   ```

2. Check that the scripts are being sourced properly:
   ```bash
   # The correct way to import utilities
   SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
   source "${SCRIPT_DIR}/utils/config.sh"
   ```

3. Check for proper variable definitions:
   ```bash
   # Make sure NC_GAME_ROOT is set correctly
   echo $NC_GAME_ROOT
   ```

4. Verify that jq is installed:
   ```bash
   which jq
   ```