#!/bin/bash
# Script to create a proper journal.json file for debugging

# Create the data directory if it doesn't exist
mkdir -p /opt/network-chronicles/data/players/player

# Create a fresh journal.json with correct format
cat > /opt/network-chronicles/data/players/player/journal.json << 'EOF'
{
  "entries": [
    {
      "id": "welcome",
      "title": "First Day",
      "content": "Today is my first day as the new system administrator. The previous admin, known only as 'The Architect', has disappeared without a trace. I've been tasked with maintaining the system and figuring out what happened.",
      "timestamp": "2025-03-04T03:41:05Z"
    }
  ]
}
EOF

# Set permissions
chmod 644 /opt/network-chronicles/data/players/player/journal.json

echo "Journal file created at /opt/network-chronicles/data/players/player/journal.json"