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

# Define common services (copied from service-discovery.sh)
declare -A SERVICE_PORTS=(
  ["http"]="80" ["https"]="443" ["ssh"]="22" ["ftp"]="21" ["mysql"]="3306"
  ["postgresql"]="5432" ["mongodb"]="27017" ["redis"]="6379" ["elasticsearch"]="9200"
  ["nginx"]="80 443" ["apache"]="80 443" ["tomcat"]="8080" ["jenkins"]="8080"
  ["prometheus"]="9090" ["grafana"]="3000" ["docker-registry"]="5000"
  ["kubernetes-api"]="6443" ["kubernetes-dashboard"]="8443" ["etcd"]="2379"
  ["rabbitmq"]="5672 15672" ["smtp"]="25" ["dns"]="53" ["ldap"]="389" ["dhcp"]="67 68"
)
declare -A SERVICE_DISPLAY_NAMES=(
  ["http"]="HTTP Web" ["https"]="HTTPS Web" ["ssh"]="SSH" ["ftp"]="FTP" ["mysql"]="MySQL DB"
  ["postgresql"]="PostgreSQL" ["mongodb"]="MongoDB" ["redis"]="Redis" ["elasticsearch"]="Elasticsearch"
  ["nginx"]="Nginx" ["apache"]="Apache" ["tomcat"]="Tomcat" ["jenkins"]="Jenkins"
  ["prometheus"]="Prometheus" ["grafana"]="Grafana" ["docker-registry"]="Docker Reg"
  ["kubernetes-api"]="K8s API" ["kubernetes-dashboard"]="K8s Dash" ["etcd"]="etcd"
  ["rabbitmq"]="RabbitMQ" ["smtp"]="SMTP" ["dns"]="DNS" ["ldap"]="LDAP" ["dhcp"]="DHCP"
)


# Get player discoveries from profile (still used for non-service elements like unusual_traffic)
PLAYER_PROFILE=$(get_player_profile "$PLAYER_ID")
if [ -f "$PLAYER_PROFILE" ]; then
  # Get discoveries as space-separated list
  DISCOVERIES=$(json_get_value "$PLAYER_PROFILE" '.discoveries | join(" ")')
else
  # Fallback to mock data for demo if profile not found
  DISCOVERIES="network_gateway local_network monitoring_service" # Example flags
  echo "Warning: Player profile not found, using demo data for non-live elements." >&2
fi

