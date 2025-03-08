#!/bin/bash
#
# network-map.sh - Interactive network visualization that evolves with player discoveries
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"
source "${SCRIPT_DIR}/utils/json-helpers.sh"

# Process command line arguments
PLAYER_ID="$1"
if [ -z "$PLAYER_ID" ]; then
  PLAYER_ID=$(whoami)
fi

# Get player directories using config utilities
PLAYER_STATE=$(get_player_state_dir "$PLAYER_ID")
MAP_DIR="${PLAYER_STATE}/network_map"

# Ensure player documents directory exists
ensure_player_documents "$PLAYER_ID"

# Ensure map directory exists
mkdir -p "${MAP_DIR}"

# Terminal colors
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
MAGENTA="\033[35m"

# Get player discoveries from profile
PLAYER_PROFILE=$(get_player_profile "$PLAYER_ID")
if [ -f "$PLAYER_PROFILE" ]; then
  # Get discoveries as space-separated list
  DISCOVERIES=$(json_get_value "$PLAYER_PROFILE" '.discoveries | join(" ")')
else
  # Fallback to mock data for demo if profile not found
  DISCOVERIES="network_gateway local_network monitoring_service"
  echo "Warning: Player profile not found, using demo data." >&2
fi

# Generate network map based on discoveries
function generate_network_map() {
  # Initialize map
  local updated_map=""
  
  # Header
  updated_map+="┌─────────────────────────────────────────────────────────────────────────┐\n"
  updated_map+="│                                                                         │\n"
  updated_map+="│                        NETWORK INFRASTRUCTURE MAP                       │\n"
  updated_map+="│                                                                         │\n"
  
  # Check for gateway discovery
  if [[ "$DISCOVERIES" == *"network_gateway"* ]]; then
    updated_map+="│                            ┌──────────────┐                           │\n"
    updated_map+="│                            │   Internet    │                           │\n"
    updated_map+="│                            └───────┬──────┘                           │\n"
    updated_map+="│                                    │                                  │\n"
    updated_map+="│                            ┌───────┴──────┐                           │\n"
    updated_map+="│                            │   Gateway    │                           │\n"
    updated_map+="│                            │  192.168.1.1  │                           │\n"
    updated_map+="│                            └───────┬──────┘                           │\n"
    updated_map+="│                                    │                                  │\n"
  else
    updated_map+="│                                                                       │\n"
    updated_map+="│                     [Network gateway not yet discovered]              │\n"
    updated_map+="│                                                                       │\n"
  fi
  
  # Check for local network discovery
  if [[ "$DISCOVERIES" == *"local_network"* ]]; then
    updated_map+="│                            ┌───────┴──────┐                           │\n"
    updated_map+="│                            │  Local Net   │                           │\n"
    updated_map+="│                            │ 192.168.1.0/24│                          │\n"
    updated_map+="│                            └──┬───┬───┬───┘                           │\n"
    updated_map+="│                               │   │   │                               │\n"
    updated_map+="│                               │   │   │                               │\n"
  else
    updated_map+="│                                    │                                  │\n"
    updated_map+="│                     [Local network not yet mapped]                    │\n"
    updated_map+="│                                                                       │\n"
  fi
  
  # Check for monitoring service discovery
  if [[ "$DISCOVERIES" == *"monitoring_service"* ]]; then
    updated_map+="│                               │   │   │                               │\n"
    updated_map+="│                               │   │   │                               │\n"
    updated_map+="│                               │   │   └───────────────┐              │\n"
    updated_map+="│                               │   │                   │              │\n"
    updated_map+="│                               │   │                ┌──┴───────┐      │\n"
    updated_map+="│                               │   │                │ Monitor  │      │\n"
    updated_map+="│                               │   │                │192.168.1.42│      │\n"
    updated_map+="│                               │   │                └──────────┘      │\n"
  fi
  
  # Check for web server discovery
  if [[ "$DISCOVERIES" == *"service_http"* || "$DISCOVERIES" == *"service_https"* || "$DISCOVERIES" == *"service_nginx"* || "$DISCOVERIES" == *"service_apache"* ]]; then
    if [[ "$DISCOVERIES" != *"monitoring_service"* ]]; then
      # If monitoring service isn't discovered, add some spacing
      updated_map+="│                               │   │                                 │\n"
      updated_map+="│                               │   │                                 │\n"
    fi
    updated_map+="│                               │   └─────────┐                       │\n"
    updated_map+="│                               │             │                       │\n"
    updated_map+="│                               │          ┌──┴───────┐               │\n"
    updated_map+="│                               │          │Web Server│               │\n"
    updated_map+="│                               │          │  HTTP(S) │               │\n"
    updated_map+="│                               │          └──────────┘               │\n"
  fi
  
  # Check for database service discovery
  if [[ "$DISCOVERIES" == *"service_mysql"* || "$DISCOVERIES" == *"service_postgresql"* || "$DISCOVERIES" == *"service_mongodb"* ]]; then
    updated_map+="│                            ┌──┴──┐                                  │\n"
    updated_map+="│                            │     │                                  │\n"
    updated_map+="│                            │  ┌──┴───────┐                          │\n"
    updated_map+="│                            │  │ Database │                          │\n"
    updated_map+="│                            │  │  Server  │                          │\n"
    updated_map+="│                            │  └──────────┘                          │\n"
  fi
  
  # Check for custom/unknown services
  has_unknown=false
  for discovery in $DISCOVERIES; do
    if [[ "$discovery" == *"service_unknown"* ]]; then
      has_unknown=true
      break
    fi
  done
  
  if $has_unknown; then
    updated_map+="│                                                                     │\n"
    updated_map+="│                      ┌────────────────────────┐                     │\n"
    updated_map+="│                      │ ${RED}Unknown Service(s)${RESET}    │                     │\n"
    updated_map+="│                      │ ${RED}Non-standard Ports${RESET}    │                     │\n"
    updated_map+="│                      └────────────────────────┘                     │\n"
  fi
  
  # Check for unusual traffic discovery
  if [[ "$DISCOVERIES" == *"unusual_traffic"* ]]; then
    updated_map+="│                               │   │                       ↑          │\n"
    updated_map+="│                               │   │                       :          │\n"
    updated_map+="│                               │   │                       :          │\n"
    updated_map+="│                               │   │         ┌─────────────┴─────┐    │\n"
    updated_map+="│                               │   │         │  External Attacker │    │\n"
    updated_map+="│                               │   │         │    45.33.22.156    │    │\n"
    updated_map+="│                               │   │         └───────────────────┘    │\n"
  fi
  
  # Footer
  updated_map+="│                                                                         │\n"
  updated_map+="└─────────────────────────────────────────────────────────────────────────┘\n"
  
  # Return the map
  echo -e "$updated_map"
}

