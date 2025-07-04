import React, { useState, useEffect } from 'react'
import Terminal from './components/Terminal'
import QuestPanel from './components/QuestPanel'
import GameEngine from './game/GameEngine'
import SplashScreen from './components/SplashScreen'
import './App.css'

function App() {
  const [gameStarted, setGameStarted] = useState(false)
  const [gameEngine] = useState(new GameEngine())
  const [player, setPlayer] = useState(null)

  useEffect(() => {
    // Initialize game engine
    gameEngine.initialize().then(() => {
      setPlayer(gameEngine.getPlayer())
    })
  }, [gameEngine])

  const handleStartGame = () => {
    setGameStarted(true)
  }

  if (!gameStarted) {
    return <SplashScreen onStart={handleStartGame} />
  }

  return (
    <div className="app">
      <Terminal gameEngine={gameEngine} player={player} setPlayer={setPlayer} />
      <QuestPanel gameEngine={gameEngine} player={player} />
    </div>
  )
}

export default App