# Network Chronicles: Content Creation Guide

This guide provides instructions for creating and extending content for the Network Chronicles system. Whether you're adding new quests, challenges, or narrative elements, this document will help you understand the content structure and creation process.

## Content Overview

Network Chronicles content is organized into several categories:

- **Quests**: Main storyline and side mission definitions
- **Challenges**: Interactive puzzles and tasks
- **Discoveries**: Elements that can be discovered through exploration
- **Events**: Triggered actions based on player behavior
- **Artifacts**: In-game items and collectibles
- **Messages**: Communications from NPCs or the system

All content is stored in the `content/` directory with appropriate subdirectories for each category.

## File Formats

Network Chronicles uses the following file formats for content:

- **JSON**: For structured data like quest definitions, discovery criteria, and event triggers
- **Markdown**: For narrative text, journal entries, and documentation
- **Bash/Shell Scripts**: For event handlers and challenge implementations
- **JavaScript**: For more complex content logic (when using the Node.js extensions)

## Creating Quests

Quests are the main storyline elements that guide players through the game. Each quest consists of a JSON definition file and a Markdown description file.

### Quest Definition (JSON)

Create a new file in `content/narrative/quests/` with the following structure:

```json
{
  "id": "investigate_unusual_traffic",
  "name": "Investigate Unusual Network Traffic",
  "description": "The Architect noted unusual traffic patterns before disappearing. Investigate the network logs to find clues.",
  "tier": 2,
  "xp": 150,
  "required_discoveries": [
    "network_logs",
    "monitoring_system"
  ],
  "required_items": [
    "admin_credentials"
  ],
  "next_quest": "trace_intrusion_source",
  "story_flags": {
    "discovered_breach": true
  }
}
```

### Quest Description (Markdown)

Create a matching Markdown file with the same name as the quest ID:

```markdown
# Investigate Unusual Network Traffic

The monitoring system has flagged unusual traffic patterns in the days leading up to The Architect's disappearance. These patterns might provide clues about what happened.

## Objectives

1. Access the network monitoring system
2. Locate the traffic logs from March 1-3
3. Identify any unusual patterns or unauthorized access attempts
4. Document your findings in your journal

## Hints

- The monitoring dashboard should be accessible at http://monitor.internal.network
- Look for traffic to unexpected destinations or at unusual times
- The Architect mentioned something about "following the packets" in their notes

## Rewards

- Network Analysis skill point
- Access to Security Subsystem
```

## Creating Challenges

Challenges are interactive puzzles or tasks that test the player's skills. Each challenge consists of a shell script implementation and optional supporting files.

### Challenge Implementation (Shell Script)

Create a new script in `content/challenges/` with the following structure:

```bash
#!/bin/bash
# encrypted-message-challenge.sh - A challenge to decrypt a message from The Architect

# Configuration
GAME_ROOT="/opt/network-chronicles"
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

echo -e "\033[1;36m[NEW CHALLENGE]\033[0m The Encrypted Message"
echo "You've found an encrypted message from The Architect."
echo "Decrypt it to reveal important information about the network infrastructure."

# Create the encrypted message if it doesn't exist
if [ ! -f "${PLAYER_STATE}/inventory/encrypted_message.txt" ]; then
  # Create the message
  cat > /tmp/secret_message.txt << EOF
To the new administrator,

If you're reading this, you've successfully decrypted my message. Well done.

The network has been compromised through the external VPN service. I've found
evidence of unauthorized access from IP 45.33.22.156 targeting our research data.

I've implemented countermeasures, but I need to investigate further. The security
keys for the research database are in the usual secure location, encrypted with
the standard rotation cipher (offset 13).

Be careful who you trust. Not everyone is who they claim to be.

- The Architect
EOF

  # Encrypt the message with a simple Caesar cipher (ROT13)
  cat /tmp/secret_message.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m' > "${PLAYER_STATE}/inventory/encrypted_message.txt"
  
  # Add a hint file
  cat > "${PLAYER_STATE}/inventory/decryption_hint.txt" << EOF
The Architect used simple rotation ciphers for quick communications.
Common tools like 'tr' can be used to decrypt these messages.
Remember the standard rotation offset we agreed on.
EOF

  # Clean up
  rm /tmp/secret_message.txt
  
  # Add to player inventory
  tmp=$(mktemp)
  jq '.inventory += ["encrypted_message", "decryption_hint"]' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"
  
  # Add notification
  echo -e "\nItems added to your inventory: encrypted_message.txt, decryption_hint.txt"
  echo -e "Use 'cat ${PLAYER_STATE}/inventory/encrypted_message.txt' to view the encrypted message."
  echo -e "Use 'cat ${PLAYER_STATE}/inventory/decryption_hint.txt' for decryption hints.\n"
fi

# Create a trigger for when the player decrypts the message
cat > "${GAME_ROOT}/triggers/decrypted_message.json" << EOF
{
  "pattern": ".*tr.*'A-Za-z'.*'N-ZA-Mn-za-m'.*encrypted_message\\.txt.*|.*cat.*encrypted_message\\.txt.*\\|.*tr.*",
  "event": "decrypted_message",
  "one_time": true
}
EOF

# Create the event handler
cat > "${GAME_ROOT}/events/decrypted_message.sh" << EOF
#!/bin/bash
PLAYER_ID="\$1"
PLAYER_STATE="${GAME_ROOT}/data/players/\${PLAYER_ID}"

# Check if already triggered
if jq -e '.story_flags.decrypted_message' "\${PLAYER_STATE}/profile.json" > /dev/null; then
  exit 0
fi

# Update player state
tmp=\$(mktemp)
jq '.story_flags.decrypted_message = true | .xp += 75 | .skill_points.security += 1' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;32m[CHALLENGE COMPLETE]\033[0m The Encrypted Message (+75 XP)"
echo -e "You successfully decrypted The Architect's message!"
echo -e "You gained +1 Security skill point."
echo -e "The message reveals information about a potential security breach.\n"

# Add journal entry
cat > "\${PLAYER_STATE}/journal/\$(date +%Y-%m-%d)_decrypted_message.md" << 'EOJ'
# Success: Decrypted Message from The Architect

I successfully decrypted the message from The Architect using a ROT13 cipher:

\`\`\`
cat encrypted_message.txt | tr 'A-Za-z' 'N-ZA-Mn-za-m'
\`\`\`

The decrypted message reveals that The Architect discovered unauthorized access to our network through the external VPN service. The intrusion came from IP 45.33.22.156 and targeted our research data.

The Architect implemented countermeasures but needed to investigate further. They mentioned that the security keys for the research database are stored in "the usual secure location" and encrypted with a rotation cipher (offset 13).

Most concerning is the warning to "be careful who you trust" and that "not everyone is who they claim to be." This suggests there might be an insider threat or someone impersonating a trusted individual.

I should:
1. Check the VPN logs for access from the suspicious IP
2. Secure the research database
3. Look for the security keys in the secure location
4. Be cautious about sharing my findings with others
EOJ

# Trigger next quest if appropriate
tmp=\$(mktemp)
jq '.current_quests += ["investigate_vpn_breach"]' "\${PLAYER_STATE}/profile.json" > "\$tmp" && mv "\$tmp" "\${PLAYER_STATE}/profile.json"

# Add quest notification
echo -e "\033[1;36m[NEW QUEST]\033[0m Investigate VPN Breach"
echo -e "Check the VPN logs for access from the suspicious IP address.\n"

# Check for level up
"${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_level_up"
EOF

chmod +x "${GAME_ROOT}/events/decrypted_message.sh"

echo "Challenge initialized. Check your inventory for the encrypted message."
```

## Creating Discoveries

Discoveries are elements that players can find through exploration and command execution. Each discovery is defined in a JSON file.

### Discovery Definition (JSON)

Create a new file in `content/discoveries/` with the following structure:

```json
{
  "id": "monitoring_dashboard",
  "name": "Network Monitoring Dashboard",
  "description": "A web-based dashboard for monitoring network traffic and system health",
  "command": ".*curl.*monitor\\.internal\\.network.*|.*wget.*monitor\\.internal\\.network.*|.*firefox.*monitor\\.internal\\.network.*",
  "xp": 40,
  "tier": 2,
  "data": {
    "location": "http://monitor.internal.network",
    "access_level": "admin",
    "discovered_at": "runtime"
  },
  "journal_entry": {
    "title": "Discovery: Network Monitoring Dashboard",
    "content": "I've found the network monitoring dashboard at http://monitor.internal.network. This dashboard provides real-time information about network traffic, system health, and security alerts.\n\nThe dashboard shows historical data going back several months, which might contain clues about unusual activity before The Architect's disappearance.\n\nI should examine the traffic patterns and security alerts from the days leading up to the incident."
  }
}
```

## Creating Events

Events are triggered by specific player actions and drive the game narrative forward. Each event consists of a trigger definition and an event handler script.

### Event Trigger (JSON)

Create a new file in `content/triggers/` with the following structure:

```json
{
  "pattern": ".*ssh.*research-server.*|.*ping.*research-server.*",
  "event": "discovered_research_server",
  "one_time": true,
  "conditions": {
    "tier_min": 2,
    "discoveries": ["network_map"]
  }
}
```

### Event Handler (Shell Script)

Create a matching script in `content/events/` with the following structure:

```bash
#!/bin/bash
# discovered_research_server.sh - Event handler for discovering the research server

PLAYER_ID="$1"
COMMAND="$2"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Check if already triggered
if jq -e '.discoveries | index("research_server")' "${PLAYER_STATE}/profile.json" > /dev/null; then
  exit 0
fi

# Update player state
tmp=$(mktemp)
jq '.discoveries += ["research_server"] | .xp += 50' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n\033[1;32m[DISCOVERY]\033[0m Research Server (+50 XP)"
echo -e "You've discovered the research server where The Architect stored their most important work."
echo -e "This server might contain critical information about their disappearance.\n"

# Add journal entry
cat > "${PLAYER_STATE}/journal/$(date +%Y-%m-%d)_research_server.md" << 'EOJ'
# Discovery: Research Server

I've discovered the existence of a dedicated research server that The Architect used for their most important work. This server is isolated from the main network and appears to have enhanced security measures.

The server is located at `research-server.internal.network` (10.10.5.50) and requires special credentials to access.

This could be where The Architect stored their findings about the security breach they were investigating. I need to find a way to access this server securely.
EOJ

# Update network map if it exists
if [ -f "${PLAYER_STATE}/network_map/network_map.txt" ]; then
  # Add the research server to the network map
  # Implementation depends on map format
  echo "Research server added to network map."
fi

# Check for quest updates
"${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"
```

## Creating Artifacts

Artifacts are collectible items that players can find and use. Each artifact is defined in a JSON file.

### Artifact Definition (JSON)

Create a new file in `content/artifacts/` with the following structure:

```json
{
  "id": "architects_key",
  "name": "The Architect's Private Key",
  "description": "A cryptographic key that provides access to The Architect's secure systems",
  "type": "credential",
  "tier": 3,
  "location": "/etc/ssh/architect_key",
  "discovery_command": ".*cat.*\\/etc\\/ssh\\/architect_key.*|.*ls.*\\/etc\\/ssh.*",
  "properties": {
    "encrypted": true,
    "passphrase_hint": "The name of my first server",
    "access_level": "administrator"
  },
  "use_commands": [
    "ssh -i /etc/ssh/architect_key architect@secure-server",
    "scp -i /etc/ssh/architect_key file architect@secure-server:"
  ],
  "journal_entry": {
    "title": "The Architect's Private Key",
    "content": "I've found The Architect's private SSH key in /etc/ssh/architect_key. This key should provide access to their secure systems, but it's encrypted with a passphrase.\n\nThe hint suggests the passphrase is 'the name of my first server'. I'll need to find that information somewhere in The Architect's notes or personal files.\n\nOnce decrypted, this key could give me access to systems that might reveal what happened to The Architect."
  }
}
```