# Display the network map
clear
echo -e "${BOLD}${CYAN}NETWORK INFRASTRUCTURE MAP${RESET}\n"

# Get player tier
if [ -f "$PLAYER_PROFILE" ]; then
  TIER=$(json_get_value "$PLAYER_PROFILE" '.tier')
else
  TIER=1
fi

echo -e "Access Level: Tier ${TIER} - $(date '+%Y-%m-%d %H:%M:%S')\n"

# Generate and display the map
generate_network_map

# Display legend based on discoveries
echo -e "\n${BOLD}LEGEND:${RESET}"
if [[ "$DISCOVERIES" == *"network_gateway"* ]]; then
  echo -e "  Gateway: Main connection to external networks"
fi
if [[ "$DISCOVERIES" == *"local_network"* ]]; then
  echo -e "  Local Network: Internal network segment (192.168.1.0/24)"
fi
if [[ "$DISCOVERIES" == *"monitoring_service"* ]]; then
  echo -e "  Monitoring Service: System monitoring and logging (192.168.1.42:8080)"
fi

# Web server services
if [[ "$DISCOVERIES" == *"service_http"* || "$DISCOVERIES" == *"service_https"* || "$DISCOVERIES" == *"service_nginx"* || "$DISCOVERIES" == *"service_apache"* ]]; then
  echo -e "  Web Server: HTTP/HTTPS service for hosting web content"
