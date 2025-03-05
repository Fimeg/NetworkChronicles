#!/bin/bash
# Network Chronicles - User Installation Script

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Set up variables
USER_HOME="$HOME"
USER_INSTALL_DIR="${USER_HOME}/.network-chronicles"
SYSTEM_DIR="/opt/network-chronicles"

# Print banner
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   NETWORK CHRONICLES: THE VANISHING ADMIN                               ║"
echo "║   User Installation Script                                              ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# Check if the user installation directory exists
if [ ! -d "$USER_INSTALL_DIR" ]; then
    echo -e "${CYAN}Creating user installation directory at ${USER_INSTALL_DIR}...${RESET}"
    mkdir -p "$USER_INSTALL_DIR"
else
    echo -e "${YELLOW}User installation directory already exists at ${USER_INSTALL_DIR}${RESET}"
fi

# Create required directories
echo -e "${CYAN}Creating required directories...${RESET}"
mkdir -p "${USER_INSTALL_DIR}/bin"
mkdir -p "${USER_INSTALL_DIR}/data"
mkdir -p "${USER_INSTALL_DIR}/content"

# Create welcome message
echo -e "${CYAN}Creating welcome message...${RESET}"
mkdir -p "${USER_HOME}/Documents"
cat > "${USER_HOME}/Documents/welcome.txt" << 'EOF'
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

# Create hidden clue
echo -e "${CYAN}Creating hidden clue...${RESET}"
mkdir -p "${USER_HOME}/.config/network-chronicles"
cat > "${USER_HOME}/.config/network-chronicles/config.json" << 'EOF'
{
  "version": "1.0.0",
  "user": "player",
  "last_login": "2024-12-31T23:59:59Z",
  "settings": {
    "theme": "terminal",
    "notifications": true,
    "debug": false
  },
  "notes": "If you're reading this, you've found my first hidden message. The network has been compromised. I've hidden evidence throughout the system. Find the network map to continue. - The Architect"
}
EOF

# Create shell integration script
echo -e "${CYAN}Creating shell integration script...${RESET}"
mkdir -p "${USER_INSTALL_DIR}/bin"
cat > "${USER_INSTALL_DIR}/bin/nc-shell-integration.sh" << 'EOF'
#!/bin/bash
# Network Chronicles - User Shell Integration

# Source the system shell integration if it exists
if [ -f "/opt/network-chronicles/bin/nc-shell-integration.sh" ]; then
  source "/opt/network-chronicles/bin/nc-shell-integration.sh"
else
  echo "Network Chronicles system installation not found."
  echo "Please contact your system administrator."
fi

# Add user-specific commands and customizations here
alias nc-explore='find ~ -type f -name "*.txt" | sort'
alias nc-inspect='cat'
alias nc-map='find /opt/network-chronicles -type d | sort | grep -v "data/players" | sed "s/^/  /;s/\/opt\/network-chronicles\///"'
EOF

# Make script executable
chmod +x "${USER_INSTALL_DIR}/bin/nc-shell-integration.sh"

# Add shell integration to bashrc if not already there
if ! grep -q "nc-shell-integration.sh" "${USER_HOME}/.bashrc"; then
    echo -e "${CYAN}Adding shell integration to .bashrc...${RESET}"
    echo "" >> "${USER_HOME}/.bashrc"
    echo "# Network Chronicles Integration" >> "${USER_HOME}/.bashrc"
    echo "if [ -f \"/opt/network-chronicles/bin/nc-shell-integration.sh\" ]; then" >> "${USER_HOME}/.bashrc"
    echo "  source \"/opt/network-chronicles/bin/nc-shell-integration.sh\"" >> "${USER_HOME}/.bashrc"
    echo "elif [ -f \"${USER_INSTALL_DIR}/bin/nc-shell-integration.sh\" ]; then" >> "${USER_HOME}/.bashrc"
    echo "  source \"${USER_INSTALL_DIR}/bin/nc-shell-integration.sh\"" >> "${USER_HOME}/.bashrc"
    echo "fi" >> "${USER_HOME}/.bashrc"
fi

# Create network map clue
echo -e "${CYAN}Creating network map clue...${RESET}"
mkdir -p "${USER_HOME}/Documents/network"
cat > "${USER_HOME}/Documents/network/map.txt" << 'EOF'
NETWORK MAP - CONFIDENTIAL

Main Segments:
  ├── Admin Network (10.0.1.0/24)
  ├── User Network (10.0.2.0/24)
  ├── Server Network (10.0.3.0/24)
  └── IoT Network (10.0.4.0/24)

Key Systems:
  ├── Gateway Router (10.0.0.1)
  ├── Main Firewall (10.0.0.2)
  ├── Admin Server (10.0.1.10)
  ├── File Server (10.0.3.20)
  ├── Database Server (10.0.3.30)
  ├── Monitoring System (10.0.3.40)
  └── Backup Server (10.0.3.50)

Note: The monitoring system has been acting strangely lately.
I've noticed unusual traffic patterns at odd hours.
Check /var/log/monitor for more details.

- The Architect
EOF

# Create first quest artifact
echo -e "${CYAN}Creating first quest artifact...${RESET}"
mkdir -p "${USER_INSTALL_DIR}/content/artifacts"
cat > "${USER_INSTALL_DIR}/content/artifacts/welcome_message.txt" << 'EOF'
To the new administrator,

If you're reading this, I'm no longer available to maintain this system.
Whether by choice or by force, my absence was necessary.

The network holds many secrets - some I've hidden intentionally, others
that emerged on their own. Trust nothing, verify everything.

Your first task is to map the network and understand its structure.
Use the 'nc-add-discovery' command with 'welcome_message' to record
this finding in your journal.

Your journey begins now.

- The Architect
EOF

# Create a symlink to the artifact in a hidden location
mkdir -p "${USER_HOME}/.local/share/network-chronicles"
ln -sf "${USER_INSTALL_DIR}/content/artifacts/welcome_message.txt" "${USER_HOME}/.local/share/network-chronicles/message.txt"

# Final message
echo -e "${GREEN}User installation complete!${RESET}"
echo -e "To start using Network Chronicles:"
echo -e "1. Start a new shell session or run:"
echo -e "   ${CYAN}source ~/.bashrc${RESET}"
echo -e "2. Type ${CYAN}nc-help${RESET} to see available commands"
echo -e "3. Begin by reading the welcome message:"
echo -e "   ${CYAN}cat ~/Documents/welcome.txt${RESET}"
echo -e ""
echo -e "Good luck on your journey!"
