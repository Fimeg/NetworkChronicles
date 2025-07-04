# Network Chronicles: API Documentation

This document provides comprehensive documentation for the Network Chronicles API, allowing developers to programmatically interact with and extend the system.

## API Overview

Network Chronicles provides several APIs for different integration needs:

1. **Command API**: For intercepting and processing terminal commands
2. **State API**: For accessing and modifying player state
3. **Content API**: For dynamically loading and managing game content
4. **Event API**: For triggering and handling game events
5. **UI API**: For customizing the user interface

These APIs can be accessed through shell scripts, JavaScript modules, or HTTP endpoints depending on the deployment configuration.

## Command API

The Command API allows you to intercept, process, and augment terminal commands.

### Shell Integration

```bash
# Register a command processor
nc-register-processor "my-processor" "/path/to/processor.sh"

# Unregister a command processor
nc-unregister-processor "my-processor"

# Process a command manually
nc-process-command "ls -la" "my-processor"
```

### Command Processor Script

```bash
#!/bin/bash
# processor.sh - Custom command processor

# Get command and player ID
COMMAND="$1"
PLAYER_ID="$2"

# Process the command
if [[ "$COMMAND" =~ ^custom-command ]]; then
  # Handle custom command
  echo "Custom command processed"
  exit 0
else
  # Pass to next processor
  exit 1
fi
```

### JavaScript Integration

```javascript
// Import the command API
const { registerProcessor, processCommand } = require('@network-chronicles/command-api');

// Register a command processor
registerProcessor('my-processor', (command, playerId) => {
  if (command.startsWith('custom-command')) {
    // Handle custom command
    console.log('Custom command processed');
    return true; // Command handled
  }
  return false; // Pass to next processor
});

// Process a command manually
processCommand('ls -la', 'my-processor');
```

### HTTP API

```
POST /api/v1/commands
Content-Type: application/json
Authorization: Bearer <api_token>

{
  "command": "ls -la",
  "player_id": "username",
  "processor": "my-processor"
}
```

Response:

```json
{
  "status": "success",
  "handled": true,
  "output": "Custom command processed"
}
```

## State API

The State API provides access to player state and game progress.

### Shell Integration

```bash
# Get player state
nc-get-state "username" "xp"

# Update player state
nc-update-state "username" ".xp += 50 | .discoveries += [\"new_item\"]"

# Check if a discovery exists
nc-has-discovery "username" "monitoring_system"
```

### JavaScript Integration

```javascript
// Import the state API
const { getPlayerState, updatePlayerState, hasDiscovery } = require('@network-chronicles/state-api');

// Get player state
const playerXp = getPlayerState('username', 'xp');

// Update player state
updatePlayerState('username', state => {
  state.xp += 50;
  state.discoveries.push('new_item');
  return state;
});

// Check if a discovery exists
const hasMonitoringSystem = hasDiscovery('username', 'monitoring_system');
```

### HTTP API

```
GET /api/v1/players/username/state?fields=xp,tier,discoveries
Authorization: Bearer <api_token>
```

Response:

```json
{
  "xp": 1250,
  "tier": 2,
  "discoveries": ["gateway", "firewall", "monitoring_system"]
}
```

```
PATCH /api/v1/players/username/state
Content-Type: application/json
Authorization: Bearer <api_token>

{
  "operations": [
    { "op": "add", "path": "/xp", "value": 50 },
    { "op": "add", "path": "/discoveries/-", "value": "new_item" }
  ]
}
```

## Content API

The Content API allows you to dynamically load, create, and manage game content.

### Shell Integration

```bash
# Load a quest
nc-load-quest "investigate_unusual_traffic"

# Create a discovery
nc-create-discovery "new_discovery" "New Discovery" "A newly created discovery" ".*custom-command.*" 50

# Check if content exists
nc-content-exists "quests" "investigate_unusual_traffic"
```

### JavaScript Integration

