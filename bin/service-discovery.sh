#!/bin/bash
#
# service-discovery.sh - Advanced service discovery for Network Chronicles
#
# This script identifies running services on the local machine and network,
# creates discoveries based on what it finds, and triggers storyline events.
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"
source "${SCRIPT_DIR}/utils/config.sh"
source "${SCRIPT_DIR}/utils/directory-management.sh"
source "${SCRIPT_DIR}/utils/json-helpers.sh"

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

# Process command line arguments
PLAYER_ID="$1"
if [ -z "$PLAYER_ID" ]; then
  PLAYER_ID=$(whoami)
fi

# Define common services with their ports and names
declare -A SERVICE_PORTS=(
  ["http"]="80"
  ["https"]="443"
  ["ssh"]="22"
  ["ftp"]="21"
  ["mysql"]="3306"
  ["postgresql"]="5432"
  ["mongodb"]="27017"
  ["redis"]="6379"
  ["elasticsearch"]="9200"
  ["nginx"]="80 443"
  ["apache"]="80 443"
  ["tomcat"]="8080"
  ["jenkins"]="8080"
  ["prometheus"]="9090"
  ["grafana"]="3000"
  ["docker-registry"]="5000"
  ["kubernetes-api"]="6443"
  ["kubernetes-dashboard"]="8443"
  ["etcd"]="2379"
  ["rabbitmq"]="5672 15672"
  ["smtp"]="25"
  ["dns"]="53"
  ["ldap"]="389"
  ["dhcp"]="67 68"
)

# Service display names - more user-friendly names for displaying
declare -A SERVICE_DISPLAY_NAMES=(
  ["http"]="HTTP Web Server"
  ["https"]="HTTPS Web Server (SSL)"
  ["ssh"]="SSH Server"
  ["ftp"]="FTP File Server"
  ["mysql"]="MySQL Database"
  ["postgresql"]="PostgreSQL Database"
  ["mongodb"]="MongoDB Database"
  ["redis"]="Redis Cache Server"
  ["elasticsearch"]="Elasticsearch Search Engine"
  ["nginx"]="Nginx Web Server"
  ["apache"]="Apache Web Server"
  ["tomcat"]="Tomcat Application Server"
  ["jenkins"]="Jenkins CI/CD Server"
  ["prometheus"]="Prometheus Monitoring"
  ["grafana"]="Grafana Dashboard"
  ["docker-registry"]="Docker Registry"
  ["kubernetes-api"]="Kubernetes API Server"
  ["kubernetes-dashboard"]="Kubernetes Dashboard"
  ["etcd"]="etcd Key-Value Store"
  ["rabbitmq"]="RabbitMQ Message Broker"
  ["smtp"]="SMTP Mail Server"
  ["dns"]="DNS Server"
  ["ldap"]="LDAP Directory Server"
  ["dhcp"]="DHCP Server"
)

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

