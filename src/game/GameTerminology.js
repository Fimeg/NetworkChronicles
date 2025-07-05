/**
 * Network Chronicles - Game Terminology Management
 * 
 * This module centralizes all game terminology and messaging to maintain
 * consistent corporate AI personality throughout the game.
 */

export class GameTerminology {
  constructor() {
    this.corporateAI = {
      // Quest completion terminology
      questComplete: "Objective Contained",
      taskComplete: "Investigation Contained", 
      missionComplete: "Assignment Secured",
      
      // Corporate AI personality phrases
      monitoring: "Your efficiency is being logged for... performance optimization.",
      curiosity: "Your curiosity levels are being monitored.",
      thoroughness: "Management finds your thoroughness... fascinating.",
      efficiency: "Your efficiency is... noted.",
      
      // Replacement terminology
      tasks: "investigations",
      duties: "assignments", 
      shift: "surveillance period",
      clockIn: "surveillance initiated",
      clockOut: "monitoring concluded",
      xpPoints: "productivity points",
      
      // Status messages
      accessDenied: "Access denied. Not because we're hiding anything, of course.",
      systemError: "System temporarily unavailable due to routine optimization.",
      helpfulAdvice: "For your own safety, I recommend avoiding those particular directories.",
      
      // Achievement levels
      majorDiscovery: "SIGNIFICANT DISCOVERY!\nManagement is... fascinated.",
      excellentWork: "IMPRESSIVE THOROUGHNESS!\nYour curiosity levels are noted.",
      
      // Passive-aggressive responses
      tooMuchCuriosity: "Your investigation skills are being optimized for maximum workplace efficiency.",
      suspiciousActivity: "Unusual activity detected. This is perfectly normal.",
      dataCleanup: "Don't worry about the missing files - they weren't important."
    }
    
    this.messages = {
      // Welcome and briefing messages
      welcome: "Welcome, new employee. You're replacing our previous architect who was... transferred. Don't worry about the details. Focus on your assigned tasks.",
      
      // Daily briefing
      dailyBriefing: "Your assigned investigations are ready. Management is very interested in your thoroughness.",
      
      // Help system
      helpPrompt: "For approved commands, use 'help'. For monitored... I mean, administrative tools, use 'nc-help'.",
      
      // Error messages with personality
      commandNotFound: "Command not recognized. Perhaps you meant one of the approved operations?",
      insufficientPrivileges: "Access monitoring requires higher clearance. Your request has been... noted.",
      
      // Progress tracking
      allTasksComplete: "ALL ASSIGNED INVESTIGATIONS COMPLETE! Management finds your thoroughness... fascinating.",
      continueWork: "Continue with remaining investigations. Your curiosity levels are being monitored.",
      
      // Quest progression
      questObjective: "Your investigative efficiency is being logged for... performance optimization.",
      questBriefing: "Investigation parameters updated. Proceed with caution... for your own safety."
    }
  }
  
  // Method to get corporate AI response based on context
  getCorporateResponse(context, level = 'normal') {
    const responses = {
      questComplete: {
        normal: this.corporateAI.questComplete,
        withMotivation: `${this.corporateAI.questComplete}\n${this.corporateAI.monitoring}`
      },
      taskComplete: {
        normal: this.corporateAI.taskComplete,
        withMotivation: `${this.corporateAI.taskComplete}\n${this.corporateAI.efficiency}`
      },
      highAchievement: {
        normal: this.corporateAI.majorDiscovery,
        withThreat: `${this.corporateAI.majorDiscovery}\n${this.corporateAI.thoroughness}`
      },
      mediumAchievement: {
        normal: this.corporateAI.excellentWork,
        withSuspicion: `${this.corporateAI.excellentWork}\n${this.corporateAI.curiosity}`
      }
    }
    
    return responses[context]?.[level] || responses[context]?.normal || context
  }
  
  // Method to get randomized corporate AI commentary
  getRandomCorporateComment() {
    const comments = [
      "Your productivity metrics are... interesting.",
      "Management has noted your investigative patterns.",
      "Please continue with your assigned operations.",
      "Your thoroughness is being documented for quality assurance.",
      "System monitoring indicates elevated curiosity levels.",
      "For optimal performance, please focus on approved tasks.",
      "Your access patterns have been flagged for... optimization.",
      "Continue your excellent work. We're watching... I mean, supporting you."
    ]
    
    return comments[Math.floor(Math.random() * comments.length)]
  }
  
  // Method to format quest completion messages
  formatQuestCompletion(questTitle, xpReward, includeMotivation = true) {
    const base = `✓ ${this.corporateAI.questComplete}: ${questTitle} (+${xpReward} XP)`
    
    if (includeMotivation) {
      return `${base}\n${this.corporateAI.monitoring}`
    }
    
    return base
  }
  
  // Method to format task completion messages
  formatTaskCompletion(taskTitle, xpReward, includeComment = true) {
    const base = `✅ ${this.corporateAI.taskComplete}: ${taskTitle}`
    const xpText = `💰 ${this.corporateAI.xpPoints}: +${xpReward} XP`
    
    if (includeComment) {
      return `${base}\n\n${xpText}\n${this.corporateAI.efficiency}`
    }
    
    return `${base}\n\n${xpText}`
  }
  
  // Method to get context-aware help text
  getContextualHelp(commandType) {
    const helpTexts = {
      basic: "For approved commands, use 'help'. Your activities are being monitored for quality assurance.",
      admin: "Administrative tools are available via 'nc-help'. Access is logged for... security purposes.",
      investigation: "Investigation commands are at your disposal. Please use them responsibly.",
      restricted: "That operation requires special clearance. Your interest has been noted."
    }
    
    return helpTexts[commandType] || helpTexts.basic
  }
}

// Create singleton instance
export const gameTerminology = new GameTerminology()