## Creating Messages

Messages are communications from NPCs or the system to the player. Each message is defined in a Markdown file.

### Message Content (Markdown)

Create a new file in `content/narrative/messages/` with the following structure:

```markdown
# Urgent Message from Security Team

**From:** security@internal.network
**To:** admin@internal.network
**Subject:** Unusual Access Patterns Detected
**Date:** March 2, 2025 09:15:22

---

Administrator,

Our automated security systems have detected unusual access patterns over the past 48 hours. Several login attempts from external IP addresses have been blocked, but we're seeing evidence of potential lateral movement within the network.

The previous administrator was investigating this issue before their sudden departure. We recommend:

1. Reviewing authentication logs in `/var/log/auth.log`
2. Checking the network monitoring dashboard for unusual traffic
3. Verifying the integrity of critical system files
4. Ensuring all security patches have been applied

Please update us on your findings as soon as possible.

Regards,
Security Team

---

**System Note:** This message was found in The Architect's email archive. The timestamp indicates it was received shortly before their disappearance.
```

## Quest Chains and Storylines

Complex narratives can be created by chaining quests together. Here's an example of a quest chain structure:

1. **Initial Quest**: `discover_monitoring_system`
   - Introduces the player to the monitoring system
   - Rewards: XP, access to monitoring dashboard

2. **Follow-up Quest**: `investigate_unusual_traffic`
   - Triggered by completing the initial quest
   - Requires analyzing traffic patterns
   - Rewards: XP, security skill point

3. **Branching Quest**: `trace_intrusion_source` or `secure_vulnerable_systems`
   - Player can choose which path to follow
   - Different rewards and story consequences

4. **Convergence Quest**: `confront_insider_threat`
   - Both branches lead here
   - Major story revelation
   - Significant rewards

Define these relationships in the quest JSON files using the `next_quest` field and conditional logic.

## Testing Content

Before adding new content to the main game, test it thoroughly:

1. Use the content testing tool:
   ```bash
   ./tools/test-content.sh content/narrative/quests/my_new_quest.json
   ```

2. Test in isolation mode:
   ```bash
   ./bin/network-chronicles-engine.sh test_mode content/challenges/my_new_challenge.sh
   ```

3. Verify journal entries are created correctly:
   ```bash
   ./bin/journal.sh test
   ```

## Content Style Guide

To maintain consistency across all game content, follow these guidelines:

### Narrative Voice

- Use second-person perspective for quest descriptions ("You discover..." not "The player discovers...")
- Use first-person perspective for journal entries ("I found..." not "You found...")
- The Architect should have a distinct voice: technical, slightly cryptic, and occasionally philosophical

### Technical Accuracy

- All commands and technical references should be accurate and functional
- Network configurations should follow standard conventions
- Security concepts should be realistic and educational

### Difficulty Progression

- Tier 1 content should be accessible to beginners
- Tier 2-3 content should require basic technical knowledge
- Tier 4-5 content should challenge experienced administrators
- Provide hints for difficult challenges

### Narrative Themes

- Mystery: The disappearance of The Architect
- Paranoia: Trust issues and potential insider threats
- Discovery: Uncovering the network's secrets
- Growth: The player's journey from novice to expert

## Contributing Content

To contribute content to the Network Chronicles project:

1. Fork the repository on GitHub
2. Create a new branch for your content
3. Add your content following the guidelines in this document
4. Test your content thoroughly
5. Submit a pull request with a clear description of your additions

The core team will review your contribution and provide feedback before merging.

## Advanced Content Creation

For advanced content creation, including custom UI elements, complex challenges, and deep infrastructure integration, see the [Advanced Content Creation Guide](advanced-content-creation.md).
