#!/bin/bash
# Complete fix script for Network Chronicles Docker container
# Copy this script to your container and run it as root

# Set up directories with proper permissions
mkdir -p /opt/network-chronicles/data/players/player
mkdir -p /opt/network-chronicles/logs
chmod -R 777 /opt/network-chronicles/data
chmod -R 777 /opt/network-chronicles/logs
mkdir -p /home/player/Documents
chown -R player:player /home/player

# Create player profile with proper permissions
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
chmod 777 /opt/network-chronicles/data/players/player/profile.json

# Create journal with proper permissions
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
chmod 777 /opt/network-chronicles/data/players/player/journal.json

# Create welcome.txt in Documents
cat > /home/player/Documents/welcome.txt << EOF
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
chmod 644 /home/player/Documents/welcome.txt

# Add direct welcome command to player's bashrc
cat >> /home/player/.bashrc << 'EOF'

# Direct welcome message function
nc-welcome() {
  echo -e "\033[0;32m=== First Day ===\033[0m"
  echo -e "Date: \033[0;36m$(date "+%Y-%m-%d %H:%M:%S")\033[0m"
  echo -e "\nToday is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.\n"
}
EOF

# Create fix for journal.sh 
mkdir -p /tmp/fixes

# Fix for journal.sh to handle welcome entry specially
cat > /tmp/fixes/journal-fix.sh << 'EOF'
#!/bin/bash
# Special journal entry display

# Display welcome entry
cat << 'WELCOME'
[32m=== First Day ===[0m
Date: [36m$(date "+%Y-%m-%d %H:%M:%S")[0m

Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.

WELCOME
EOF
chmod +x /tmp/fixes/journal-fix.sh

# Modify nc-journal to use the fix
cat > /tmp/fixes/nc-journal-wrapper.sh << 'EOF'
#!/bin/bash
# Wrapper for nc-journal

if [ "$1" = "welcome" ]; then
  /tmp/fixes/journal-fix.sh
else
  /opt/network-chronicles/bin/journal.sh "player" "$@"
fi
EOF
chmod +x /tmp/fixes/nc-journal-wrapper.sh

# Replace nc-journal in the player's bashrc
cat >> /home/player/.bashrc << 'EOF'

# Override nc-journal with fixed version
nc-journal() {
  if [ "$1" = "welcome" ]; then
    /tmp/fixes/journal-fix.sh
  else
    /opt/network-chronicles/bin/journal.sh "player" "$@"
  fi
}
EOF

echo -e "\033[0;32mAll fixes applied!\033[0m"
echo "Please log out and log back in for the changes to take effect."
echo "Then try 'nc-status', 'nc-journal welcome', and 'nc-welcome' commands."