# Generate network map based on discoveries and live data
function generate_network_map() {
  # Initialize map
  local updated_map=""

  # --- Gather Live Network Data ---
  local gateway_ip="Unknown"
  local local_cidr="Unknown"

  # Get default gateway
  gateway_ip=$(ip route | grep default | awk '{print $3}' | head -n 1)
  if [ -z "$gateway_ip" ]; then
      gateway_ip="Not Found"
  fi

  # Get primary local network CIDR (simplistic approach - gets first non-loopback IPv4)
  local_cidr=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
   if [ -z "$local_cidr" ]; then
      local_cidr="Not Found"
  fi

  # Get local listening ports (TCP only for simplicity)
  local listening_ports=""
  if command -v ss &> /dev/null; then
      # Use ss, filter IPv4/IPv6, get local address:port, extract port after last colon
      listening_ports=$(ss -tlpn | grep LISTEN | awk '{print $4}' | sed 's/.*://' | sort -un)
  elif command -v netstat &> /dev/null; then
      # Use netstat, filter IPv4/IPv6, get local address:port, extract port after last colon
      listening_ports=$(netstat -tlpn | grep LISTEN | awk '{print $4}' | sed 's/.*://' | sort -un)
  fi
  # --- End Live Data Gathering ---

  # Header
  updated_map+="┌─────────────────────────────────────────────────────────────────────────┐\n"
  updated_map+="│                                                                         │\n"
  updated_map+="│                        NETWORK INFRASTRUCTURE MAP                       │\n"
  updated_map+="│                                                                         │\n"

  # Display Gateway (using live data)
  updated_map+="│                            ┌──────────────┐                           │\n"
  updated_map+="│                            │   Internet    │                           │\n"
  updated_map+="│                            └───────┬──────┘                           │\n"
  updated_map+="│                                    │                                  │\n"
  updated_map+="│                            ┌───────┴──────┐                           │\n"
  # Pad the gateway IP to fit box (adjust width as needed)
  local gw_display=$(printf "%-13s" "$gateway_ip")
  updated_map+="│                            │   Gateway    │                           │\n"
  updated_map+="│                            │ ${gw_display:0:13} │                           │\n"
  updated_map+="│                            └───────┬──────┘                           │\n"
  updated_map+="│                                    │                                  │\n"

  # Display Local Network (using live data)
  updated_map+="│                            ┌───────┴──────┐                           │\n"
  # Pad the CIDR to fit box (adjust width as needed)
  local cidr_display=$(printf "%-13s" "$local_cidr")
  updated_map+="│                            │  Local Net   │                           │\n"
  updated_map+="│                            │ ${cidr_display:0:13} │                           │\n"
  updated_map+="│                            └──┬───┬───┬───┘                           │\n"
  updated_map+="│                               │   │   │                               │\n"
  updated_map+="│                               │   │   │                               │\n"

  # --- Live Local Service Display Logic ---
  local displayed_services="" # Keep track of displayed services to avoid duplicates

  # Add boxes for listening ports/services under Local Net
  if [ -n "$listening_ports" ]; then
      local service_count=0
      local service_line1="│                               " # Start padding
      local service_line2="│                               "
      local service_line3="│                               "
      local service_line4="│                               "

      for port in $listening_ports; do
          local service_name="Unknown"
          local service_id="unknown_${port}"
          local service_color=$RED # Default to red for unknown

          # Try to identify known service
          for known_service in "${!SERVICE_PORTS[@]}"; do
              for known_port in ${SERVICE_PORTS[$known_service]}; do
                  if [ "$port" = "$known_port" ]; then
                      # Check if this specific service type was already displayed (e.g., multiple HTTP ports)
                      # Use service_id for tracking displayed types to handle aliases like http/nginx
                      local display_type_id=$known_service
                      # Special handling for web servers
                      if [[ "$known_service" == "http" || "$known_service" == "https" || "$known_service" == "nginx" || "$known_service" == "apache" || "$known_service" == "tomcat" ]]; then
                          display_type_id="web_server"
                      fi
                      # Special handling for databases
                      if [[ "$known_service" == *"sql"* || "$known_service" == "mongo"* ]]; then
                          display_type_id="database"
                      fi

                      if [[ "$displayed_services" != *";${display_type_id};"* ]]; then
                          service_name=${SERVICE_DISPLAY_NAMES[$known_service]:-$known_service}
                          service_id=$known_service # Keep original ID for potential future use
                          # Assign colors based on type (example)
                          case "$display_type_id" in
                              web_server) service_color=$GREEN ;;
                              ssh) service_color=$YELLOW ;;
                              database) service_color=$MAGENTA ;;
                              *) service_color=$CYAN ;;
                          esac
                          displayed_services+=";${display_type_id};" # Mark type as displayed
                          break 2 # Break both inner loops
                      else
                          service_name="" # Already displayed this type, skip adding another box
                          break # Break inner loop
                      fi
                  fi
              done
          done

          # If still unknown after checking known ports, mark as Unknown
          if [ "$service_name" == "Unknown" ]; then
               # Check if 'Unknown' type is already displayed to avoid multiple Unknown boxes
               if [[ "$displayed_services" != *";unknown;"* ]]; then
                   service_name="Unknown"
                   service_color=$RED
                   displayed_services+=";unknown;" # Mark unknown type as displayed once
               else
                   service_name="" # Skip subsequent unknown boxes
               fi
          fi

          # Only add box if service wasn't skipped
          if [ -n "$service_name" ]; then
              # Truncate long names
              local display_name_short=$(printf "%-10.10s" "$service_name")
              local port_display=$(printf "%-5s" "$port") # Display the actual port

              # Add service box representation (simple horizontal layout for now)
              service_line1+="┌────────────┐ "
              service_line2+="│${service_color}${display_name_short}${RESET}│ "
              service_line3+="│ Port:${port_display} │ "
              service_line4+="└────────────┘ "
              service_count=$((service_count + 1))

              # Simple line break logic (adjust number based on terminal width estimate)
              if [ $service_count -ge 4 ]; then # Adjust max boxes per line if needed
                  updated_map+="${service_line1}\n"
                  updated_map+="${service_line2}\n"
                  updated_map+="${service_line3}\n"
                  updated_map+="${service_line4}\n"
                  # Reset for next line
                  service_line1="│                               "
                  service_line2="│                               "
                  service_line3="│                               "
                  service_line4="│                               "
                  service_count=0
              fi
          fi
      done

      # Add any remaining service boxes
      if [ $service_count -gt 0 ]; then
           # Pad remaining lines to align
           local padding_needed=$(( (4 - service_count) * 15 )) # 15 chars per box+space approx
           local padding_str=$(printf '%*s' $padding_needed '')
           service_line1+="$padding_str│\n"
           service_line2+="$padding_str│\n"
           service_line3+="$padding_str│\n"
           service_line4+="$padding_str│\n"
           updated_map+="${service_line1}"
           updated_map+="${service_line2}"
           updated_map+="${service_line3}"
           updated_map+="${service_line4}"
      fi

  else
      updated_map+="│                      [No listening services detected]                 │\n"
  fi

  # --- End Live Local Service Display ---

  # --- Keep existing discovery flag logic for non-service items ---
  # Example: Unusual Traffic (still relies on discovery flag)
  if [[ "$DISCOVERIES" == *"unusual_traffic"* ]]; then
    # Add spacing if needed
    if [ -z "$listening_ports" ]; then
        updated_map+="│                                                                         │\n" # Add space if no services shown
    fi
    updated_map+="│                                                                         │\n"
    updated_map+="│                                                     ┌─────────────────┐ │\n"
    updated_map+="│                                                     │External Attacker│ │\n"
    updated_map+="│                                                     │  45.33.22.156   │ │\n"
    updated_map+="│                                                     └─────────┬───────┘ │\n"
    updated_map+="│                                                               │         │\n"
    updated_map+="│                                                             ${RED}ATTACK${RESET} │         │\n"
    updated_map+="│                                                               ▼         │\n"
  fi

  # Footer
  # Add blank lines to ensure footer is at the bottom, adjust number as needed
  updated_map+="│                                                                         │\n"
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
# Need to capture live data vars here as they are local to the function
gateway_ip=$(ip route | grep default | awk '{print $3}' | head -n 1)
[ -z "$gateway_ip" ] && gateway_ip="Not Found"
local_cidr=$(ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | head -n 1)
[ -z "$local_cidr" ] && local_cidr="Not Found"

