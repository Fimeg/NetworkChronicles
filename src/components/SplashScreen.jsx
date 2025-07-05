import React, { useState, useEffect } from 'react'

function SplashScreen({ onStart }) {
  const [showFullBriefing, setShowFullBriefing] = useState(false)
  const [currentText, setCurrentText] = useState('')
  const [showButton, setShowButton] = useState(false)

  const recruitId = Math.random().toString(36).substr(2, 8).toUpperCase()

  const briefingContent = `
╔═══════════════════════════════════════════════════════════════════════════╗
║                        URGENT JOB ASSIGNMENT                             ║
║                     Network Security Division                            ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║ RECRUIT ID: ${recruitId}                                                    ║
║ CLEARANCE LEVEL: RESTRICTED                                               ║
║ ASSIGNMENT: Junior Systems Administrator                                  ║
║                                                                           ║
║ [SEC] CONFIDENTIAL BRIEFING:                                             ║
║                                                                           ║
║ Our Senior Systems Architect has been unreachable for several days.      ║
║ This individual has been with the company since its founding and is       ║
║ a key partner to the CEO. Their absence is... unprecedented.             ║
║                                                                           ║
║ YOU HAVE BEEN ASSIGNED TO:                                               ║
║ • Take over daily system administration duties                           ║
║ • Monitor network security and service status                            ║
║ • Maintain operational continuity                                        ║
║ • Report any unusual findings through proper channels                    ║
║                                                                           ║
║ [SYS] DAILY TASKS: Monitor systems, check logs, verify services          ║
║ [DATA] REPORTING: Document all activities and anomalies                  ║
║ [*] SUCCESS: Maintain 99% uptime and system integrity                    ║
║                                                                           ║
║ Remember: You are here to learn and maintain systems.                    ║
║ Follow standard procedures and protocols.                                ║
╚═══════════════════════════════════════════════════════════════════════════╝`

  useEffect(() => {
    // Show briefing after short delay
    const timer = setTimeout(() => {
      setShowFullBriefing(true)
    }, 500)

    return () => clearTimeout(timer)
  }, [])

  useEffect(() => {
    if (showFullBriefing) {
      // Typewriter effect for briefing
      let i = 0
      setCurrentText('')
      
      const typeWriter = setInterval(() => {
        if (i < briefingContent.length) {
          setCurrentText(briefingContent.slice(0, i + 1))
          i++
        } else {
          clearInterval(typeWriter)
          setTimeout(() => setShowButton(true), 200)
        }
      }, 5)

      return () => clearInterval(typeWriter)
    }
  }, [showFullBriefing])

  if (!showFullBriefing) {
    return (
      <div className="splash-screen">
        <div className="splash-title">NETWORK CHRONICLES 2.0</div>
        <div className="splash-subtitle">Linux Learning Terminal</div>
        <div className="loading-indicator">
          <div className="dots">
            <span>●</span>
            <span>●</span>
            <span>●</span>
          </div>
          <div className="loading-text">Establishing Secure Connection...</div>
        </div>
      </div>
    )
  }

  return (
    <div className="splash-screen">
      <div className="splash-title">INCOMING TRANSMISSION</div>
      <div className="splash-subtitle">[ENCRYPTED CHANNEL ESTABLISHED]</div>
      
      <div className="mission-briefing">
        <pre className="mission-content">{currentText}</pre>
      </div>

      {showButton && (
        <button className="splash-button terminal-access" onClick={onStart}>
          ACCESS TERMINAL →
        </button>
      )}
    </div>
  )
}

export default SplashScreen