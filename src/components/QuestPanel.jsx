import React, { useState, useEffect } from 'react'

function QuestPanel({ gameEngine, player }) {
  const [currentQuest, setCurrentQuest] = useState('')
  const [isCollapsed, setIsCollapsed] = useState(false)

  useEffect(() => {
    if (gameEngine && player) {
      const quest = gameEngine.getCurrentQuest()
      setCurrentQuest(quest)
    }
  }, [gameEngine, player])

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
        <div className="quest-panel-content">
          <div className="quest-content">
            {currentQuest}
          </div>
        </div>
      )}
    </div>
  )
}

export default QuestPanel