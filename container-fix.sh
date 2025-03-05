#!/bin/bash
# Script to fix container permission issues
# Run this inside the container

# Create directories
mkdir -p /opt/network-chronicles/data/players/player
mkdir -p /opt/network-chronicles/logs

# Set wide-open permissions
chmod -R 777 /opt/network-chronicles/data
chmod -R 777 /opt/network-chronicles/logs

# Create initial player files manually
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

# Set permissions on files
chmod 777 /opt/network-chronicles/data/players/player/profile.json
chmod 777 /opt/network-chronicles/data/players/player/journal.json

# Create player Documents directory
mkdir -p /home/player/Documents
chown -R player:player /home/player/Documents

# Create a welcome.txt file to help with exploration
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

# Fix permissions for welcome.txt
chown player:player /home/player/Documents/welcome.txt
chmod 644 /home/player/Documents/welcome.txt

echo "Fix complete. Please try nc-status and nc-journal now."