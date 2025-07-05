import React, { useState, useEffect, useRef } from 'react'
import GettingStartedPopup from './GettingStartedPopup'

function Terminal({ gameEngine, player, setPlayer }) {
  const [output, setOutput] = useState([])
  const [input, setInput] = useState('')
  const [commandHistory, setCommandHistory] = useState([])
  const [historyIndex, setHistoryIndex] = useState(-1)
  const [notification, setNotification] = useState('')
  const [currentDir, setCurrentDir] = useState('~')
  const [promptStatus, setPromptStatus] = useState('status-rookie')
  const [lastActivity, setLastActivity] = useState(Date.now())
  const [celebration, setCelebration] = useState('')
  const [showGettingStarted, setShowGettingStarted] = useState(false)
  const inputRef = useRef(null)
  const outputRef = useRef(null)

  // Command syntax highlighting function
  const highlightCommand = (command) => {
    if (!command) return command
    
    const parts = command.split(' ')
    const highlightedParts = parts.map((part, index) => {
      // First part is usually the command
      if (index === 0) {
        return `<span class="cmd-keyword">${part}</span>`
      }
      // Flags (start with -)
      if (part.startsWith('-')) {
        return `<span class="cmd-flag">${part}</span>`
      }
      // Paths (contain / or start with ~ or .)
      if (part.includes('/') || part.startsWith('~') || part.startsWith('.')) {
        return `<span class="cmd-path">${part}</span>`
      }
      // Numbers
      if (/^\d+$/.test(part)) {
        return `<span class="cmd-number">${part}</span>`
      }
      // Quoted strings
      if ((part.startsWith('"') && part.endsWith('"')) || (part.startsWith("'") && part.endsWith("'"))) {
        return `<span class="cmd-string">${part}</span>`
      }
      // Operators
      if (['|', '>', '<', '>>', '&&', '||', ';'].includes(part)) {
        return `<span class="cmd-operator">${part}</span>`
      }
      // Default
      return part
    })
    
    return highlightedParts.join(' ')
  }

  useEffect(() => {
    if (gameEngine && player) {
      const welcomeMessage = gameEngine.getWelcomeMessage()
      const shiftStatus = gameEngine.getShiftStatus()
      
      setOutput([
        { type: 'system', content: welcomeMessage },
        { type: 'alert', content: shiftStatus.clockedIn ? 
          `[*] SHIFT ACTIVE: ${shiftStatus.currentShift} | Tasks: ${shiftStatus.tasksCompleted}/4 | Daily XP: ${shiftStatus.dailyXP}` :
          '[!] SHIFT REQUIRED: You must clock in to begin your duties. Use "nc-clock-in" to start your shift.' }
      ])

      // Check if getting started guide has been shown
      const hasSeenGettingStarted = localStorage.getItem('nc-getting-started-seen')
      const installTimestamp = localStorage.getItem('nc-install-timestamp')
      const sessionFirstRun = sessionStorage.getItem('nc-session-first-run')
      const now = Date.now()
      
      // Force popup for new installations (within 10 minutes), first session, or if never seen
      const isNewInstall = !installTimestamp || (now - parseInt(installTimestamp)) < 600000
      const isFirstSession = !sessionFirstRun
      
      if (!hasSeenGettingStarted || isNewInstall || isFirstSession) {
        if (!installTimestamp) {
          localStorage.setItem('nc-install-timestamp', now.toString())
        }
        if (!sessionFirstRun) {
          sessionStorage.setItem('nc-session-first-run', 'true')
        }
        setTimeout(() => setShowGettingStarted(true), 1500)
      }
    }
  }, [gameEngine, player])

  useEffect(() => {
    // Force scroll to bottom when output changes
    scrollToBottom()
  }, [output])

  // Update prompt status based on game state
  useEffect(() => {
    if (gameEngine && player) {
      const shiftStatus = gameEngine.getShiftStatus()
      if (!shiftStatus.clockedIn) {
        setPromptStatus('status-clocked-out')
      } else if (player.level >= 3) {
        setPromptStatus('status-advanced')
      } else if (player.level >= 2) {
        setPromptStatus('status-experienced')
      } else {
        setPromptStatus('status-rookie')
      }
    }
  }, [gameEngine, player])

  // Ambient terminal activity - system messages with improved variety
  useEffect(() => {
    if (!gameEngine || !player) return
    
    let recentMessages = []
    const maxRecentMessages = 5
    
    const ambientMessages = [
      '[SYS] Network monitoring active...',
      '[LOG] Backup process completed successfully', 
      '[NET] Checking network connectivity...',
      '[SEC] Security scan running in background',
      '[MON] System resources: Normal',
      '[TASK] Daily maintenance scheduled',
      '[INFO] Log rotation completed',
      '[NET] DNS resolution: Operational',
      '[SYS] Temperature sensors: Normal',
      '[SEC] Firewall status: Active',
      '[MON] CPU usage: 12%',
      '[MEM] Memory usage: 68%',
      '[DISK] Disk health check passed',
      '[NET] IPv6 connectivity verified',
      '[SEC] Intrusion detection active',
      '[SYS] Service watchdog running',
      '[LOG] System logs archived',
      '[NET] Gateway ping: 2ms',
      '[MON] Load average: 0.45',
      '[SEC] Certificate expiry check: OK'
    ]

    const investigativeMessages = [
      '[ALERT] Unusual file access pattern detected',
      '[LOG] Encrypted data found in temp directory',
      '[NET] Unknown connection attempt logged',
      '[SEC] Administrative privileges escalation noted',
      '[SYS] Missing log entries from yesterday',
      '[WARN] System configuration changes detected',
      '[AUDIT] Suspicious login time detected',
      '[CRYPTO] Unrecognized encryption key found',
      '[NET] Port scan activity on network',
      '[FILE] Hidden directory discovered',
      '[PROC] Unexpected process execution',
      '[LOG] Access logs show anomalies'
    ]

    const getRandomMessage = (messageArray) => {
      // Filter out messages that were recently shown
      const availableMessages = messageArray.filter(msg => !recentMessages.includes(msg))
      
      // If all messages have been used recently, reset the recent list
      if (availableMessages.length === 0) {
        recentMessages = []
        return messageArray[Math.floor(Math.random() * messageArray.length)]
      }
      
      const selectedMessage = availableMessages[Math.floor(Math.random() * availableMessages.length)]
      
      // Add to recent messages and maintain max size
      recentMessages.push(selectedMessage)
      if (recentMessages.length > maxRecentMessages) {
        recentMessages.shift()
      }
      
      return selectedMessage
    }

    const activityTimer = setInterval(() => {
      const now = Date.now()
      const timeSinceLastActivity = now - lastActivity
      
      // Only show ambient messages if user has been idle for 45+ seconds
      if (timeSinceLastActivity > 45000) {
        const shiftStatus = gameEngine.getShiftStatus()
        if (shiftStatus.clockedIn) {
          // Chance for investigative messages increases with progress
          const useInvestigative = player.level >= 2 && Math.random() < 0.25
          const messages = useInvestigative ? investigativeMessages : ambientMessages
          const randomMessage = getRandomMessage(messages)
          
          addToOutput(randomMessage, 'system')
          setLastActivity(now)
        }
      }
    }, 60000) // Check every 60 seconds (reduced frequency)

    return () => clearInterval(activityTimer)
  }, [gameEngine, player, lastActivity])

  // Scroll to bottom with multiple fallback methods
  const scrollToBottom = () => {
    if (outputRef.current) {
      // Only scroll if we have more content than the container height
      const shouldScroll = outputRef.current.scrollHeight > outputRef.current.clientHeight
      
      if (shouldScroll) {
        outputRef.current.scrollTop = outputRef.current.scrollHeight
      } else {
        // Ensure we're at the top when there's minimal content
        outputRef.current.scrollTop = 0
      }
    }
  }

  const addToOutput = (content, type = 'normal') => {
    setOutput(prev => [...prev, { type, content, timestamp: Date.now() }])
    // Force immediate scroll
    scrollToBottom()
  }

  const handleCommand = async (command) => {
    // Reset activity timer on user input
    setLastActivity(Date.now())
    
    // Handle blank lines for spacing
    if (!command.trim()) {
      addToOutput(`${player?.name || 'player'}@linux-terminal:${currentDir}$ `, 'command')
      return
    }

    // Add command to history
    setCommandHistory(prev => [...prev, command])
    setHistoryIndex(-1)

    // Show command in output
    addToOutput(`${player?.name || 'player'}@linux-terminal:${currentDir}$ ${command}`, 'command')
    
    // Force scroll immediately after showing command
    scrollToBottom()

    try {
      const result = await gameEngine.executeCommand(command)
      
      // Handle clear command specially
      if (result.type === 'clear') {
        if (result.showWelcome) {
          // Show welcome message and shift status after clear
          const welcomeMessage = gameEngine.getWelcomeMessage()
          const shiftStatus = gameEngine.getShiftStatus()
          const currentTime = new Date().toLocaleString()
          
          setOutput([
            { type: 'system', content: `[${currentTime}] Terminal cleared` },
            { type: 'system', content: welcomeMessage },
            { type: 'alert', content: shiftStatus.clockedIn ? 
              `[*] SHIFT ACTIVE: ${shiftStatus.currentShift} | Tasks: ${shiftStatus.tasksCompleted}/4 | Daily XP: ${shiftStatus.dailyXP}` :
              '[!] SHIFT REQUIRED: You must clock in to begin your duties. Use "nc-clock-in" to start your shift.' }
          ])
        } else {
          setOutput([])
        }
        return
      }
      
      if (result.output) {
        addToOutput(result.output, result.type || 'normal')
        scrollToBottom()
      }

      if (result.xpGained && result.xpGained > 0) {
        if (result.xpGained >= 50) {
          showCelebration(`SIGNIFICANT DISCOVERY!\nManagement is... fascinated.\n+${result.xpGained} XP`)
        } else if (result.xpGained >= 25) {
          showCelebration(`IMPRESSIVE THOROUGHNESS!\nYour curiosity levels are noted.\n+${result.xpGained} XP`)
        } else {
          showNotification(`+${result.xpGained} XP`)
        }
      }

      if (result.playerUpdate) {
        setPlayer(gameEngine.getPlayer())
      }

      // Force quest panel update when quest completes
      if (result.questUpdate) {
        // Force re-render by updating a dummy state
        setLastActivity(Date.now())
      }

      if (result.shiftUpdate) {
        const shiftStatus = gameEngine.getShiftStatus()
        addToOutput(shiftStatus.clockedIn ? 
          `[>] SHIFT STATUS: ${shiftStatus.currentShift} | Tasks: ${shiftStatus.tasksCompleted}/4 | Daily XP: ${shiftStatus.dailyXP}` :
          '[CLK] SHIFT ENDED - Clock in again to continue your duties', 'alert')
        scrollToBottom()
      }

      if (result.discovery) {
        addToOutput(result.discovery, 'discovery')
        scrollToBottom()
      }

      // Update current directory for cd commands
      if (command.trim().startsWith('cd') && result.type !== 'error') {
        // Get updated directory
        try {
          const pwdResult = await gameEngine.executeCommand('pwd')
          if (pwdResult.output) {
            const shortDir = pwdResult.output.replace(process.env.HOME || '/home/user', '~')
            setCurrentDir(shortDir)
          }
        } catch (pwdError) {
          // Ignore pwd errors
        }
      }

    } catch (error) {
      addToOutput(`Error: ${error.message}`, 'error')
    }
  }

  const showNotification = (message) => {
    setNotification(message)
    setTimeout(() => setNotification(''), 3000)
  }

  const showCelebration = (message) => {
    setCelebration(message)
    setTimeout(() => setCelebration(''), 2000)
  }

  const handleGettingStartedClose = () => {
    setShowGettingStarted(false)
  }

  const handleSaveToJournal = () => {
    // Mark as seen in localStorage
    localStorage.setItem('nc-getting-started-seen', 'true')
    
    // Add to game engine journal if available
    if (gameEngine && gameEngine.addToJournal) {
      gameEngine.addToJournal('getting-started', {
        title: 'Getting Started Guide',
        content: 'Essential first steps and command reference for new system administrators',
        category: 'orientation',
        timestamp: new Date().toISOString()
      })
    }
    
    // Show a confirmation message
    addToOutput('[JOURNAL] Getting Started guide saved to your personal records', 'info')
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    handleCommand(input)
    setInput('')
  }

  const handleTabCompletion = () => {
    if (!gameEngine) return

    // Get discovered/learned commands from game engine
    const basicCommands = ['help', 'clear', 'pwd', 'ls', 'cd', 'cat', 'ps', 'netstat', 'whoami', 'date', 'uname', 'df', 'free', 'top', 'ifconfig', 'ping']
    const learnedCommands = Array.from(gameEngine.commandsLearned || [])
    const discoveredCommands = Array.from(gameEngine.discoveredCommands || [])
    
    // Combine all available commands for tab completion
    const availableCommands = [...new Set([...basicCommands, ...learnedCommands, ...discoveredCommands])]

    const currentInput = input.trim()
    const matches = availableCommands.filter(cmd => cmd.startsWith(currentInput))

    if (matches.length === 1) {
      // Single match - complete it
      setInput(matches[0] + ' ')
    } else if (matches.length > 1) {
      // Multiple matches - show them
      const commonPrefix = matches.reduce((prefix, cmd) => {
        while (cmd.indexOf(prefix) !== 0) {
          prefix = prefix.substring(0, prefix.length - 1)
        }
        return prefix
      })
      
      if (commonPrefix.length > currentInput.length) {
        setInput(commonPrefix)
      } else {
        // Show available completions
        addToOutput(`${player?.name || 'player'}@linux-terminal:${currentDir}$ ${currentInput}`, 'command')
        addToOutput(matches.join('  '), 'info')
        addToOutput('', 'blank')
      }
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Tab') {
      e.preventDefault()
      handleTabCompletion()
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      if (commandHistory.length > 0) {
        const newIndex = historyIndex < commandHistory.length - 1 ? historyIndex + 1 : historyIndex
        setHistoryIndex(newIndex)
        setInput(commandHistory[commandHistory.length - 1 - newIndex] || '')
      }
    } else if (e.key === 'ArrowDown') {
      e.preventDefault()
      if (historyIndex > 0) {
        const newIndex = historyIndex - 1
        setHistoryIndex(newIndex)
        setInput(commandHistory[commandHistory.length - 1 - newIndex] || '')
      } else if (historyIndex === 0) {
        setHistoryIndex(-1)
        setInput('')
      }
    } else if (e.key === 'l' && e.ctrlKey) {
      e.preventDefault()
      setOutput([])
    } else if (e.key === 'c' && e.ctrlKey) {
      e.preventDefault()
      if (input.trim()) {
        addToOutput(`${player?.name || 'player'}@linux-terminal:${currentDir}$ ${input}^C`, 'command')
        setInput('')
      }
    } else if (e.key === 'u' && e.ctrlKey) {
      e.preventDefault()
      setInput('')
    }
  }

  const renderOutput = (item) => {
    switch (item.type) {
      case 'command':
        // Extract prompt and command parts
        const promptMatch = item.content.match(/^([^$]+\$ )(.*)$/)
        if (promptMatch) {
          const [, prompt, command] = promptMatch
          return (
            <div className="terminal-line text-green">
              <span>{prompt}</span>
              <span dangerouslySetInnerHTML={{ __html: highlightCommand(command) }} />
            </div>
          )
        }
        return <div className="terminal-line text-green">{item.content}</div>
      case 'error':
        return <div className="terminal-line command-error">{item.content}</div>
      case 'success':
        return <div className="terminal-line command-success status-display">{item.content}</div>
      case 'info':
        return <div className="terminal-line command-info status-display">{item.content}</div>
      case 'warning':
        return <div className="terminal-line command-warning">{item.content}</div>
      case 'alert':
        return <div className="terminal-line text-yellow status-display">{item.content}</div>
      case 'system':
        return <div className="terminal-line text-cyan">{item.content}</div>
      case 'blank':
        return <div className="terminal-line">&nbsp;</div>
      case 'quest':
        return (
          <div className="quest-box">
            <div className="quest-title">Current Quest</div>
            <div className="quest-description">{item.content}</div>
          </div>
        )
      case 'discovery':
        return (
          <div className="lesson-box">
            <div className="lesson-title">Discovery!</div>
            <div className="lesson-description">{item.content}</div>
          </div>
        )
      default:
        return <div className="terminal-line">{item.content}</div>
    }
  }

  return (
    <div className="terminal">
      <div className="terminal-header">
        <div className="terminal-title">Network Chronicles 2.0 - Linux Learning Terminal</div>
        <div className="terminal-controls">
          <div className="terminal-control control-close"></div>
          <div className="terminal-control control-minimize"></div>
          <div className="terminal-control control-maximize"></div>
        </div>
      </div>

      <div className="terminal-body">
        <div className="terminal-output" ref={outputRef}>
          {output.map((item, index) => (
            <div key={`${item.timestamp}-${index}`}>
              {renderOutput(item)}
            </div>
          ))}
        </div>

        <form onSubmit={handleSubmit} className="terminal-input-container">
          <span className={`terminal-prompt ${promptStatus}`}>{player?.name || 'player'}@linux-terminal:{currentDir}$</span>
          <input
            ref={inputRef}
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            className="terminal-input"
            autoFocus
            autoComplete="off"
          />
        </form>
      </div>

      {player && gameEngine && (
        <div className="status-bar">
          <div className="status-item">
            <span className="status-label">Level:</span>
            <span className="status-value">{player.level}</span>
          </div>
          <div className="status-item">
            <span className="status-label">XP:</span>
            <span className="status-value">{player.xp}</span>
          </div>
          <div className="progress-bar">
            <div 
              className="progress-fill" 
              style={{ width: `${(player.xp % 100)}%` }}
            ></div>
          </div>
          <div className="status-item">
            <span className="status-label">Shift:</span>
            <span className={`status-value ${gameEngine.getShiftStatus().clockedIn ? 'status-on' : 'status-off'}`}>
              {gameEngine.getShiftStatus().clockedIn ? '[ON]' : '[OFF - nc-clock-in to start]'}
            </span>
          </div>
          <div className="status-item">
            <span className="status-label">Tasks:</span>
            <span className="status-value">{gameEngine.getShiftStatus().tasksCompleted}/4</span>
          </div>
        </div>
      )}

      {notification && (
        <div className="discovery-notification">
          {notification}
        </div>
      )}

      {celebration && (
        <div className="discovery-celebration">
          {celebration.split('\n').map((line, index) => (
            <div key={index}>{line}</div>
          ))}
        </div>
      )}

      {showGettingStarted && (
        <GettingStartedPopup 
          onClose={handleGettingStartedClose}
          onSaveToJournal={handleSaveToJournal}
        />
      )}
    </div>
  )
}

export default Terminal