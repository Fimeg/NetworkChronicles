# Network Chronicles: System Architecture

This document outlines the architecture of the Network Chronicles system, explaining how the various components work together to create an immersive gamified documentation experience.

## System Overview

Network Chronicles is built with a modular architecture that separates game mechanics, content, and user interface components. This design allows for flexibility in deployment, content creation, and integration with real infrastructure.

![Architecture Overview](../assets/images/architecture-diagram.png)

## Core Components

### 1. Game Engine

The game engine is the central component that manages player state, story progression, and game mechanics. It's responsible for:

- Tracking player progress and state
- Processing commands and triggering events
- Managing the discovery system
- Handling quests and challenges
- Coordinating between other components

**Key Files:**
- `bin/network-chronicles-engine.sh`: Main engine script
- `src/engine/state-manager.js`: Player state management
- `src/engine/event-system.js`: Event handling system
- `src/engine/discovery-manager.js`: Discovery tracking

### 2. Shell Integration

The shell integration component provides a seamless interface between the player's terminal and the game engine. It:

- Intercepts and processes terminal commands
- Augments the command prompt with game information
- Provides game-specific commands
- Displays notifications and updates

**Key Files:**
- `bin/nc-shell-integration.sh`: Shell integration script
- `src/ui/prompt-customizer.js`: Command prompt customization
- `src/ui/notification-manager.js`: In-terminal notifications

### 3. Journal System

The journal system provides an interactive documentation interface that evolves with player progress. It:

- Displays and manages journal entries
- Organizes discovered documentation
- Provides a network map visualization
- Tracks inventory and achievements

**Key Files:**
- `bin/journal.sh`: Journal interface script
- `src/ui/journal-renderer.js`: Journal display system
- `src/ui/map-generator.js`: Network map visualization

### 4. Content Management

The content management system handles all game content, including narrative elements, challenges, and discoveries. It:

- Loads and manages story content
- Provides challenge definitions
- Defines discoverable elements
- Manages event triggers

**Key Files:**
- `src/engine/content-loader.js`: Content loading system
- `content/narrative/quests/`: Quest definitions
- `content/challenges/`: Challenge implementations
- `content/discoveries/`: Discoverable elements

### 5. Infrastructure Integration

The infrastructure integration component connects the game with real network infrastructure. It:

- Discovers and maps real network components
- Integrates real system logs with game narrative
- Adapts game content based on actual infrastructure
- Provides hooks for custom infrastructure integration

**Key Files:**
- `bin/discover-infrastructure.sh`: Infrastructure discovery script
- `src/engine/infrastructure-adapter.js`: Integration adapter
- `config/infrastructure.json`: Infrastructure configuration

## Data Flow

1. **Command Processing Flow:**
   ```
   User Command → Shell Integration → Game Engine → Event System → Player State Update → UI Update
   ```

2. **Discovery Flow:**
   ```
   User Command → Shell Integration → Game Engine → Discovery Check → Content Unlocked → Player State Update → Journal Update
   ```

3. **Quest Progression Flow:**
   ```
   Discovery → Quest Check → Quest Update → New Content Unlocked → Notification → Journal Update
   ```

## State Management

Player state is stored in JSON format and includes:

- Basic player information (ID, creation date, playtime)
- Progress metrics (tier, XP, skill points)
- Game state (quests, discoveries, achievements)
- Inventory and documentation

Example player state:

```json
{
  "player_id": "username",
  "created_at": "2025-03-01T12:00:00Z",
  "last_login": "2025-03-03T08:30:00Z",
  "playtime": 7200,
  "tier": 2,
  "xp": 1500,
  "skill_points": {
    "networking": 3,
    "security": 2,
    "systems": 1,
    "devops": 0
  },
  "current_quests": ["map_network_services"],
  "completed_quests": ["initial_access", "discover_gateway"],
  "discoveries": ["gateway", "firewall", "web_server"],
  "inventory": ["basic_terminal", "network_scanner", "admin_credentials"],
  "achievements": ["digital_archaeologist"],
  "story_flags": {
    "met_architect_ai": true,
    "discovered_breach": false
  }
}
```

## Event System

The event system uses a trigger-based approach:

