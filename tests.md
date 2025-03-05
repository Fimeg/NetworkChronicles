# Network Chronicles Testing Guide

This document outlines the key testing scenarios and "cheats" to quickly validate the Network Chronicles demo functionality.

## Quick Start

1. Run the Docker container:
   ```
   docker-compose up -d
   docker exec -it network-chronicles bash
   su - player
   ```

2. Verify shell integration is working:
   ```
   # You should see the NC prompt indicator
   nc-status
   # Should display your current status
   ```

## Testing Quests and Progression

### Tier 1: Digital Footprints

1. **Initial Access Quest**
   ```
   # Find the welcome message
   cat ~/.local/share/network-chronicles/message.txt
   
   # Record the discovery
   nc-add-discovery welcome_message
   
   # Check status - quest should update
   nc-status
   ```

2. **Map Network Quest**
   ```
   # Discover the network components
   nc-add-discovery network_gateway
   nc-add-discovery local_network
   
   # Check status - quest should update
   nc-status
   ```

3. **Investigate Unusual Traffic Quest**
   ```
   # Find the monitoring service
   nc-add-discovery monitoring_service
   
   # Analyze the logs
   cat /var/log/auth.log | grep "45.33.22.156"
   
   # Check status - quest should update
   nc-status
   ```

4. **Secure Vulnerable Service Quest**
   ```
   # Skip implementing the firewall rule with discovery shortcut
   nc-add-discovery secured_service
   
   # Check status - quest should update
   nc-status
   ```

5. **Analyze Breach Timeline Quest**
   ```
   # Add the breach timeline discovery
   nc-add-discovery breach_timeline
   
   # Check status - quest should update
   nc-status
   ```

6. **Discover The Architect's Final Message Quest**
   ```
   # Find and read the message
   mkdir -p /home/player/.architect
   echo "Test message from The Architect" > /home/player/.architect/final_message.txt
   cat /home/player/.architect/final_message.txt
   
   # Add discovery manually if not triggered
   nc-add-discovery architects_final_message
   
   # Check status - should advance to Tier 2
   nc-status
   ```

## Network Map Visualization

```
# View the network map
nc-map
```

## Checking Journal Entries

```
# View journal entries
nc-journal
```

## Reset Demo (if needed)

```
# Exit player account
exit

# Remove player data to restart
rm -rf /opt/network-chronicles/data/players/player

# Log in again
su - player
```

## Complete Demo in 60 Seconds

For a quick demonstration of the entire Tier 1 storyline:

```
nc-add-discovery welcome_message
nc-add-discovery network_gateway
nc-add-discovery local_network
nc-add-discovery monitoring_service
nc-add-discovery unusual_traffic
nc-add-discovery secured_service
nc-add-discovery breach_timeline
nc-add-discovery architects_final_message
nc-status
nc-map
nc-journal
```

## Common Issues and Fixes

1. **Shell integration not working**
   - Check if sourced correctly: `source /opt/network-chronicles/bin/nc-shell-integration.sh`

2. **Commands not found**
   - Ensure installation paths are correct: `ls -la /opt/network-chronicles/bin/`

3. **Permissions issues**
   - Fix with: `chmod +x /opt/network-chronicles/bin/*.sh`

4. **Discovery not triggered**
   - Use manual discovery: `nc-add-discovery [discovery_id]`