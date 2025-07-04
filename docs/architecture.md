# Network Chronicles 2.0: System Architecture

This document outlines the architecture of Network Chronicles 2.0, a React-based web application that provides an interactive Linux learning terminal experience.

## System Overview

Network Chronicles 2.0 is built with a modern web architecture that separates game logic, user interface, and content management. This design allows for better user experience, easier content creation, and simplified deployment.

## Core Components

### 1. React Frontend (`/src/`)

The frontend is a React application that provides an authentic terminal experience in the browser:

**Key Files:**
- `src/App.jsx`: Main application component
- `src/components/Terminal.jsx`: Terminal emulator with command processing
- `src/components/GettingStartedPopup.jsx`: Onboarding experience
- `src/components/QuestPanel.jsx`: Quest management interface
- `src/components/SplashScreen.jsx`: Loading screen experience

**Features:**
- CRT terminal effects and authentic Linux terminal feel
- Command syntax highlighting
- Tab completion and command history
- Real-time system integration

### 2. Game Engine (`/src/game/`)

The game engine manages all game logic, state, and narrative progression:

**Key Files:**
- `src/game/GameEngine.js`: Core game logic and command processing
- `src/game/SystemIntegration.js`: Real system integration and service discovery

**Responsibilities:**
- Player state management (XP, level, progress)
- Quest system and narrative progression
- Command execution and validation
- Discovery system and learning tracking
- Educational failure system with consequences

### 3. Content System (`/content/`)

A JSON-based content management system that stores all game content:

**Structure:**
```
content/
├── artifacts/           # Hidden messages and discoveries
├── challenges/          # Shell scripts for challenges
├── discoveries/         # Discovery definitions and rewards
├── events/             # Event scripts and triggers
├── narrative/          # Story content and quests
├── templates/          # Service templates
└── triggers/           # Event trigger definitions
```

**Key Features:**
- Modular content system for easy contribution
- JSON-based configuration for non-technical contributors
- Validation scripts for content quality
- Extensible service discovery templates

### 4. Express Backend (`/server.js`)

A lightweight Node.js backend that serves the application and handles API requests:

**Responsibilities:**
- Static file serving
- WebSocket support for real-time features
- Health check endpoints
- CORS configuration for development

### 5. Build System

**Tools:**
- **Vite**: Fast build tool and development server
- **React**: Component-based UI framework
- **CSS**: Custom styling with CRT effects and terminal themes

**Scripts:**
- `npm run dev`: Development server with hot reloading
- `npm run build`: Production build
- `npm run serve`: Production server

## Data Flow

1. **User Input**: Commands entered in the terminal component
2. **Game Engine**: Processes commands and updates game state
3. **Content System**: Provides quest data, discoveries, and narrative
4. **UI Update**: React re-renders based on state changes
5. **System Integration**: Real-time service discovery and network analysis

## Deployment Architecture

### Development Mode
```
[Browser] ← → [Vite Dev Server] ← → [React App] ← → [Game Engine]
                                         ↓
                                   [Content System]
```

### Production Mode
```
[Browser] ← → [Express Server] ← → [Built React App] ← → [Game Engine]
                                         ↓
                                   [Content System]
```

### Docker Deployment
```
[Docker Container: Node.js Alpine]
├── [Express Server]
├── [Built React App]
├── [Game Engine]
└── [Content System]
```

## Security Architecture

### Content Security
- All content is JSON-based and validated
- No arbitrary code execution from content files
- Sanitized HTML output in terminal

### System Integration
- Read-only system integration by default
- No modification of system files
- Educational failure system instead of blocking

### Web Security
- CORS configuration for appropriate origins
- No sensitive data exposure
- Client-side state management only

## Extensibility

### Adding New Content
1. Create JSON files in appropriate content directories
2. Use validation scripts to ensure content quality
3. Test through the game interface

### Adding New Features
1. Extend GameEngine.js for new game mechanics
2. Add React components for new UI elements
3. Update content templates as needed

### Service Integration
1. Add service templates in `/content/templates/services/`
2. Create corresponding discovery definitions
3. Update SystemIntegration.js for detection logic

## Performance Considerations

### Frontend Performance
- Component memoization for expensive operations
- Virtualized scrolling for long terminal output
- Efficient state management to minimize re-renders

### Backend Performance
- Lightweight Express server with minimal middleware
- Static file serving with appropriate caching headers
- WebSocket connections for real-time features

### Content Loading
- Lazy loading of content based on player progress
- JSON parsing optimization
- Efficient quest and discovery lookup

## Monitoring and Debugging

### Development Tools
- React DevTools for component inspection
- Browser console for game state debugging
- Network tab for API request monitoring

### Production Monitoring
- Health check endpoint at `/health`
- Error boundaries for graceful error handling
- Logging for game progression and errors

## Migration from v1.x

Network Chronicles 2.0 represents a complete architectural rewrite:

- **v1.x**: Shell script-based with terminal integration
- **v2.0**: React web application with terminal emulation

Key improvements:
- Better user experience with modern web technologies
- Easier content contribution through JSON templates
- Enhanced narrative with cyberpunk mystery elements
- Cross-platform compatibility through web browsers
- Simplified deployment with Docker support

---

This architecture provides a solid foundation for the Network Chronicles 2.0 learning experience while maintaining flexibility for future enhancements and community contributions.