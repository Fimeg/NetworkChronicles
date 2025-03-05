# Network Chronicles: Setup Guide

This guide provides detailed instructions for setting up the Network Chronicles system in various environments.

## System Requirements

- **Operating System**: Linux (Ubuntu 20.04+ recommended), macOS 10.15+, or Windows 10+ with WSL2
- **Shell**: Bash or Zsh
- **Required Packages**:
  - `jq` (JSON processor)
  - `openssl` (for encryption challenges)
  - `git` (for version control)
  - `nodejs` and `npm` (v14+ for advanced features)
  - `docker` and `docker-compose` (optional, for containerized deployment)

## Installation Options

### Option 1: Standard Installation (Recommended)

This option installs Network Chronicles in the standard location (`/opt/network-chronicles`) and integrates with the system.

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/network-chronicles.git
   cd network-chronicles
   ```

2. Run the installation script with sudo:
   ```bash
   sudo ./install.sh
   ```

3. Follow the prompts to configure your installation.

4. Add shell integration to your `.bashrc` or `.zshrc`:
   ```bash
   echo 'source /opt/network-chronicles/bin/nc-shell-integration.sh' >> ~/.bashrc
   ```

5. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

### Option 2: User-Space Installation

This option installs Network Chronicles in your home directory without requiring root privileges.

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/network-chronicles.git
   cd network-chronicles
   ```

2. Run the user installation script:
   ```bash
   ./install-user.sh
   ```

3. Follow the prompts to configure your installation.

4. Add shell integration to your `.bashrc` or `.zshrc`:
   ```bash
   echo 'source ~/network-chronicles/bin/nc-shell-integration.sh' >> ~/.bashrc
   ```

5. Reload your shell:
   ```bash
   source ~/.bashrc
   ```

### Option 3: Docker Installation

This option runs Network Chronicles in a Docker container, which is useful for testing or isolated environments.

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/network-chronicles.git
   cd network-chronicles
   ```

2. Build and run the Docker container:
   ```bash
   docker-compose up -d
   ```

3. Access the Network Chronicles shell:
   ```bash
   docker exec -it network-chronicles bash
   ```

## Configuration

### Basic Configuration

The main configuration file is located at `/opt/network-chronicles/config/settings.json` (or `~/network-chronicles/config/settings.json` for user installations).

You can modify this file to adjust game parameters:

```json
{
  "game": {
    "name": "Network Chronicles",
    "version": "1.0.0",
    "difficulty": "medium",
    "xp_multiplier": 1.0
  },
  "paths": {
    "data_dir": "/opt/network-chronicles/data",
    "content_dir": "/opt/network-chronicles/content",
    "log_dir": "/opt/network-chronicles/logs"
  },
  "features": {
    "multiplayer": false,
    "real_infrastructure_integration": true,
    "time_sensitive_events": true
  }
}
```

### Advanced Configuration

#### Integration with Real Infrastructure

To integrate Network Chronicles with your actual network infrastructure:

1. Edit the infrastructure configuration file:
   ```bash
   sudo nano /opt/network-chronicles/config/infrastructure.json
   ```

2. Configure your network details:
   ```json
   {
     "network": {
       "domain": "your-domain.local",
       "subnets": [
         {
           "name": "management",
           "cidr": "10.0.1.0/24",
           "vlan": 10
         },
         {
           "name": "servers",
           "cidr": "10.0.2.0/24",
           "vlan": 20
         }
       ]
     },
     "services": [
       {
         "name": "web-server",
         "host": "web.your-domain.local",
         "ip": "10.0.2.10",
         "ports": [80, 443]
       },
       {
         "name": "database",
         "host": "db.your-domain.local",
         "ip": "10.0.2.20",
         "ports": [3306]
       }
     ]
   }
   ```

3. Run the infrastructure discovery script:
   ```bash
   sudo /opt/network-chronicles/bin/discover-infrastructure.sh
   ```

#### Multi-User Setup

For environments with multiple users:

1. Edit the users configuration file:
   ```bash
   sudo nano /opt/network-chronicles/config/users.json
   ```

2. Configure user access levels:
   ```json
   {
     "users": [
       {
         "username": "admin",
         "role": "administrator",
         "starting_tier": 3
       },
       {
         "username": "user1",
         "role": "player",
         "starting_tier": 1
       }
     ],
     "teams": [
       {
         "name": "operations",
         "members": ["admin", "user1"],
         "shared_discoveries": true
       }
     ]
   }
   ```

3. Apply the user configuration:
   ```bash
   sudo /opt/network-chronicles/bin/apply-user-config.sh
   ```

## Troubleshooting

### Common Issues

#### Shell Integration Not Working

If the game prompt and commands aren't appearing:

1. Verify the integration script is sourced in your shell configuration:
   ```bash
   grep -r "nc-shell-integration" ~/.bashrc ~/.zshrc
   ```

2. Ensure the integration script is executable:
   ```bash
   chmod +x /opt/network-chronicles/bin/nc-shell-integration.sh
   ```

3. Check for errors in the shell integration:
   ```bash
   bash -x /opt/network-chronicles/bin/nc-shell-integration.sh
   ```

#### Game Engine Errors

If you encounter errors with the game engine:

1. Check the logs:
   ```bash
   cat /opt/network-chronicles/logs/engine.log
   ```

2. Verify dependencies are installed:
   ```bash
   /opt/network-chronicles/bin/check-dependencies.sh
   ```

3. Reset the game state (caution: this will erase progress):
   ```bash
   /opt/network-chronicles/bin/reset-player.sh $(whoami)
   ```

### Getting Help

If you encounter issues not covered in this guide:

1. Check the [Troubleshooting Guide](troubleshooting.md) for more detailed solutions.
2. Visit the [GitHub Issues](https://github.com/yourusername/network-chronicles/issues) page to report bugs or request help.
3. Join the [Network Chronicles Community](https://discord.gg/network-chronicles) for community support.

## Next Steps

After installation, see the [Getting Started Guide](getting-started.md) for your first steps in the Network Chronicles adventure.