fi

# Database services
if [[ "$DISCOVERIES" == *"service_mysql"* ]]; then
  echo -e "  MySQL Database: Relational database service"
fi
if [[ "$DISCOVERIES" == *"service_postgresql"* ]]; then
  echo -e "  PostgreSQL Database: Advanced relational database service"
fi
if [[ "$DISCOVERIES" == *"service_mongodb"* ]]; then
  echo -e "  MongoDB Database: NoSQL document database service"
fi

# Unknown services
has_unknown=false
for discovery in $DISCOVERIES; do
  if [[ "$discovery" == *"service_unknown"* ]]; then
    port="${discovery#service_unknown_}"
    echo -e "  ${RED}Unknown Service:${RESET} Unidentified service on port $port"
    has_unknown=true
  fi
done

if [[ "$DISCOVERIES" == *"unusual_traffic"* ]]; then
  echo -e "  ${RED}Suspicious Traffic:${RESET} Unauthorized access attempts from 45.33.22.156"
fi

# Display discovery status
echo -e "\n${BOLD}DISCOVERY STATUS:${RESET}"

# Get total number of possible discoveries
if [ -f "$PLAYER_PROFILE" ]; then
  # In a real implementation, we might want to determine this from the content directory
  TOTAL_DISCOVERIES=12
else
  # For demo mode
  TOTAL_DISCOVERIES=12
fi

# Count actual discoveries
DISCOVERY_COUNT=$(echo "$DISCOVERIES" | wc -w)

echo -e "  Network Components Discovered: ${DISCOVERY_COUNT}/${TOTAL_DISCOVERIES}"

# Add a progress bar for discovery progress
PROGRESS_PERCENT=$((DISCOVERY_COUNT * 100 / TOTAL_DISCOVERIES))
PROGRESS_BAR=""
for ((i=0; i<20; i++)); do
  if [ $((i * 5)) -lt $PROGRESS_PERCENT ]; then
    PROGRESS_BAR="${PROGRESS_BAR}█"
  else
    PROGRESS_BAR="${PROGRESS_BAR}░"
  fi
done

echo -e "  Progress: [${PROGRESS_BAR}] ${PROGRESS_PERCENT}%"

# Display navigation options
echo -e "\n${BOLD}OPTIONS:${RESET}"
echo -e "  1) Export map to documentation"
echo -e "  2) View detailed component information"
echo -e "  0) Return to main menu"

echo -e "\nEnter your choice: "
read -r choice

case $choice in
  1)
    # Export map to documentation
    DOCS_DIR=$(get_player_docs_dir "$PLAYER_ID")
    MAP_FILE="${DOCS_DIR}/network_map.txt"
    
    # Generate map and save to file
    generate_network_map > "$MAP_FILE"
    
    echo -e "\n${GREEN}Map exported to documentation at:${RESET}"
    echo -e "${MAP_FILE}"
    sleep 2
    ;;
    
  2)
    # View detailed component information
    echo -e "\n${YELLOW}Component information:${RESET}"
    
    # Simple implementation - in a real version, this would show more details
    echo -e "${BOLD}Discovered components:${RESET}"
    for component in $DISCOVERIES; do
      echo -e "  - ${component}"
    done
    
    echo -e "\nPress any key to continue..."
    read -n 1
    ;;
    
  *)
    # Default - just exit
    ;;
esac

echo -e "\nExiting network map viewer."
exit 0