```javascript
// Import the content API
const { loadQuest, createDiscovery, contentExists } = require('@network-chronicles/content-api');

// Load a quest
const quest = loadQuest('investigate_unusual_traffic');

// Create a discovery
createDiscovery({
  id: 'new_discovery',
  name: 'New Discovery',
  description: 'A newly created discovery',
  command: '.*custom-command.*',
  xp: 50
});

// Check if content exists
const questExists = contentExists('quests', 'investigate_unusual_traffic');
```

### HTTP API

```
GET /api/v1/content/quests/investigate_unusual_traffic
Authorization: Bearer <api_token>
```

Response:

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

```
POST /api/v1/content/discoveries
Content-Type: application/json
Authorization: Bearer <api_token>

{
  "id": "new_discovery",
  "name": "New Discovery",
  "description": "A newly created discovery",
  "command": ".*custom-command.*",
  "xp": 50
}
```

## Event API

The Event API allows you to trigger and handle game events.

### Shell Integration

```bash
# Trigger an event
nc-trigger-event "discovered_secret" "username" "custom-command"

# Register an event handler
nc-register-handler "discovered_secret" "/path/to/handler.sh"

# Check if an event has occurred
nc-event-occurred "username" "discovered_secret"
```

### JavaScript Integration

```javascript
// Import the event API
const { triggerEvent, registerHandler, eventOccurred } = require('@network-chronicles/event-api');

// Trigger an event
triggerEvent('discovered_secret', 'username', 'custom-command');

// Register an event handler
registerHandler('discovered_secret', (playerId, command) => {
  console.log(`Player ${playerId} discovered a secret with command: ${command}`);
  // Update player state, add notifications, etc.
});

// Check if an event has occurred
const secretDiscovered = eventOccurred('username', 'discovered_secret');
```

### HTTP API

```
POST /api/v1/events
Content-Type: application/json
Authorization: Bearer <api_token>

{
  "event": "discovered_secret",
  "player_id": "username",
  "data": {
    "command": "custom-command",
    "timestamp": "2025-03-03T20:15:30Z"
  }
}
```

## UI API

The UI API allows you to customize the user interface and notifications.

### Shell Integration

```bash
# Send a notification
nc-send-notification "username" "You discovered a hidden file!" "discovery"

# Update the prompt
nc-update-prompt "username" "custom-prefix" "custom-suffix"

# Add a journal entry
nc-add-journal-entry "username" "Discovery: Hidden File" "I found a hidden file containing important information..."
```

### JavaScript Integration

```javascript
// Import the UI API
const { sendNotification, updatePrompt, addJournalEntry } = require('@network-chronicles/ui-api');

// Send a notification
sendNotification('username', 'You discovered a hidden file!', 'discovery');

// Update the prompt
updatePrompt('username', {
  prefix: 'custom-prefix',
  suffix: 'custom-suffix'
});

// Add a journal entry
addJournalEntry('username', {
  title: 'Discovery: Hidden File',
  content: 'I found a hidden file containing important information...',
  tags: ['discovery', 'important']
});
```

### HTTP API

```
POST /api/v1/players/username/notifications
Content-Type: application/json
Authorization: Bearer <api_token>

{
  "message": "You discovered a hidden file!",
  "type": "discovery",
  "priority": "normal"
}
```

## Integration Examples

### Custom Challenge Integration

This example shows how to create a custom challenge that integrates with the Network Chronicles APIs:

