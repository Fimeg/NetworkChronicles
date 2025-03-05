#!/bin/bash
#
# template-processor.sh - Utility script for processing templates
#
# This script loads template files and processes them to generate
# dynamic content based on discoveries.
#
# Part of Network Chronicles: The Vanishing Admin

# Import other utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/config.sh"
source "${SCRIPT_DIR}/json-helpers.sh"

# Function to process a template with variables
process_template() {
  local template_path="$1"
  local output_path="$2"
  shift 2
  local vars=("$@")  # All remaining arguments are variable assignments
  
  # Check if template exists
  if [ ! -f "$template_path" ]; then
    echo "Error: Template file not found: $template_path" >&2
    return 1
  fi
  
  # Read template
  local template=$(cat "$template_path")
  
  # Process each variable
  for var_assignment in "${vars[@]}"; do
    local var_name="${var_assignment%%=*}"
    local var_value="${var_assignment#*=}"
    
    # Replace placeholder with value
    template="${template//\{$var_name\}/$var_value}"
  done
  
  # Write processed template to output path
  if [ -n "$output_path" ]; then
    echo "$template" > "$output_path"
    return $?
  else
    # If no output path provided, print to stdout
    echo "$template"
    return 0
  fi
}

# Load a service template
get_service_template() {
  local service_type="$1"
  local template_dir="${NC_GAME_ROOT}/content/templates/services"
  
  # Look for exact match first
  if [ -f "${template_dir}/${service_type}.json" ]; then
    cat "${template_dir}/${service_type}.json"
    return 0
  fi
  
  # If not found, try to find a template that matches related_services
  for template in "${template_dir}"/*.json; do
    if [ -f "$template" ]; then
      local related=$(jq -r '.related_services | join(" ")' "$template" 2>/dev/null)
      if [[ " $related " == *" $service_type "* ]]; then
        cat "$template"
        return 0
      fi
    fi
  done
  
  # If no match found, use the unknown service template
  if [ -f "${template_dir}/unknown_service.json" ]; then
    cat "${template_dir}/unknown_service.json"
    return 0
  fi
  
  # If all else fails
  echo '{"error": "No suitable template found"}' 
  return 1
}

# Generate challenge file from template
generate_challenge() {
  local player_id="$1"
  local template_json="$2"
  local challenge_id="$3"
  shift 3
  local vars=("$@")  # Additional variables
  
  # Extract challenge from template
  local challenge_data=""
  for challenge in $(echo "$template_json" | jq -c '.challenges[]'); do
    local id=$(echo "$challenge" | jq -r '.id')
    if [ "$id" = "$challenge_id" ]; then
      challenge_data="$challenge"
      break
    fi
  done
  
  if [ -z "$challenge_data" ]; then
    echo "Error: Challenge $challenge_id not found in template" >&2
    return 1
  fi
  
  # Get target directory
  local docs_dir=$(get_player_docs_dir "$player_id")
  mkdir -p "${docs_dir}/challenges"
  
  # Get challenge details
  local title=$(echo "$challenge_data" | jq -r '.title')
  local description=$(echo "$challenge_data" | jq -r '.description')
  local tasks=$(echo "$challenge_data" | jq -r '.tasks | join("\n- ")')
  local hints=$(echo "$challenge_data" | jq -r '.hints | join("\n- ")')
  
  # Process variables
  for var_assignment in "${vars[@]}"; do
    local var_name="${var_assignment%%=*}"
    local var_value="${var_assignment#*=}"
    
    # Replace placeholders
    title="${title//\{$var_name\}/$var_value}"
    description="${description//\{$var_name\}/$var_value}"
    tasks="${tasks//\{$var_name\}/$var_value}"
    hints="${hints//\{$var_name\}/$var_value}"
  done
  
  # Create challenge file
  cat > "${docs_dir}/challenges/${challenge_id}.txt" << EOF
Mission Objective: ${title}
==========================================

${description}

TASKS:
- ${tasks}

HINTS:
- ${hints}

SECURITY LEVEL: STANDARD
ARCHITECT PRIORITY: HIGH
EOF

  return 0
}

# Generate journal entry from template
generate_journal_entry() {
  local player_id="$1"
  local template_json="$2"
  shift 2
  local vars=("$@")  # Additional variables
  
  # Get journal file
  local player_state=$(get_player_state_dir "$player_id")
  local journal_file="${player_state}/journal.json"
  
  # Check if journal exists
  if [ ! -f "$journal_file" ]; then
    echo "Error: Journal file not found for player $player_id" >&2
    return 1
  fi
  
  # Extract journal entry data from template
  local title=$(echo "$template_json" | jq -r '.narrative.journal_entry.title')
  local content=$(echo "$template_json" | jq -r '.narrative.journal_entry.content')
  local entry_id="service_discovery_$(date +%s)"
  
  # Process variables
  for var_assignment in "${vars[@]}"; do
    local var_name="${var_assignment%%=*}"
    local var_value="${var_assignment#*=}"
    
    # Replace placeholders
    title="${title//\{$var_name\}/$var_value}"
    content="${content//\{$var_name\}/$var_value}"
  done
  
  # Add entry to journal
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)
  jq ".entries += [{
    \"id\": \"$entry_id\",
    \"title\": \"$title\",
    \"content\": \"$content\",
    \"timestamp\": \"$timestamp\"
  }]" "$journal_file" > "$tmp" && mv "$tmp" "$journal_file"
  
  return $?
}

# Generate documentation from template
generate_documentation() {
  local player_id="$1"
  local service_type="$2"
  local template_json="$3"
  shift 3
  local vars=("$@")  # Additional variables
  
  # Get docs directory
  local docs_dir=$(get_player_docs_dir "$player_id")
  mkdir -p "${docs_dir}/network/services"
  
  # Extract documentation from template
  local display_name=$(echo "$template_json" | jq -r '.display_name')
  local service_details=$(echo "$template_json" | jq -r '.documentation.service_details')
  local security_considerations=$(echo "$template_json" | jq -r '.documentation.security_considerations | join("\n- ")')
  local related_commands=$(echo "$template_json" | jq -r '.documentation.related_commands | join("\n- ")')
  
  # Process variables
  for var_assignment in "${vars[@]}"; do
    local var_name="${var_assignment%%=*}"
    local var_value="${var_assignment#*=}"
    
    # Replace placeholders
    display_name="${display_name//\{$var_name\}/$var_value}"
    service_details="${service_details//\{$var_name\}/$var_value}"
    security_considerations="${security_considerations//\{$var_name\}/$var_value}"
    related_commands="${related_commands//\{$var_name\}/$var_value}"
  done
  
  # Create documentation file
  cat > "${docs_dir}/network/services/${service_type}.txt" << EOF
SERVICE DETAILS: ${display_name}
=====================================
Service Type: ${service_type}
Status: Active
Discovery Date: $(date '+%Y-%m-%d %H:%M:%S')

DESCRIPTION:
${service_details}

SECURITY CONSIDERATIONS:
- ${security_considerations}

USEFUL COMMANDS:
- ${related_commands}
EOF

  return 0
}

# Main function for direct testing
main() {
  local command="$1"
  shift
  
  case "$command" in
    process-template)
      process_template "$@"
      ;;
    get-service-template)
      get_service_template "$@"
      ;;
    generate-challenge)
      generate_challenge "$@"
      ;;
    generate-journal)
      generate_journal_entry "$@"
      ;;
    generate-docs)
      generate_documentation "$@"
      ;;
    *)
      echo "Usage: template-processor.sh <command> [arguments]"
      echo "Commands:"
      echo "  process-template <template-path> <output-path> [var1=value1 var2=value2 ...]"
      echo "  get-service-template <service-type>"
      echo "  generate-challenge <player-id> <template-json> <challenge-id> [var1=value1 ...]"
      echo "  generate-journal <player-id> <template-json> [var1=value1 ...]"
      echo "  generate-docs <player-id> <service-type> <template-json> [var1=value1 ...]"
      return 1
      ;;
  esac
  
  return $?
}

# If the script is being run directly, execute main with arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi