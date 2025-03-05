#!/bin/bash
# setup-demo.sh - Prepares Network Chronicles for demonstration

# Ensure script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root"
  exit 1
fi

echo "Setting up Network Chronicles for demonstration..."

# Configuration
INSTALL_DIR="/opt/network-chronicles"
CURRENT_DIR=$(pwd)
PROJECT_FILES="${CURRENT_DIR}"

# Create utility directories first
echo "Creating utility directories..."
mkdir -p "${INSTALL_DIR}/bin/utils"

# Copy utilities
echo "Installing utility scripts..."
cp "${PROJECT_FILES}/bin/utils/config.sh" "${INSTALL_DIR}/bin/utils/"
cp "${PROJECT_FILES}/bin/utils/directory-management.sh" "${INSTALL_DIR}/bin/utils/"
cp "${PROJECT_FILES}/bin/utils/json-helpers.sh" "${INSTALL_DIR}/bin/utils/"
cp "${PROJECT_FILES}/bin/utils/script-template.sh" "${INSTALL_DIR}/bin/utils/"

# Source the directory management utility to create all needed directories
source "${INSTALL_DIR}/bin/utils/directory-management.sh"
echo "Creating installation directory structure..."
# First ensure the NC_GAME_ROOT is set correctly
export NC_GAME_ROOT="${INSTALL_DIR}"
# Create all required directories
ensure_game_directories

# Copy files
echo "Copying files..."
# Copy binaries
cp "${PROJECT_FILES}/bin/network-chronicles-engine.sh" "${INSTALL_DIR}/bin/"
cp "${PROJECT_FILES}/bin/nc-shell-integration.sh" "${INSTALL_DIR}/bin/"
cp "${PROJECT_FILES}/bin/journal.sh" "${INSTALL_DIR}/bin/" 2>/dev/null || echo "Journal script not found, skipping"
cp "${PROJECT_FILES}/bin/network-map.sh" "${INSTALL_DIR}/bin/"

# Copy content
cp "${PROJECT_FILES}/content/artifacts/"* "${INSTALL_DIR}/content/artifacts/" 2>/dev/null
cp "${PROJECT_FILES}/content/challenges/"* "${INSTALL_DIR}/content/challenges/" 2>/dev/null
cp "${PROJECT_FILES}/content/discoveries/"* "${INSTALL_DIR}/content/discoveries/" 2>/dev/null
cp "${PROJECT_FILES}/content/events/"* "${INSTALL_DIR}/content/events/" 2>/dev/null
cp "${PROJECT_FILES}/content/triggers/"* "${INSTALL_DIR}/content/triggers/" 2>/dev/null
cp "${PROJECT_FILES}/content/narrative/quests/"* "${INSTALL_DIR}/content/narrative/quests/" 2>/dev/null

# Set permissions
echo "Setting permissions..."
chmod -R 755 "${INSTALL_DIR}/bin"
chmod -R 755 "${INSTALL_DIR}/content/events"
chmod -R 755 "${INSTALL_DIR}/content/challenges"
chmod -R 775 "${INSTALL_DIR}/data"
chmod -R 775 "${INSTALL_DIR}/logs"

