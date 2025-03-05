/**
 * Network Chronicles - Main Entry Point
 * 
 * This file serves as the main entry point for the Node.js integration of Network Chronicles.
 * It provides advanced features that complement the core bash implementation.
 */

// Import required modules
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const path = require('path');
const fs = require('fs');
const { spawn } = require('child_process');
const winston = require('winston');
const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Configure logger
const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// Configuration
const config = {
  port: process.env.PORT || 3000,
  gameRoot: process.env.GAME_ROOT || '/opt/network-chronicles',
  apiEnabled: process.env.API_ENABLED === 'true' || false,
  webUiEnabled: process.env.WEB_UI_ENABLED === 'true' || false,
  multiplayerEnabled: process.env.MULTIPLAYER_ENABLED === 'true' || false
};

// Initialize Express app
const app = express();
const server = http.createServer(app);
const io = socketIo(server);

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static files if web UI is enabled
if (config.webUiEnabled) {
  app.use(express.static(path.join(__dirname, '../public')));
}

// API Routes
if (config.apiEnabled) {
  // Import API routes
  const apiRoutes = require('./api');
  app.use('/api/v1', apiRoutes);
}

// Socket.IO for multiplayer features
if (config.multiplayerEnabled) {
  io.on('connection', (socket) => {
    logger.info('New client connected');
    
    socket.on('login', (data) => {
      // Handle player login
      logger.info(`Player login: ${data.playerId}`);
    });
    
    socket.on('share_discovery', (data) => {
      // Handle discovery sharing
      logger.info(`Discovery shared: ${data.discoveryId}`);
      socket.broadcast.emit('new_discovery', data);
    });
    
    socket.on('disconnect', () => {
      logger.info('Client disconnected');
    });
  });
}

// Game Engine Integration
class GameEngine {
  constructor() {
    this.gameRoot = config.gameRoot;
    logger.info(`Game engine initialized with root: ${this.gameRoot}`);
  }
  
  /**
   * Execute a game engine command
   * @param {string} command - The command to execute
   * @param {string} playerId - The player ID
   * @returns {Promise<string>} Command output
   */
  executeCommand(command, playerId) {
    return new Promise((resolve, reject) => {
      const enginePath = path.join(this.gameRoot, 'bin/network-chronicles-engine.sh');
      
      if (!fs.existsSync(enginePath)) {
        return reject(new Error(`Game engine not found at ${enginePath}`));
      }
      
      const process = spawn(enginePath, [command, playerId]);
      let output = '';
      
      process.stdout.on('data', (data) => {
        output += data.toString();
      });
      
      process.stderr.on('data', (data) => {
        logger.error(`Game engine error: ${data.toString()}`);
      });
      
      process.on('close', (code) => {
        if (code === 0) {
          resolve(output);
        } else {
          reject(new Error(`Game engine exited with code ${code}`));
        }
      });
    });
  }
  
  /**
   * Get player state
   * @param {string} playerId - The player ID
   * @returns {Promise<Object>} Player state
   */
  async getPlayerState(playerId) {
    const playerStatePath = path.join(
      this.gameRoot,
      'data/players',
      playerId,
      'profile.json'
    );
    
    try {
      if (!fs.existsSync(playerStatePath)) {
        throw new Error(`Player state not found for ${playerId}`);
      }
      
      const data = fs.readFileSync(playerStatePath, 'utf8');
      return JSON.parse(data);
    } catch (error) {
      logger.error(`Error getting player state: ${error.message}`);
      throw error;
    }
  }
  
  /**
   * Update player state
   * @param {string} playerId - The player ID
   * @param {Object} updates - State updates
   * @returns {Promise<Object>} Updated player state
   */
  async updatePlayerState(playerId, updates) {
    const playerStatePath = path.join(
      this.gameRoot,
      'data/players',
      playerId,
      'profile.json'
    );
    
    try {
      if (!fs.existsSync(playerStatePath)) {
        throw new Error(`Player state not found for ${playerId}`);
      }
      
      const data = fs.readFileSync(playerStatePath, 'utf8');
      const currentState = JSON.parse(data);
      
      const updatedState = {
        ...currentState,
        ...updates,
        last_updated: new Date().toISOString()
      };
      
      fs.writeFileSync(
        playerStatePath,
        JSON.stringify(updatedState, null, 2),
        'utf8'
      );
      
      return updatedState;
    } catch (error) {
      logger.error(`Error updating player state: ${error.message}`);
      throw error;
    }
  }
}

// Initialize game engine
const gameEngine = new GameEngine();

// Make game engine available to routes
app.set('gameEngine', gameEngine);

// Start server
server.listen(config.port, () => {
  logger.info(`Network Chronicles server running on port ${config.port}`);
  logger.info(`API Enabled: ${config.apiEnabled}`);
  logger.info(`Web UI Enabled: ${config.webUiEnabled}`);
  logger.info(`Multiplayer Enabled: ${config.multiplayerEnabled}`);
});

// Export for testing
module.exports = {
  app,
  server,
  gameEngine,
  config,
  logger
};
