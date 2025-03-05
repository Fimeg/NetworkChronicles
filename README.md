####EARLY EARLY ALPHA - I DO NOT recommend anyone but developers use this - yet... ###

# Network Chronicles: The Vanishing Admin

A gamified self-discovering documentation system that transforms traditional network documentation into an immersive mystery adventure.

![Network Chronicles Logo](assets/images/logo.png)

## Overview

Network Chronicles revolutionizes technical documentation by transforming it from a passive reading experience into an interactive adventure. By embedding critical infrastructure knowledge within an engaging narrative framework, it addresses the fundamental challenge of IT documentation: making it compelling enough that people actually want to engage with it.

Players assume the role of a new system administrator tasked with maintaining a network after the mysterious disappearance of their predecessor, known only as "The Architect." Through exploration, puzzle-solving, and documentation, players uncover both the network's secrets and the truth behind The Architect's vanishing.

## Key Features

- **Narrative-Driven Discovery:** Learn about your infrastructure through an engaging storyline
- **Progressive Knowledge Building:** Information is revealed at the appropriate time and context
- **Active Learning Model:** Discover, solve problems, and document findings
- **Gamification Elements:** Experience points, tiers, achievements, and challenges
- **Terminal Integration:** Seamlessly blends with your actual terminal experience
- **Dynamic Journal System:** Automatically documents discoveries and progress
- **Extensible Content:** Easy to customize for your specific infrastructure

## Installation

### System Requirements

- Linux or macOS
- Bash or Zsh shell
- jq (JSON processor)
- Node.js (optional, for advanced features)

### Quick Install

For a standard installation:

```bash
curl -sSL https://network-chronicles.example.com/install.sh | bash
```

For a user-space installation (no root required):

```bash
curl -sSL https://network-chronicles.example.com/install-user.sh | bash
```

### Docker Installation

```bash
git clone https://github.com/network-chronicles/network-chronicles.git
cd network-chronicles
docker-compose up -d
```

## Getting Started

After installation, log out and log back in to activate the shell integration. You'll see a welcome message and instructions on how to begin.

Basic commands:

- `nc-status` - Display your current status
- `nc-journal` - View your journal
- `nc-help` - Show available commands

## Customization

Network Chronicles is designed to be customized for your specific infrastructure. See the [Content Creation Guide](docs/content-creation.md) for details on how to:

- Add custom quests and challenges
- Integrate with your actual network infrastructure
- Create your own narrative elements
- Extend the system with new features

## Architecture

The system consists of several components:

1. **Core Game Engine** - Manages player state, story progression, and game mechanics
2. **Shell Integration** - Provides a seamless interface between the terminal and the game
3. **Journal System** - Interactive documentation that evolves with player progress
4. **Content Management** - Handles narrative elements, challenges, and discoveries
5. **Infrastructure Integration** - Connects the game with real network infrastructure

For more details, see the [Architecture Documentation](docs/architecture.md).

## Development

For information on developing and extending Network Chronicles, see the [Development Guide](docs/development.md).

## API

Network Chronicles provides several APIs for integration with other systems. See the [API Documentation](docs/api.md) for details.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by the countless system administrators who maintain our digital infrastructure
- Thanks to all contributors and testers who have helped shape this project
