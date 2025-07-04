import express from 'express'
import path from 'path'
import { fileURLToPath } from 'url'
import fs from 'fs'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const app = express()
const PORT = process.env.PORT || 3000

// Middleware
app.use(express.json())
app.use(express.static(path.join(__dirname, 'dist')))

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '2.0.0-alpha.1',
    uptime: process.uptime()
  })
})

// API endpoints for game data persistence
app.get('/api/player/:id', (req, res) => {
  const playerId = req.params.id
  const playerDataPath = path.join(__dirname, 'user-data', `${playerId}.json`)
  
  try {
    if (fs.existsSync(playerDataPath)) {
      const playerData = JSON.parse(fs.readFileSync(playerDataPath, 'utf8'))
      res.json(playerData)
    } else {
      // Return default player data
      res.json({
        id: playerId,
        name: playerId,
        level: 1,
        xp: 0,
        discoveries: [],
        quests: [],
        currentQuestIndex: 0,
        journalEntries: [],
        createdAt: new Date().toISOString()
      })
    }
  } catch (error) {
    console.error('Error reading player data:', error)
    res.status(500).json({ error: 'Failed to read player data' })
  }
})

app.post('/api/player/:id', (req, res) => {
  const playerId = req.params.id
  const playerData = req.body
  const playerDataPath = path.join(__dirname, 'user-data', `${playerId}.json`)
  
  try {
    // Ensure user-data directory exists
    const userDataDir = path.join(__dirname, 'user-data')
    if (!fs.existsSync(userDataDir)) {
      fs.mkdirSync(userDataDir, { recursive: true })
    }
    
    // Save player data
    fs.writeFileSync(playerDataPath, JSON.stringify(playerData, null, 2))
    res.json({ success: true })
  } catch (error) {
    console.error('Error saving player data:', error)
    res.status(500).json({ error: 'Failed to save player data' })
  }
})

// Serve React app for all other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'))
})

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err.stack)
  res.status(500).json({ error: 'Something went wrong!' })
})

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Network Chronicles 2.0 Alpha server running on port ${PORT}`)
  console.log(`Health check available at http://localhost:${PORT}/health`)
  
  // Log startup info
  const startupInfo = {
    timestamp: new Date().toISOString(),
    version: '2.0.0-alpha.1',
    port: PORT,
    environment: process.env.NODE_ENV || 'development',
    healthcheck: `/health`
  }
  
  console.log('Startup info:', JSON.stringify(startupInfo, null, 2))
})

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully')
  process.exit(0)
})

process.on('SIGINT', () => {
  console.log('SIGINT received, shutting down gracefully')  
  process.exit(0)
})