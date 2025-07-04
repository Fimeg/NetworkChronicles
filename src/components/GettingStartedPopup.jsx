import React from 'react'

function GettingStartedPopup({ onClose, onSaveToJournal }) {
  const handleClose = () => {
    // Save to journal before closing
    onSaveToJournal()
    onClose()
  }

  return (
    <div className="popup-overlay">
      <div className="popup-container getting-started-popup">
        <div className="popup-header">
          <div className="popup-title">[ORIENTATION] Getting Started Guide</div>
          <button className="popup-close" onClick={handleClose}>×</button>
        </div>
        
        <div className="popup-content">
          <div className="orientation-section">
            <div className="section-title">[&gt;] ESSENTIAL FIRST STEPS:</div>
            <div className="step-list">
              <div className="step-item">
                <span className="step-number">1.</span>
                <span className="step-text">Type <span className="cmd-highlight">'nc-clock-in'</span> to start your shift and receive your daily briefing</span>
              </div>
              <div className="step-item">
                <span className="step-number">2.</span>
                <span className="step-text">Use <span className="cmd-highlight">'nc-daily-tasks'</span> to see your assigned duties</span>
              </div>
              <div className="step-item">
                <span className="step-number">3.</span>
                <span className="step-text">Complete training tasks to build your Linux skills</span>
              </div>
              <div className="step-item">
                <span className="step-number">4.</span>
                <span className="step-text">Maintain system security and monitor for any unusual activity</span>
              </div>
            </div>
          </div>

          <div className="orientation-section">
            <div className="section-title">[CMD] COMMAND REFERENCE:</div>
            <div className="command-grid">
              <div className="command-item">
                <span className="cmd-name">help</span>
                <span className="cmd-desc">Basic terminal commands</span>
              </div>
              <div className="command-item">
                <span className="cmd-name">nc-help</span>
                <span className="cmd-desc">System administration tools</span>
              </div>
              <div className="command-item">
                <span className="cmd-name">nc-status</span>
                <span className="cmd-desc">View your progress and stats</span>
              </div>
              <div className="command-item">
                <span className="cmd-name">quests</span>
                <span className="cmd-desc">See mission progression</span>
              </div>
            </div>
          </div>

          <div className="orientation-section">
            <div className="section-title">[INFO] IMPORTANT NOTES:</div>
            <div className="note-list">
              <div className="note-item">[TIP] This guide will be saved to your journal for future reference</div>
              <div className="note-item">[WARN] You must clock in to receive duties and earn XP</div>
              <div className="note-item">[SYS] System messages will appear periodically during your shift</div>
            </div>
          </div>
        </div>

        <div className="popup-footer">
          <button className="popup-btn primary" onClick={handleClose}>
            [SAVE] Save to Journal & Continue
          </button>
        </div>
      </div>
    </div>
  )
}

export default GettingStartedPopup