# Function to detect local listening services
detect_local_services() {
  log_message "INFO" "Detecting local services..."
  
  # Get player profile path using utility function
  local profile=$(get_player_profile "$PLAYER_ID")
  if [ ! -f "$profile" ]; then
    log_message "ERROR" "Player profile not found for $PLAYER_ID"
    return 1
  fi
  
  # Temporary file to store service information
  local services_file=$(mktemp)
  
  # Use ss to get listening ports (more modern than netstat)
  if command -v ss &> /dev/null; then
    log_message "INFO" "Using ss to detect services..."
    ss -tuln | grep LISTEN | awk '{print $5}' | sed 's/.*://' | sort -u > "$services_file"
  # Fallback to netstat if ss is not available
  elif command -v netstat &> /dev/null; then
    log_message "INFO" "Using netstat to detect services..."
    netstat -tuln | grep LISTEN | awk '{print $4}' | sed 's/.*://' | sort -u > "$services_file"
  # If neither is available, we'll need to try a different approach
  else
    log_message "WARNING" "Neither ss nor netstat found, using lsof..."
    # Try lsof as a last resort
    if command -v lsof &> /dev/null; then
      lsof -i -P -n | grep LISTEN | awk '{print $9}' | sed 's/.*://' | sort -u > "$services_file"
    else
      log_message "ERROR" "No suitable tool found to detect network services."
      rm "$services_file"
      return 1
    fi
  fi
  
  # Now process the discovered ports
  log_message "INFO" "Processing discovered services..."
  
  # Create a directory to store service details
  local docs_dir=$(get_player_docs_dir "$PLAYER_ID")
  mkdir -p "${docs_dir}/network/services"
  
  # Collect detected services
  local detected_services=()
  local discovered_ports=()
  
  # Process each port and map to known services
  while read port; do
    # Skip empty lines
    [ -z "$port" ] && continue
    
    discovered_ports+=("$port")
    local service_name=""
    
    # Try to identify the service based on port
    for service in "${!SERVICE_PORTS[@]}"; do
      for service_port in ${SERVICE_PORTS[$service]}; do
        if [ "$port" = "$service_port" ]; then
          service_name="$service"
          detected_services+=("$service")
          
          # Generate a discovery ID for this service
          local discovery_id="service_${service}"
          
          # Check if this service has already been discovered
          local already_discovered=$(json_get_value "$profile" ".discoveries | index(\"$discovery_id\") != null")
          
          if [ "$already_discovered" != "true" ]; then
            # Add to discoveries
            json_add_to_array "$profile" ".discoveries" "\"$discovery_id\""
            
            # Award XP for finding a new service
            json_update_field "$profile" ".xp" "(.xp + 25)"
            
            # Save service details to documentation
            cat > "${docs_dir}/network/services/${service}.txt" << EOF
SERVICE DETAILS: ${SERVICE_DISPLAY_NAMES[$service]}
=====================================
Service Type: ${service}
Port: ${port}
Status: Active
Discovery Date: $(date '+%Y-%m-%d %H:%M:%S')

DESCRIPTION:
This service was detected on your system during a network discovery scan.
It appears to be a ${SERVICE_DISPLAY_NAMES[$service]}.

SECURITY NOTES:
- Ensure this service is properly secured.
- Check if this service should be publicly accessible.
- Monitor logs for unauthorized access attempts.
EOF

            # Print notification to user
            log_message "SUCCESS" "Discovered ${SERVICE_DISPLAY_NAMES[$service]} on port $port (+25 XP)"
          fi
          
          break
        fi
      done
      [ -n "$service_name" ] && break
    done
    
    # If the service wasn't identified, mark it as unknown
    if [ -z "$service_name" ]; then
      local discovery_id="service_unknown_${port}"
      
      # Check if already discovered
      local already_discovered=$(json_get_value "$profile" ".discoveries | index(\"$discovery_id\") != null")
      
      if [ "$already_discovered" != "true" ]; then
        # Add to discoveries
        json_add_to_array "$profile" ".discoveries" "\"$discovery_id\""
        
        # Award XP for finding an unknown service
        json_update_field "$profile" ".xp" "(.xp + 20)"
        
        # Save service details to documentation
        cat > "${docs_dir}/network/services/unknown_${port}.txt" << EOF
SERVICE DETAILS: Unknown Service
=====================================
Service Type: Unidentified
Port: ${port}
Status: Active
Discovery Date: $(date '+%Y-%m-%d %H:%M:%S')

DESCRIPTION:
This unidentified service was detected on your system during a network discovery scan.
The Architect's notes don't mention what should be running on port ${port}.

SECURITY NOTES:
- This might be a legitimate service or could be suspicious.
- Investigate what process is using this port with: sudo lsof -i :${port}
- Consider whether this service should be running on your system.
EOF

        # Print notification to user
        log_message "WARNING" "Discovered unknown service on port $port (+20 XP)"
      fi
    fi
  done < "$services_file"
  
  # Clean up
  rm "$services_file"
  
  # Create a summary file
  cat > "${docs_dir}/network/services_summary.txt" << EOF
NETWORK SERVICES SUMMARY
=====================================
Scan Date: $(date '+%Y-%m-%d %H:%M:%S')
Detected Services: ${#detected_services[@]}
Detected Ports: ${#discovered_ports[@]}

ACTIVE SERVICES:
EOF

  # Add detected services to summary
  for service in "${detected_services[@]}"; do
    echo "- ${SERVICE_DISPLAY_NAMES[$service]} (${service})" >> "${docs_dir}/network/services_summary.txt"
  done
  
  # Add a section for unknown ports
  echo -e "\nUNIDENTIFIED PORTS:" >> "${docs_dir}/network/services_summary.txt"
  for port in "${discovered_ports[@]}"; do
    local known=false
    for service in "${detected_services[@]}"; do
      for service_port in ${SERVICE_PORTS[$service]}; do
        if [ "$port" = "$service_port" ]; then
          known=true
          break
        fi
      done
      $known && break
    done
    
    if ! $known; then
      echo "- Unknown service on port $port" >> "${docs_dir}/network/services_summary.txt"
    fi
  done
  
  log_message "SUCCESS" "Service discovery complete! Found ${#discovered_ports[@]} active ports."
  
  # Return number of services found
  return ${#discovered_ports[@]}
}

# Function to create dynamic narrative content
create_service_narrative() {
  log_message "INFO" "Generating narrative elements based on discovered services..."
  
  # Get player profile path using utility function
  local profile=$(get_player_profile "$PLAYER_ID")
  local player_state=$(get_player_state_dir "$PLAYER_ID")
  
  # Check which services were discovered
  local web_server=false
  local database=false
  local monitoring=false
  local custom_service=false
  
  # Check for specific service types
  if json_get_value "$profile" '.discoveries | index("service_http") != null or .discoveries | index("service_https") != null or .discoveries | index("service_nginx") != null or .discoveries | index("service_apache") != null'; then
    web_server=true
  fi
  
  if json_get_value "$profile" '.discoveries | index("service_mysql") != null or .discoveries | index("service_postgresql") != null or .discoveries | index("service_mongodb") != null'; then
    database=true
  fi
  
  if json_get_value "$profile" '.discoveries | index("service_prometheus") != null or .discoveries | index("service_grafana") != null'; then
    monitoring=true
  fi
  
  # Check for unknown services
  if json_get_value "$profile" '.discoveries[] | select(startswith("service_unknown_")) | length > 0'; then
    custom_service=true
  fi
  
  # Create a new journal entry based on discoveries
  local journal_file="${player_state}/journal.json"
  
  # Check if the journal exists
  if [ ! -f "$journal_file" ]; then
    log_message "ERROR" "Journal file not found"
    return 1
  fi
  
  # Create journal entry title and content based on what was found
  local title="Network Service Analysis"
  local content=""
  
  # Build journal content based on discovered services
  content+="I've conducted a thorough scan of the network services and documented my findings.\n\n"
  
  if $web_server; then
    content+="**Web Server Discovered**\n\n"
    content+="I found a web server running on the network. The Architect appears to have set up this service "
    
    if $database; then
      content+="with a connected database. This suggests they were running some kind of web application. "
      content+="I should investigate what's being served and whether it contains any clues.\n\n"
    else
      content+="for some purpose. The web content might contain important information.\n\n"
    fi
  fi
  
  if $monitoring; then
    content+="**Monitoring System Active**\n\n"
    content+="A monitoring system is active on the network. This suggests The Architect was "
    content+="watching for something specific. The monitoring data might reveal what they were "
    content+="concerned about before their disappearance.\n\n"
  fi
  
  if $custom_service; then
    content+="**Unidentified Services Detected**\n\n"
    content+="I've found one or more services running on non-standard ports. These could be "
    content+="custom applications set up by The Architect, or potentially suspicious services "
    content+="that shouldn't be there. I need to investigate these further to determine their purpose.\n\n"
  fi
  
  content+="I'll continue mapping and documenting these services. Each one could potentially "
  content+="contain information about what happened to The Architect."
  
  # Add entry to journal
  local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local tmp=$(mktemp)
  jq ".entries += [{
    \"id\": \"service_discovery_summary\",
    \"title\": \"$title\",
    \"content\": \"$content\",
    \"timestamp\": \"$timestamp\"
  }]" "$journal_file" > "$tmp" && mv "$tmp" "$journal_file"
  
  log_message "SUCCESS" "Created new journal entry based on discovered services."
  
  # Create or modify quest content based on discoveries
  if $custom_service; then
    # Create a new challenge related to investigating the unknown service
    local docs_dir=$(get_player_docs_dir "$PLAYER_ID")
    mkdir -p "${docs_dir}/challenges"
    
    # Create challenge file
    cat > "${docs_dir}/challenges/investigate_unknown_service.txt" << EOF
Mission Objective: Investigate Unidentified Services
==========================================

The Architect appears to have configured custom services running on non-standard ports.
These services weren't documented in any official network diagrams and could be:

1. Custom tools set up by The Architect
2. Compromised services or backdoors
3. Critical infrastructure with hidden purposes

Your task is to:
- Identify what processes are using these ports (lsof -i :<port>)
- Check the service configuration files
- Investigate communication patterns to/from these services
- Determine if they pose a security risk

Report your findings by creating a new journal entry with your analysis.

SECURITY LEVEL: ELEVATED
EOF

    log_message "INFO" "Created custom service investigation challenge."
  fi
  
  if $database && $web_server; then
    # Create a web application quest
    local docs_dir=$(get_player_docs_dir "$PLAYER_ID")
    mkdir -p "${docs_dir}/challenges"
    
    # Create challenge file
    cat > "${docs_dir}/challenges/web_application_analysis.txt" << EOF
Mission Objective: Web Application Analysis
==========================================

The presence of both a web server and database indicates The Architect
was running a web application. This could contain essential information
about their research or activities before disappearing.

Your task is to:
- Identify what web application is running
- Locate the application configuration files
- Check for database credentials or configuration
- Look for unusual access patterns in web server logs

SECURITY LEVEL: STANDARD
EOF

    log_message "INFO" "Created web application analysis challenge."
  fi
  
  return 0
}

# Function to enhance network map with discovered services
enhance_network_map() {
  log_message "INFO" "Enhancing network map with service information..."
  
  # Get player profile path using utility function
  local profile=$(get_player_profile "$PLAYER_ID")
  local player_state=$(get_player_state_dir "$PLAYER_ID")
  
  # Placeholder for future network map enhancements
  # This would modify the map visualization to include service information
  
  log_message "INFO" "Network map enhancement complete."
  return 0
}

# Main function
main() {
  echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYAN}║${RESET}          ${YELLOW}NETWORK CHRONICLES${RESET} - ${GREEN}Advanced Service Discovery${RESET}          ${CYAN}║${RESET}"
  echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════╝${RESET}"
  echo ""
  
  # Display banner
  log_message "INFO" "Beginning service discovery scan for player: $PLAYER_ID"
  
  # Detect services
  detect_local_services
  local services_found=$?
  
  if [ $services_found -gt 0 ]; then
    # Create narrative content based on discovered services
    create_service_narrative
    
    # Enhance network map
    enhance_network_map
    
    # Fix permissions
    local player_state=$(get_player_state_dir "$PLAYER_ID")
    chmod -R 777 "$player_state" 2>/dev/null || true
    
    log_message "SUCCESS" "Service discovery and storyline integration complete!"
    log_message "INFO" "Discovered $services_found services on your network."
    log_message "INFO" "Check your journal for updated entries."
  else
    log_message "WARNING" "No services were found or an error occurred."
  fi
  
  return 0
}

# Run main function
main "$@"