import React, { useState, useEffect } from 'react'

function QuestPanel({ gameEngine, player }) {
  const [currentQuest, setCurrentQuest] = useState('')
  const [isCollapsed, setIsCollapsed] = useState(false)
  const [questKey, setQuestKey] = useState(0)

  useEffect(() => {
    if (gameEngine && player) {
      const quest = gameEngine.getCurrentQuest()
      const questIndex = gameEngine.currentQuestIndex
      const completedQuests = gameEngine.quests.filter(q => q.completed).length
      
      setCurrentQuest(quest)
      setQuestKey(`${questIndex}-${completedQuests}`)
    }
  }, [gameEngine, player, gameEngine?.currentQuestIndex, gameEngine?.quests, player?.xp, player?.completedQuests])

  // Poll for quest updates every 2 seconds
  useEffect(() => {
    if (!gameEngine || !player) return

    const pollInterval = setInterval(() => {
      const quest = gameEngine.getCurrentQuest()
      const questIndex = gameEngine.currentQuestIndex
      const completedQuests = gameEngine.quests.filter(q => q.completed).length
      const newQuestKey = `${questIndex}-${completedQuests}`
      
      if (quest !== currentQuest || questKey !== newQuestKey) {
        setCurrentQuest(quest)
        setQuestKey(newQuestKey)
      }
    }, 2000)

    return () => clearInterval(pollInterval)
  }, [gameEngine, player, currentQuest, questKey])

  if (!currentQuest) {
    return null
  }

  return (
    <div className="quest-panel">
      <div className="quest-panel-header" onClick={() => setIsCollapsed(!isCollapsed)}>
        <span className="quest-panel-title">📋 Current Objective</span>
        <span className="quest-panel-toggle">{isCollapsed ? '▼' : '▲'}</span>
      </div>
      
      {!isCollapsed && (
        <div className="quest-panel-content" key={questKey}>
          <div className="quest-content">
            {currentQuest}
          </div>
        </div>
      )}
    </div>
  )
}

export default QuestPanel