```javascript
// custom-challenge.js
const { getPlayerState, updatePlayerState } = require('@network-chronicles/state-api');
const { sendNotification, addJournalEntry } = require('@network-chronicles/ui-api');
const { registerHandler } = require('@network-chronicles/event-api');

// Define the challenge
const challenge = {
  id: 'decode_binary_message',
  name: 'Binary Decoder',
  description: 'Decode a binary message left by The Architect',
  tier: 2,
  xp: 100
};

// Create binary message file
const fs = require('fs');
const path = require('path');

function setupChallenge(playerId) {
  const playerState = getPlayerState(playerId);
  const playerDir = path.join('/opt/network-chronicles/data/players', playerId);
  
  // Create binary message if it doesn't exist
  const binaryPath = path.join(playerDir, 'inventory', 'binary_message.txt');
  if (!fs.existsSync(binaryPath)) {
    const message = 'The Architect has left a message in binary code';
    const binary = message.split('').map(char => char.charCodeAt(0).toString(2).padStart(8, '0')).join(' ');
    
    fs.writeFileSync(binaryPath, binary);
    
    // Update player inventory
    updatePlayerState(playerId, state => {
      state.inventory.push('binary_message');
      return state;
    });
    
    // Send notification
    sendNotification(playerId, 'You found a binary encoded message in your inventory!', 'discovery');
  }
}

// Register event handler for when player attempts to decode
registerHandler('binary_decode_attempt', (playerId, command) => {
  // Check if the player is using a valid decoding approach
  if (command.includes('binary') && (command.includes('convert') || command.includes('decode'))) {
    // Player successfully decoded the message
    updatePlayerState(playerId, state => {
      state.xp += challenge.xp;
      state.discoveries.push('decoded_binary_message');
      return state;
    });
    
    // Add journal entry
    addJournalEntry(playerId, {
      title: 'Decoded Binary Message',
      content: `I successfully decoded the binary message left by The Architect. The message reads:
      
"The Architect has left a message in binary code"

This seems to be a test to verify my technical skills. I should look for more complex encoded messages elsewhere in the system.`,
      tags: ['discovery', 'puzzle']
    });
    
    // Send completion notification
    sendNotification(playerId, `Challenge complete: ${challenge.name} (+${challenge.xp} XP)`, 'challenge');
    
    return true; // Event handled
  }
  
  return false; // Event not handled
});

// Export the challenge
module.exports = {
  challenge,
  setup: setupChallenge
};
```

### Custom UI Integration

This example shows how to create a custom UI element that integrates with the Network Chronicles:

```javascript
// custom-network-map.js
const { getPlayerState } = require('@network-chronicles/state-api');
const { registerCommand } = require('@network-chronicles/command-api');
const blessed = require('blessed');
const contrib = require('blessed-contrib');

// Register custom command
registerCommand('network-map', (args, playerId) => {
  showNetworkMap(playerId);
  return true; // Command handled
});

// Show interactive network map
function showNetworkMap(playerId) {
  const playerState = getPlayerState(playerId);
  const discoveries = playerState.discoveries || [];
  
  // Create screen
  const screen = blessed.screen({
    smartCSR: true,
    title: 'Network Chronicles: Interactive Network Map'
  });
  
  // Create map
  const map = contrib.map({
    label: 'Network Infrastructure Map',
    top: 0,
    left: 0,
    width: '80%',
    height: '70%'
  });
  
  // Create details box
  const details = blessed.box({
    label: 'Component Details',
    top: 0,
    right: 0,
    width: '20%',
    height: '70%',
    content: 'Select a component to view details',
    border: {
      type: 'line'
    },
    style: {
      border: {
        fg: 'blue'
      }
    }
  });
  
  // Create legend
  const legend = blessed.box({
    label: 'Legend',
    bottom: 0,
    left: 0,
    width: '100%',
    height: '30%',
    content: 'Green: Discovered\nRed: Security Issue\nBlue: Critical System\nGray: Undiscovered',
    border: {
      type: 'line'
    },
    style: {
      border: {
        fg: 'green'
      }
    }
  });
  
  // Add components to screen
  screen.append(map);
  screen.append(details);
  screen.append(legend);
  
  // Add markers based on discoveries
  if (discoveries.includes('gateway')) {
    map.addMarker({
      lat: 52.5,
      lon: 13.4,
      color: 'green',
      char: 'G'
    });
  }
  
  if (discoveries.includes('firewall')) {
    map.addMarker({
      lat: 52.4,
      lon: 13.4,
      color: 'red',
      char: 'F'
    });
  }
  
  if (discoveries.includes('web_server')) {
    map.addMarker({
      lat: 52.4,
      lon: 13.5,
      color: 'blue',
      char: 'W'
    });
  }
  
  // Handle key presses
  screen.key(['escape', 'q', 'C-c'], function() {
    return process.exit(0);
  });
  
  // Render the screen
  screen.render();
}

// Export the module
module.exports = {
  showNetworkMap
};
```

