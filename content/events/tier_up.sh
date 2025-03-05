#!/bin/bash
# tier_up.sh - Event handler for player tier advancement

PLAYER_ID="$1"
NEW_TIER="$2"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Update player tier
tmp=$(mktemp)
jq ".tier = $NEW_TIER" "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"

# Add journal entry
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JOURNAL_FILE="${PLAYER_STATE}/journal.json"

# Create tier-specific message
case $NEW_TIER in
  2)
    TIER_NAME="Network Cartography"
    TIER_MESSAGE="I've gained enough experience to reach Tier 2: Network Cartography. This grants me access to more network segments and tools for mapping the infrastructure. I should be able to discover more about the network topology now."
    ;;
  3)
    TIER_NAME="Shadow Protocol"
    TIER_MESSAGE="I've advanced to Tier 3: Shadow Protocol. This grants me access to maintenance procedures, automation systems, and potentially evidence of security breaches. I'm getting closer to understanding what happened to The Architect."
    ;;
  4)
    TIER_NAME="Fortress Mentality"
    TIER_MESSAGE="I've reached Tier 4: Fortress Mentality. I now have access to the security architecture and defensive protocols. I should be able to discover The Architect's sophisticated monitoring system and uncover more about the security incident."
    ;;
  5)
    TIER_NAME="Architect's Vision"
    TIER_MESSAGE="I've achieved the highest tier: Architect's Vision. I now have access to advanced configurations and custom solutions. I should be able to uncover the truth behind The Architect's disappearance."
    ;;
  *)
    TIER_NAME="Unknown Tier"
    TIER_MESSAGE="I've advanced to an unknown tier. This is unexpected and may indicate a system error."
    ;;
esac

# Create journal entry
tmp=$(mktemp)
jq ".entries += [{
  \"id\": \"tier_up_${NEW_TIER}\",
  \"title\": \"Advanced to Tier ${NEW_TIER}: ${TIER_NAME}\",
  \"content\": \"${TIER_MESSAGE}\",
  \"timestamp\": \"${TIMESTAMP}\"
}]" "$JOURNAL_FILE" > "$tmp" && mv "$tmp" "$JOURNAL_FILE"

# Display notification
echo -e "\n\033[1;33m[TIER UP]\033[0m You have advanced to Tier ${NEW_TIER}: ${TIER_NAME}"
echo -e "You now have access to new areas and capabilities."
echo -e "Type 'nc-status' to see your updated status.\n"

# Unlock tier-specific content
case $NEW_TIER in
  2)
    # Unlock network mapping tools
    mkdir -p "${PLAYER_STATE}/inventory/tools"
    echo "Network mapping tools unlocked" > "${PLAYER_STATE}/inventory/tools/network_mapper.txt"
    echo -e "Network mapping tools have been added to your inventory."
    
    # Check if player has the required discoveries for Architect contact
    HAS_WELCOME=$(jq -r '.discoveries | contains(["welcome_message"])' "${PLAYER_STATE}/profile.json")
    HAS_GATEWAY=$(jq -r '.discoveries | contains(["network_gateway"])' "${PLAYER_STATE}/profile.json")
    HAS_LOCAL=$(jq -r '.discoveries | contains(["local_network"])' "${PLAYER_STATE}/profile.json")
    
    if [ "$HAS_WELCOME" = "true" ] && [ "$HAS_GATEWAY" = "true" ] && [ "$HAS_LOCAL" = "true" ]; then
      # Create flags directory if it doesn't exist
      mkdir -p "${PLAYER_STATE}/flags"
      
      # If not already triggered, suggest looking for encrypted channels
      if [ ! -f "${PLAYER_STATE}/flags/architect_contact" ]; then
        echo -e "\n\033[0;35m[HINT]\033[0m With your new access level, you might discover hidden communication channels."
        echo -e "\033[0;35m[HINT]\033[0m Check your journal and status for unusual signals."
        
        # Trigger the architect contact event
        if [ -f "${GAME_ROOT}/content/events/architect_contact.sh" ]; then
          echo -e "\nInitiating contact protocol..."
          "${GAME_ROOT}/content/events/architect_contact.sh" "$PLAYER_ID"
          touch "${PLAYER_STATE}/flags/architect_contact"
        fi
      fi
    fi
    ;;
  3)
    # Unlock automation tools
    mkdir -p "${PLAYER_STATE}/inventory/tools"
    echo "Automation tools unlocked" > "${PLAYER_STATE}/inventory/tools/automation_toolkit.txt"
    echo -e "Automation tools have been added to your inventory."
    ;;
  4)
    # Unlock security tools
    mkdir -p "${PLAYER_STATE}/inventory/tools"
    echo "Security tools unlocked" > "${PLAYER_STATE}/inventory/tools/security_toolkit.txt"
    echo -e "Security tools have been added to your inventory."
    ;;
  5)
    # Unlock The Architect's personal files
    mkdir -p "${PLAYER_STATE}/inventory/artifacts"
    echo "The Architect's personal files unlocked" > "${PLAYER_STATE}/inventory/artifacts/architect_files.txt"
    echo -e "The Architect's personal files have been added to your inventory."
    ;;
esac

exit 0