generate_network_map # Call function to display map

# Display legend (update with live data info)
echo -e "\n${BOLD}LEGEND:${RESET}"
echo -e "  Gateway: Main connection to external networks (${gateway_ip})"
echo -e "  Local Network: Primary internal network segment (${local_cidr})"
echo -e "  Local Services: Services detected listening on this machine (ports shown)"
# Add specific service legends if needed, or rely on map display
# Example: echo -e "  ${GREEN}Web Server:${RESET} HTTP/HTTPS service"

# Keep legend for items still based on discovery flags
if [[ "$DISCOVERIES" == *"unusual_traffic"* ]]; then
  echo -e "  ${RED}Suspicious Traffic:${RESET} Potential unauthorized access from 45.33.22.156"
fi

# Display discovery status (still based on flags for game progress)
echo -e "\n${BOLD}DISCOVERY STATUS (Gameplay):${RESET}"

# Get total number of possible discoveries
if [ -f "$PLAYER_PROFILE" ]; then
  # In a real implementation, we might want to determine this from the content directory
  TOTAL_DISCOVERIES=12 # Placeholder
else
  # For demo mode
  TOTAL_DISCOVERIES=12 # Placeholder
fi

# Count actual discoveries
DISCOVERY_COUNT=$(echo "$DISCOVERIES" | wc -w)

echo -e "  Game Discoveries Logged: ${DISCOVERY_COUNT}/${TOTAL_DISCOVERIES}"

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
echo -e "  2) View detailed component information (based on game discoveries)"
echo -e "  0) Exit Map Viewer"

echo -e "\nEnter your choice: "
read -r choice

case $choice in
  1)
    # Export map to documentation
    DOCS_DIR=$(get_player_docs_dir "$PLAYER_ID")
    MAP_FILE="${DOCS_DIR}/network_map_$(date +%Y%m%d_%H%M%S).txt"

    # Generate map and save to file (need to regenerate to capture output)
    generate_network_map > "$MAP_FILE"

    echo -e "\n${GREEN}Map exported to documentation at:${RESET}"
    echo -e "${MAP_FILE}"
    sleep 2
    ;;

  2)
    # View detailed component information (based on game discovery flags)
    echo -e "\n${YELLOW}Component Information (Based on Game Discoveries):${RESET}"

    echo -e "${BOLD}Logged Discoveries:${RESET}"
    if [ -n "$DISCOVERIES" ]; then
        for component in $DISCOVERIES; do
          echo -e "  - ${component}"
        done
    else
        echo "  None yet."
    fi

    echo -e "\nPress any key to continue..."
    read -n 1 -s
    ;;

  *)
    # Default - just exit
    ;;
esac

echo -e "\nExiting network map viewer."
exit 0
