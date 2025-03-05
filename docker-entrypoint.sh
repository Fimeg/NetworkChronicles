#!/bin/bash
# Docker entrypoint script for Network Chronicles

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RESET='\033[0m'

echo -e "${CYAN}Initializing Network Chronicles Docker environment...${RESET}"

# Validate that directories exist with proper permissions
mkdir -p /opt/network-chronicles/data/players/player
mkdir -p /opt/network-chronicles/logs
mkdir -p /home/player/Documents

# Ensure player files exist and have correct permissions
if [ ! -f "/opt/network-chronicles/data/players/player/profile.json" ]; then
    echo -e "${CYAN}Creating initial player profile...${RESET}"
    cat > /opt/network-chronicles/data/players/player/profile.json << EOF
{
  "id": "player",
  "name": "player",
  "tier": 1,
  "xp": 0,
  "discoveries": [],
  "quests": {
    "current": "initial_access",
    "completed": []
  },
  "created_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "last_login": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
fi

if [ ! -f "/opt/network-chronicles/data/players/player/journal.json" ]; then
    echo -e "${CYAN}Creating initial journal...${RESET}"
    cat > /opt/network-chronicles/data/players/player/journal.json << EOF
{
  "entries": [
    {
      "id": "welcome",
      "title": "First Day",
      "content": "Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.",
      "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
    }
  ]
}
EOF
fi

# Set proper ownership and permissions
echo -e "${CYAN}Setting permissions...${RESET}"
chmod -R 777 /opt/network-chronicles/data
chmod -R 777 /opt/network-chronicles/logs
chmod 666 /opt/network-chronicles/data/players/player/profile.json
chmod 666 /opt/network-chronicles/data/players/player/journal.json

# Fix ownership
if id player &>/dev/null; then
  chown -R player:player /home/player
  chown -R player:player /opt/network-chronicles/data/players/player
fi

echo -e "${GREEN}Network Chronicles initialization complete!${RESET}"

# Ensure bin directory scripts are executable
chmod -R 755 /opt/network-chronicles/bin/
echo -e "${GREEN}Made bin scripts executable${RESET}"

# Install command links if the install-commands.sh script exists
if [ -f "/opt/network-chronicles/bin/install-commands.sh" ]; then
    echo -e "${CYAN}Installing command links...${RESET}"
    chmod +x /opt/network-chronicles/bin/install-commands.sh
    /opt/network-chronicles/bin/install-commands.sh /opt/network-chronicles
    echo -e "${GREEN}Command links installed${RESET}"
fi

# Create player directories and set proper permissions
if id player &>/dev/null; then
  # Create necessary player directories
  mkdir -p /home/player/Documents
  mkdir -p /opt/network-chronicles/data/players/player
  
  # Set proper ownership and permissions
  chown -R player:player /home/player
  chmod -R 777 /opt/network-chronicles/data/players
  
  # Ensure all player files have the right permissions
  find /opt/network-chronicles/data/players -type f -exec chmod 644 {} \;
  find /opt/network-chronicles/logs -type d -exec chmod 777 {} \;
  
  # Create welcome document
  if [ ! -f "/home/player/Documents/welcome.txt" ]; then
    cat > "/home/player/Documents/welcome.txt" << 'EOF'
===============================================================================
                  WELCOME TO THE NETWORK CHRONICLES
===============================================================================

You have been appointed as the new system administrator after the mysterious
disappearance of your predecessor, known only as "The Architect."

Your task is to maintain the system, discover its secrets, and perhaps uncover
what happened to The Architect.

To begin your journey:

1. Type 'nc-status' to see your current status
2. Type 'nc-journal' to view your journal
3. Type 'nc-help' for more commands

Good luck, and remember: Trust nothing, verify everything.

- The Management
===============================================================================
EOF
    chown player:player /home/player/Documents/welcome.txt
  fi
  
  echo "Player home directories prepared."
fi

# Now check if the core files are already installed
if [ ! -f "/opt/network-chronicles/bin/network-chronicles-engine.sh" ]; then
    echo -e "${CYAN}First-time setup: Installing Network Chronicles...${RESET}"
    
    # First install the system files
    # Copy all the bin files from the mounted volume to the system location
    if [ -d "/opt/network-chronicles/bin" ] && [ "$(ls -A /opt/network-chronicles/bin 2>/dev/null)" ]; then
        echo -e "${CYAN}System binaries already mounted, ensuring they are executable...${RESET}"
        chmod +x /opt/network-chronicles/bin/*.sh 2>/dev/null || true
    else
        echo -e "${CYAN}Creating system binaries...${RESET}"
        mkdir -p /opt/network-chronicles/bin
        
        # Create a minimal engine for bootstrapping
        cat > /opt/network-chronicles/bin/network-chronicles-engine.sh << 'EOF'
#!/bin/bash
# Network Chronicles - Core Engine (Bootstrap version)
echo "Network Chronicles Engine v1.0.0"
echo "Processing command: $@"
case "$1" in
    status)
        echo "Current status: Initial setup phase"
        ;;
    process)
        echo "Processing command: $2"
        ;;
    add-discovery)
        echo "Discovery added: $2"
        ;;
    *)
        echo "Network Chronicles Engine"
        echo "Usage: network-chronicles-engine.sh <command> [args...]"
        ;;
esac
exit 0
EOF
        chmod +x /opt/network-chronicles/bin/network-chronicles-engine.sh
    fi
    
    # Make sure content directories exist
    mkdir -p /opt/network-chronicles/content/narrative/quests
    mkdir -p /opt/network-chronicles/content/discoveries
    mkdir -p /opt/network-chronicles/content/challenges
    mkdir -p /opt/network-chronicles/content/events
    mkdir -p /opt/network-chronicles/content/triggers
    mkdir -p /opt/network-chronicles/data/players
    
    # Ensure proper permissions on data directories
    mkdir -p /opt/network-chronicles/logs
    chmod -R 755 /opt/network-chronicles/content
    chmod -R 755 /opt/network-chronicles/data
    chmod -R 777 /opt/network-chronicles/logs
    
    # Run the user installation script as the player user
    echo -e "${CYAN}Running user installation...${RESET}"
    su - player -c "cd /opt/network-chronicles && ./install-user.sh"
    
    # Now create the shell integration script
    echo -e "${CYAN}Creating shell integration script...${RESET}"
    cat > /opt/network-chronicles/bin/nc-shell-integration.sh << 'EOF'
#!/bin/bash
# Network Chronicles - Shell Integration

# Set up variables
GAME_ROOT="/opt/network-chronicles"
BIN_DIR="${GAME_ROOT}/bin"
ENGINE="${BIN_DIR}/network-chronicles-engine.sh"
PLAYER_ID=$(whoami)

# Colors
GREEN='\[\033[0;32m\]'
CYAN='\[\033[0;36m\]'
YELLOW='\[\033[1;33m\]'
RED='\[\033[0;31m\]'
RESET='\[\033[0m\]'

# Prepare paths
mkdir -p "${GAME_ROOT}/data/players/${PLAYER_ID}" 2>/dev/null
mkdir -p "${GAME_ROOT}/data/players/${PLAYER_ID}/Documents" 2>/dev/null
mkdir -p "/home/${PLAYER_ID}/Documents" 2>/dev/null

# Make sure Documents directory exists
if [ ! -d "/home/${PLAYER_ID}/Documents" ]; then
  mkdir -p "/home/${PLAYER_ID}/Documents" 2>/dev/null
fi

# Custom prompt
nc_prompt() {
  # Default to tier 1
  local tier=1
  
  # Try to get player tier if profile exists
  if [ -f "${GAME_ROOT}/data/players/${PLAYER_ID}/profile.json" ]; then
    tier=$(jq -r '.tier // 1' "${GAME_ROOT}/data/players/${PLAYER_ID}/profile.json" 2>/dev/null || echo "1")
  fi
  
  # Set prompt based on tier
  case "$tier" in
    1)
      PS1="${GREEN}[NC:T1]${RESET} \u@\h:\w\$ "
      ;;
    2)
      PS1="${CYAN}[NC:T2]${RESET} \u@\h:\w\$ "
      ;;
    3)
      PS1="${YELLOW}[NC:T3]${RESET} \u@\h:\w\$ "
      ;;
    4|5)
      PS1="${RED}[NC:T${tier}]${RESET} \u@\h:\w\$ "
      ;;
    *)
      PS1="\u@\h:\w\$ "
      ;;
  esac
}

# Set up prompt
PROMPT_COMMAND="nc_prompt"

# Command wrappers
nc-status() {
  echo "Network Chronicles Status"
  echo "-------------------------"
  echo "Player: $PLAYER_ID"
  echo "Checking quest status..."
  
  # Use the engine if it exists, otherwise show default status
  if [ -x "$ENGINE" ]; then
    $ENGINE status "$PLAYER_ID"
  else
    echo "Engine not fully initialized. Please complete setup."
    echo "Try exploring your home directory to find initial clues."
  fi
}

nc-journal() {
  # Ensure Documents exists
  mkdir -p "/home/${PLAYER_ID}/Documents" 2>/dev/null
  
  if [ -x "${BIN_DIR}/journal.sh" ]; then
    "${BIN_DIR}/journal.sh" "$PLAYER_ID" "$@"
  else
    echo "Journal system not yet initialized. Try again after completing initial setup."
    echo "You can read welcome.txt in your Documents directory for now."
    
    # Create welcome.txt if it doesn't exist
    if [ ! -f "/home/${PLAYER_ID}/Documents/welcome.txt" ]; then
      mkdir -p "/home/${PLAYER_ID}/Documents" 2>/dev/null
      cat > "/home/${PLAYER_ID}/Documents/welcome.txt" << 'WELCOME_EOF'
===============================================================================
                  WELCOME TO THE NETWORK CHRONICLES
===============================================================================

You have been appointed as the new system administrator after the mysterious
disappearance of your predecessor, known only as "The Architect."

Your task is to maintain the system, discover its secrets, and perhaps uncover
what happened to The Architect.

To begin your journey:

1. Type 'nc-status' to see your current status
2. Type 'nc-journal' to view your journal
3. Type 'nc-help' for more commands

Good luck, and remember: Trust nothing, verify everything.

- The Management
===============================================================================
WELCOME_EOF
    fi
    
    ls -la ~/Documents/ 2>/dev/null
  fi
}

nc-map() {
  if [ -x "${BIN_DIR}/network-map.sh" ]; then
    "${BIN_DIR}/network-map.sh" "$PLAYER_ID"
  else
    echo "Network map not yet available. Discover network components first."
  fi
}

nc-add-discovery() {
  if [ -z "$1" ]; then
    echo "Usage: nc-add-discovery <discovery_id>"
    return 1
  fi
  
  echo "Adding discovery: $1"
  
  # Use the engine if it exists
  if [ -x "$ENGINE" ]; then
    $ENGINE add-discovery "$PLAYER_ID" "$1"
  else
    # Fallback to basic discovery tracking
    mkdir -p "${GAME_ROOT}/data/players/${PLAYER_ID}"
    echo "$1" >> "${GAME_ROOT}/data/players/${PLAYER_ID}/discoveries.txt"
    echo "Discovery recorded: $1"
  fi
}

nc-help() {
  echo -e "${GREEN}Network Chronicles Commands:${RESET}"
  echo -e "  nc-status         Display your current status"
  echo -e "  nc-journal        View your journal"
  echo -e "  nc-map            View network map (when available)"
  echo -e "  nc-add-discovery  Add a discovery (e.g., welcome_message)"
  echo -e "  nc-help           Display this help message"
}

# Welcome message
echo -e "${GREEN}Welcome to Network Chronicles: The Vanishing Admin${RESET}"
echo -e "Type ${CYAN}nc-help${RESET} for available commands"
EOF
    chmod +x /opt/network-chronicles/bin/nc-shell-integration.sh
    
    # Make sure all scripts are executable
    chmod +x /opt/network-chronicles/bin/*.sh 2>/dev/null || true
    
    echo -e "${GREEN}Installation complete!${RESET}"
else
    echo -e "${GREEN}Network Chronicles is already installed.${RESET}"
fi

# Create initial quest if it doesn't exist
if [ ! -f "/opt/network-chronicles/content/narrative/quests/initial_access.json" ]; then
    echo -e "${CYAN}Creating initial quest...${RESET}"
    
    # Create directory if it doesn't exist
    mkdir -p /opt/network-chronicles/content/narrative/quests
    
    # Create initial quest JSON
    cat > /opt/network-chronicles/content/narrative/quests/initial_access.json << EOF
{
  "id": "initial_access",
  "name": "Initial System Access",
  "description": "Gain access to the system and locate The Architect's first message",
  "tier": 1,
  "xp": 100,
  "required_discoveries": ["welcome_message"],
  "next_quest": "map_network"
}
EOF

    # Create initial quest description
    cat > /opt/network-chronicles/content/narrative/quests/initial_access.md << EOF
# Initial System Access

You've been assigned as the new system administrator after the mysterious disappearance of your predecessor, known only as "The Architect."

## Objectives

1. Explore the system to get familiar with it
2. Locate The Architect's welcome message
3. Document your findings in your journal

## Hints

- Look for files in your home directory
- The Architect was known for leaving cryptic notes
- Use standard terminal commands to explore

## Rewards

- Access to basic system tools
- XP towards Tier 2 access
EOF

    echo -e "${GREEN}Initial quest created.${RESET}"
fi

# Display welcome message
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   NETWORK CHRONICLES: THE VANISHING ADMIN                               ║"
echo "║   Docker Environment                                                    ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo "Welcome to the Network Chronicles Docker environment!"
echo ""
echo "To start your adventure:"
echo "1. Log in as the player user: su - player"
echo "2. Type 'nc-status' to see your current status"
echo "3. Type 'nc-journal' to view your journal"
echo "4. Type 'nc-help' for more commands"
echo ""
echo "Enjoy your adventure in Network Chronicles!"

# Execute the command passed to docker run
exec "$@"