1. **Triggers** are defined in JSON files that specify patterns to match against user commands
2. **Event Handlers** are shell scripts that execute when triggers are activated
3. **Notifications** are generated by event handlers to inform the player
4. **State Updates** are performed by event handlers to progress the game

Example trigger:

```json
{
  "pattern": ".*cat.*\\/var\\/log\\/auth\\.log.*|.*grep.*auth\\.log.*",
  "event": "discovered_auth_logs",
  "one_time": true
}
```

Example event handler:

```bash
#!/bin/bash
# discovered_auth_logs.sh
PLAYER_ID="$1"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"

# Update player state
tmp=$(mktemp)
jq '.discoveries += ["auth_logs"] | .xp += 30' "${PLAYER_STATE}/profile.json" > "$tmp" && mv "$tmp" "${PLAYER_STATE}/profile.json"

# Add notification
echo -e "\n[DISCOVERY] You found the authentication logs! (+30 XP)"
echo -e "These logs contain records of login attempts and may provide clues about The Architect's disappearance.\n"

# Add journal entry
cat > "${PLAYER_STATE}/journal/$(date +%Y-%m-%d)_auth_logs.md" << 'EOJ'
# Discovery: Authentication Logs

I've found the system authentication logs at `/var/log/auth.log`. These logs contain records of all login attempts to the system.

Looking through the logs, I noticed some suspicious failed login attempts from an external IP address shortly before The Architect's last login. This might be related to their disappearance.

I should investigate these IP addresses further and check for other suspicious activity in the logs.
EOJ

# Check for quest updates
"${GAME_ROOT}/bin/network-chronicles-engine.sh" process "check_quest_updates"
```

## Extension Points

Network Chronicles is designed to be extensible in several ways:

### 1. Custom Challenges

Create new challenges by adding files to the `content/challenges/` directory. Challenges can be:

- Puzzle-based (cryptography, log analysis)
- Task-based (system configuration, network mapping)
- Time-sensitive (incident response scenarios)

### 2. Custom Narrative

Extend the story by adding new quests, messages, and artifacts to the `content/narrative/` directory. The narrative system supports:

- Branching storylines
- Character development
- Side quests
- Multiple endings

### 3. Infrastructure Integration

Customize infrastructure integration by modifying:

- `config/infrastructure.json`: Define your network structure
- `bin/discover-infrastructure.sh`: Customize discovery logic
- `src/engine/infrastructure-adapter.js`: Adapt to specific environments

### 4. UI Customization

Customize the user interface by modifying:

- `bin/nc-shell-integration.sh`: Change terminal integration
- `bin/journal.sh`: Modify journal interface
- `src/ui/`: Update UI components

## Security Considerations

Network Chronicles is designed with security in mind:

1. **Privilege Separation**: The game engine runs with user privileges, while infrastructure integration may require elevated privileges.

2. **Sandboxing**: Challenges and events are executed in a controlled environment to prevent unintended system modifications.

3. **Configuration Validation**: All user-provided configuration is validated before use to prevent injection attacks.

4. **Secure Defaults**: Default configurations are secure and require explicit opt-in for features that may have security implications.

## Performance Considerations

To ensure good performance, Network Chronicles:

1. **Minimizes Command Interception Overhead**: Shell integration is designed to have minimal impact on terminal performance.

2. **Uses Background Processing**: Long-running tasks are executed in the background to keep the UI responsive.

3. **Implements Caching**: Frequently accessed content is cached to reduce load times.

4. **Provides Configuration Options**: Performance-sensitive features can be tuned or disabled based on system capabilities.

## Deployment Scenarios

Network Chronicles supports various deployment scenarios:

1. **Single-User Development Environment**: Install in user space for personal use.

2. **Multi-User Home Lab**: Install system-wide with multi-user support for shared learning.

3. **Enterprise Training Environment**: Deploy in a containerized environment for standardized training.

4. **Integrated Production Environment**: Integrate with actual production infrastructure for on-the-job training.

## Future Architecture Directions

Planned architectural improvements include:

1. **Web Interface**: A complementary web UI for enhanced visualization and remote access.

2. **API Layer**: A formal API for third-party integrations and extensions.

3. **Plugin System**: A structured plugin system for community-contributed content.

4. **Cloud Integration**: Native integration with cloud infrastructure providers.

5. **Machine Learning**: Adaptive difficulty and personalized content based on player behavior.