# Create demo auth.log file
echo "Creating demo files..."
mkdir -p /var/log
cat > /var/log/auth.log << EOF
Mar  1 02:14:22 server sshd[12345]: Accepted publickey for admin from 10.10.1.42 port 49812
Mar  1 08:35:16 server sshd[12346]: Failed password for invalid user postgres from 192.168.1.105 port 59104
Mar  1 08:35:18 server sshd[12347]: Failed password for invalid user postgres from 192.168.1.105 port 59106
Mar  1 14:22:05 server sshd[12348]: Accepted publickey for admin from 10.10.1.42 port 51442
Mar  2 01:17:33 server sshd[12349]: Failed password for admin from 45.33.22.156 port 40022
Mar  2 01:17:35 server sshd[12350]: Failed password for admin from 45.33.22.156 port 40023
Mar  2 01:17:38 server sshd[12351]: Failed password for admin from 45.33.22.156 port 40025
Mar  2 01:17:42 server sshd[12352]: Failed password for admin from 45.33.22.156 port 40028
Mar  2 01:17:45 server sshd[12353]: Failed password for admin from 45.33.22.156 port 40030
Mar  2 01:18:01 server sshd[12354]: Accepted publickey for admin from 10.10.1.42 port 52001
Mar  2 01:18:45 server sshd[12355]: message repeated 20 times: Failed password for admin from 45.33.22.156
Mar  2 01:20:12 server sshd[12356]: Connection closed by 45.33.22.156 port 40158 [preauth]
Mar  2 02:17:45 server sshd[12357]: Accepted publickey for admin from 10.10.1.42 port 52201
Mar  2 02:35:22 server sshd[12358]: Received disconnect from 10.10.1.42 port 52201:11: disconnected by user
Mar  2 02:35:22 server sshd[12358]: Disconnected from user admin 10.10.1.42 port 52201
Mar  3 00:00:01 server CRON[12359]: pam_unix(cron:session): session opened for user root
Mar  3 00:00:01 server CRON[12359]: pam_unix(cron:session): session closed for user root
EOF

# Create shell integration
echo "Setting up shell integration..."
for home_dir in /home/*; do
  user=$(basename "$home_dir")
  
  # Backup existing .bashrc
  if [ -f "$home_dir/.bashrc" ]; then
    cp "$home_dir/.bashrc" "$home_dir/.bashrc.bak"
  fi
  
  # Add Network Chronicles integration
  echo "" >> "$home_dir/.bashrc"
  echo "# Network Chronicles Integration" >> "$home_dir/.bashrc"
  echo "if [ -f \"${INSTALL_DIR}/bin/nc-shell-integration.sh\" ]; then" >> "$home_dir/.bashrc"
  echo "  source \"${INSTALL_DIR}/bin/nc-shell-integration.sh\"" >> "$home_dir/.bashrc"
  echo "fi" >> "$home_dir/.bashrc"
  
  # Set proper ownership
  chown "$user:$user" "$home_dir/.bashrc"
  
  echo "Shell integration added for user $user"
done

echo "Creating completion message..."
cat > "${INSTALL_DIR}/welcome.txt" << EOF
 _   _      _                      _      _____ _                      _      _           
| \ | |    | |                    | |    / ____| |                    (_)    | |          
|  \| | ___| |___      _____  _ __| | __| |    | |__  _ __ ___  _ __  _  ___| | ___  ___ 
| . \` |/ _ \ __\ \ /\ / / _ \| '__| |/ /| |    | '_ \| '__/ _ \| '_ \| |/ __| |/ _ \/ __|
| |\  |  __/ |_ \ V  V / (_) | |  |   < | |____| | | | | | (_) | | | | | (__| |  __/\__ \\
|_| \_|\___|\__| \_/\_/ \___/|_|  |_|\_\ \_____|_| |_|_|  \___/|_| |_|_|\___|_|\___||___/
                                                                                          
THE VANISHING ADMIN

Welcome to Network Chronicles! The game is now installed and ready for your demonstration.

Getting Started:
1. Start exploring with the following commands:
   - nc-status    - View current game status
   - nc-journal   - Access your journal
   - nc-map       - View network map
   - nc-help      - Show all available commands

2. Demo Walkthrough:
   - Find the welcome message
   - Map the network infrastructure
   - Discover the monitoring service
   - Investigate unusual traffic patterns
   - Secure the vulnerable service

Your mission is to uncover what happened to The Architect while
documenting and securing the network infrastructure.

Good luck, Administrator!
EOF

# Create symlinks for easy access
ln -sf "${INSTALL_DIR}/bin/network-chronicles-engine.sh" /usr/local/bin/network-chronicles
ln -sf "${INSTALL_DIR}/bin/network-map.sh" /usr/local/bin/nc-map

echo "Installation complete!"
echo "Please restart your shell or run 'source ~/.bashrc' to activate Network Chronicles."
echo ""
cat "${INSTALL_DIR}/welcome.txt"
echo ""
echo "To begin your adventure, type 'nc-status'."