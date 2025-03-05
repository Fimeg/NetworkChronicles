# Network Chronicles: Development Guide

This guide provides detailed information for developers who want to contribute to the Network Chronicles project. It covers the development environment setup, architecture overview, coding standards, and testing procedures.

## Development Environment Setup

### Prerequisites

Before you begin, ensure you have the following installed:

- **Bash or Zsh shell**: Required for running scripts
- **Git**: For version control
- **Node.js** (v14+): For advanced features and testing
- **npm**: For package management
- **jq**: For JSON processing
- **openssl**: For encryption challenges

### Setting Up Your Development Environment

1. **Fork and Clone the Repository**

   ```bash
   git clone https://github.com/YOUR_USERNAME/network-chronicles.git
   cd network-chronicles
   git remote add upstream https://github.com/original/network-chronicles.git
   ```

2. **Install Development Dependencies**

   ```bash
   npm install
   ```

3. **Set Up Development Configuration**

   ```bash
   cp config/settings.example.json config/settings.local.json
   # Edit settings.local.json with your development settings
   ```

4. **Run the Development Setup Script**

   ```bash
   ./scripts/setup-dev.sh
   ```

## Project Structure

The Network Chronicles project is organized as follows:

```
network-chronicles/
├── bin/                    # Executable scripts
│   ├── network-chronicles-engine.sh
│   ├── journal.sh
│   └── nc-shell-integration.sh
├── src/                    # Source code
│   ├── engine/             # Core game engine
│   ├── ui/                 # User interface components
│   ├── challenges/         # Challenge implementations
│   └── utils/              # Utility functions
├── data/                   # Data storage (not in git)
│   ├── players/            # Player state and progress
│   └── global/             # Global game state
├── content/                # Game content
│   ├── narrative/          # Story elements
│   │   ├── quests/         # Quest definitions
│   │   ├── messages/       # In-game messages
│   │   └── artifacts/      # Discoverable items
│   ├── challenges/         # Challenge definitions
│   ├── discoveries/        # Discoverable elements
│   └── events/             # Event triggers and handlers
├── docs/                   # Documentation
│   ├── setup.md            # Setup instructions
│   ├── architecture.md     # System architecture
│   ├── content-creation.md # Guide for creating content
│   └── api.md              # API documentation
├── tests/                  # Test suite
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── fixtures/           # Test fixtures
├── scripts/                # Development and build scripts
├── config/                 # Configuration files
└── tools/                  # Development tools
```

## Core Components

### Game Engine

The game engine (`bin/network-chronicles-engine.sh`) is the central component that manages player state, story progression, and game mechanics. It's responsible for:

- Tracking player progress and state
- Processing commands and triggering events
- Managing the discovery system
- Handling quests and challenges

### Shell Integration

The shell integration (`bin/nc-shell-integration.sh`) provides a seamless interface between the player's terminal and the game engine. It:

- Intercepts and processes terminal commands
- Augments the command prompt with game information
- Provides game-specific commands
- Displays notifications and updates

### Journal System

The journal system (`bin/journal.sh`) provides an interactive documentation interface that evolves with player progress. It:

- Displays and manages journal entries
- Organizes discovered documentation
- Provides a network map visualization
- Tracks inventory and achievements

## Development Workflow

### Feature Development Process

1. **Create a Feature Branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Implement Your Changes**

   Follow the coding standards and ensure your changes are well-documented.

3. **Write Tests**

   Add appropriate tests for your changes in the `tests/` directory.

4. **Run Tests**

   ```bash
   npm test
   ```

5. **Submit a Pull Request**

   Push your changes to your fork and create a pull request against the main repository.

### Debugging

For debugging issues in the game engine:

1. **Enable Debug Mode**

   ```bash
   export NC_DEBUG=true
   ```

2. **Run with Verbose Logging**

   ```bash
   ./bin/network-chronicles-engine.sh status --verbose
   ```

3. **Check Logs**

   ```bash
   cat logs/engine.log
   ```

### Testing

Network Chronicles uses several types of tests:

1. **Unit Tests**

   Test individual functions and components in isolation.

   ```bash
   npm run test:unit
   ```

2. **Integration Tests**

   Test how components work together.

   ```bash
   npm run test:integration
   ```

3. **End-to-End Tests**

   Test the entire system from a user's perspective.

   ```bash
   npm run test:e2e
   ```

4. **Content Tests**

   Validate game content for correctness.

   ```bash
   npm run test:content
   ```

## Coding Standards

### Bash Scripting

- Use 2-space indentation
- Use `#!/bin/bash` shebang
- Include comments for complex logic
- Use meaningful variable names
- Quote variables to prevent word splitting
- Use functions for reusable code
- Check for errors and handle them gracefully
- Use `set -e` to exit on error when appropriate

Example:

```bash
#!/bin/bash
# Example function with error handling

function process_file() {
  local file="$1"
  
  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file" >&2
    return 1
  fi
  
  # Process the file
  cat "$file" | grep "pattern" || true
}
```

### JavaScript

