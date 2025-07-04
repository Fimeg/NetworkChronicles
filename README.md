# Network Chronicles 2.0: The Vanishing Admin

⚠️ **ALPHA RELEASE - TESTERS WELCOME!** ⚠️

🚀 **MAJOR REWRITE** - Interactive Linux learning terminal with real-time system integration and personalized narratives.

## 🧪 Alpha Testing Notice

**This is an alpha release seeking testers and feedback!**

- **Expect changes**: Story elements, commands, and features may change significantly
- **No migration support**: Moving from older versions is not supported  
- **Breaking changes**: Future updates may require starting fresh
- **Feedback welcome**: Issues, suggestions, and contributions are encouraged
- **Solo development**: Please be patient with response times

**Perfect for**: Linux learners, cyberpunk fans, interactive fiction enthusiasts, and anyone who wants to help shape an innovative learning platform.

A gamified Linux learning system that transforms traditional system administration training into an immersive cyberpunk mystery adventure.

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

- Linux, macOS, or Windows
- Node.js 16+ and npm
- Git
- Modern web browser (Chrome 90+, Firefox 88+, Safari 14+)

### Quick Install

**Local Development Installation:**

```bash
# Clone the repository
git clone https://github.com/Fimeg/NetworkChronicles.git
cd NetworkChronicles

# Install dependencies
npm install

# Build the application
npm run build

# Start the server
npm run serve
```

**Or use the install script:**

```bash
# Download and run the installer
wget https://github.com/Fimeg/NetworkChronicles/raw/main/install.sh
chmod +x install.sh
./install.sh
```

### Docker Installation

```bash
git clone https://github.com/Fimeg/NetworkChronicles.git
cd NetworkChronicles
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
