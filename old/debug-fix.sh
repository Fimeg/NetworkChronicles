#!/bin/bash
# Debug and fix script - run this inside the container as root

echo "Diagnosing permissions issue..."

# Create directories if they don't exist
mkdir -p /opt/network-chronicles/data/players/player
mkdir -p /opt/network-chronicles/logs

# Check current permissions
echo "Current permissions:"
ls -la /opt/network-chronicles/data/players

# Check if profile.json exists
echo "Checking for profile.json:"
find /opt/network-chronicles/data/players -name "profile.json" -ls

# Create profile.json if it doesn't exist
if [ ! -f "/opt/network-chronicles/data/players/player/profile.json" ]; then
  echo "Creating profile.json..."
  cat > /opt/network-chronicles/data/players/player/profile.json << 'EOF'
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
  "created_at": "2025-03-04T12:00:00Z",
  "last_login": "2025-03-04T12:00:00Z"
}
EOF
fi

# Create journal.json if it doesn't exist
if [ ! -f "/opt/network-chronicles/data/players/player/journal.json" ]; then
  echo "Creating journal.json..."
  cat > /opt/network-chronicles/data/players/player/journal.json << 'EOF'
{
  "entries": [
    {
      "id": "welcome",
      "title": "First Day",
      "content": "Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.",
      "timestamp": "2025-03-04T12:00:00Z"
    }
  ]
}
EOF
fi

# Set aggressive permissions
echo "Setting permissions..."
chmod -R 777 /opt/network-chronicles/data
chmod -R 777 /opt/network-chronicles/logs

# Check result
echo "New permissions:"
ls -la /opt/network-chronicles/data/players/player/

# Check if jq can read the file
echo "Testing jq access as player:"
su - player -c "jq . /opt/network-chronicles/data/players/player/profile.json"

# Add debug version of nc-status
cat > /tmp/debug-status.sh << 'EOF'
#!/bin/bash
echo "Debug version of nc-status"
echo "Player profile path: /opt/network-chronicles/data/players/player/profile.json"

if [ -f "/opt/network-chronicles/data/players/player/profile.json" ]; then
  echo "File exists"
  ls -la /opt/network-chronicles/data/players/player/profile.json
else
  echo "File does not exist"
fi

echo "Trying to read with jq..."
jq . /opt/network-chronicles/data/players/player/profile.json

echo "=== Player Status ==="
echo "Done"
EOF
chmod +x /tmp/debug-status.sh

echo "Debug script created at /tmp/debug-status.sh"
echo "Run 'su - player' to switch to player user"
echo "Then run '/tmp/debug-status.sh' to debug"

# Add debug version of nc-journal
cat > /tmp/debug-journal.sh << 'EOF'
#!/bin/bash
echo "Debug version of nc-journal"

if [ "$1" = "welcome" ]; then
  echo "=== First Day ==="
  echo "Date: 2025-03-04 12:00:00"
  echo
  echo "Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened."
  echo
fi
EOF
chmod +x /tmp/debug-journal.sh

echo "Debug journal created at /tmp/debug-journal.sh"
echo "Run '/tmp/debug-journal.sh welcome' to test"

echo "Fix complete. Please try nc-status and nc-journal again, or use the debug scripts."