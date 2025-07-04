# Migration Guide: Network Chronicles v1.x → 2.0

This guide helps existing Network Chronicles users understand the changes and transition to version 2.0.

## 🚨 Breaking Changes Overview

Network Chronicles 2.0 is a **complete rewrite** and is **not compatible** with previous versions. This means:

- ❌ No automatic migration of player data
- ❌ Different installation process and requirements  
- ❌ Changed command structure and gameplay mechanics
- ❌ New file structure and configuration format

## 🎯 Why the Rewrite?

### v1.x Limitations
- Shell script architecture was difficult to extend
- Limited interactive features and user engagement
- Challenging to contribute content and improvements
- Platform compatibility issues and installation complexity

### v2.0 Improvements  
- React-based web interface with authentic terminal feel
- Real-time system integration and service discovery
- Enhanced narrative with cyberpunk mystery elements
- Community-friendly content contribution system
- Docker support and easier deployment options

## 📋 Migration Decision Matrix

### Stay with v1.x if:
- ✅ You have extensive customizations that work well
- ✅ Your setup is stable and meets your needs
- ✅ You prefer pure shell script implementation
- ✅ You want to avoid learning new interface

### Migrate to v2.0 if:
- ✅ You want enhanced interactive features
- ✅ You're interested in the cyberpunk narrative
- ✅ You want to contribute content to the community
- ✅ You prefer modern web-based interfaces
- ✅ You want active development and new features

## 🔄 Migration Paths

### Path 1: Fresh Start (Recommended)
**Best for**: Most users wanting the full v2.0 experience

1. **Backup your v1.x setup**:
   ```bash
   # Create backup directory
   mkdir ~/network-chronicles-v1-backup
   
   # Copy your existing installation
   cp -r /opt/network-chronicles ~/network-chronicles-v1-backup/
   cp -r ~/.config/network-chronicles ~/network-chronicles-v1-backup/config/
   
   # Export your player data if customized
   cp -r ~/.local/share/network-chronicles ~/network-chronicles-v1-backup/data/
   ```

2. **Install v2.0 fresh**:
   ```bash
   # Clone the new version
   git clone https://github.com/network-chronicles/network-chronicles.git
   cd network-chronicles
   
   # Install dependencies and build
   npm install
   npm run build
   
   # Start the application
   npm run serve
   ```

3. **Access via web browser**:
   - Open http://localhost:3000
   - Begin fresh learning journey

### Path 2: Side-by-Side Setup
**Best for**: Users who want to keep both versions

1. **Keep v1.x installation** in current location
2. **Install v2.0 in different directory**:
   ```bash
   mkdir ~/network-chronicles-2.0
   cd ~/network-chronicles-2.0
   git clone https://github.com/network-chronicles/network-chronicles.git .
   npm install && npm run build
   ```

3. **Use different ports** if running simultaneously:
   ```bash
   # v2.0 on custom port
   PORT=3001 npm run serve
   ```

### Path 3: Docker Migration
**Best for**: Users wanting containerized deployment

1. **Backup existing data** (same as Path 1)
2. **Use Docker Compose**:
   ```bash
   git clone https://github.com/network-chronicles/network-chronicles.git
   cd network-chronicles
   docker-compose up -d
   ```

3. **Access at http://localhost:3000**

## 📊 Feature Comparison

| Feature | v1.x | v2.0 |
|---------|------|------|
| **Interface** | Pure terminal | Web-based terminal emulation |
| **Narrative** | Basic shell prompts | Rich cyberpunk mystery story |
| **Learning Path** | Linear command discovery | Quest-based exploration |
| **System Integration** | Limited | Real-time service discovery |
| **Customization** | Shell script editing | JSON-based content system |
| **Community Content** | Manual file editing | Structured contribution templates |
| **Installation** | Shell scripts | npm/Docker |
| **Platform Support** | Linux/macOS | Linux/macOS/Windows (via Docker) |
| **Progress Tracking** | File-based | JSON state management |
| **Visual Features** | None | CRT effects, syntax highlighting |

## 🛠️ Data Migration (Manual)

While automatic migration isn't supported, you can manually transfer some concepts:

### Player Progress
v1.x stored progress in files. In v2.0, you can:

1. **Review your v1.x achievements**:
   ```bash
   # Check your old progress
   cat ~/.local/share/network-chronicles/player_profile.json
   ```

2. **Set similar progress in v2.0**:
   - Use the web interface to progress through quests
   - Your learning experience will be enhanced with new narrative

### Custom Commands
v1.x custom commands can inspire v2.0 contributions:

1. **Document your v1.x customizations**
2. **Contribute to v2.0** using the [content contribution system](CONTRIBUTING_NARRATIVE.md)
3. **Share with the community** to benefit everyone

### Configuration Preferences
Some preferences can be manually applied:

```javascript
// v2.0 preferences (stored in browser localStorage)
{
  "terminalTheme": "cyberpunk",
  "difficultyLevel": "intermediate", 
  "showHints": true,
  "enableCRTEffects": true
}
```

## 🆘 Troubleshooting Migration Issues

### Common Problems

#### "Can't find v1.x installation"
- Check `/opt/network-chronicles` and `~/.local/share/network-chronicles`
- Look for shell integration in `~/.bashrc` or `~/.zshrc`

#### "v2.0 won't start"
- Ensure Node.js 16+ is installed: `node --version`
- Check for port conflicts: `lsof -i :3000`
- Review build logs: `npm run build`

#### "Missing my old progress"
- v2.0 progress is separate and starts fresh
- Consider this an opportunity to experience improved learning path

#### "Performance issues"
- v2.0 is web-based and requires modern browser
- Minimum requirements: Chrome 90+, Firefox 88+, Safari 14+

### Getting Help

1. **Check documentation**: [ALPHA_TESTING.md](ALPHA_TESTING.md)
2. **Search existing issues**: Use GitHub issue search
3. **Create migration issue**: Use `migration-help` label
4. **Community discussions**: Ask in GitHub Discussions

## 📚 Learning v2.0 Differences

### New Concepts to Learn

#### Quest System
- **v1.x**: Linear command discovery
- **v2.0**: Story-driven investigation missions with objectives

#### Service Discovery
- **v1.x**: Manual network scanning
- **v2.0**: Automatic detection with narrative context

#### Educational Moments
- **v1.x**: Basic command help
- **v2.0**: Interactive learning with safety guidance

#### Community Content
- **v1.x**: Edit shell scripts directly
- **v2.0**: JSON-based templates for contributions

### Commands Mapping

| v1.x Command | v2.0 Equivalent | Notes |
|--------------|-----------------|-------|
| `nc-status` | `nc-status` | Enhanced with more information |
| `nc-help` | `nc-help` | Separated from general `help` |
| `nc-journal` | Built into web UI | Accessible via interface |
| Custom commands | Quest system | Integrated into narrative |

## 🎯 Next Steps After Migration

### For New v2.0 Users
1. **Start the tutorial**: Follow the getting started popup
2. **Explore freely**: Discovery is encouraged and safe
3. **Read the narrative**: The Architect's story unfolds through exploration
4. **Join the community**: Contribute content and provide feedback

### For v1.x Veterans
1. **Appreciate the improvements**: Notice enhanced UX and features  
2. **Share knowledge**: Help other users with migration
3. **Contribute content**: Your experience can enrich the narrative
4. **Provide feedback**: Help shape v2.0 development

## 📝 Migration Checklist

### Before Migration
- [ ] Backup existing v1.x installation and data
- [ ] Document any custom configurations or commands
- [ ] Note your progress and favorite features
- [ ] Ensure system meets v2.0 requirements

### During Migration  
- [ ] Choose appropriate migration path
- [ ] Follow installation instructions carefully
- [ ] Test v2.0 functionality before removing v1.x
- [ ] Keep v1.x backup until comfortable with v2.0

### After Migration
- [ ] Explore v2.0 features and interface
- [ ] Provide feedback on your migration experience
- [ ] Consider contributing to community content
- [ ] Help other users with their migration questions

## 🎉 Welcome to Network Chronicles 2.0!

The migration to v2.0 represents a significant evolution in the Network Chronicles experience. While it requires starting fresh, the enhanced features, improved learning experience, and community-driven development make it a worthwhile transition.

Remember: **Both versions serve different needs**. There's no pressure to migrate immediately, and the legacy version remains available for those who prefer it.

Thank you for being part of the Network Chronicles community! 🚀