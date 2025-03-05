#!/bin/bash
# Fix permissions in the container

# Set up directories
mkdir -p /opt/network-chronicles/data/players/player
mkdir -p /opt/network-chronicles/logs
mkdir -p /home/player/Documents

# Fix permissions
chown -R player:player /opt/network-chronicles/data/players/player
chmod -R 777 /opt/network-chronicles/data/players
chmod -R 777 /opt/network-chronicles/logs
chown -R player:player /home/player

# Initialize player profile with correct permissions
if [ ! -f "/opt/network-chronicles/data/players/player/profile.json" ]; then
  cat > "/opt/network-chronicles/data/players/player/profile.json" << EOF
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

# Initialize journal with correct permissions
if [ ! -f "/opt/network-chronicles/data/players/player/journal.json" ]; then
  cat > "/opt/network-chronicles/data/players/player/journal.json" << EOF
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

# Set 777 permissions for everything to ensure any process can read/write
chmod 777 /opt/network-chronicles/data/players/player/profile.json
chmod 777 /opt/network-chronicles/data/players/player/journal.json

echo "Fixed permissions and initialized player data"