## Authentication and Security

### API Tokens

To use the HTTP API, you need to obtain an API token:

```bash
# Generate an API token
nc-generate-token "username" "read,write" 30

# Revoke an API token
nc-revoke-token "token_id"

# List active tokens
nc-list-tokens "username"
```

### Permission Levels

The API supports the following permission levels:

- **read**: Access to read-only endpoints
- **write**: Access to modify player state and content
- **admin**: Full access to all endpoints
- **system**: Special access for system integration

### Security Best Practices

1. **Token Management**:
   - Generate tokens with the minimum required permissions
   - Set appropriate expiration times
   - Revoke tokens when no longer needed

2. **Secure Communication**:
   - Always use HTTPS for HTTP API access
   - Encrypt sensitive data in transit

3. **Input Validation**:
   - Validate all input parameters
   - Sanitize user-generated content

4. **Rate Limiting**:
   - Implement rate limiting for API requests
   - Monitor for suspicious activity

## Error Handling

The API uses standard HTTP status codes and returns detailed error messages:

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "The parameter 'xp' must be a positive integer",
    "details": {
      "parameter": "xp",
      "value": -10,
      "constraint": "positive integer"
    }
  }
}
```

Common error codes:

- **invalid_parameter**: A parameter is missing or invalid
- **not_found**: The requested resource does not exist
- **unauthorized**: Authentication is required
- **forbidden**: The authenticated user lacks permission
- **conflict**: The request conflicts with the current state
- **internal_error**: An unexpected error occurred

## Webhooks

Network Chronicles supports webhooks for event notifications:

```bash
# Register a webhook
nc-register-webhook "https://example.com/webhook" "player.level_up,discovery.new"

# Test a webhook
nc-test-webhook "webhook_id" "player.level_up"

# List registered webhooks
nc-list-webhooks
```

### Webhook Payload

```json
{
  "event": "player.level_up",
  "timestamp": "2025-03-03T20:15:30Z",
  "player_id": "username",
  "data": {
    "previous_tier": 1,
    "new_tier": 2,
    "xp": 1050
  }
}
```

### Supported Webhook Events

- **player.level_up**: Player reached a new tier
- **player.quest_complete**: Player completed a quest
- **discovery.new**: Player made a new discovery
- **challenge.complete**: Player completed a challenge
- **system.startup**: System started up
- **system.shutdown**: System is shutting down

## API Versioning

The Network Chronicles API uses semantic versioning:

- **Major version** (v1, v2): Breaking changes
- **Minor version** (v1.1, v1.2): New features, non-breaking
- **Patch version** (v1.1.1, v1.1.2): Bug fixes

API endpoints include the major version in the URL path:

```
/api/v1/players
/api/v2/players
```

## Rate Limiting

The API implements rate limiting to prevent abuse:

- **Standard limit**: 60 requests per minute
- **Burst limit**: 10 requests per second
- **Admin limit**: 120 requests per minute

Rate limit headers are included in all responses:

```
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1583271600
```

## Pagination

List endpoints support pagination:

```
GET /api/v1/players?limit=10&offset=20
```

Paginated responses include metadata:

```json
{
  "data": [...],
  "pagination": {
    "total": 45,
    "limit": 10,
    "offset": 20,
    "next": "/api/v1/players?limit=10&offset=30",
    "previous": "/api/v1/players?limit=10&offset=10"
  }
}
```

## API Client Libraries

Official client libraries are available for:

- **JavaScript/Node.js**: `@network-chronicles/api-client`
- **Python**: `network-chronicles-api`
- **Ruby**: `network_chronicles_api`
- **Go**: `github.com/Fimeg/NetworkChronicles/api-client-go`

### JavaScript Example

```javascript
const NetworkChronicles = require('@network-chronicles/api-client');