- Use 2-space indentation
- Use semicolons
- Use camelCase for variables and functions
- Use PascalCase for classes
- Use UPPER_CASE for constants
- Use ES6+ features when appropriate
- Document functions with JSDoc comments
- Use async/await for asynchronous code

Example:

```javascript
/**
 * Process player data and update state
 * @param {string} playerId - The player's ID
 * @param {Object} data - The data to process
 * @returns {Promise<Object>} The updated player state
 */
async function processPlayerData(playerId, data) {
  try {
    const playerState = await getPlayerState(playerId);
    const updatedState = {
      ...playerState,
      ...data,
      lastUpdated: new Date().toISOString()
    };
    return savePlayerState(playerId, updatedState);
  } catch (error) {
    console.error(`Error processing data for player ${playerId}:`, error);
    throw error;
  }
}
```

### JSON

- Use 2-space indentation
- Use consistent property naming (camelCase preferred)
- Include comments in JSON files that support them (using `//` or `/* */`)
- Validate JSON files against schemas when possible

Example:

```json
{
  "id": "discover_monitoring_system",
  "name": "Discover Monitoring System",
  "description": "Find and access the network monitoring system",
  "tier": 2,
  "xp": 150,
  "required_discoveries": [
    "network_map",
    "admin_credentials"
  ],
  "next_quest": "investigate_unusual_traffic"
}
```

## Advanced Development Topics

### Creating Custom Challenges

Custom challenges can be created by adding a shell script to the `content/challenges/` directory:

1. Create a new script file:

   ```bash
   touch content/challenges/my_custom_challenge.sh
   chmod +x content/challenges/my_custom_challenge.sh
   ```

2. Implement the challenge logic:

   ```bash
   #!/bin/bash
   # my_custom_challenge.sh - Description of your challenge
   
   GAME_ROOT="/opt/network-chronicles"
   PLAYER_ID="$1"
   PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"
   
   echo -e "\033[1;36m[NEW CHALLENGE]\033[0m My Custom Challenge"
   echo "Description of the challenge goes here."
   
   # Challenge implementation...
   ```

3. Create any necessary supporting files
4. Test your challenge
5. Document your challenge in the appropriate quest

### Extending the API

The Network Chronicles API can be extended with custom endpoints:

1. Create a new API module in `src/api/`:

   ```javascript
   // src/api/custom-endpoint.js
   const { registerEndpoint } = require('../core/api-extension');
   
   registerEndpoint({
     method: 'GET',
     path: '/api/v1/custom/endpoint',
     handler: async (req, res) => {
       // Implementation...
       res.json({ result: 'success' });
     },
     permissions: ['read']
   });
   
   module.exports = {
     name: 'custom-endpoint'
   };
   ```

2. Register your module in `src/api/index.js`
3. Test your endpoint
4. Document your endpoint in the API documentation

### Creating Custom UI Components

Custom UI components can be added to enhance the player experience:

1. Create a new UI component in `src/ui/`:

   ```javascript
   // src/ui/custom-component.js
   const blessed = require('blessed');
   
   function createCustomComponent(screen, options) {
     const component = blessed.box({
       top: options.top || 0,
       left: options.left || 0,
       width: options.width || '50%',
       height: options.height || '50%',
       content: options.content || '',
       border: {
         type: 'line'
       },
       style: {
         border: {
           fg: options.borderColor || 'blue'
         }
       }
     });
     
     screen.append(component);
     return component;
   }
   
   module.exports = {
     createCustomComponent
   };
   ```

2. Use your component in the appropriate context
3. Test your component
4. Document your component

## Troubleshooting

### Common Issues

1. **Shell Integration Not Working**

   - Check if the integration script is sourced in your shell configuration
   - Ensure the script has execute permissions
   - Check for syntax errors in the script

2. **Game Engine Errors**

   - Check the logs for error messages
   - Verify that all required directories exist
   - Ensure JSON files are valid

3. **Content Not Loading**

   - Check file permissions
   - Verify JSON syntax
   - Ensure file paths are correct

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [documentation](./README.md)
2. Search for existing issues on GitHub
3. Ask for help in the community channels
4. Open a new issue with detailed information about your problem

## Release Process

### Versioning

Network Chronicles follows [Semantic Versioning](https://semver.org/):

- **Major version** (1.0.0): Breaking changes
- **Minor version** (0.1.0): New features, non-breaking
- **Patch version** (0.0.1): Bug fixes

### Creating a Release

1. Update the version number in `package.json` and `bin/network-chronicles-engine.sh`
2. Update the CHANGELOG.md file
3. Create a new git tag:

   ```bash
   git tag -a v1.0.0 -m "Version 1.0.0"
   git push origin v1.0.0
   ```

4. Create a GitHub release with release notes
5. Publish the release artifacts

## Additional Resources

- [GitHub Flow](https://guides.github.com/introduction/flow/)
- [Bash Scripting Guide](https://tldp.org/LDP/abs/html/)
- [JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Semantic Versioning](https://semver.org/)
