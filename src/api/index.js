/**
 * Network Chronicles - API Routes
 * 
 * This file defines the API routes for the Network Chronicles system.
 * These routes provide programmatic access to game data and functionality.
 */

const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');

// JWT Secret
const JWT_SECRET = process.env.JWT_SECRET || 'network-chronicles-secret';

// Authentication middleware
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader) {
    return res.status(401).json({ error: 'Authentication required' });
  }
  
  const token = authHeader.split(' ')[1];
  
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};

// API Documentation
router.get('/', (req, res) => {
  res.json({
    name: 'Network Chronicles API',
    version: '1.0.0',
    description: 'API for interacting with the Network Chronicles system',
    endpoints: [
      { path: '/auth/login', method: 'POST', description: 'Authenticate and get a token' },
      { path: '/players', method: 'GET', description: 'Get all players (requires admin)' },
      { path: '/players/:id', method: 'GET', description: 'Get player details' },
      { path: '/quests', method: 'GET', description: 'Get all quests' },
      { path: '/quests/:id', method: 'GET', description: 'Get quest details' },
      { path: '/discoveries', method: 'GET', description: 'Get player discoveries' },
      { path: '/journal', method: 'GET', description: 'Get player journal entries' },
      { path: '/journal', method: 'POST', description: 'Create a journal entry' }
    ]
  });
});

// Authentication
router.post('/auth/login', (req, res) => {
  const { username, password } = req.body;
  
  if (!username || !password) {
    return res.status(400).json({ error: 'Username and password required' });
  }
  
  // In a real implementation, this would validate against stored credentials
  // For now, we'll use a simple check for the player user
  if (username === 'player' && password === 'discover') {
    const token = jwt.sign(
      { id: username, role: 'player' },
      JWT_SECRET,
      { expiresIn: '24h' }
    );
    
    return res.json({ token });
  }
  
  return res.status(401).json({ error: 'Invalid credentials' });
});

// Players
router.get('/players', authenticate, (req, res) => {
  // Only admins can list all players
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  
  const gameEngine = req.app.get('gameEngine');
  const playersDir = path.join(gameEngine.gameRoot, 'data/players');
  
  try {
    if (!fs.existsSync(playersDir)) {
      return res.json({ players: [] });
    }
    
    const players = fs.readdirSync(playersDir)
      .filter(dir => fs.statSync(path.join(playersDir, dir)).isDirectory());
    
    res.json({ players });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/players/:id', authenticate, async (req, res) => {
  const playerId = req.params.id;
  
  // Players can only access their own data unless they're an admin
  if (req.user.id !== playerId && req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Access denied' });
  }
  
  const gameEngine = req.app.get('gameEngine');
  
  try {
    const playerState = await gameEngine.getPlayerState(playerId);
    res.json(playerState);
  } catch (error) {
    res.status(404).json({ error: error.message });
  }
});

// Quests
router.get('/quests', authenticate, (req, res) => {
  const gameEngine = req.app.get('gameEngine');
  const questsDir = path.join(gameEngine.gameRoot, 'content/narrative/quests');
  
  try {
    if (!fs.existsSync(questsDir)) {
      return res.json({ quests: [] });
    }
    
    const questFiles = fs.readdirSync(questsDir)
      .filter(file => file.endsWith('.json'));
    
    const quests = questFiles.map(file => {
      const questData = fs.readFileSync(path.join(questsDir, file), 'utf8');
      return JSON.parse(questData);
    });
    
    res.json({ quests });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/quests/:id', authenticate, (req, res) => {
  const questId = req.params.id;
  const gameEngine = req.app.get('gameEngine');
  const questPath = path.join(
    gameEngine.gameRoot,
    'content/narrative/quests',
    `${questId}.json`
  );
  
  try {
    if (!fs.existsSync(questPath)) {
      return res.status(404).json({ error: 'Quest not found' });
    }
    
    const questData = fs.readFileSync(questPath, 'utf8');
    const quest = JSON.parse(questData);
    
    // Get the quest description from the markdown file if it exists
    const questDescPath = path.join(
      gameEngine.gameRoot,
      'content/narrative/quests',
      `${questId}.md`
    );
    
    if (fs.existsSync(questDescPath)) {
      quest.description_full = fs.readFileSync(questDescPath, 'utf8');
    }
    
    res.json(quest);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Discoveries
router.get('/discoveries', authenticate, async (req, res) => {
  const playerId = req.user.id;
  const gameEngine = req.app.get('gameEngine');
  
  try {
    const playerState = await gameEngine.getPlayerState(playerId);
    
    if (!playerState.discoveries) {
      return res.json({ discoveries: [] });
    }
    
    res.json({ discoveries: playerState.discoveries });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Journal
router.get('/journal', authenticate, async (req, res) => {
  const playerId = req.user.id;
  const gameEngine = req.app.get('gameEngine');
  const journalPath = path.join(
    gameEngine.gameRoot,
    'data/players',
    playerId,
    'journal.json'
  );
  
  try {
    if (!fs.existsSync(journalPath)) {
      return res.json({ entries: [] });
    }
    
    const journalData = fs.readFileSync(journalPath, 'utf8');
    const journal = JSON.parse(journalData);
    
    res.json(journal);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/journal', authenticate, async (req, res) => {
  const playerId = req.user.id;
  const { title, content } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: 'Title and content required' });
  }
  
  const gameEngine = req.app.get('gameEngine');
  const journalPath = path.join(
    gameEngine.gameRoot,
    'data/players',
    playerId,
    'journal.json'
  );
  
  try {
    let journal = { entries: [] };
    
    if (fs.existsSync(journalPath)) {
      const journalData = fs.readFileSync(journalPath, 'utf8');
      journal = JSON.parse(journalData);
    }
    
    const newEntry = {
      id: Date.now().toString(),
      title,
      content,
      timestamp: new Date().toISOString()
    };
    
    journal.entries.push(newEntry);
    
    fs.writeFileSync(journalPath, JSON.stringify(journal, null, 2), 'utf8');
    
    res.status(201).json(newEntry);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Execute game engine command
router.post('/engine/execute', authenticate, async (req, res) => {
  const playerId = req.user.id;
  const { command } = req.body;
  
  if (!command) {
    return res.status(400).json({ error: 'Command required' });
  }
  
  const gameEngine = req.app.get('gameEngine');
  
  try {
    const output = await gameEngine.executeCommand(command, playerId);
    res.json({ output });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