const client = new NetworkChronicles.Client({
  apiToken: 'your_api_token',
  baseUrl: 'https://your-server.com/api/v1'
});

async function getPlayerProgress(playerId) {
  try {
    const player = await client.players.get(playerId);
    const quests = await client.players.getQuests(playerId);
    
    console.log(`Player ${player.name} (Tier ${player.tier})`);
    console.log(`XP: ${player.xp}/${player.next_tier_xp}`);
    console.log('Active Quests:');
    quests.current.forEach(quest => {
      console.log(`- ${quest.name}`);
    });
  } catch (error) {
    console.error('API Error:', error.message);
  }
}

getPlayerProgress('username');
```

## Extending the API

You can extend the Network Chronicles API with custom endpoints:

### Custom Endpoint (JavaScript)

```javascript
// custom-api.js
const { registerEndpoint } = require('@network-chronicles/api-extension');

// Register a custom endpoint
registerEndpoint({
  method: 'GET',
  path: '/api/v1/custom/player-stats',
  handler: async (req, res) => {
    const { playerId } = req.query;
    
    // Get player state
    const playerState = await req.services.state.getPlayerState(playerId);
    
    // Calculate statistics
    const stats = {
      commandsExecuted: playerState.command_history?.length || 0,
      discoveriesFound: playerState.discoveries?.length || 0,
      questsCompleted: playerState.completed_quests?.length || 0,
      totalXp: playerState.xp || 0,
      playtime: playerState.playtime || 0,
      efficiency: calculateEfficiency(playerState)
    };
    
    // Return the statistics
    res.json({
      player_id: playerId,
      stats
    });
  },
  permissions: ['read']
});

// Helper function to calculate efficiency
function calculateEfficiency(playerState) {
  if (!playerState.playtime || playerState.playtime === 0) {
    return 0;
  }
  
  return Math.round((playerState.xp / (playerState.playtime / 3600)) * 100) / 100;
}

// Export the module
module.exports = {
  name: 'custom-player-stats'
};
```

### Registering the Extension

```bash
# Register the custom API extension
nc-register-api-extension "/path/to/custom-api.js"

# Restart the API server
nc-restart-api
```

## API Documentation Generation

Network Chronicles includes tools to generate API documentation:

```bash
# Generate API documentation
nc-generate-api-docs --format html --output /path/to/output

# Generate OpenAPI specification
nc-generate-openapi --output /path/to/openapi.json
```

## Troubleshooting

### Common Issues

1. **Authentication Failures**:
   - Verify the API token is valid and has not expired
   - Check that the token has the required permissions
   - Ensure the token is correctly included in the Authorization header

2. **Rate Limiting**:
   - Implement exponential backoff for retries
   - Optimize API usage to reduce request frequency
   - Consider caching responses where appropriate

3. **Data Consistency**:
   - Use transactions for related updates
   - Implement optimistic concurrency control
   - Validate state changes before committing

### Debugging

Enable debug mode for detailed logging:

```bash
# Enable API debug mode
nc-config set api.debug true

# View API logs
nc-logs api
```

## Support and Resources

- **API Reference**: [https://network-chronicles.example.com/api-reference](https://network-chronicles.example.com/api-reference)
- **Developer Forum**: [https://community.network-chronicles.example.com/developers](https://community.network-chronicles.example.com/developers)
- **GitHub Repository**: [https://github.com/Fimeg/NetworkChronicles/api](https://github.com/Fimeg/NetworkChronicles/api)
- **Issue Tracker**: [https://github.com/Fimeg/NetworkChronicles/api/issues](https://github.com/Fimeg/NetworkChronicles/api/issues)
