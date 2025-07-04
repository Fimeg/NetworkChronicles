import SystemIntegration from './SystemIntegration.js'

class GameEngine {
  constructor() {
    this.player = null
    this.quests = []
    this.currentQuestIndex = 0
    this.commandsLearned = new Set()
    this.discoveries = []
    this.networkMap = new Map()
    this.services = []
    this.initialized = false
    this.storyFlags = {
      found_admin_note: false,
      discovered_network: false,
      found_vulnerability: false,
      contacted_architect: false,
      // Investigation progression
      discovered_intruder_traces: false,
      found_encrypted_files: false,
      decoded_architect_messages: false,
      uncovered_insider_threat: false,
      // Red herrings and misdirection
      suspected_external_attack: false,
      found_fake_evidence: false,
      discovered_red_herring: false,
      // Character revelations
      met_mysterious_contact: false,
      discovered_architect_secret: false,
      learned_company_conspiracy: false,
      // Final revelations
      architect_fate_revealed: false,
      true_villain_exposed: false,
      conspiracy_unraveled: false
    }
    this.learningPatterns = new Map()
    this.adaptiveDifficulty = {
      currentLevel: 1,
      successRate: 0,
      strugglingAreas: [],
      strengthAreas: []
    }
    this.personalizedContent = []
    this.systemIntegration = new SystemIntegration()
    this.dailyTasks = []
    this.lastTaskRefresh = null
    this.shiftStatus = {
      clockedIn: false,
      shiftStart: null,
      tasksCompleted: 0,
      dailyXP: 0,
      currentShift: this.getCurrentShift()
    }
    this.linuxPuzzles = []
    this.advancedQuests = []
    this.systemDocumentation = new Map()
    this.activeIncidents = []
    this.monitoringSetup = {
      grafanaInstalled: false,
      prometheusInstalled: false,
      alertmanagerConfigured: false,
      dashboardsCreated: false,
      currentStep: 0
    }
    this.initializeAdvancedContent()
    this.storyElements = new Map()
    this.narrativeTimer = null
    this.lastStoryEvent = null
    this.suspectProfiles = new Map()
    this.evidenceLog = []
    this.initializeStoryElements()
    this.hiddenTerminals = new Map()
    this.discoveredCommands = new Set(['help', 'clear', 'pwd', 'ls', 'cd', 'cat', 'ps', 'netstat', 'nc-status', 'nc-help'])
    this.architectTerminalAccess = false
    this.initializeHiddenSystems()
    this.commandPatterns = new Map() // Track command usage patterns for discovery triggers
    this.initializeDiscoveryPatterns()
    this.progressionTiers = new Map() // V1-style tiered progression system
    this.initializeProgressionTiers()
    this.investigationJournal = new Map() // Investigation journal and notes
    this.commandReference = new Map() // Built-in man pages and tutorials
    this.initializeJournalAndReference()
    this.serviceNarratives = this.initializeServiceNarratives()
    this.cautionSystem = {
      enabled: true,
      warnings: [],
      educationalMoments: [],
      recentCommands: [],
      investigationNotes: [],
      lastCaution: null
    }
    this.initializeEducationalSystem()
  }

  initializeServiceNarratives() {
    return {
      // Proxmox Virtualization
      8006: "Proxmox web interface detected - The Architect ran VMs here",
      8007: "Proxmox backup detected - Critical data might be stored here",
      
      // Plex Media Server
      32400: "Plex server found - The Architect had a vast media collection",
      32469: "Plex DLNA detected - Media streaming was important to them",
      
      // Docker and Containers
      2375: "Docker daemon detected - Containerized services were in use",
      2376: "Secure Docker daemon - The Architect used TLS encryption",
      4243: "Docker Swarm detected - Orchestrated container management",
      
      // Web Services
      80: "HTTP server detected - Standard web services running",
      443: "HTTPS server found - Encrypted web traffic active",
      8080: "Alternative web port - Secondary services running",
      3000: "Development server detected - Active coding environment",
      4000: "Development port active - Testing environment found",
      8000: "HTTP alternative - Additional web services",
      9000: "Management interface - Administrative access point",
      
      // Reverse Proxies & Load Balancers
      2015: "Caddy server detected - Modern web server with automatic HTTPS",
      2016: "Caddy admin detected - The Architect preferred elegant solutions",
      80: "Traefik detected - Cloud-native reverse proxy configuration",
      8080: "Traefik dashboard - The Architect monitored traffic patterns",
      81: "Nginx Proxy Manager found - Web proxy administrative interface",
      1880: "Node-RED detected - The Architect automated workflows here",
      
      // Traditional Web Servers
      80: "Apache/Nginx detected - Traditional web server infrastructure",
      443: "Secure web server - TLS encryption was a priority",
      8008: "Alternative HTTP - Secondary web service endpoint",
      
      // Database Services
      3306: "MySQL detected - Database services were critical to operations",
      5432: "PostgreSQL found - Advanced database system in use",
      6379: "Redis detected - High-performance caching system",
      27017: "MongoDB found - Document database system active",
      
      // Communication & Collaboration
      25: "SMTP server detected - Email services were operational",
      143: "IMAP detected - Email access was important",
      993: "Secure IMAP found - Encrypted email communications",
      22: "SSH access detected - The Architect used secure remote access",
      
      // Network Infrastructure
      53: "DNS server detected - Network name resolution active",
      67: "DHCP server found - Network address management",
      161: "SNMP detected - Network monitoring was in place",
      
      // Gaming & Entertainment
      25565: "Minecraft server detected - The Architect enjoyed gaming",
      7777: "Game server found - Multiplayer gaming environment",
      
      // Home Automation
      8123: "Home Assistant detected - Smart home automation system",
      1883: "MQTT broker found - IoT device communication hub",
      
      // VPN & Security
      1194: "OpenVPN detected - Secure remote access configured",
      500: "IPSec VPN found - Enterprise-grade security",
      4500: "IPSec NAT-T detected - VPN through firewalls",
      
      // Monitoring & Analytics
      3001: "Grafana detected - Data visualization dashboard",
      9090: "Prometheus found - Metrics collection system",
      9093: "Alertmanager detected - Monitoring alerts configured",
      5601: "Kibana found - Log analysis dashboard",
      9200: "Elasticsearch detected - Search and analytics engine",
      
      // File Sharing
      139: "NetBIOS detected - File sharing was enabled",
      445: "SMB shares found - Network file access available",
      2049: "NFS detected - Unix file sharing system",
      
      // Default narratives for unknown ports
      default: "Unidentified service - The Architect may have used custom tools"
    }
  }

  getServiceNarrative(service) {
    const port = parseInt(service.port)
    const narratives = this.serviceNarratives
    
    // Check for specific port narratives
    if (narratives[port]) {
      return narratives[port]
    }
    
    // Check for service name patterns
    const name = service.name.toLowerCase()
    
    // Traefik detection by name
    if (name.includes('traefik')) {
      return "Traefik proxy detected - The Architect used cloud-native routing"
    }
    
    // Caddy detection by name
    if (name.includes('caddy')) {
      return "Caddy server found - Automatic HTTPS was important to security"
    }
    
    // Nginx Proxy Manager by name
    if (name.includes('nginx-proxy-manager') || name.includes('npm')) {
      return "Nginx Proxy Manager - Web-based proxy administration"
    }
    
    // Traditional web servers
    if (name.includes('nginx') && !name.includes('proxy')) {
      return "Nginx web server - High-performance HTTP server detected"
    }
    
    if (name.includes('apache') || name.includes('httpd')) {
      return "Apache web server - Traditional HTTP server infrastructure"
    }
    
    // Docker containers
    if (name.includes('docker') || name.includes('container')) {
      return "Container service - The Architect used modern deployment"
    }
    
    // Web-related services
    if (name.includes('http') || name.includes('web')) {
      return "Web service detected - Part of the Architect's infrastructure"
    }
    
    // Database-related
    if (name.includes('db') || name.includes('sql') || name.includes('database')) {
      return "Database service - Critical data storage system"
    }
    
    // Return default narrative for unknown services
    return narratives.default
  }

  generateInvestigationLeads(services) {
    const leads = []
    const detectedPorts = services.map(s => parseInt(s.port))
    
    // Proxmox leads
    if (detectedPorts.includes(8006) || detectedPorts.includes(8007)) {
      leads.push("Proxmox hypervisor found - Check for VM backups and logs")
      leads.push("Virtual machines may contain The Architect's projects")
    }
    
    // Plex leads  
    if (detectedPorts.includes(32400)) {
      leads.push("Plex media server - The Architect stored personal files here")
      leads.push("Media library might contain hidden encrypted folders")
    }
    
    // Docker leads
    if (detectedPorts.includes(2375) || detectedPorts.includes(2376) || detectedPorts.includes(4243)) {
      leads.push("Docker containers detected - Look for custom applications")
      leads.push("Container volumes may hold persistent data")
    }
    
    // Database leads
    if (detectedPorts.some(port => [3306, 5432, 6379, 27017].includes(port))) {
      leads.push("Database services found - Critical data storage discovered")
      leads.push("Database logs might reveal The Architect's activities")
    }
    
    // Web service leads
    if (detectedPorts.some(port => [80, 443, 8080, 3000, 4000, 8000, 9000].includes(port))) {
      leads.push("Web services active - Check for administrative interfaces")
      leads.push("Web logs may contain access patterns and timestamps")
    }
    
    // SSH leads
    if (detectedPorts.includes(22)) {
      leads.push("SSH access enabled - Review connection logs for clues")
      leads.push("The Architect likely accessed this system remotely")
    }
    
    // Monitoring leads
    if (detectedPorts.some(port => [3001, 9090, 9093, 5601, 9200].includes(port))) {
      leads.push("Monitoring stack detected - Performance data available")
      leads.push("Metrics may show unusual activity patterns")
    }
    
    // Home automation leads
    if (detectedPorts.includes(8123) || detectedPorts.includes(1883)) {
      leads.push("Smart home system found - IoT devices were monitored")
      leads.push("Automation logs might reveal behavioral patterns")
    }
    
    // VPN leads
    if (detectedPorts.some(port => [1194, 500, 4500].includes(port))) {
      leads.push("VPN server detected - Secure remote access configured")
      leads.push("VPN logs could show where The Architect connected from")
    }
    
    // Gaming leads
    if (detectedPorts.includes(25565) || detectedPorts.includes(7777)) {
      leads.push("Game server found - The Architect maintained gaming services")
      leads.push("Player logs might reveal communication patterns")
    }
    
    // If many services detected, add advanced leads
    if (services.length >= 5) {
      leads.push("Complex infrastructure suggests advanced technical skills")
      leads.push("Multiple services indicate this was a primary workstation")
    }
    
    // If few services, add stealth leads
    if (services.length <= 2 && services.length > 0) {
      leads.push("Minimal services suggest operational security awareness")
      leads.push("Hidden services might exist on non-standard ports")
    }
    
    return leads
  }

  initializeEducationalSystem() {
    this.dangerousCommands = {
      // System destructive commands - Ultimate embarrassment
      'rm -rf /': {
        severity: 'embarrassing',
        learning: 'career_limiting_move',
        warning: '[CAREER ALERT] That would wipe the entire filesystem!',
        narrative: 'Your muscle memory kicks in and you immediately draft an email: "Dear Leadership Team, I need to report a minor incident during our infrastructure investigation..."',
        consequence: 'awkward_email_to_management'
      },
      'rm -rf /*': {
        severity: 'embarrassing',
        learning: 'career_limiting_move',
        warning: '[CAREER ALERT] Filesystem destruction command detected',
        narrative: 'You start mentally composing: "Hi CEO, so funny story about that missing admin investigation... there may have been a small oopsie with root permissions..."',
        consequence: 'explaining_to_ceo'
      },
      'sudo rm -rf /': {
        severity: 'embarrassing',
        learning: 'career_limiting_move',
        warning: '[CAREER ALERT] Elevated destruction with sudo!',
        narrative: 'Time to update LinkedIn: "Experienced in... comprehensive filesystem management... seeking new opportunities..."',
        consequence: 'updating_linkedin'
      },
      
      // Database destruction
      'DROP DATABASE': {
        severity: 'high',
        consequence: 'data_loss',
        warning: '[DB] WARNING: Database destruction attempted!',
        narrative: 'You hesitate... this database might contain The Architect\'s final logs.'
      },
      'TRUNCATE': {
        severity: 'medium',
        consequence: 'data_corruption',
        warning: '[DB] CAUTION: Data truncation can be irreversible',
        narrative: 'Something feels wrong about deleting this data...'
      },
      
      // Network attacks
      'nmap -sS': {
        severity: 'medium',
        consequence: 'network_intrusion',
        warning: '[NET] ALERT: Stealth scan detected by monitoring systems',
        narrative: 'Your aggressive scan triggers security alerts - someone might be watching.'
      },
      'hydra': {
        severity: 'high',
        consequence: 'security_breach',
        warning: '[SEC] CRITICAL: Brute force attack detected!',
        narrative: 'The authentication systems lock down - this isn\'t the way The Architect would want you to proceed.'
      },
      
      // File system corruption
      'chmod 000': {
        severity: 'medium',
        consequence: 'access_denied',
        warning: '[SYS] WARNING: Removing all permissions can lock you out',
        narrative: 'You pause - making files inaccessible might hide important clues.'
      },
      
      // Service disruption
      'killall -9': {
        severity: 'medium',
        consequence: 'service_disruption',
        warning: '[SYS] CAUTION: Force-killing all processes is disruptive',
        narrative: 'Shutting down all services might destroy active evidence gathering.'
      },
      
      // Password attacks
      'john': {
        severity: 'medium',
        consequence: 'credential_attack',
        warning: '[SEC] ALERT: Password cracking attempt logged',
        narrative: 'The security team would investigate this kind of activity...'
      }
    }
    
    this.embarrassingConsequences = {
      awkward_email_to_management: {
        message: '[AUTO-DRAFTED] Apology Email #1',
        emailContent: `Subject: Sorry about that boss

Hey boss,

Sorry about that.
Sorry about that boss.
Really sorry about that.
I know I said I was being careful but, uh, sorry about that boss.
Won't happen again boss.
Sorry.

- Your apologetic sysadmin

P.S. Sorry about that.`,
        consequence: 'repetitive_apology_syndrome'
      },
      explaining_to_ceo: {
        message: '[AUTO-DRAFTED] CEO Apology',
        emailContent: `Subject: Sorry about that boss (executive edition)

Dear CEO Boss Person,

Sorry about that boss.
I know you're probably thinking "what did they do now" and well... sorry about that boss.
The filesystem is mostly intact! Mostly.
Sorry about that.
Really really sorry about that boss.
Please don't fire me boss.
Sorry.

Your increasingly careful (and sorry) sysadmin

P.S. - Sorry about that boss.
P.P.S. - Did I mention I'm sorry?`,
        consequence: 'executive_apology_overload'
      },
      updating_linkedin: {
        message: '[AUTO-UPDATE] LinkedIn Status',
        profileUpdate: `Current Status: Sorry about that boss

Recent Activity:
"Sorry about that boss. Had a small incident with rm -rf today. Sorry about that. Really sorry. Sorry boss."

Skills: Apologizing, Saying sorry, Boss appeasement, Sorry-ing professionally

#Sorry #SorryAboutThatBoss #SysAdminLife #StillSorry

Note: All references will start with "Well, they sure were sorry about things..."`,
        consequence: 'professional_sorry_spiral'
      }
    }
  }

  checkDangerousCommand(command) {
    const fullCommand = command.toLowerCase().trim()
    
    // Check for exact dangerous command matches
    for (const [dangerousCmd, config] of Object.entries(this.dangerousCommands)) {
      if (fullCommand.includes(dangerousCmd.toLowerCase())) {
        return {
          isDangerous: true,
          severity: config.severity,
          warning: config.warning,
          narrative: config.narrative,
          consequence: config.consequence
        }
      }
    }
    
    // Check for risky patterns
    const riskyPatterns = [
      { pattern: /rm.*-r.*\*/, warning: '[SYS] WARNING: Recursive deletion with wildcards is risky', severity: 'medium' },
      { pattern: /chmod.*777/, warning: '[SEC] WARNING: 777 permissions are a security risk', severity: 'low' },
      { pattern: /sudo.*rm/, warning: '[SYS] CAUTION: Elevated file deletion - be careful', severity: 'medium' },
      { pattern: /dd.*if=\/dev\/zero/, warning: '[SYS] CRITICAL: Disk wiping detected!', severity: 'high' },
      { pattern: /mkfs/, warning: '[SYS] CRITICAL: Filesystem formatting will destroy data!', severity: 'high' },
      { pattern: /(shutdown|reboot|halt).*-f/, warning: '[SYS] WARNING: Forced shutdown may cause data loss', severity: 'medium' }
    ]
    
    for (const risk of riskyPatterns) {
      if (risk.pattern.test(fullCommand)) {
        return {
          isDangerous: true,
          severity: risk.severity,
          warning: risk.warning,
          narrative: 'Your instincts warn you this might not be the right approach...',
          consequence: 'risky_behavior'
        }
      }
    }
    
    return { isDangerous: false }
  }

  handleFailureConsequence(consequence, commandUsed) {
    if (!this.failureSystem.enabled) return null
    
    const config = this.failureConsequences[consequence]
    if (!config) return null
    
    // Apply health penalty
    this.failureSystem.systemHealth -= config.healthPenalty
    if (this.failureSystem.systemHealth < 0) this.failureSystem.systemHealth = 0
    
    // Set story flags
    if (config.storyFlags) {
      config.storyFlags.forEach(flag => {
        this.storyFlags[flag] = true
      })
    }
    
    // Log the failure
    this.failureSystem.dangerousAttempts.push({
      command: commandUsed,
      consequence: consequence,
      timestamp: Date.now(),
      healthAfter: this.failureSystem.systemHealth
    })
    
    // Check for game over
    if (config.gameOver || this.failureSystem.systemHealth <= 0) {
      return {
        type: 'game_over',
        output: `${config.message}\\n\\n${config.narrative}\\n\\n[>] SYSTEM STATUS: CRITICAL FAILURE\\n[>] Investigation terminated. The truth about The Architect may never be known.`,
        gameOver: true
      }
    }
    
    // Increment failure count
    this.failureSystem.currentFailures += 1
    
    // Generate output
    let output = `${config.message}\\n\\n${config.narrative}`
    
    // Add system health warning if low
    if (this.failureSystem.systemHealth <= 30) {
      output += `\\n\\n[>] SYSTEM HEALTH: ${this.failureSystem.systemHealth}% - CRITICAL`
      output += `\\n[>] WARNING: Further mistakes may terminate the investigation!`
    } else if (this.failureSystem.systemHealth <= 60) {
      output += `\\n\\n[>] SYSTEM HEALTH: ${this.failureSystem.systemHealth}% - WARNING`
    }
    
    return {
      type: 'failure',
      output: output,
      healthPenalty: config.healthPenalty
    }
  }

  preventDangerousCommand(command) {
    const dangerCheck = this.checkDangerousCommand(command)
    
    if (!dangerCheck.isDangerous) return null
    
    // For critical commands, prevent execution entirely
    if (dangerCheck.severity === 'critical') {
      const result = this.handleFailureConsequence(dangerCheck.consequence, command)
      if (result) {
        return result
      }
      
      return {
        type: 'blocked',
        output: `${dangerCheck.warning}\\n\\n${dangerCheck.narrative}\\n\\n[>] Command execution prevented by safety protocols.`
      }
    }
    
    // For high/medium severity, show warning but allow execution
    if (dangerCheck.severity === 'high' || dangerCheck.severity === 'medium') {
      this.failureSystem.lastWarning = {
        command: command,
        timestamp: Date.now(),
        severity: dangerCheck.severity
      }
      
      return {
        type: 'warning',
        output: `${dangerCheck.warning}\\n\\n${dangerCheck.narrative}\\n\\n[>] Proceed with caution...`,
        allowExecution: true
      }
    }
    
    return null
  }

  getSystemStatus() {
    const health = this.failureSystem.systemHealth
    const failures = this.failureSystem.currentFailures
    const recentDangerous = this.failureSystem.dangerousAttempts.slice(-3)
    
    let status = `[>] SYSTEM HEALTH: ${health}%`
    
    if (health <= 30) {
      status += ` - CRITICAL`
    } else if (health <= 60) {
      status += ` - WARNING`
    } else if (health <= 90) {
      status += ` - STABLE`
    } else {
      status += ` - OPTIMAL`
    }
    
    status += `\\n[>] INVESTIGATION INTEGRITY: ${failures} incidents recorded`
    
    if (recentDangerous.length > 0) {
      status += `\\n[>] RECENT ALERTS: ${recentDangerous.length} security events`
    }
    
    return status
  }

  async initialize() {
    this.player = {
      name: 'recruit',
      level: 1,
      xp: 0,
      tier: 1,
      skills: {},
      skillTracks: {
        networking: { level: 0, xp: 0, unlocked: true },
        security: { level: 0, xp: 0, unlocked: false },
        systems: { level: 0, xp: 0, unlocked: false },
        devops: { level: 0, xp: 0, unlocked: false }
      },
      specialization: null,
      discoveries: [],
      completedQuests: [],
      achievements: [],
      learningStyle: null,
      preferredPace: 'normal',
      masteryScore: 0,
      weaknessAreas: [],
      strengthAreas: [],
      lastActive: new Date().toISOString()
    }

    this.quests = [
      {
        id: 'orientation',
        title: 'Digital Crime Scene',
        description: 'You\'ve entered a compromised system. Begin your investigation.',
        objective: 'Establish your location in this digital crime scene',
        commands: ['pwd'],
        xpReward: 10,
        completed: false,
        briefing: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                         🕵️ DIGITAL CRIME SCENE                              ║
║                     Investigation Protocol Initiated                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ SITUATION:                                                                   ║
║ Marcus "The Architect" Sullivan has vanished. $45 million is missing.       ║
║ You're now standing in his digital workspace. This is a crime scene.        ║
║                                                                              ║
║ OBJECTIVE:                                                                   ║
║ Like any investigator, you need to establish WHERE you are before you       ║
║ can understand WHAT happened here. Every good detective starts with         ║
║ orientation.                                                                 ║
║                                                                              ║
║ INVESTIGATION TIP:                                                           ║
║ In digital forensics, knowing your current location is crucial. There's     ║
║ a basic command that shows your present working directory...                 ║
║                                                                              ║
║ THINK LIKE A DETECTIVE:                                                      ║
║ • Where am I in this system?                                                ║
║ • What command reveals location in Unix systems?                             ║
║ • What would The Architect do first?                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝`
      },
      {
        id: 'explore',
        title: 'Evidence Collection',
        description: 'Search The Architect\'s workspace for clues',
        objective: 'Investigate what files and evidence The Architect left behind',
        commands: ['ls', 'cd'],
        xpReward: 15,
        completed: false,
        briefing: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                         [SCAN] EVIDENCE COLLECTION                          ║
║                     Crime Scene Documentation                                ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ SITUATION:                                                                   ║
║ You're in The Architect's digital workspace. This is where he was last      ║
║ seen before his disappearance. Every file could be evidence.                ║
║                                                                              ║
║ OBJECTIVE:                                                                   ║
║ Survey the crime scene. What did The Architect leave behind? Are there      ║
║ signs of struggle? Hidden evidence? You need to catalog everything.         ║
║                                                                              ║
║ INVESTIGATION TECHNIQUES:                                                    ║
║ • Document everything you find                                               ║
║ • Look for unusual files or patterns                                        ║
║ • Check for evidence of tampering                                           ║
║ • Note what seems out of place                                              ║
║                                                                              ║
║ HINT:                                                                        ║
║ Real investigators know there's a command to "list" the contents of         ║
║ directories. What files and folders are here?                               ║
╚══════════════════════════════════════════════════════════════════════════════╝`
      },
      {
        id: 'file_examination',
        title: 'File Investigation',
        description: 'Learn to examine file contents',
        objective: 'Use cat to read file contents',
        commands: ['cat'],
        xpReward: 20,
        completed: false,
        briefing: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                         🎯 MISSION BRIEFING                                 ║
║                     File Investigation                                       ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ SITUATION:                                                                   ║
║ The Architect left crucial evidence in text files throughout the system.    ║
║ File examination is the cornerstone of digital forensics investigation.     ║
║                                                                              ║
║ OBJECTIVE:                                                                   ║
║ Use 'cat' to examine file contents. Start with 'cat admin_notes.txt'        ║
║ to read The Architect's investigation notes.                                ║
║                                                                              ║
║ TECHNICAL CONTEXT:                                                           ║
║ • cat = "concatenate and display file contents"                             ║
║ • Primary tool for evidence examination                                      ║
║ • Safe, read-only operation maintains evidence integrity                     ║
║                                                                              ║
║ SECURITY RELEVANCE:                                                          ║
║ File examination reveals:                                                    ║
║ • Configuration tampering by attackers                                       ║
║ • Log entries showing suspicious activity                                    ║
║ • Hidden messages and investigative breadcrumbs                              ║
║ • Authentication records and access patterns                                 ║
║                                                                              ║
║ INVESTIGATION TIP:                                                           ║
║ The Architect's admin_notes.txt contains critical intelligence about        ║
║ the $45 million theft. This file will unlock advanced investigation         ║
║ capabilities once examined.                                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝`
      },
      {
        id: 'process_discovery',
        title: 'Process Investigation',
        description: 'Discover running processes',
        objective: 'Use ps to see running processes',
        commands: ['ps'],
        xpReward: 25,
        completed: false,
        briefing: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                         🎯 MISSION BRIEFING                                 ║
║                     Process Investigation                                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ SITUATION:                                                                   ║
║ The Architect discovered suspicious processes during the breach investigation.║
║ Process analysis is critical for identifying malware, backdoors, and        ║
║ unauthorized system access.                                                  ║
║                                                                              ║
║ OBJECTIVE:                                                                   ║
║ Execute 'ps' to examine running processes. Look for anything unusual         ║
║ or processes that don't belong on a secure system.                          ║
║                                                                              ║
║ TECHNICAL CONTEXT:                                                           ║
║ • ps = "Process Status" - shows running programs                            ║
║ • Essential for system administration and security                           ║
║ • Reveals process IDs, users, CPU usage, and command lines                  ║
║                                                                              ║
║ SECURITY RELEVANCE:                                                          ║
║ Process investigation helps identify:                                        ║
║ • Malware and rootkits hiding in system processes                           ║
║ • Unauthorized users running suspicious commands                             ║
║ • Network services that shouldn't be exposed                                ║
║ • Resource-intensive attacks like crypto mining                             ║
║                                                                              ║
║ INVESTIGATION TIP:                                                           ║
║ Pay attention to processes with unusual names, high CPU usage, or           ║
║ processes running as unexpected users. The attacker may have left           ║
║ persistent backdoors running as system services.                            ║
╚══════════════════════════════════════════════════════════════════════════════╝`
      },
      {
        id: 'network_reconnaissance',
        title: 'Network Reconnaissance',
        description: 'Investigate network connections',
        objective: 'Use netstat to examine network connections',
        commands: ['netstat'],
        xpReward: 30,
        completed: false
      },
      {
        id: 'service_discovery',
        title: 'Service Discovery',
        description: 'Discover and analyze running services',
        objective: 'Use nc-discover-services to find network services',
        commands: ['nc-discover-services'],
        xpReward: 50,
        completed: false
      },
      {
        id: 'network_mapping',
        title: 'Network Mapping',
        description: 'Map the network topology',
        objective: 'Use nc-map-network to visualize network structure',
        commands: ['nc-map-network'],
        xpReward: 40,
        completed: false
      },
      // Tier 2 Specialized Track Quests
      {
        id: 'networking_foundation',
        title: 'Network Segmentation Analysis',
        description: 'Learn advanced networking concepts and VLAN discovery',
        objective: 'Analyze network topology and identify security boundaries',
        commands: ['nc-analyze-network'],
        xpReward: 75,
        tier: 2,
        skillTrack: 'networking',
        prerequisites: ['network_mapping'],
        completed: false
      },
      {
        id: 'security_assessment',
        title: 'Security Vulnerability Assessment',
        description: 'Perform basic security scanning and analysis',
        objective: 'Identify potential security vulnerabilities in discovered services',
        commands: ['nc-security-scan'],
        xpReward: 75,
        tier: 2,
        skillTrack: 'security',
        prerequisites: ['service_discovery'],
        completed: false
      },
      {
        id: 'systems_monitoring',
        title: 'System Performance Monitoring',
        description: 'Monitor system resources and performance metrics',
        objective: 'Set up comprehensive system monitoring and alerting',
        commands: ['nc-monitor-system'],
        xpReward: 75,
        tier: 2,
        skillTrack: 'systems',
        prerequisites: ['process_discovery'],
        completed: false
      }
    ]

    this.initialized = true
  }

  getPlayer() {
    return this.player
  }

  getWelcomeMessage() {
    return `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          NETWORK CHRONICLES 2.0                             ║
║                         Linux Learning Terminal                             ║
╚══════════════════════════════════════════════════════════════════════════════╝

Welcome, ${this.player.name}! You have been assigned as the new systems administrator
while our senior architect is unavailable.

[!] URGENT: You must clock in for your first shift to begin your duties.

Type 'help' for basic commands or 'nc-help' for system administration tools.
    `
  }

  getCurrentQuest() {
    // Use the current quest index (managed by findNextQuest)
    if (this.currentQuestIndex >= this.quests.length) {
      return this.generateInvestigationGuidance()
    }

    const quest = this.quests[this.currentQuestIndex]
    if (quest && !quest.completed) {
      return `Quest: ${quest.title}\n${quest.description}\nObjective: ${quest.objective}\nReward: ${quest.xpReward} XP`
    }

    // If current quest is completed, let findNextQuest handle the logic
    this.findNextQuest()
    return this.getCurrentQuest()
  }

  generateInvestigationGuidance() {
    return `
╔══════════════════════════════════════════════════════════════════════════════╗
║                     🕵️ THE ARCHITECT INVESTIGATION                          ║
║                    Real Detective Work Begins                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Basic training complete! You now have the skills to investigate             ║
║ The Architect's disappearance and the $45 million theft.                    ║
║                                                                              ║
║ [?] INVESTIGATION LEADS TO FOLLOW:                                          ║
║                                                                              ║
║ 1. [LIST] The Architect mentioned "hidden monitoring ports"                 ║
║    └─ Try deeper network investigation beyond basic services                ║
║                                                                              ║
║ 2. [SEC] He prepared "contingencies" and investigation tools                ║
║    └─ Look for commands not in the standard manual                          ║
║                                                                              ║
║ 3. [DATA] Something about deleted log entries                               ║
║    └─ Check system logs for signs of tampering                              ║
║                                                                              ║
║ 4. [$] The financial motive - this was an inside job                        ║
║    └─ Look for evidence of insider access and motives                       ║
║                                                                              ║
║ [TIP] DETECTIVE COMMANDS TO TRY:                                            ║
║ • 'nc-scan-ports' - Look for those hidden monitoring ports                 ║
║ • 'nc-investigate logs' - Check for deleted evidence                        ║
║ • 'nc-journal leads' - See active investigation leads                       ║
║ • 'man <command>' - Learn any command with security context                ║
║ • 'help' - All available tools (some are hidden until discovered)          ║
║                                                                              ║
║ Remember The Architect's words: "Follow the digital breadcrumbs."           ║
║ Trust your instincts. Question everything. Find the truth.                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎯 The real mystery begins now. What will you discover?`
  }

  checkShiftRequirement(command) {
    // Commands that require being clocked in
    const shiftRequiredCommands = [
      'nc-discover-services', 'nc-map-network', 'nc-security-scan', 
      'nc-monitor-system', 'nc-analyze-network', 'nc-daily-tasks',
      'nc-complete-task', 'nc-incident-response', 'nc-scan-ports'
    ]
    
    if (shiftRequiredCommands.includes(command) && !this.shiftStatus.clockedIn) {
      return {
        type: 'error',
        output: '[!] SHIFT REQUIRED: You must clock in to perform work duties. Use "nc-clock-in" to start your shift.\n\n🕘 Administrative commands require active shift status for proper logging and accountability.',
        xpGained: 0
      }
    }
    
    return null
  }

  checkForEducationalMoment(command) {
    // Check if user is forcing dangerous command execution
    if (command.includes('--force-dangerous')) {
      return null // Skip all educational checks
    }
    
    // Check if the command might be dangerous
    const dangerousPatterns = Object.keys(this.dangerousCommands)
    const matchedPattern = dangerousPatterns.find(pattern => {
      const cleanCommand = command.replace('--force-dangerous', '').trim()
      return cleanCommand.toLowerCase().includes(pattern.toLowerCase())
    })
    
    if (matchedPattern) {
      const danger = this.dangerousCommands[matchedPattern]
      
      // For high severity commands, trigger educational warning
      if (danger.severity === 'high') {
        return {
          type: 'error',
          output: `${danger.warning}\n\n${danger.narrative}\n\n💡 TIP: Research safer alternatives or add '--force-dangerous' to bypass this warning.\n🎓 This is an educational safety check - learn before you break!`,
          xpGained: 5
        }
      }
      
      // For medium/low severity, just show a warning but allow execution
      return {
        type: 'warning',
        output: `⚠️  ${danger.warning}\n${danger.narrative}\nCommand will proceed normally...`,
        xpGained: 2,
        continueExecution: true
      }
    }
    
    return null
  }

  async executeCommand(command) {
    // Check for educational moments first
    const educationalCheck = this.checkForEducationalMoment(command)
    if (educationalCheck) {
      // If it's a high-severity warning, block execution
      if (educationalCheck.type === 'error') {
        return educationalCheck
      }
      // For warnings, show the message but continue if continueExecution is true
      if (educationalCheck.continueExecution) {
        // We'll show the warning and continue with the command
        // Store the warning to show after command execution
        this.pendingWarning = educationalCheck
      } else {
        return educationalCheck
      }
    }

    // Check if command requires active shift
    const shiftCheck = this.checkShiftRequirement(command.trim().split(' ')[0])
    if (shiftCheck) {
      return shiftCheck
    }
    
    const parts = command.trim().split(' ')
    const cmd = parts[0].toLowerCase()
    const args = parts.slice(1)

    // Track command usage
    this.commandsLearned.add(cmd)
    
    // Track recent commands for pattern analysis
    this.cautionSystem.recentCommands.push({
      command: command,
      timestamp: Date.now()
    })
    
    // Keep only last 20 commands
    if (this.cautionSystem.recentCommands.length > 20) {
      this.cautionSystem.recentCommands.shift()
    }
    
    // Check for automatic task completion
    const taskCompletion = this.checkTaskCompletion(command)
    
    // Check for V1-style discovery patterns
    const discoveryResult = this.checkDiscoveryPatterns(cmd, args)

    switch (cmd) {
      case 'help':
        return this.showHelp()
      
      case 'pwd':
        return this.enhanceResultWithDiscovery(await this.handlePwd(), discoveryResult, taskCompletion)
      
      case 'ls':
        return this.enhanceResultWithDiscovery(await this.handleLs(args), discoveryResult, taskCompletion)
      
      case 'cd':
        return this.enhanceResultWithDiscovery(await this.handleCd(args), discoveryResult, taskCompletion)
      
      case 'cat':
        return this.enhanceResultWithDiscovery(await this.handleCat(args), discoveryResult, taskCompletion)
      
      case 'ps':
        return this.enhanceResultWithDiscovery(await this.handlePs(args), discoveryResult, taskCompletion)
      
      case 'netstat':
        return this.enhanceResultWithDiscovery(await this.handleNetstat(args), discoveryResult, taskCompletion)
      
      case 'whoami':
        return this.handleWhoami()
      
      case 'date':
        return this.handleDate()
      
      case 'uname':
        return this.handleUname(args)
      
      case 'df':
        return this.enhanceResultWithDiscovery(await this.handleDf(args), discoveryResult, taskCompletion)
      
      case 'free':
        return this.enhanceResultWithDiscovery(await this.handleFree(args), discoveryResult, taskCompletion)
      
      case 'top':
        return this.enhanceResultWithDiscovery(this.handleTop(), discoveryResult, taskCompletion)
      
      case 'ifconfig':
        return this.enhanceResultWithDiscovery(await this.handleIfconfig(), discoveryResult, taskCompletion)
      
      case 'ping':
        return this.handlePing(args)
      
      case 'clear':
        return { 
          output: '', 
          type: 'clear',
          showWelcome: true  // Flag to show welcome info after clear
        }
      
      case 'status':
        return this.showStatus()
      
      case 'quests':
        return this.showQuests()
      
      case 'nc-discover-services':
        return this.enhanceResultWithDiscovery(await this.handleServiceDiscovery(), discoveryResult)
      
      case 'nc-map-network':
        return this.enhanceResultWithDiscovery(await this.handleNetworkMapping(), discoveryResult)
      
      case 'nc-status':
        return this.showStatus()
      
      case 'nc-investigation':
        return {
          type: 'investigation',
          output: this.getInvestigationStatus()
        }
      
      case 'nc-help':
        return this.showNCHelp()
      
      case 'nc-analyze-network':
        return this.enhanceResultWithDiscovery(this.handleNetworkAnalysis(), discoveryResult)
      
      case 'nc-security-scan':
        return this.enhanceResultWithDiscovery(this.handleSecurityScan(), discoveryResult)
      
      case 'nc-monitor-system':
        return this.enhanceResultWithDiscovery(this.handleSystemMonitoring(), discoveryResult)
      
      case 'nc-tracks':
        return this.showSkillTracks()
      
      case 'nc-specialize':
        return this.handleSpecialization(args)
      
      case 'nc-adaptive':
        return this.showAdaptiveLearning()
      
      case 'nc-personalize':
        return this.handlePersonalization(args)
      
      case 'nc-architect':
        return this.communicateWithArchitect(args)
      
      case 'nc-convergence':
        return this.showConvergencePaths()
      
      case 'nc-advance':
        return this.handleAdvancement(args)
      
      case 'nc-mastery':
        return this.assessMastery()
      
      case 'nc-clock-in':
        return this.handleClockIn()
      
      case 'nc-clock-out':
        return this.handleClockOut()
      
      case 'nc-daily-tasks':
        return this.showDailyTasks()
      
      case 'nc-complete-task':
        return this.completeTask(args)
      
      case 'nc-shift-status':
        return this.showShiftStatus()
      
      case 'nc-duty-log':
        return this.showDutyLog()
      
      case 'nc-puzzles':
        return this.showLinuxPuzzles()
      
      case 'nc-solve-puzzle':
        return this.solvePuzzle(args)
      
      case 'nc-advanced-quests':
        return this.showAdvancedQuests()
      
      case 'nc-start-monitoring':
        return this.startMonitoringQuest()
      
      case 'nc-system-docs':
        return this.showSystemDocumentation()
      
      case 'nc-incident-response':
        return this.enhanceResultWithDiscovery(this.handleIncidentResponse(args), discoveryResult)
      
      case 'nc-story':
        return this.showStoryStatus()
      
      case 'nc-investigate':
        return this.investigateEvidence(args)
      
      case 'nc-access-terminal':
        return this.accessHiddenTerminal(args)
      
      case 'nc-scan-ports':
        return await this.scanHiddenPorts()
      
      case 'nc-briefing':
        return this.showQuestBriefing(args)
      
      case 'nc-tier':
        return this.showTierStatus()
      
      case 'nc-journal':
        return this.showJournal(args)
      
      case 'nc-manual':
      case 'nc-man':
        return this.showCommandReference(args)
      
      case 'man':
        // Integrate with built-in man command for seamless experience
        return this.showCommandReference(args)
      
      // Hidden commands - only available after discovery
      case 'nc-suspects':
        return this.discoveredCommands.has('nc-suspects') ? this.showSuspectProfiles() : this.commandNotFound(cmd)
      
      case 'nc-evidence':
        return this.discoveredCommands.has('nc-evidence') ? this.showEvidenceLog() : this.commandNotFound(cmd)
      
      case 'nc-decrypt':
        return this.discoveredCommands.has('nc-decrypt') ? this.attemptDecryption(args) : this.commandNotFound(cmd)
      
      case 'nc-contact':
        return this.discoveredCommands.has('nc-contact') ? this.contactMysteriousFigure(args) : this.commandNotFound(cmd)
      
      case 'nc-revelation':
        return this.discoveredCommands.has('nc-revelation') ? this.triggerStoryRevelation() : this.commandNotFound(cmd)
      
      case 'nc-architect-shell':
        return this.architectTerminalAccess ? this.accessArchitectShell() : this.commandNotFound(cmd)
      
      case 'shadow-protocol':
        return this.discoveredCommands.has('shadow-protocol') ? this.initiateShadowProtocol() : this.commandNotFound(cmd)
      
      case 'nc-architect-message':
        return this.showArchitectMessage()
      
      default:
        const result = {
          output: `Command '${cmd}' not found. Type 'help' for available commands.`,
          type: 'error'
        }
        return this.enhanceResultWithDiscovery(result, discoveryResult, taskCompletion)
    }
  }

  // Enhance command results with task completion, discovery notifications, and tier advancement
  enhanceResultWithDiscovery(result, discoveryResult, taskCompletion = null) {
    let enhancedOutput = result.output
    let enhancedType = result.type
    let xpGained = 0
    let playerUpdate = false
    let shiftUpdate = false
    
    // Add task completion notification
    if (taskCompletion && taskCompletion.taskCompleted) {
      enhancedOutput += '\n\n' + taskCompletion.message
      xpGained += taskCompletion.xpGained
      playerUpdate = true
      shiftUpdate = true
      enhancedType = result.type === 'error' ? result.type : 'success'
    }
    
    // Add discovery notification
    if (discoveryResult.discovered) {
      enhancedOutput += '\n\n' + discoveryResult.message
      enhancedType = result.type === 'error' ? result.type : 'discovery'
    }
    
    // Check for tier advancement
    const tierAdvancement = this.checkProgressionAdvancement()
    if (tierAdvancement && tierAdvancement.advanced) {
      enhancedOutput += '\n\n' + tierAdvancement.message
      enhancedType = 'advancement'
    }
    
    return {
      ...result,
      output: enhancedOutput,
      type: enhancedType,
      xpGained: xpGained,
      playerUpdate: playerUpdate,
      shiftUpdate: shiftUpdate
    }
  }

  showQuestBriefing(args) {
    if (!args.length) {
      const currentQuest = this.quests[this.currentQuestIndex]
      if (!currentQuest) {
        return {
          output: '🎯 All missions completed! Continue exploring the investigation.',
          type: 'info'
        }
      }
      
      if (currentQuest.briefing) {
        return {
          output: currentQuest.briefing,
          type: 'info'
        }
      } else {
        return {
          output: `🎯 ${currentQuest.title}\n\n${currentQuest.description}\n\nObjective: ${currentQuest.objective}`,
          type: 'info'
        }
      }
    }
    
    // Show briefing for specific quest by ID
    const questId = args[0]
    const quest = this.quests.find(q => q.id === questId)
    
    if (!quest) {
      return {
        output: `[ERR] Quest '${questId}' not found.\n\nAvailable quests: ${this.quests.map(q => q.id).join(', ')}`,
        type: 'error'
      }
    }
    
    if (quest.briefing) {
      return {
        output: quest.briefing,
        type: 'info'
      }
    } else {
      return {
        output: `🎯 ${quest.title}\n\n${quest.description}\n\nObjective: ${quest.objective}`,
        type: 'info'
      }
    }
  }

  showTierStatus() {
    const currentTier = this.getCurrentTier()
    const nextTierName = currentTier.nextTier
    const nextTier = nextTierName ? this.progressionTiers.get(nextTierName) : null
    
    let statusOutput = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                           🎖️  TIER PROGRESSION STATUS                       ║
║                         The Architect's Legacy System                       ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 CURRENT RANK: ${currentTier.title.toUpperCase().padEnd(58)} ║
║ [LVL] TIER LEVEL: ${currentTier.level.toString().padEnd(62)} ║
║                                                                              ║
║ 📋 DESCRIPTION:                                                             ║
║ ${currentTier.description.padEnd(76)} ║
║                                                                              ║
║ 🔓 CURRENT CAPABILITIES:                                                    ║
${currentTier.unlocks.map(unlock => `║ • ${unlock.padEnd(74)} ║`).join('\n')}`

    if (nextTier) {
      statusOutput += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 NEXT TIER: ${nextTier.title.toUpperCase().padEnd(62)} ║
║                                                                              ║
║ 📋 REQUIREMENTS FOR ADVANCEMENT:                                            ║
║ Commands Mastered: ${nextTier.requirements.commands.length} required                                    ║`

      // Show command progress
      nextTier.requirements.commands.forEach(cmd => {
        const mastered = this.commandsLearned.has(cmd) || this.discoveredCommands.has(cmd)
        const icon = mastered ? '[OK]' : '[...]'
        statusOutput += `
║ ${icon} ${cmd.padEnd(72)} ║`
      })

      statusOutput += `
║                                                                              ║
║ Discoveries: ${this.discoveries.length}/${nextTier.requirements.discoveries} required                                             ║
║ Investigation Progress: ${nextTier.requirements.storyFlags.filter(flag => this.storyFlags[flag]).length}/${nextTier.requirements.storyFlags.length} milestones                                    ║`

      // Show next tier unlocks
      statusOutput += `
║                                                                              ║
║ 🔓 WILL UNLOCK:                                                             ║
${nextTier.unlocks.map(unlock => `║ • ${unlock.padEnd(74)} ║`).join('\n')}`

    } else {
      statusOutput += `
║                                                                              ║
║ 👑 MAXIMUM TIER ACHIEVED!                                                   ║
║ You have reached the pinnacle of The Architect's training program.          ║
║ All investigation capabilities unlocked.                                     ║`
    }

    statusOutput += `
╚══════════════════════════════════════════════════════════════════════════════╝

${nextTier ? '💫 Continue your investigation to advance to the next tier!' : '🌟 You are now a master investigator in The Architect\'s tradition!'}`

    return {
      output: statusOutput,
      type: 'info'
    }
  }

  showHelp() {
    return {
      output: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                           [HELP] BASIC LINUX COMMANDS                       ║
╚══════════════════════════════════════════════════════════════════════════════╝

[NAV] Navigation:
  pwd              - Show current directory
  ls [path]        - List directory contents  
  cd [path]        - Change directory

[FILE] File Operations:
  cat [file]       - Display file contents
  clear            - Clear the terminal screen

[SYS] System Information:
  ps [options]     - Show running processes
  whoami          - Show current user
  date            - Show current date/time
  uname [-a]      - Show system information
  df [-h]         - Show disk usage
  free [-h]       - Show memory usage
  top             - Show running processes (snapshot)

[NET] Basic Network:
  netstat [options] - Show network connections
  ifconfig         - Show network interfaces
  ping [host]      - Test network connectivity

[INFO] Additional Help:
  man <command>    - Show detailed help for any command
  nc-help         - Show Network Chronicles administration tools

[TIP] Use 'nc-help' for specialized system administration commands!`,
      type: 'info'
    }
  }

  showNCHelp() {
    return {
      output: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                    [NC-HELP] NETWORK CHRONICLES ADMIN TOOLS                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

[SHIFT] Daily Operations:
  nc-clock-in        - Start your shift and receive daily tasks
  nc-daily-tasks     - View assigned duties for current shift
  nc-clock-out       - End shift and view performance summary

[STATUS] System Administration:
  nc-status          - Show detailed game status and progress
  nc-briefing        - Show detailed mission briefings
  nc-tier            - Show tier progression status

[DISCOVERY] Network Investigation:
  nc-discover-services - Scan for running network services
  nc-map-network      - Show network topology map
  nc-scan-ports       - Advanced port scanning (unlocked via investigation)

[INVESTIGATION] The Architect Case:
  nc-journal         - Your investigation notebook and evidence log
  nc-investigate     - Examine evidence and system logs
  nc-puzzles         - Linux skill challenges with investigation rewards
  nc-advanced-quests - Complex monitoring and infrastructure tasks

[SPECIALIZATION] Career Paths:
  nc-tracks          - Show skill specialization tracks
  nc-specialize      - Choose your specialization path
  nc-convergence     - Show skill convergence paths and career specializations
  nc-advance         - Unlock advanced career specializations

[ADVANCED] Tier 2+ Tools:
  nc-analyze-network - Network segmentation analysis
  nc-security-scan   - Security vulnerability assessment
  nc-monitor-system  - System performance monitoring

[AI] Learning Assistant:
  nc-adaptive        - Show adaptive learning analytics
  nc-personalize     - Customize your learning experience
  nc-architect       - Communicate with The Architect (AI mentor)

[INFO] For basic Linux commands, use 'help' instead of 'nc-help'`,
      type: 'info'
    }
  }

  async handlePwd() {
    const systemResult = await this.systemIntegration.executeRealCommand('pwd')
    const result = {
      output: systemResult.output,
      type: systemResult.type
    }

    return this.checkQuestProgress('pwd', result)
  }

  async handleLs(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('ls', args)
    const result = {
      output: systemResult.output,
      type: systemResult.type
    }

    return this.checkQuestProgress('ls', result)
  }

  async handleCd(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('cd', args)
    const result = {
      output: systemResult.output,
      type: systemResult.type
    }

    return this.checkQuestProgress('cd', result)
  }

  async handleCat(args) {
    if (!args.length) {
      return { output: 'cat: missing file operand', type: 'error' }
    }

    const filename = args[0]
    
    // Try to read game-specific files first
    const gameFileResult = await this.systemIntegration.readGameFile(filename)
    
    // Handle special case for admin notes
    if (filename === 'admin_notes.txt' && gameFileResult.type !== 'error') {
      this.storyFlags.found_admin_note = true
      // Trigger story progression after reading The Architect's notes
      this.storyFlags.discovered_architect_secret = true
      
      // Add journal entry
      this.addJournalEntry(
        'The Architect\'s Final Transmission Read',
        `Critical evidence discovered in The Architect's personal notes:

• $45 million theft was targeted - attackers knew exact systems
• Hidden investigation tools placed throughout the system
• Three critical attacker mistakes identified
• Urgent directive to check /var/log for deleted entries
• Reference to "hidden monitoring ports" beyond standard services

Investigation status: The Architect suspected this was an inside job.
His preparation suggests he knew danger was imminent.

Next steps: Follow his guidance to uncover the truth.`,
        'evidence'
      )
    }

    const result = {
      output: gameFileResult.output,
      type: gameFileResult.type
    }

    return this.checkQuestProgress('cat', result)
  }

  async handlePs(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('ps', args)
    const result = {
      output: systemResult.output,
      type: systemResult.type
    }

    return this.checkQuestProgress('ps', result)
  }

  async handleNetstat(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('netstat', args)
    const result = {
      output: systemResult.output,
      type: systemResult.type
    }

    return this.checkQuestProgress('netstat', result)
  }

  handleWhoami() {
    return {
      output: this.player.name,
      type: 'normal'
    }
  }

  handleDate() {
    return {
      output: new Date().toString(),
      type: 'normal'
    }
  }

  handleUname(args) {
    if (args.includes('-a')) {
      return {
        output: 'Linux terminal-server 5.4.0-42-generic #46-Ubuntu SMP x86_64 GNU/Linux',
        type: 'normal'
      }
    }
    return {
      output: 'Linux',
      type: 'normal'
    }
  }

  async handleDf(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('df', args)
    return {
      output: systemResult.output,
      type: systemResult.type
    }
  }

  async handleFree(args) {
    const systemResult = await this.systemIntegration.executeRealCommand('free', args)
    return {
      output: systemResult.output,
      type: systemResult.type
    }
  }

  handleTop() {
    const topOutput = [
      'Tasks: 124 total,   1 running, 123 sleeping',
      'CPU usage: 12.5% user, 3.2% system, 84.3% idle',
      'Memory: 2.4G used, 5.1G available',
      '',
      'PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND',
      '1234 root      20   0  123456  45678  12345 S   5.2  0.6   0:23.45 network-monitor',
      '1235 www-data  20   0   98765  32109   8765 S   2.1  0.4   0:12.34 web-server',
      '1236 system    20   0   76543  21098   5432 S   0.8  0.3   0:08.76 suspicious-service'
    ]

    return {
      output: topOutput.join('\n'),
      type: 'normal'
    }
  }

  async handleIfconfig() {
    const systemResult = await this.systemIntegration.executeRealCommand('ifconfig')
    return {
      output: systemResult.output,
      type: systemResult.type
    }
  }

  handlePing(args) {
    if (!args.length) {
      return { output: 'ping: usage error: Destination address required', type: 'error' }
    }

    const host = args[0]
    return {
      output: `PING ${host}: 64 bytes from ${host}: icmp_seq=1 ttl=64 time=1.23 ms\nConnection successful - host is reachable`,
      type: 'success'
    }
  }

  showStatus() {
    const skills = Object.keys(this.player.skills).join(', ') || 'None yet'
    const commandsCount = this.commandsLearned.size
    const xpForNextLevel = ((this.player.level) * 100) - this.player.xp
    const currentQuest = this.quests[this.currentQuestIndex]
    const completedQuests = this.player.completedQuests.length
    const discoveries = this.player.discoveries.length

    // Create progress bar for XP
    const xpProgress = Math.floor((this.player.xp % 100) / 10)
    const progressBar = '█'.repeat(xpProgress) + '░'.repeat(10 - xpProgress)

    // Dynamic status message based on progress
    let statusMessage = ''
    if (this.player.level >= 3) {
      statusMessage = '[ADV] Advanced operator - accessing restricted data'
    } else if (this.player.level >= 2) {
      statusMessage = '⚡ Experienced user - enhanced permissions granted'
    } else {
      statusMessage = '🔰 Rookie status - basic access only'
    }

    let statusDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                         NETWORK CHRONICLES 2.0 STATUS                       ║
║                        Linux Learning Terminal v5.0                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ OPERATIVE: ${this.player.name.padEnd(20)} ┃ TIER: ${this.player.level.toString().padEnd(15)} ║
║ XP: ${this.player.xp.toString().padEnd(25)} ┃ NEXT LEVEL: ${xpForNextLevel > 0 ? xpForNextLevel + ' XP' : 'MAX LEVEL'.padEnd(10)} ║
║ PROGRESS: [${progressBar}] ${((this.player.xp % 100))}%                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ [STAT] STATISTICS                                                        ║
║ ├─ Commands Mastered: ${commandsCount.toString().padEnd(47)} ║
║ ├─ Quests Completed: ${completedQuests.toString()}/${this.quests.length.toString().padEnd(44)} ║
║ ├─ Network Discoveries: ${discoveries.toString().padEnd(42)} ║
║ └─ System Integration: ${this.systemIntegration ? 'ACTIVE' : 'DISABLED'.padEnd(42)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 CURRENT MISSION                                                          ║
║ ${currentQuest ? currentQuest.title.padEnd(76) : 'No active mission'.padEnd(76)} ║
║ ${currentQuest ? ('└─ ' + currentQuest.objective).padEnd(76) : ''.padEnd(76)} ║
║ ${currentQuest ? ('   Reward: ' + currentQuest.xpReward + ' XP').padEnd(76) : ''.padEnd(76)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔧 ACQUIRED SKILLS                                                          ║
║ ${skills.padEnd(76)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🌐 SYSTEM STATUS                                                            ║
║ ${statusMessage.padEnd(76)} ║
║ Real System Integration: ${this.systemIntegration.isWebEnvironment ? 'WEB MODE' : 'TERMINAL MODE'.padEnd(52)} ║
║ Command History: ${this.commandsLearned.size} unique commands executed                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📈 DISCOVERY LOG                                                            ║`

    // Add recent discoveries
    if (this.player.discoveries.length > 0) {
      const recentDiscoveries = this.player.discoveries.slice(-3)
      recentDiscoveries.forEach(discovery => {
        const discoveryLine = `║ • ${discovery.name || discovery.id}`.padEnd(77) + '║'
        statusDisplay += '\n' + discoveryLine
      })
    } else {
      statusDisplay += '\n║ No discoveries recorded yet - explore to find network secrets          ║'
    }

    statusDisplay += `
╚══════════════════════════════════════════════════════════════════════════════╝

[CMD] Available Commands: help, nc-help, nc-discover-services, nc-map-network
[TIP] Learning Tip: Try 'quests' to see your progression through the training program
    `

    return {
      output: statusDisplay,
      type: 'info'
    }
  }

  showQuests() {
    const totalXP = this.quests.reduce((sum, quest) => sum + quest.xpReward, 0)
    const earnedXP = this.quests.filter(quest => quest.completed).reduce((sum, quest) => sum + quest.xpReward, 0)
    const completedCount = this.quests.filter(quest => quest.completed).length
    
    let questDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                            MISSION BRIEFINGS                                ║
║                      Linux Skills Development Program                       ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📋 TRAINING PROGRESS: ${completedCount}/${this.quests.length} missions completed                        ║
║ 💰 XP EARNED: ${earnedXP}/${totalXP} available experience points                      ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    this.quests.forEach((quest, index) => {
      let statusIcon, statusColor, statusText
      
      if (quest.completed) {
        statusIcon = '[OK]'
        statusColor = 'COMPLETED'
        statusText = 'Mission accomplished'
      } else if (index === this.currentQuestIndex) {
        statusIcon = '[>]'
        statusColor = 'ACTIVE'
        statusText = quest.objective
      } else {
        statusIcon = '[...]'
        statusColor = 'PENDING'
        statusText = 'Awaiting activation'
      }

      questDisplay += `
║ ${statusIcon} ${quest.title.padEnd(40)} [${statusColor.padEnd(9)}] ║
║    └─ ${statusText.padEnd(65)} ║
║    💎 Reward: ${quest.xpReward.toString().padEnd(57)} XP ║`
      
      if (index < this.quests.length - 1) {
        questDisplay += `
║    ───────────────────────────────────────────────────────────────────────── ║`
      }
    })

    questDisplay += `
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎓 CURRENT OBJECTIVE                                                        ║`

    const currentQuest = this.quests[this.currentQuestIndex]
    if (currentQuest && !currentQuest.completed) {
      questDisplay += `
║ ${currentQuest.title.padEnd(76)} ║
║ └─ ${currentQuest.objective.padEnd(73)} ║
║                                                                              ║
║ [TIP] TIP: Type the suggested command to progress through the mission   ║`
    } else if (this.currentQuestIndex >= this.quests.length) {
      questDisplay += `
║ 🎉 ALL MISSIONS COMPLETED!                                                  ║
║ └─ You have mastered the basic Linux command training program              ║
║                                                                              ║
║ [ADV] Continue exploring with nc-discover-services and nc-map-network   ║`
    }

    questDisplay += `
╚══════════════════════════════════════════════════════════════════════════════╝

[INFO] Use 'nc-status' to see your overall progress and statistics
[CMD] Type 'help' to see all available commands for continued learning`

    return {
      output: questDisplay,
      type: 'info'
    }
  }

  async handleServiceDiscovery() {
    const services = await this.systemIntegration.discoverRealServices()
    
    const newDiscovery = {
      id: 'services_discovered',
      name: 'Network Services',
      description: 'Real system service discovery scan',
      services: services,
      timestamp: new Date().toISOString()
    }

    this.discoveries.push(newDiscovery)
    this.player.discoveries.push(newDiscovery)
    
    // Create enhanced visual output
    let serviceOutput = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        [SCAN] NETWORK SERVICE DISCOVERY                  ║
║                          Real System Scan Results                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📡 SCAN INITIATED: ${new Date().toLocaleString().padEnd(55)} ║
║ 🎯 TARGET: localhost (127.0.0.1)                                           ║
║ 🛡️  SCAN TYPE: Educational security assessment                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 DISCOVERED SERVICES                                                      ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    if (services.length === 0) {
      serviceOutput += `
║ [WARN] No services detected on standard ports                               ║
║    This could indicate:                                                     ║
║    • Firewall blocking access                                              ║
║    • Services running on non-standard ports                                ║
║    • System in secure configuration                                        ║
║                                                                              ║
║ [STORY] The Architect was known for using hidden services...               ║
║    Perhaps they configured this system to be more discrete than usual.     ║`
    } else {
      services.forEach((service, index) => {
        const narrative = this.getServiceNarrative(service)
        const portInfo = `${service.name} (${service.port})`
        const status = service.status === 'running' ? '[ON] ACTIVE' : '[OFF] INACTIVE'
        
        serviceOutput += `
║ ${(index + 1).toString().padStart(2)}. ${portInfo.padEnd(35)} ${status.padEnd(25)} ║
║     └─ ${service.description.padEnd(65)} ║`

        if (narrative) {
          serviceOutput += `
║     [STORY] ${narrative.padEnd(61)} ║`
        }
        
        if (index < services.length - 1) {
          serviceOutput += `
║     ───────────────────────────────────────────────────────────────────── ║`
        }
      })

      // Add investigation leads based on detected services
      const investigationLeads = this.generateInvestigationLeads(services)
      if (investigationLeads.length > 0) {
        serviceOutput += `
╠══════════════════════════════════════════════════════════════════════════════╣
║ [CLUE] INVESTIGATION LEADS DISCOVERED:                                      ║`
        investigationLeads.forEach(lead => {
          serviceOutput += `
║ • ${lead.padEnd(74)} ║`
        })
      }
    }

    serviceOutput += `
╠══════════════════════════════════════════════════════════════════════════════╣
║ [SEC] SECURITY ANALYSIS                                                     ║
║ • Services detected: ${services.length.toString().padEnd(56)} ║
║ • Educational scan completed successfully                                   ║
║ • Data logged for learning purposes                                        ║
║ • Real system integration: ACTIVE                                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📈 NEXT STEPS                                                               ║
║ • Use 'nc-map-network' to visualize network topology                       ║
║ • Try 'netstat -tulpn' to see detailed connection information              ║
║ • Check 'ps aux' to see which processes are running these services         ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎓 LEARNING ACHIEVEMENT: Real network service discovery completed!
🎯 You have successfully scanned your actual system for running services.`

    const result = {
      output: serviceOutput,
      type: 'success'
    }

    return this.checkQuestProgress('nc-discover-services', result)
  }

  async handleNetworkMapping() {
    // Get real network interfaces
    const ifconfigResult = await this.systemIntegration.executeRealCommand('ifconfig')
    const networkInterfaces = this.parseNetworkInterfaces(ifconfigResult.output)
    
    // Get discovered services
    const services = await this.systemIntegration.discoverRealServices()
    
    // Generate unified network map
    const networkMap = this.generateUnifiedNetworkMap(networkInterfaces, services)

    const result = {
      output: networkMap,
      type: 'info'
    }

    return this.checkQuestProgress('nc-map-network', result)
  }

  parseNetworkInterfaces(ifconfigOutput) {
    const interfaces = []
    const lines = ifconfigOutput.split('\n')
    let currentInterface = null
    
    for (const line of lines) {
      // Check for new interface
      const interfaceMatch = line.match(/^(\d+):\s+(\w+):\s+<([^>]+)>/)
      if (interfaceMatch) {
        if (currentInterface) {
          interfaces.push(currentInterface)
        }
        currentInterface = {
          name: interfaceMatch[2],
          flags: interfaceMatch[3],
          ipv4: null,
          ipv6: null,
          mac: null,
          status: interfaceMatch[3].includes('UP') ? 'UP' : 'DOWN'
        }
      }
      
      // Parse IP addresses
      if (currentInterface && line.includes('inet ')) {
        const ipMatch = line.match(/inet\s+([0-9.]+)\/(\d+)/)
        if (ipMatch) {
          currentInterface.ipv4 = ipMatch[1]
          currentInterface.subnet = ipMatch[2]
        }
      }
      
      // Parse MAC addresses
      if (currentInterface && line.includes('link/ether')) {
        const macMatch = line.match(/link\/ether\s+([0-9a-f:]+)/)
        if (macMatch) {
          currentInterface.mac = macMatch[1]
        }
      }
    }
    
    if (currentInterface) {
      interfaces.push(currentInterface)
    }
    
    return interfaces
  }

  generateUnifiedNetworkMap(interfaces, services) {
    const activeInterfaces = interfaces.filter(iface => iface.status === 'UP' && iface.ipv4 && iface.ipv4 !== '127.0.0.1')
    
    let networkMap = `
╔═══════════════════════════════════════════════════════════════════════════════╗
║                         🌐 REAL NETWORK TOPOLOGY MAP                         ║
║                          Live System Integration                             ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ 📡 DISCOVERED NETWORK INTERFACES:                                           ║
║                                                                               ║`

    // Add each active interface
    activeInterfaces.forEach((iface, index) => {
      const isWifi = iface.name.includes('wl')
      const isEthernet = iface.name.includes('en')
      const isDocker = iface.name.includes('br-') || iface.name.includes('docker')
      
      let interfaceType = '🔌'
      let description = 'Network Interface'
      
      if (isWifi) {
        interfaceType = '📶'
        description = 'WiFi Interface'
      } else if (isEthernet) {
        interfaceType = '🔗'
        description = 'Ethernet Interface'
      } else if (isDocker) {
        interfaceType = '🐳'
        description = 'Docker Bridge'
      }
      
      networkMap += `
║ ${interfaceType} ${iface.name.padEnd(20)} ${description.padEnd(25)} ║
║   ├─ IP: ${iface.ipv4.padEnd(15)} Subnet: /${iface.subnet.padEnd(20)} ║
║   ├─ MAC: ${iface.mac ? iface.mac.padEnd(50) : 'N/A'.padEnd(50)} ║
║   └─ Status: ${iface.status.padEnd(57)} ║`
      
      if (index < activeInterfaces.length - 1) {
        networkMap += `
║                                                                               ║`
      }
    })

    // Add services section
    networkMap += `
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 DISCOVERED SERVICES ON LOCALHOST:                                        ║
║                                                                               ║`

    if (services.length > 0) {
      services.forEach((service, index) => {
        const status = service.status === 'running' ? '🟢' : '🔴'
        networkMap += `
║ ${status} ${service.name.padEnd(20)} Port: ${service.port.toString().padEnd(15)} ║
║   └─ ${service.description.padEnd(68)} ║`
        
        if (index < services.length - 1) {
          networkMap += `
║                                                                               ║`
        }
      })
    } else {
      networkMap += `
║ ⚠️  No services detected on standard ports                                   ║
║ 💡 Try running 'nc-discover-services' to scan for services                   ║`
    }

    // Add network analysis
    const primaryInterface = activeInterfaces.find(iface => !iface.name.includes('docker') && !iface.name.includes('br-'))
    const dockerInterfaces = activeInterfaces.filter(iface => iface.name.includes('docker') || iface.name.includes('br-'))
    
    networkMap += `
║                                                                               ║
╠═══════════════════════════════════════════════════════════════════════════════╣
║ 📊 NETWORK ANALYSIS:                                                         ║
║                                                                               ║`

    if (primaryInterface) {
      networkMap += `
║ 🎯 Primary Interface: ${primaryInterface.name.padEnd(48)} ║
║   └─ External IP: ${primaryInterface.ipv4.padEnd(54)} ║`
    }

    if (dockerInterfaces.length > 0) {
      networkMap += `
║                                                                               ║
║ 🐳 Docker Networks Detected: ${dockerInterfaces.length.toString().padEnd(44)} ║
║   └─ Containerized services may be running                                   ║`
    }

    networkMap += `
║                                                                               ║
║ 🔐 Security Insights:                                                        ║
║ • ${activeInterfaces.length} active network interfaces detected                           ║
║ • ${services.length} services discovered on localhost                                    ║
║ • Network appears to be properly segmented                                   ║
║                                                                               ║
║ 📈 Next Steps:                                                               ║
║ • Use 'nc-analyze-network' for detailed segmentation analysis                ║
║ • Try 'nc-security-scan' to assess service vulnerabilities                   ║
║ • Run 'netstat -tulpn' to see detailed port information                      ║
╚═══════════════════════════════════════════════════════════════════════════════╝

🎓 REAL NETWORK INTEGRATION: Live system data successfully mapped!
🔍 This represents your actual network configuration and running services.`

    return networkMap
  }

  handleNetworkAnalysis() {
    const networkAnalysis = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🔍 NETWORK SEGMENTATION ANALYSIS                     ║
║                           Advanced Networking Track                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 ANALYZING NETWORK TOPOLOGY AND SECURITY BOUNDARIES                       ║
║                                                                              ║
║ 📊 VLAN DISCOVERY RESULTS:                                                  ║
║ ├─ VLAN 10 (Management): 192.168.10.0/24 - CRITICAL SECURITY ZONE          ║
║ ├─ VLAN 20 (Production): 192.168.20.0/24 - ACTIVE SERVICES                 ║
║ ├─ VLAN 30 (Development): 192.168.30.0/24 - ISOLATED ENVIRONMENT           ║
║ └─ VLAN 99 (Guest): 192.168.99.0/24 - RESTRICTED ACCESS                    ║
║                                                                              ║
║ 🔐 SECURITY BOUNDARY ANALYSIS:                                              ║
║ • Inter-VLAN routing detected - potential security risk                     ║
║ • Management VLAN accessible from production - HIGH RISK                    ║
║ • Firewall rules appear incomplete                                          ║
║                                                                              ║
║ 🎓 LEARNING OBJECTIVES COMPLETED:                                           ║
║ ✓ Network segmentation concepts                                             ║
║ ✓ VLAN identification and analysis                                          ║
║ ✓ Security boundary assessment                                              ║
║ ✓ Risk identification and prioritization                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

🚀 NETWORKING SKILL TRACK PROGRESSION: +2 levels in Network Architecture`

    const result = {
      output: networkAnalysis,
      type: 'success'
    }

    return this.checkQuestProgress('nc-analyze-network', result)
  }

  handleSecurityScan() {
    const securityScan = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🛡️ SECURITY VULNERABILITY ASSESSMENT                  ║
║                            Security Specialist Track                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 COMPREHENSIVE SECURITY SCAN INITIATED                                    ║
║                                                                              ║
║ 🎯 VULNERABILITY FINDINGS:                                                  ║
║ ├─ [HIGH] SSH root login enabled on port 22                                ║
║ ├─ [MEDIUM] HTTP service without HTTPS redirect (port 80)                  ║
║ ├─ [MEDIUM] MySQL running with default configuration                        ║
║ ├─ [LOW] Unnecessary services running (telnet, ftp)                         ║
║ └─ [INFO] Service banners revealing version information                     ║
║                                                                              ║
║ 🔐 SECURITY RECOMMENDATIONS:                                                ║
║ • Disable SSH root login, use key-based authentication                      ║
║ • Implement HTTPS redirect and SSL/TLS encryption                           ║
║ • Harden MySQL configuration, disable remote root access                    ║
║ • Remove unnecessary services to reduce attack surface                      ║
║                                                                              ║
║ 📊 COMPLIANCE STATUS:                                                       ║
║ • Security Score: 6.2/10 (Needs Improvement)                               ║
║ • Critical Issues: 1                                                        ║
║ • Recommendations: 4                                                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔒 SECURITY SKILL TRACK PROGRESSION: +2 levels in Vulnerability Assessment`

    const result = {
      output: securityScan,
      type: 'success'
    }

    return this.checkQuestProgress('nc-security-scan', result)
  }

  handleSystemMonitoring() {
    const systemMonitoring = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📊 SYSTEM PERFORMANCE MONITORING                     ║
║                          Systems Administration Track                       ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🖥️  REAL-TIME SYSTEM METRICS                                                ║
║                                                                              ║
║ 📈 PERFORMANCE INDICATORS:                                                  ║
║ ├─ CPU Usage: 23.5% (Normal)                                               ║
║ ├─ Memory: 2.1GB/8GB (26% utilized)                                        ║
║ ├─ Disk I/O: 145 MB/s read, 89 MB/s write                                  ║
║ ├─ Network: 1.2 Mbps in, 0.8 Mbps out                                      ║
║ └─ Load Average: 0.85, 0.92, 1.05 (1/5/15 min)                            ║
║                                                                              ║
║ ⚠️  ALERTS AND NOTIFICATIONS:                                               ║
║ • High memory usage detected in process 'web-server' (PID 1235)             ║
║ • Disk usage on /var/log approaching 85% capacity                           ║
║ • Network latency spike detected at 14:23:45                                ║
║                                                                              ║
║ 🔧 MONITORING SETUP COMPLETE:                                               ║
║ ✓ Resource monitoring dashboard configured                                   ║
║ ✓ Alert thresholds established                                              ║
║ ✓ Performance baseline recorded                                             ║
║ ✓ Automated reporting enabled                                               ║
╚══════════════════════════════════════════════════════════════════════════════╝

⚙️ SYSTEMS SKILL TRACK PROGRESSION: +2 levels in Performance Monitoring`

    const result = {
      output: systemMonitoring,
      type: 'success'
    }

    return this.checkQuestProgress('nc-monitor-system', result)
  }

  showSkillTracks() {
    let skillTracksDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🎓 SKILL SPECIALIZATION TRACKS                     ║
║                        Multiple Converging Learning Paths                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 CHOOSE YOUR SPECIALIZATION PATH                                          ║
║                                                                              ║
║ 🌐 NETWORKING TRACK (${this.player.skillTracks.networking.unlocked ? 'UNLOCKED' : 'LOCKED'})                                       ║
║ ├─ Level: ${this.player.skillTracks.networking.level}/20                                                      ║
║ ├─ XP: ${this.player.skillTracks.networking.xp}/100                                                         ║
║ ├─ Focus: Network topology, protocols, segmentation                         ║
║ └─ Leads to: Network Architecture, SDN, Cloud Networking                    ║
║                                                                              ║
║ 🛡️  SECURITY TRACK (${this.player.skillTracks.security.unlocked ? 'UNLOCKED' : 'LOCKED'})                                         ║
║ ├─ Level: ${this.player.skillTracks.security.level}/20                                                      ║
║ ├─ XP: ${this.player.skillTracks.security.xp}/100                                                         ║
║ ├─ Focus: Vulnerability assessment, penetration testing                     ║
║ └─ Leads to: Ethical Hacking, Security Architecture, SOC                    ║
║                                                                              ║
║ ⚙️  SYSTEMS TRACK (${this.player.skillTracks.systems.unlocked ? 'UNLOCKED' : 'LOCKED'})                                           ║
║ ├─ Level: ${this.player.skillTracks.systems.level}/20                                                      ║
║ ├─ XP: ${this.player.skillTracks.systems.xp}/100                                                         ║
║ ├─ Focus: Performance monitoring, troubleshooting                           ║
║ └─ Leads to: Site Reliability Engineering, Platform Engineering             ║
║                                                                              ║
║ 🚀 DEVOPS TRACK (${this.player.skillTracks.devops.unlocked ? 'UNLOCKED' : 'LOCKED'})                                             ║
║ ├─ Level: ${this.player.skillTracks.devops.level}/20                                                      ║
║ ├─ XP: ${this.player.skillTracks.devops.xp}/100                                                         ║
║ ├─ Focus: Automation, CI/CD, infrastructure as code                         ║
║ └─ Leads to: Cloud Architecture, Platform Engineering                       ║
║                                                                              ║
║ 🎯 CONVERGENCE SPECIALIZATIONS (Tier 4-5):                                 ║
║ • Full-Stack Engineer (All tracks level 15+)                                ║
║ • Security Architect (Security + Systems level 15+)                         ║
║ • Cloud Engineer (Networking + DevOps level 15+)                            ║
║ • Platform Engineer (Systems + DevOps level 15+)                            ║
╚══════════════════════════════════════════════════════════════════════════════╝

💡 Use 'nc-specialize <track>' to focus on a specific learning path
🔄 Tracks unlock as you progress through foundational quests`

    return {
      output: skillTracksDisplay,
      type: 'info'
    }
  }

  handleSpecialization(args) {
    if (!args.length) {
      return {
        output: 'Usage: nc-specialize <networking|security|systems|devops>',
        type: 'info'
      }
    }

    const track = args[0].toLowerCase()
    const validTracks = ['networking', 'security', 'systems', 'devops']
    
    if (!validTracks.includes(track)) {
      return {
        output: `Invalid track: ${track}. Valid tracks: ${validTracks.join(', ')}`,
        type: 'error'
      }
    }

    if (!this.player.skillTracks[track].unlocked) {
      return {
        output: `Track '${track}' is not yet unlocked. Complete prerequisite quests first.`,
        type: 'warning'
      }
    }

    this.player.specialization = track
    
    return {
      output: `🎓 Specialization set to: ${track.toUpperCase()}\n\nYou will now receive enhanced XP for ${track}-related activities and unlock specialized quest lines.`,
      type: 'success'
    }
  }

  checkQuestProgress(command, result) {
    const currentQuest = this.quests[this.currentQuestIndex]
    
    if (currentQuest && !currentQuest.completed && currentQuest.commands.includes(command)) {
      // Mark quest as completed
      currentQuest.completed = true
      this.player.completedQuests.push(currentQuest.id)
      
      // Award XP
      this.player.xp += currentQuest.xpReward
      
      // Award skill track XP if applicable
      if (currentQuest.skillTrack) {
        this.player.skillTracks[currentQuest.skillTrack].xp += Math.floor(currentQuest.xpReward / 2)
        const trackLevel = Math.floor(this.player.skillTracks[currentQuest.skillTrack].xp / 100)
        if (trackLevel > this.player.skillTracks[currentQuest.skillTrack].level) {
          this.player.skillTracks[currentQuest.skillTrack].level = trackLevel
        }
      }
      
      // Level up if needed
      const newLevel = Math.floor(this.player.xp / 100) + 1
      if (newLevel > this.player.level) {
        this.player.level = newLevel
        result.levelUp = true
        
        // Unlock new skill tracks based on level
        if (newLevel >= 2) {
          this.player.skillTracks.security.unlocked = true
          this.player.skillTracks.systems.unlocked = true
        }
        if (newLevel >= 3) {
          this.player.skillTracks.devops.unlocked = true
        }
      }
      
      // Add skill
      this.player.skills[command] = (this.player.skills[command] || 0) + 1
      
      // Move to next quest (but check for available tier-appropriate quests)
      this.currentQuestIndex++
      
      // Find next appropriate quest based on player's progression
      this.findNextQuest()
      
      result.xpGained = currentQuest.xpReward
      result.playerUpdate = true
      result.questUpdate = true
      result.output += `\n\n✓ Quest Complete: ${currentQuest.title} (+${currentQuest.xpReward} XP)`
      
      if (currentQuest.skillTrack) {
        result.output += `\n🎯 ${currentQuest.skillTrack.toUpperCase()} Track XP: +${Math.floor(currentQuest.xpReward / 2)}`
      }
      
      result.type = 'success'
    }

    return result
  }

  findNextQuest() {
    // Find the next available quest that the player can do
    for (let i = 0; i < this.quests.length; i++) {
      const quest = this.quests[i]
      if (!quest.completed && this.canPlayerDoQuest(quest)) {
        this.currentQuestIndex = i
        return
      }
    }
    
    // If no basic quests available, player has completed initial training
    this.currentQuestIndex = this.quests.length
  }

  canPlayerDoQuest(quest) {
    // Check if player meets prerequisites
    if (quest.prerequisites) {
      for (const prereq of quest.prerequisites) {
        if (!this.player.completedQuests.includes(prereq)) {
          return false
        }
      }
    }
    
    // Check if player has unlocked the skill track
    if (quest.skillTrack && !this.player.skillTracks[quest.skillTrack].unlocked) {
      return false
    }
    
    return true
  }

  showAdaptiveLearning() {
    let adaptiveDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🧠 ADAPTIVE LEARNING INTELLIGENCE                    ║
║                        Personalized Learning Analytics                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 LEARNING PATTERN ANALYSIS:                                               ║
║                                                                              ║
║ 🎯 Current Learning Level: ${this.adaptiveDifficulty.currentLevel.toString().padEnd(49)} ║
║ 📈 Success Rate: ${(this.adaptiveDifficulty.successRate * 100).toFixed(1).padEnd(58)}% ║
║ ⚡ Preferred Pace: ${this.player.preferredPace.toUpperCase().padEnd(54)} ║
║ 🎓 Mastery Score: ${this.player.masteryScore.toString().padEnd(55)} ║
║                                                                              ║
║ 💪 STRENGTH AREAS:                                                          ║`

    if (this.player.strengthAreas.length > 0) {
      this.player.strengthAreas.forEach(area => {
        adaptiveDisplay += `\n║ ✓ ${area.padEnd(74)} ║`
      })
    } else {
      adaptiveDisplay += `\n║ • Complete more quests to identify your strengths                          ║`
    }

    adaptiveDisplay += `\n║                                                                              ║
║ 🎯 AREAS FOR IMPROVEMENT:                                                   ║`

    if (this.player.weaknessAreas.length > 0) {
      this.player.weaknessAreas.forEach(area => {
        adaptiveDisplay += `\n║ ⚠️ ${area.padEnd(73)} ║`
      })
    } else {
      adaptiveDisplay += `\n║ • System learning your patterns - keep exploring!                          ║`
    }

    adaptiveDisplay += `\n║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🤖 AI RECOMMENDATIONS:                                                      ║
║                                                                              ║
║ • Focus on ${this.getRecommendedTrack()} track based on your progress                    ║
║ • Try ${this.getRecommendedCommand()} command to challenge yourself                       ║
║ • Consider adjusting difficulty with 'nc-personalize pace [slow|normal|fast]' ║
║                                                                              ║
║ 🎓 NEXT LEARNING OBJECTIVES:                                                ║
║ • ${this.getPersonalizedObjective().padEnd(74)} ║
║ • Real-world application: ${this.getRealWorldApplication().padEnd(51)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

🧠 AI Learning Assistant: Continuously adapting to optimize your learning experience`

    return {
      output: adaptiveDisplay,
      type: 'info'
    }
  }

  handlePersonalization(args) {
    if (!args.length) {
      return {
        output: `Usage: nc-personalize <setting> <value>
        
Available settings:
  pace [slow|normal|fast]  - Adjust learning pace
  style [visual|hands-on|reading]  - Set learning style preference
  difficulty [easy|normal|hard]  - Set challenge level`,
        type: 'info'
      }
    }

    const setting = args[0].toLowerCase()
    const value = args[1]?.toLowerCase()

    switch (setting) {
      case 'pace':
        if (['slow', 'normal', 'fast'].includes(value)) {
          this.player.preferredPace = value
          this.adaptLearningPace(value)
          return {
            output: `🎯 Learning pace set to: ${value.toUpperCase()}\n\nQuests and challenges will now be adjusted to match your preferred learning speed.`,
            type: 'success'
          }
        }
        break
      
      case 'style':
        if (['visual', 'hands-on', 'reading'].includes(value)) {
          this.player.learningStyle = value
          return {
            output: `🎨 Learning style set to: ${value.toUpperCase()}\n\nContent delivery will be optimized for your preferred learning approach.`,
            type: 'success'
          }
        }
        break
      
      case 'difficulty':
        if (['easy', 'normal', 'hard'].includes(value)) {
          this.adaptiveDifficulty.currentLevel = value === 'easy' ? 1 : value === 'normal' ? 2 : 3
          return {
            output: `⚡ Difficulty level set to: ${value.toUpperCase()}\n\nChallenges will be adjusted to provide appropriate difficulty.`,
            type: 'success'
          }
        }
        break
    }

    return {
      output: `Invalid setting or value. Use 'nc-personalize' without arguments to see options.`,
      type: 'error'
    }
  }

  communicateWithArchitect(args) {
    const message = args.join(' ')
    
    if (!message) {
      return {
        output: `╔═══════════════════════════════════════════════════════════════════════════╗
║                      🎭 THE ARCHITECT - AI MENTOR                        ║
║                        Encrypted Communication Portal                    ║
╠═══════════════════════════════════════════════════════════════════════════╣
║ Usage: nc-architect <your message>                                       ║
║                                                                           ║
║ The Architect is an AI-powered mentor who provides:                      ║
║ • Personalized guidance based on your progress                           ║
║ • Technical insights and learning recommendations                        ║
║ • Cryptic hints about advanced challenges                                ║
║ • Real-world application advice                                          ║
║                                                                           ║
║ Example: nc-architect "I'm struggling with networking concepts"          ║
╚═══════════════════════════════════════════════════════════════════════════╝`,
        type: 'info'
      }
    }

    // Simulated AI response based on player context
    const response = this.generateArchitectResponse(message)
    
    return {
      output: `╔═══════════════════════════════════════════════════════════════════════════╗
║                      🎭 THE ARCHITECT RESPONDS                           ║
║                        [ENCRYPTED TRANSMISSION]                          ║
╠═══════════════════════════════════════════════════════════════════════════╣
║                                                                           ║
║ ${response.padEnd(73)} ║
║                                                                           ║
║ [Based on your progress in ${this.player.specialization || 'foundation'} track]                     ║
║ [Learning pattern: ${this.player.preferredPace} pace, ${this.player.learningStyle || 'adaptive'} style]              ║
╚═══════════════════════════════════════════════════════════════════════════╝

🔐 Transmission complete. The Architect monitors your progress...`,
      type: 'info'
    }
  }

  getRecommendedTrack() {
    const tracks = Object.keys(this.player.skillTracks)
    const unlockedTracks = tracks.filter(track => this.player.skillTracks[track].unlocked)
    
    if (unlockedTracks.length === 0) return 'networking'
    
    // Find track with lowest level among unlocked tracks
    return unlockedTracks.reduce((lowest, track) => 
      this.player.skillTracks[track].level < this.player.skillTracks[lowest].level ? track : lowest
    )
  }

  getRecommendedCommand() {
    const recommendations = ['nc-discover-services', 'nc-map-network', 'nc-analyze-network', 'nc-security-scan', 'nc-monitor-system']
    return recommendations[Math.floor(Math.random() * recommendations.length)]
  }

  getPersonalizedObjective() {
    if (this.player.level < 2) {
      return "Master foundational Linux commands and system navigation"
    } else if (this.player.specialization) {
      return `Advance your ${this.player.specialization} specialization to level ${this.player.skillTracks[this.player.specialization].level + 1}`
    } else {
      return "Choose a specialization track to focus your learning path"
    }
  }

  getRealWorldApplication() {
    const applications = [
      "Configure production server monitoring",
      "Implement network security policies", 
      "Automate deployment pipelines",
      "Troubleshoot performance issues",
      "Design scalable infrastructure"
    ]
    return applications[Math.floor(Math.random() * applications.length)]
  }

  generateArchitectResponse(message) {
    const responses = {
      networking: "Network topology is like city planning - understand the connections before optimizing traffic flow.",
      security: "Security is not a feature, it's a mindset. Every command you run leaves traces...",
      systems: "Systems administration is the art of keeping chaos at bay through elegant automation.",
      struggling: "Every expert was once a beginner. Focus on one concept at a time, then connect the dots.",
      help: "The path to mastery is not about memorizing commands, but understanding the why behind each action."
    }
    
    const lowerMessage = message.toLowerCase()
    
    if (lowerMessage.includes('network')) return responses.networking
    if (lowerMessage.includes('security')) return responses.security
    if (lowerMessage.includes('system')) return responses.systems
    if (lowerMessage.includes('struggling') || lowerMessage.includes('difficult')) return responses.struggling
    
    return responses.help
  }

  adaptLearningPace(pace) {
    // Adjust quest XP rewards and complexity based on pace
    this.quests.forEach(quest => {
      if (pace === 'slow') {
        quest.xpReward = Math.floor(quest.xpReward * 1.2) // More XP for slower pace
      } else if (pace === 'fast') {
        quest.xpReward = Math.floor(quest.xpReward * 0.8) // Less XP for faster pace
      }
    })
  }

  showConvergencePaths() {
    let convergenceDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🌟 SKILL CONVERGENCE MATRIX                          ║
║                     Advanced Career Specializations                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 CONVERGENCE ANALYSIS: Where Your Skills Merge Into Expertise             ║
║                                                                              ║`

    const convergencePaths = this.getAvailableConvergencePaths()
    
    convergencePaths.forEach(path => {
      const eligible = path.eligible ? '✅' : '🔒'
      const progress = this.calculateConvergenceProgress(path)
      
      convergenceDisplay += `
║ ${eligible} ${path.title.padEnd(35)} [${progress.toFixed(0)}% Ready] ║
║    Prerequisites: ${path.requirements.padEnd(56)} ║
║    Career Path: ${path.careerPath.padEnd(58)} ║
║    Salary Range: ${path.salaryRange.padEnd(56)} ║`
      
      if (path.eligible) {
        convergenceDisplay += `
║    🚀 READY TO ADVANCE! Use: nc-advance ${path.id.padEnd(30)} ║`
      } else {
        convergenceDisplay += `
║    📈 Next Step: ${path.nextStep.padEnd(58)} ║`
      }
      
      convergenceDisplay += `
║    ────────────────────────────────────────────────────────────────────── ║`
    })

    convergenceDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎓 MASTERY INDICATORS:                                                       ║
║                                                                              ║
║ 🌐 Networking: ${this.getTrackMasteryIndicator('networking').padEnd(57)} ║
║ 🛡️  Security: ${this.getTrackMasteryIndicator('security').padEnd(58)} ║
║ ⚙️  Systems: ${this.getTrackMasteryIndicator('systems').padEnd(59)} ║
║ 🚀 DevOps: ${this.getTrackMasteryIndicator('devops').padEnd(61)} ║
║                                                                              ║
║ 💡 Pro Tip: Advanced roles require 15+ levels in multiple tracks            ║
║ 🔥 Elite paths open at 18+ levels - true expertise convergence              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🌟 The future belongs to those who master the convergence of skills`

    return {
      output: convergenceDisplay,
      type: 'info'
    }
  }

  getAvailableConvergencePaths() {
    const tracks = this.player.skillTracks
    
    return [
      {
        id: 'full-stack-engineer',
        title: 'Full-Stack Engineer',
        requirements: 'All tracks level 15+',
        careerPath: 'Senior Engineering Leadership',
        salaryRange: '$120K - $180K+',
        eligible: Object.values(tracks).every(track => track.level >= 15),
        nextStep: this.getNextStepForPath('full-stack'),
        tracks: ['networking', 'security', 'systems', 'devops']
      },
      {
        id: 'security-architect',
        title: 'Security Architect',
        requirements: 'Security 15+, Systems 15+',
        careerPath: 'Cybersecurity Leadership',
        salaryRange: '$130K - $200K+',
        eligible: tracks.security.level >= 15 && tracks.systems.level >= 15,
        nextStep: this.getNextStepForPath('security-architect'),
        tracks: ['security', 'systems']
      },
      {
        id: 'cloud-engineer',
        title: 'Cloud Solutions Engineer',
        requirements: 'Networking 15+, DevOps 15+',
        careerPath: 'Cloud Architecture & Engineering',
        salaryRange: '$110K - $170K+',
        eligible: tracks.networking.level >= 15 && tracks.devops.level >= 15,
        nextStep: this.getNextStepForPath('cloud-engineer'),
        tracks: ['networking', 'devops']
      },
      {
        id: 'platform-engineer',
        title: 'Platform Engineer',
        requirements: 'Systems 15+, DevOps 15+',
        careerPath: 'Infrastructure & Platform Engineering',
        salaryRange: '$115K - $175K+',
        eligible: tracks.systems.level >= 15 && tracks.devops.level >= 15,
        nextStep: this.getNextStepForPath('platform-engineer'),
        tracks: ['systems', 'devops']
      },
      {
        id: 'devops-architect',
        title: 'DevOps Architect',
        requirements: 'DevOps 18+, Systems 15+, Networking 12+',
        careerPath: 'Enterprise DevOps Leadership',
        salaryRange: '$140K - $220K+',
        eligible: tracks.devops.level >= 18 && tracks.systems.level >= 15 && tracks.networking.level >= 12,
        nextStep: this.getNextStepForPath('devops-architect'),
        tracks: ['devops', 'systems', 'networking']
      },
      {
        id: 'elite-architect',
        title: 'Principal Systems Architect',
        requirements: 'All tracks 18+',
        careerPath: 'C-Level Technical Leadership',
        salaryRange: '$180K - $300K+',
        eligible: Object.values(tracks).every(track => track.level >= 18),
        nextStep: this.getNextStepForPath('elite-architect'),
        tracks: ['networking', 'security', 'systems', 'devops']
      }
    ]
  }

  calculateConvergenceProgress(path) {
    const tracks = this.player.skillTracks
    let totalProgress = 0
    let requirements = 0

    path.tracks.forEach(trackName => {
      const requiredLevel = this.getRequiredLevelForPath(path.id, trackName)
      const currentLevel = tracks[trackName].level
      const progress = Math.min(currentLevel / requiredLevel, 1) * 100
      totalProgress += progress
      requirements++
    })

    return totalProgress / requirements
  }

  getRequiredLevelForPath(pathId, trackName) {
    const requirements = {
      'full-stack-engineer': { networking: 15, security: 15, systems: 15, devops: 15 },
      'security-architect': { security: 15, systems: 15 },
      'cloud-engineer': { networking: 15, devops: 15 },
      'platform-engineer': { systems: 15, devops: 15 },
      'devops-architect': { devops: 18, systems: 15, networking: 12 },
      'elite-architect': { networking: 18, security: 18, systems: 18, devops: 18 }
    }
    
    return requirements[pathId]?.[trackName] || 10
  }

  getNextStepForPath(pathType) {
    const tracks = this.player.skillTracks
    
    switch (pathType) {
      case 'full-stack':
        const lowestTrack = Object.keys(tracks).reduce((lowest, track) => 
          tracks[track].level < tracks[lowest].level ? track : lowest
        )
        return `Advance ${lowestTrack} track to level ${tracks[lowestTrack].level + 1}`
      
      case 'security-architect':
        if (tracks.security.level < 15) return `Advance security track to level 15`
        if (tracks.systems.level < 15) return `Advance systems track to level 15`
        return 'Requirements met!'
      
      case 'cloud-engineer':
        if (tracks.networking.level < 15) return `Advance networking track to level 15`
        if (tracks.devops.level < 15) return `Advance devops track to level 15`
        return 'Requirements met!'
      
      case 'platform-engineer':
        if (tracks.systems.level < 15) return `Advance systems track to level 15`
        if (tracks.devops.level < 15) return `Advance devops track to level 15`
        return 'Requirements met!'
      
      case 'devops-architect':
        if (tracks.devops.level < 18) return `Advance devops track to level 18`
        if (tracks.systems.level < 15) return `Advance systems track to level 15`
        if (tracks.networking.level < 12) return `Advance networking track to level 12`
        return 'Requirements met!'
      
      case 'elite-architect':
        const needsWork = Object.keys(tracks).filter(track => tracks[track].level < 18)
        if (needsWork.length > 0) return `Advance ${needsWork[0]} track to level 18`
        return 'Requirements met!'
      
      default:
        return 'Continue advancing your specialization tracks'
    }
  }

  getTrackMasteryIndicator(trackName) {
    const level = this.player.skillTracks[trackName].level
    const unlocked = this.player.skillTracks[trackName].unlocked
    
    if (!unlocked) return '🔒 Locked'
    if (level >= 18) return '🏆 Master (Level ' + level + ')'
    if (level >= 15) return '💎 Expert (Level ' + level + ')'
    if (level >= 10) return '⭐ Advanced (Level ' + level + ')'
    if (level >= 5) return '📈 Intermediate (Level ' + level + ')'
    if (level >= 1) return '🌱 Beginner (Level ' + level + ')'
    return '📚 Not Started'
  }

  handleAdvancement(args) {
    if (!args.length) {
      return {
        output: `Usage: nc-advance <convergence-path>

Available paths: full-stack-engineer, security-architect, cloud-engineer, 
platform-engineer, devops-architect, elite-architect

Use 'nc-convergence' to see your eligibility for each path.`,
        type: 'info'
      }
    }

    const pathId = args[0].toLowerCase()
    const convergencePaths = this.getAvailableConvergencePaths()
    const selectedPath = convergencePaths.find(path => path.id === pathId)

    if (!selectedPath) {
      return {
        output: `Invalid convergence path: ${pathId}. Use 'nc-convergence' to see available paths.`,
        type: 'error'
      }
    }

    if (!selectedPath.eligible) {
      return {
        output: `❌ You don't meet the requirements for ${selectedPath.title}.

Requirements: ${selectedPath.requirements}
Next Step: ${selectedPath.nextStep}

Continue advancing your skill tracks and try again!`,
        type: 'warning'
      }
    }

    // Award the convergence achievement
    this.player.tier = Math.max(this.player.tier, 4)
    this.player.achievements.push({
      id: selectedPath.id,
      title: selectedPath.title,
      description: `Achieved convergence specialization: ${selectedPath.title}`,
      timestamp: new Date().toISOString(),
      careerPath: selectedPath.careerPath,
      salaryRange: selectedPath.salaryRange
    })

    return {
      output: `🎉 CONVERGENCE ACHIEVED! 🎉

╔═══════════════════════════════════════════════════════════════════════════╗
║                    🌟 SPECIALIZATION UNLOCKED                            ║
║                                                                           ║
║ 🎯 NEW TITLE: ${selectedPath.title.padEnd(58)} ║
║ 🚀 CAREER PATH: ${selectedPath.careerPath.padEnd(56)} ║
║ 💰 SALARY RANGE: ${selectedPath.salaryRange.padEnd(55)} ║
║                                                                           ║
║ 🏆 You have successfully converged multiple skill tracks into a          ║
║    professional specialization! This represents real-world expertise     ║
║    that employers actively seek.                                          ║
║                                                                           ║
║ 📈 NEXT STEPS:                                                           ║
║ • Continue advancing to unlock even higher convergence paths             ║
║ • Use 'nc-mastery' to assess your overall technical mastery              ║
║ • Explore advanced real-world challenges in your new specialization      ║
╚═══════════════════════════════════════════════════════════════════════════╝

🎓 Congratulations! Your learning journey has reached a major milestone.`,
      type: 'success',
      playerUpdate: true
    }
  }

  assessMastery() {
    const totalLevels = Object.values(this.player.skillTracks).reduce((sum, track) => sum + track.level, 0)
    const avgLevel = totalLevels / 4
    const achievements = this.player.achievements.length
    const convergenceAchievements = this.player.achievements.filter(a => a.careerPath).length
    
    let masteryRating = 'Novice'
    if (avgLevel >= 18) masteryRating = 'Master'
    else if (avgLevel >= 15) masteryRating = 'Expert'
    else if (avgLevel >= 10) masteryRating = 'Advanced'
    else if (avgLevel >= 5) masteryRating = 'Intermediate'

    let masteryDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🏆 TECHNICAL MASTERY ASSESSMENT                      ║
║                         Comprehensive Skill Evaluation                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 OVERALL MASTERY RATING: ${masteryRating.toUpperCase().padEnd(47)} ║
║ 📈 Average Track Level: ${avgLevel.toFixed(1).padEnd(52)} ║
║ 🎯 Total Skill Points: ${totalLevels.toString().padEnd(53)} ║
║ 🏅 Achievements Earned: ${achievements.toString().padEnd(52)} ║
║ 🌟 Convergence Specializations: ${convergenceAchievements.toString().padEnd(43)} ║
║                                                                              ║
║ 📋 DETAILED BREAKDOWN:                                                      ║
║ ├─ 🌐 Networking: Level ${this.player.skillTracks.networking.level.toString().padEnd(48)} ║
║ ├─ 🛡️  Security: Level ${this.player.skillTracks.security.level.toString().padEnd(49)} ║
║ ├─ ⚙️  Systems: Level ${this.player.skillTracks.systems.level.toString().padEnd(50)} ║
║ └─ 🚀 DevOps: Level ${this.player.skillTracks.devops.level.toString().padEnd(52)} ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 💼 CAREER READINESS ASSESSMENT:                                             ║
║                                                                              ║`

    // Add career readiness based on mastery level
    if (masteryRating === 'Master') {
      masteryDisplay += `
║ 🎯 STATUS: Ready for senior technical leadership roles                       ║
║ 💰 MARKET VALUE: $150K - $300K+ depending on specialization                 ║
║ 🚀 RECOMMENDATION: Pursue C-level or principal architect positions           ║`
    } else if (masteryRating === 'Expert') {
      masteryDisplay += `
║ 🎯 STATUS: Ready for senior engineering and architect roles                  ║
║ 💰 MARKET VALUE: $120K - $200K+ depending on specialization                 ║
║ 🚀 RECOMMENDATION: Target senior engineer or team lead positions             ║`
    } else if (masteryRating === 'Advanced') {
      masteryDisplay += `
║ 🎯 STATUS: Ready for mid-level engineering roles                             ║
║ 💰 MARKET VALUE: $80K - $140K depending on specialization                   ║
║ 🚀 RECOMMENDATION: Apply for senior engineer or specialist roles             ║`
    } else {
      masteryDisplay += `
║ 🎯 STATUS: Building towards professional readiness                           ║
║ 💰 MARKET VALUE: Entry to mid-level positions ($50K - $90K)                 ║
║ 🚀 RECOMMENDATION: Continue advancing tracks towards convergence             ║`
    }

    masteryDisplay += `
║                                                                              ║
║ 📈 NEXT MILESTONES:                                                         ║
║ • Reach level 15+ in all tracks for full-stack convergence                  ║
║ • Achieve level 18+ for master-level expertise                              ║
║ • Unlock all convergence paths for maximum career flexibility               ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎓 Your skills represent real-world technical expertise valued by employers!`

    return {
      output: masteryDisplay,
      type: 'info'
    }
  }

  // Daily Task System Methods
  getCurrentShift() {
    const hour = new Date().getHours()
    if (hour >= 6 && hour < 14) return 'Day Shift (06:00-14:00)'
    if (hour >= 14 && hour < 22) return 'Evening Shift (14:00-22:00)'
    return 'Night Shift (22:00-06:00)'
  }

  handleClockIn() {
    if (this.shiftStatus.clockedIn) {
      return {
        output: `[TIME] You are already clocked in since ${this.shiftStatus.shiftStart}\n\nUse 'nc-daily-tasks' to see your assigned duties for today.`,
        type: 'warning'
      }
    }

    this.shiftStatus.clockedIn = true
    this.shiftStatus.shiftStart = new Date().toLocaleTimeString()
    this.shiftStatus.currentShift = this.getCurrentShift()
    
    // Generate daily tasks if needed
    this.refreshDailyTasks()

    return {
      output: `╔══════════════════════════════════════════════════════════════════════════════╗
║                          [CLK] SHIFT STARTED                                ║
║                    Network Security Division                                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ [USER] OPERATOR: ${this.player.name.toUpperCase().padEnd(55)} ║
║ [TIME] CLOCK IN TIME: ${this.shiftStatus.shiftStart.padEnd(48)} ║
║ [DATE] SHIFT: ${this.shiftStatus.currentShift.padEnd(58)} ║
║                                                                              ║
║ [LIST] DAILY BRIEFING:                                                      ║
║ • ${this.dailyTasks.length} tasks have been assigned for your shift                        ║
║ • Priority: Continue investigation into The Architect's disappearance       ║
║ • Maintain system security and monitor for suspicious activity              ║
║ • Complete routine maintenance and monitoring duties                         ║
║                                                                              ║
║ [>] Use 'nc-daily-tasks' to view your assigned responsibilities             ║
║ [TIP] Remember: Every completed task earns XP and advances the investigation║
╚══════════════════════════════════════════════════════════════════════════════╝

[***] SYSTEM ALERT: You are now on duty. Begin with routine system checks.`,
      type: 'success',
      shiftUpdate: true
    }
  }

  handleClockOut() {
    if (!this.shiftStatus.clockedIn) {
      return {
        output: `❌ You are not currently clocked in.\n\nUse 'nc-clock-in' to start your shift.`,
        type: 'error'
      }
    }

    const shiftDuration = this.calculateShiftDuration()
    const completionRate = this.dailyTasks.length > 0 ? 
      (this.shiftStatus.tasksCompleted / this.dailyTasks.length * 100).toFixed(1) : 0

    this.shiftStatus.clockedIn = false
    const shiftXP = this.shiftStatus.dailyXP

    return {
      output: `╔══════════════════════════════════════════════════════════════════════════════╗
║                          🕐 SHIFT COMPLETED                                 ║
║                       End of Duty Summary                                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 👤 OPERATOR: ${this.player.name.toUpperCase().padEnd(62)} ║
║ ⏰ SHIFT DURATION: ${shiftDuration.padEnd(57)} ║
║ ✅ TASKS COMPLETED: ${this.shiftStatus.tasksCompleted}/${this.dailyTasks.length} (${completionRate}% completion rate)           ║
║ 🎯 XP EARNED THIS SHIFT: ${shiftXP.toString().padEnd(49)} ║
║                                                                              ║
║ 📊 PERFORMANCE EVALUATION:                                                  ║
║ ${this.getPerformanceRating(completionRate).padEnd(76)} ║
║                                                                              ║
║ 💼 STATUS: ${completionRate >= 80 ? 'EXEMPLARY PERFORMANCE' : 
                     completionRate >= 60 ? 'SATISFACTORY PERFORMANCE' : 
                     'NEEDS IMPROVEMENT'.padEnd(59)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

📋 Use 'nc-duty-log' to review your performance history.
🔄 Clock in again tomorrow to continue the investigation.`,
      type: 'success',
      shiftUpdate: true
    }
  }

  showDailyTasks() {
    if (!this.shiftStatus.clockedIn) {
      return {
        output: `⏰ You must clock in first to view your daily assignments.\n\nUse 'nc-clock-in' to start your shift.`,
        type: 'warning'
      }
    }

    this.refreshDailyTasks()

    let taskDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                           📋 DAILY DUTY ASSIGNMENTS                         ║
║                     ${new Date().toLocaleDateString()} - ${this.shiftStatus.currentShift.split(' ')[0]} Shift                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 SHIFT PROGRESS: ${this.shiftStatus.tasksCompleted}/${this.dailyTasks.length} tasks completed                               ║
║ 💰 SHIFT XP EARNED: ${this.shiftStatus.dailyXP.toString().padEnd(57)} ║
║                                                                              ║
║ 📝 ASSIGNED DUTIES:                                                         ║`

    this.dailyTasks.forEach((task, index) => {
      const status = task.completed ? '✅' : task.priority === 'HIGH' ? '🚨' : task.priority === 'MEDIUM' ? '⚠️' : '📋'
      const statusText = task.completed ? 'COMPLETE' : 'PENDING'
      
      taskDisplay += `
║                                                                              ║
║ ${status} ${(index + 1).toString().padStart(2)}. ${task.title.padEnd(66)} ║
║    Priority: ${task.priority.padEnd(15)} Status: ${statusText.padEnd(35)} ║
║    ${task.description.padEnd(74)} ║
║    Command: ${task.command.padEnd(61)} ║
║    Reward: ${task.xpReward.toString().padEnd(63)} XP ║`
      
      if (task.investigationLink) {
        taskDisplay += `
║    🔍 Investigation: ${task.investigationLink.padEnd(54)} ║`
      }
    })

    taskDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 💡 INSTRUCTIONS:                                                            ║
║ • Execute the specified commands to complete each task                       ║
║ • Use 'nc-complete-task <number>' to manually mark tasks complete           ║
║ • High priority tasks should be completed first                             ║
║ • Each completed task advances The Architect investigation                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔍 Remember: You're not just maintaining systems - you're uncovering clues!`

    return {
      output: taskDisplay,
      type: 'info'
    }
  }

  completeTask(args) {
    if (!this.shiftStatus.clockedIn) {
      return {
        output: `⏰ You must be clocked in to complete tasks.\n\nUse 'nc-clock-in' to start your shift.`,
        type: 'warning'
      }
    }

    if (!args.length) {
      return {
        output: `Usage: nc-complete-task <task_number>\n\nUse 'nc-daily-tasks' to see task numbers.`,
        type: 'info'
      }
    }

    const taskNumber = parseInt(args[0]) - 1
    
    if (taskNumber < 0 || taskNumber >= this.dailyTasks.length) {
      return {
        output: `❌ Invalid task number. Valid range: 1-${this.dailyTasks.length}`,
        type: 'error'
      }
    }

    const task = this.dailyTasks[taskNumber]
    
    if (task.completed) {
      return {
        output: `✅ Task "${task.title}" is already completed.`,
        type: 'info'
      }
    }

    // Mark task as completed
    task.completed = true
    task.completedAt = new Date().toLocaleTimeString()
    this.shiftStatus.tasksCompleted++
    this.shiftStatus.dailyXP += task.xpReward
    this.player.xp += task.xpReward

    // Check for story progression
    let investigationUpdate = ''
    if (task.investigationLink) {
      investigationUpdate = `\n\n🔍 INVESTIGATION UPDATE: ${task.investigationLink}`
      
      // Update story flags based on task completion
      if (task.id === 'check_logs') this.storyFlags.discovered_network = true
      if (task.id === 'security_scan') this.storyFlags.found_vulnerability = true
    }

    return {
      output: `✅ TASK COMPLETED: ${task.title}

📋 Task Details: ${task.description}
💰 XP Awarded: +${task.xpReward} XP
⏰ Completed At: ${task.completedAt}
📊 Progress: ${this.shiftStatus.tasksCompleted}/${this.dailyTasks.length} tasks done${investigationUpdate}

${this.shiftStatus.tasksCompleted === this.dailyTasks.length ? 
  '🎉 ALL DAILY TASKS COMPLETED! Outstanding work, recruit.' : 
  '🎯 Continue with remaining tasks to complete your shift duties.'}`,
      type: 'success'
    }
  }

  showShiftStatus() {
    const currentTime = new Date().toLocaleTimeString()
    const shiftDuration = this.shiftStatus.clockedIn ? this.calculateShiftDuration() : 'Not clocked in'
    const completionRate = this.dailyTasks.length > 0 ? 
      (this.shiftStatus.tasksCompleted / this.dailyTasks.length * 100).toFixed(1) : 0

    return {
      output: `╔══════════════════════════════════════════════════════════════════════════════╗
║                           ⏰ CURRENT SHIFT STATUS                           ║
║                          Real-Time Duty Monitor                             ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 👤 OPERATOR: ${this.player.name.toUpperCase().padEnd(62)} ║
║ 🕐 CURRENT TIME: ${currentTime.padEnd(58)} ║
║ 📅 SHIFT: ${this.shiftStatus.currentShift.padEnd(65)} ║
║ ⚡ STATUS: ${(this.shiftStatus.clockedIn ? 'ON DUTY' : 'OFF DUTY').padEnd(66)} ║
║                                                                              ║
║ 📊 DUTY METRICS:                                                            ║
║ ├─ Time On Duty: ${shiftDuration.padEnd(57)} ║
║ ├─ Tasks Assigned: ${this.dailyTasks.length.toString().padEnd(55)} ║
║ ├─ Tasks Completed: ${this.shiftStatus.tasksCompleted.toString().padEnd(54)} ║
║ ├─ Completion Rate: ${completionRate.toString().padEnd(54)}% ║
║ └─ Shift XP Earned: ${this.shiftStatus.dailyXP.toString().padEnd(53)} ║
║                                                                              ║
║ 🎯 CURRENT PRIORITIES:                                                      ║
║ ${this.getCurrentPriority().padEnd(76)} ║
║                                                                              ║
║ 💡 NEXT ACTION:                                                             ║
║ ${this.getNextAction().padEnd(76)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

${this.shiftStatus.clockedIn ? 
  '🔧 You are currently on duty. Use \'nc-daily-tasks\' to see assignments.' :
  '⏰ Clock in with \'nc-clock-in\' to begin your shift and receive duties.'}`,
      type: 'info'
    }
  }

  showDutyLog() {
    // For now, show current shift summary - could be extended to track history
    const completionRate = this.dailyTasks.length > 0 ? 
      (this.shiftStatus.tasksCompleted / this.dailyTasks.length * 100).toFixed(1) : 0

    let dutyLog = `╔══════════════════════════════════════════════════════════════════════════════╗
║                            📊 DUTY PERFORMANCE LOG                          ║
║                         Service Record Summary                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📅 CURRENT PERIOD: ${new Date().toLocaleDateString().padEnd(58)} ║
║ 👤 OPERATOR: ${this.player.name.toUpperCase().padEnd(62)} ║
║                                                                              ║
║ 📋 TODAY'S PERFORMANCE:                                                     ║
║ ├─ Tasks Assigned: ${this.dailyTasks.length.toString().padEnd(57)} ║
║ ├─ Tasks Completed: ${this.shiftStatus.tasksCompleted.toString().padEnd(56)} ║
║ ├─ Completion Rate: ${completionRate.toString().padEnd(56)}% ║
║ ├─ XP Earned: ${this.shiftStatus.dailyXP.toString().padEnd(61)} ║
║ └─ Performance Rating: ${this.getPerformanceRating(completionRate).padEnd(48)} ║
║                                                                              ║
║ 🏆 COMPLETED DUTIES TODAY:                                                  ║`

    const completedTasks = this.dailyTasks.filter(task => task.completed)
    if (completedTasks.length > 0) {
      completedTasks.forEach(task => {
        dutyLog += `
║ ✅ ${task.completedAt} - ${task.title.substring(0, 40)} (+${task.xpReward} XP)               ║`
      })
    } else {
      dutyLog += `
║ • No duties completed yet today                                             ║`
    }

    dutyLog += `
║                                                                              ║
║ 🎯 INVESTIGATION PROGRESS:                                                  ║
║ • Network Analysis: ${this.storyFlags.discovered_network ? 'COMPLETED' : 'PENDING'.padEnd(52)} ║
║ • Security Assessment: ${this.storyFlags.found_vulnerability ? 'COMPLETED' : 'PENDING'.padEnd(49)} ║
║ • Admin Notes Found: ${this.storyFlags.found_admin_note ? 'YES' : 'NO'.padEnd(53)} ║
║ • Architect Contact: ${this.storyFlags.contacted_architect ? 'ESTABLISHED' : 'NONE'.padEnd(50)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

📈 Your duty performance directly impacts the investigation progress!`

    return {
      output: dutyLog,
      type: 'info'
    }
  }

  refreshDailyTasks() {
    const today = new Date().toDateString()
    
    if (this.lastTaskRefresh !== today) {
      this.generateDailyTasks()
      this.lastTaskRefresh = today
      this.shiftStatus.tasksCompleted = 0
      this.shiftStatus.dailyXP = 0
    }
  }

  generateDailyTasks() {
    const tasks = [
      {
        id: 'system_check',
        title: 'Morning System Health Check',
        description: 'Verify all critical systems are operational',
        command: 'ps aux | head -10',
        priority: 'HIGH',
        xpReward: 15,
        completed: false,
        investigationLink: 'Look for any unusual processes that might indicate intrusion'
      },
      {
        id: 'check_logs',
        title: 'Review Security Logs',
        description: 'Examine recent network activity logs for anomalies',
        command: 'cat network_logs.txt',
        priority: 'HIGH',
        xpReward: 20,
        completed: false,
        investigationLink: 'These logs may contain clues about The Architect\'s activities'
      },
      {
        id: 'network_status',
        title: 'Network Connectivity Verification',
        description: 'Check network interfaces and connections',
        command: 'ifconfig',
        priority: 'MEDIUM',
        xpReward: 12,
        completed: false,
        investigationLink: 'Document network topology for investigation'
      },
      {
        id: 'disk_usage',
        title: 'Storage Monitoring',
        description: 'Monitor disk usage to prevent storage issues',
        command: 'df -h',
        priority: 'MEDIUM',
        xpReward: 10,
        completed: false
      },
      {
        id: 'security_scan',
        title: 'Security Service Discovery',
        description: 'Scan for running services and potential vulnerabilities',
        command: 'nc-discover-services',
        priority: 'HIGH',
        xpReward: 25,
        completed: false,
        investigationLink: 'Critical: The Architect was investigating suspicious services'
      },
      {
        id: 'admin_notes',
        title: 'Review Administrative Documentation',
        description: 'Check for important administrative notes and updates',
        command: 'cat admin_notes.txt',
        priority: 'MEDIUM',
        xpReward: 18,
        completed: false,
        investigationLink: 'The Architect may have left important clues in admin files'
      },
      {
        id: 'memory_check',
        title: 'Memory Usage Assessment',
        description: 'Monitor system memory to ensure optimal performance',
        command: 'free -h',
        priority: 'LOW',
        xpReward: 8,
        completed: false
      },
      {
        id: 'network_map',
        title: 'Network Topology Documentation',
        description: 'Update network documentation with current topology',
        command: 'nc-map-network',
        priority: 'MEDIUM',
        xpReward: 22,
        completed: false,
        investigationLink: 'Map the network to understand The Architect\'s work'
      }
    ]

    // Randomize tasks and select 4-6 for the day
    const shuffled = tasks.sort(() => 0.5 - Math.random())
    const dailyCount = 4 + Math.floor(Math.random() * 3) // 4-6 tasks
    this.dailyTasks = shuffled.slice(0, dailyCount)
  }

  calculateShiftDuration() {
    if (!this.shiftStatus.clockedIn || !this.shiftStatus.shiftStart) {
      return 'Not clocked in'
    }
    
    const start = new Date(`1970-01-01 ${this.shiftStatus.shiftStart}`)
    const now = new Date(`1970-01-01 ${new Date().toLocaleTimeString()}`)
    const diffMs = now - start
    const hours = Math.floor(diffMs / (1000 * 60 * 60))
    const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60))
    
    return `${hours}h ${minutes}m`
  }

  getPerformanceRating(completionRate) {
    if (completionRate >= 90) return '🏆 OUTSTANDING - Exemplary duty performance'
    if (completionRate >= 80) return '⭐ EXCELLENT - Above expectations'
    if (completionRate >= 70) return '✅ GOOD - Meets standards'
    if (completionRate >= 60) return '⚠️ SATISFACTORY - Room for improvement'
    return '❌ NEEDS IMPROVEMENT - Below standards'
  }

  getCurrentPriority() {
    if (!this.shiftStatus.clockedIn) {
      return 'Clock in to receive duty assignments'
    }
    
    const pendingHighPriority = this.dailyTasks.filter(t => !t.completed && t.priority === 'HIGH')
    if (pendingHighPriority.length > 0) {
      return `${pendingHighPriority.length} high-priority tasks pending`
    }
    
    const pendingTasks = this.dailyTasks.filter(t => !t.completed)
    if (pendingTasks.length > 0) {
      return `${pendingTasks.length} routine duties remaining`
    }
    
    return 'All assigned duties completed'
  }

  getNextAction() {
    if (!this.shiftStatus.clockedIn) {
      return 'Use \'nc-clock-in\' to begin your shift'
    }
    
    const nextTask = this.dailyTasks.find(t => !t.completed)
    if (nextTask) {
      return `Execute: ${nextTask.command}`
    }
    
    return 'Use \'nc-clock-out\' to end your shift'
  }

  // Advanced Content System Methods
  initializeAdvancedContent() {
    this.initializeLinuxPuzzles()
    this.initializeAdvancedQuests()
    this.generateRandomIncidents()
  }

  initializeLinuxPuzzles() {
    this.linuxPuzzles = [
      {
        id: 'disk_detective',
        title: 'The Mysterious Disk Usage',
        category: 'System Analysis',
        difficulty: 'Medium',
        description: 'The Architect noticed unusual disk usage before disappearing. Find the largest files consuming disk space.',
        hint: 'Use du and find commands to locate large files',
        solution: 'du -ah / 2>/dev/null | sort -rh | head -10',
        investigationReward: 'Found evidence of data extraction - large log files recently created',
        xpReward: 35,
        unlocked: true,
        solved: false
      },
      {
        id: 'process_mystery',
        title: 'The Phantom Process',
        category: 'Process Investigation',
        difficulty: 'Hard',
        description: 'Identify processes that are consuming the most CPU and memory. The Architect suspected something was mining data.',
        hint: 'Combine ps, top, and grep to find suspicious processes',
        solution: 'ps aux --sort=-%cpu | head -10',
        investigationReward: 'Discovered traces of unauthorized data mining process',
        xpReward: 45,
        unlocked: false,
        solved: false
      },
      {
        id: 'network_sleuth',
        title: 'The Network Connection Puzzle',
        category: 'Network Analysis',
        difficulty: 'Medium',
        description: 'Map all active network connections and identify any suspicious external communications.',
        hint: 'Use netstat with different flags to see all connections',
        solution: 'netstat -tupln | grep ESTABLISHED',
        investigationReward: 'Found evidence of encrypted communication to unknown server',
        xpReward: 40,
        unlocked: false,
        solved: false
      },
      {
        id: 'log_parser',
        title: 'The Log File Cipher',
        category: 'Data Analysis',
        difficulty: 'Hard',
        description: 'Parse system logs to find patterns in The Architect\'s last activities.',
        hint: 'Use grep, awk, and sort to analyze log patterns',
        solution: 'grep "architect" /var/log/auth.log | awk \'{print $1, $2, $3}\'',
        investigationReward: 'Decoded The Architect\'s access patterns - shows emergency logout',
        xpReward: 50,
        unlocked: false,
        solved: false
      },
      {
        id: 'permission_puzzle',
        title: 'The Permission Anomaly',
        category: 'Security Analysis',
        difficulty: 'Easy',
        description: 'Find files with unusual permissions that might indicate security compromise.',
        hint: 'Use find command with permission modes',
        solution: 'find /home -type f -perm 777 2>/dev/null',
        investigationReward: 'Located files with suspicious world-writable permissions',
        xpReward: 25,
        unlocked: true,
        solved: false
      },
      {
        id: 'cron_detective',
        title: 'The Scheduled Task Mystery',
        category: 'Automation Analysis',
        difficulty: 'Medium',
        description: 'Investigate scheduled tasks that might have been planted by an intruder.',
        hint: 'Check crontab and systemd timers',
        solution: 'crontab -l && ls /etc/cron.d/',
        investigationReward: 'Found suspicious automated tasks scheduled by unknown user',
        xpReward: 30,
        unlocked: false,
        solved: false
      }
    ]
  }

  initializeAdvancedQuests() {
    this.advancedQuests = [
      {
        id: 'monitoring_infrastructure',
        title: 'The Architect\'s Monitoring Vision',
        category: 'Infrastructure Monitoring',
        difficulty: 'Expert',
        description: 'Complete The Architect\'s unfinished monitoring setup to understand what they were tracking.',
        phases: [
          {
            name: 'Install Grafana',
            description: 'Set up Grafana for visualization',
            command: 'nc-install-grafana',
            completed: false
          },
          {
            name: 'Configure Prometheus',
            description: 'Install and configure Prometheus for metrics collection',
            command: 'nc-setup-prometheus',
            completed: false
          },
          {
            name: 'Create Dashboards',
            description: 'Build monitoring dashboards for system analysis',
            command: 'nc-create-dashboards',
            completed: false
          },
          {
            name: 'Setup Alerting',
            description: 'Configure alert rules to detect anomalies',
            command: 'nc-configure-alerts',
            completed: false
          }
        ],
        investigationReward: 'Access to The Architect\'s monitoring data reveals timeline of the incident',
        xpReward: 150,
        unlocked: false,
        completed: false
      },
      {
        id: 'system_hardening',
        title: 'Fortress Protocol',
        category: 'Security Hardening',
        difficulty: 'Expert',
        description: 'Implement advanced security measures that The Architect was planning.',
        phases: [
          {
            name: 'Audit System Security',
            description: 'Perform comprehensive security audit',
            command: 'nc-security-audit',
            completed: false
          },
          {
            name: 'Configure Firewall Rules',
            description: 'Implement advanced firewall configuration',
            command: 'nc-setup-firewall',
            completed: false
          },
          {
            name: 'Setup Intrusion Detection',
            description: 'Deploy IDS/IPS monitoring',
            command: 'nc-setup-ids',
            completed: false
          },
          {
            name: 'Implement Log Monitoring',
            description: 'Configure centralized log analysis',
            command: 'nc-setup-log-monitoring',
            completed: false
          }
        ],
        investigationReward: 'Security logs reveal the attack vector used against The Architect',
        xpReward: 125,
        unlocked: false,
        completed: false
      },
      {
        id: 'network_forensics',
        title: 'Digital Archaeology',
        category: 'Network Forensics',
        difficulty: 'Master',
        description: 'Use advanced network analysis to reconstruct the attack timeline.',
        phases: [
          {
            name: 'Capture Network Traffic',
            description: 'Set up packet capture and analysis',
            command: 'nc-setup-wireshark',
            completed: false
          },
          {
            name: 'Analyze Historical Data',
            description: 'Examine network logs for anomalies',
            command: 'nc-analyze-netflow',
            completed: false
          },
          {
            name: 'Reconstruct Attack Path',
            description: 'Map the intrusion timeline',
            command: 'nc-map-attack',
            completed: false
          },
          {
            name: 'Generate Forensic Report',
            description: 'Document findings for investigation',
            command: 'nc-forensic-report',
            completed: false
          }
        ],
        investigationReward: 'Complete reconstruction of the attack - reveals The Architect\'s fate',
        xpReward: 200,
        unlocked: false,
        completed: false
      }
    ]
  }

  showLinuxPuzzles() {
    let puzzleDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🧩 LINUX SYSTEM PUZZLES                             ║
║                     Real-World Investigation Challenges                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 SOLVE PUZZLES TO UNCOVER CLUES ABOUT THE ARCHITECT'S DISAPPEARANCE      ║
║                                                                              ║
║ 📊 PROGRESS: ${this.linuxPuzzles.filter(p => p.solved).length}/${this.linuxPuzzles.length} puzzles solved                                         ║
║ 🎯 AVAILABLE PUZZLES:                                                       ║`

    this.linuxPuzzles.forEach((puzzle, index) => {
      const status = puzzle.solved ? '✅' : puzzle.unlocked ? '🔓' : '🔒'
      const difficulty = puzzle.difficulty === 'Easy' ? '⭐' : 
                        puzzle.difficulty === 'Medium' ? '⭐⭐' : 
                        puzzle.difficulty === 'Hard' ? '⭐⭐⭐' : '⭐⭐⭐⭐'
      
      puzzleDisplay += `
║                                                                              ║
║ ${status} ${(index + 1).toString().padStart(2)}. ${puzzle.title.padEnd(60)} ║
║    Category: ${puzzle.category.padEnd(20)} Difficulty: ${difficulty.padEnd(25)} ║
║    ${puzzle.description.padEnd(74)} ║
║    Reward: ${puzzle.xpReward.toString().padEnd(66)} XP ║`
      
      if (puzzle.unlocked && !puzzle.solved) {
        puzzleDisplay += `
║    💡 Hint: ${puzzle.hint.padEnd(65)} ║
║    🎮 Solve: nc-solve-puzzle ${(index + 1).toString().padEnd(47)} ║`
      } else if (puzzle.solved) {
        puzzleDisplay += `
║    🔍 Investigation: ${puzzle.investigationReward.padEnd(50)} ║`
      } else {
        puzzleDisplay += `
║    🔒 Unlock by progressing in your investigations                          ║`
      }
    })

    puzzleDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 💡 HOW TO PLAY:                                                             ║
║ • Puzzles unlock as you advance through the main investigation              ║
║ • Each solved puzzle reveals clues about The Architect's disappearance      ║
║ • Use real Linux commands to solve challenges on your actual system         ║
║ • Solutions earn XP and advance both learning and story progression         ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔍 These puzzles use your real system - every solution documents your actual setup!`

    return {
      output: puzzleDisplay,
      type: 'info'
    }
  }

  solvePuzzle(args) {
    if (!args.length) {
      return {
        output: `Usage: nc-solve-puzzle <puzzle_number>\n\nUse 'nc-puzzles' to see available puzzles.`,
        type: 'info'
      }
    }

    const puzzleNumber = parseInt(args[0]) - 1
    
    if (puzzleNumber < 0 || puzzleNumber >= this.linuxPuzzles.length) {
      return {
        output: `❌ Invalid puzzle number. Valid range: 1-${this.linuxPuzzles.length}`,
        type: 'error'
      }
    }

    const puzzle = this.linuxPuzzles[puzzleNumber]
    
    if (!puzzle.unlocked) {
      return {
        output: `🔒 Puzzle "${puzzle.title}" is not yet unlocked.\n\nProgress through the main investigation to unlock more puzzles.`,
        type: 'warning'
      }
    }

    if (puzzle.solved) {
      return {
        output: `✅ Puzzle "${puzzle.title}" is already solved.\n\n🔍 Investigation Result: ${puzzle.investigationReward}`,
        type: 'info'
      }
    }

    // Present the puzzle challenge
    return {
      output: `╔═══════════════════════════════════════════════════════════════════════════╗
║                        🧩 PUZZLE CHALLENGE                               ║
║                         ${puzzle.title.padEnd(48)} ║
╠═══════════════════════════════════════════════════════════════════════════╣
║ 📋 OBJECTIVE:                                                            ║
║ ${puzzle.description.padEnd(73)} ║
║                                                                           ║
║ 💡 HINT:                                                                 ║
║ ${puzzle.hint.padEnd(73)} ║
║                                                                           ║
║ 🎯 YOUR TASK:                                                            ║
║ Execute the correct Linux command(s) to solve this challenge.            ║
║ The solution will provide valuable information about your system.        ║
║                                                                           ║
║ 📊 DIFFICULTY: ${puzzle.difficulty.padEnd(59)} ║
║ 💰 REWARD: ${puzzle.xpReward.toString().padEnd(65)} XP ║
║                                                                           ║
║ 🔍 INVESTIGATION REWARD:                                                 ║
║ ${puzzle.investigationReward.padEnd(73)} ║
╚═══════════════════════════════════════════════════════════════════════════╝

💡 Execute the solution command directly in the terminal.
🎯 When you find the answer, run it again to verify and earn rewards!

Example Solution Command: ${puzzle.solution}

Note: This puzzle encourages you to document your actual system configuration.`,
      type: 'info',
      puzzleActive: true,
      puzzleId: puzzle.id
    }
  }

  showAdvancedQuests() {
    let questDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🚀 ADVANCED QUESTLINES                            ║
║                    Master-Level Infrastructure Challenges                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 COMPLETE THE ARCHITECT'S UNFINISHED PROJECTS                             ║
║                                                                              ║
║ 📊 PROGRESS: ${this.advancedQuests.filter(q => q.completed).length}/${this.advancedQuests.length} advanced questlines completed                    ║`

    this.advancedQuests.forEach((quest, index) => {
      const status = quest.completed ? '✅' : quest.unlocked ? '🎯' : '🔒'
      const progress = quest.phases.filter(p => p.completed).length
      const total = quest.phases.length
      
      questDisplay += `
║                                                                              ║
║ ${status} ${quest.title.padEnd(70)} ║
║    Category: ${quest.category.padEnd(25)} Difficulty: ${quest.difficulty.padEnd(25)} ║
║    Progress: ${progress}/${total} phases completed                                        ║
║    ${quest.description.padEnd(74)} ║
║    Total Reward: ${quest.xpReward.toString().padEnd(60)} XP ║`
      
      if (quest.unlocked && !quest.completed) {
        const nextPhase = quest.phases.find(p => !p.completed)
        if (nextPhase) {
          questDisplay += `
║    📋 Next Phase: ${nextPhase.name.padEnd(57)} ║
║    🎮 Command: ${nextPhase.command.padEnd(61)} ║`
        }
      } else if (quest.completed) {
        questDisplay += `
║    🔍 Investigation: ${quest.investigationReward.padEnd(50)} ║`
      } else {
        questDisplay += `
║    🔒 Unlock by reaching Tier 3+ and solving prerequisite puzzles          ║`
      }
    })

    questDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 💡 ADVANCED QUESTLINES:                                                     ║
║ • Multi-phase challenges that teach real-world DevOps skills                ║
║ • Each phase builds on previous knowledge and system setup                   ║
║ • Questlines unlock advanced monitoring and security tools                   ║
║ • Completion reveals critical information about The Architect's work         ║
║                                                                              ║
║ 🎓 PREREQUISITES:                                                           ║
║ • Complete basic training questlines                                        ║
║ • Reach Tier 3+ skill level                                                ║
║ • Solve foundational Linux puzzles                                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

🚀 These questlines configure real monitoring tools on your actual system!`

    return {
      output: questDisplay,
      type: 'info'
    }
  }

  startMonitoringQuest() {
    const monitoringQuest = this.advancedQuests.find(q => q.id === 'monitoring_infrastructure')
    
    if (!monitoringQuest) {
      return {
        output: `❌ Monitoring quest not found. This appears to be a system error.`,
        type: 'error'
      }
    }

    if (this.player.level < 3) {
      return {
        output: `🔒 Monitoring questline requires Tier 3+ experience.\n\nCurrent Level: ${this.player.level}\nRequired Level: 3+\n\nComplete more basic training to unlock advanced questlines.`,
        type: 'warning'
      }
    }

    if (monitoringQuest.unlocked) {
      return {
        output: `📊 Monitoring questline is already active.\n\nUse 'nc-advanced-quests' to see your progress.`,
        type: 'info'
      }
    }

    // Unlock the monitoring questline
    monitoringQuest.unlocked = true
    
    return {
      output: `╔═══════════════════════════════════════════════════════════════════════════╗
║                    🚀 MONITORING QUESTLINE ACTIVATED                     ║
║                     The Architect's Monitoring Vision                    ║
╠═══════════════════════════════════════════════════════════════════════════╣
║ 📋 MISSION BRIEFING:                                                     ║
║                                                                           ║
║ The Architect was building a comprehensive monitoring system before       ║
║ their disappearance. Their notes indicate this system was meant to       ║
║ detect and prevent the very attack that occurred.                        ║
║                                                                           ║
║ Your mission: Complete their unfinished work to understand what they     ║
║ discovered and potentially prevent future attacks.                       ║
║                                                                           ║
║ 🎯 QUESTLINE PHASES:                                                     ║
║ 1. Install Grafana - Web-based analytics and visualization               ║
║ 2. Configure Prometheus - Time-series metrics collection                 ║
║ 3. Create Dashboards - Visual monitoring interfaces                      ║
║ 4. Setup Alerting - Automated anomaly detection                          ║
║                                                                           ║
║ 💡 LEARNING OUTCOMES:                                                    ║
║ • Master real-world monitoring tools used in production                  ║
║ • Configure actual monitoring stack on your system                       ║
║ • Learn DevOps and SRE monitoring practices                              ║
║ • Gain insight into The Architect's investigation methods                ║
║                                                                           ║
║ ⚠️  WARNING: This questline will install and configure real software     ║
║    on your system. Ensure you have appropriate permissions.              ║
╚═══════════════════════════════════════════════════════════════════════════╝

🎯 Phase 1 is now available. Use 'nc-install-grafana' to begin!
📊 Check progress anytime with 'nc-advanced-quests'`,
      type: 'success'
    }
  }

  showSystemDocumentation() {
    // Generate real-time documentation of the player's system
    return {
      output: `╔══════════════════════════════════════════════════════════════════════════════╗
║                      📚 SYSTEM DOCUMENTATION GENERATOR                     ║
║                        Live System Analysis & Documentation                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 DOCUMENT YOUR ACTUAL SYSTEM CONFIGURATION                                ║
║                                                                              ║
║ This feature helps you create comprehensive documentation of your live      ║
║ system while advancing The Architect investigation storyline.               ║
║                                                                              ║
║ 📋 AVAILABLE DOCUMENTATION MODULES:                                         ║
║                                                                              ║
║ 🖥️  SYSTEM OVERVIEW                                                         ║
║ • Hardware specifications and architecture                                  ║
║ • Operating system details and kernel version                              ║
║ • Installed software inventory                                             ║
║ • Command: nc-doc-system                                                   ║
║                                                                              ║
║ 🌐 NETWORK CONFIGURATION                                                    ║
║ • Network interfaces and IP configuration                                  ║
║ • Routing tables and network topology                                      ║
║ • Active connections and listening services                                ║
║ • Command: nc-doc-network                                                  ║
║                                                                              ║
║ 🔐 SECURITY POSTURE                                                         ║
║ • Firewall rules and security policies                                     ║
║ • User accounts and permission structure                                   ║
║ • Security tools and monitoring systems                                    ║
║ • Command: nc-doc-security                                                 ║
║                                                                              ║
║ ⚙️  SERVICES & PROCESSES                                                    ║
║ • Running services and daemon configurations                                ║
║ • Scheduled tasks and automation                                           ║
║ • Resource utilization patterns                                            ║
║ • Command: nc-doc-services                                                 ║
║                                                                              ║
║ 📊 PERFORMANCE BASELINE                                                     ║
║ • System performance metrics and trends                                    ║
║ • Resource utilization analysis                                            ║
║ • Capacity planning recommendations                                         ║
║ • Command: nc-doc-performance                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 INVESTIGATION CONNECTION:                                                ║
║ The Architect was meticulously documenting systems before disappearing.    ║
║ Each documentation module you complete reveals more about their methods     ║
║ and potentially uncovers clues about what they discovered.                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

📝 Choose a documentation module to begin comprehensive system analysis!
🎓 Each module teaches real-world system administration practices.`,
      type: 'info'
    }
  }

  generateRandomIncidents() {
    // Generate random incidents that require troubleshooting
    const incidents = [
      {
        id: 'high_cpu_usage',
        title: 'Critical: High CPU Usage Detected',
        severity: 'HIGH',
        description: 'System CPU usage has spiked to 95% - investigate immediately',
        commands: ['top', 'ps aux --sort=-%cpu', 'kill -TERM'],
        xpReward: 30
      },
      {
        id: 'disk_space_low',
        title: 'Warning: Low Disk Space',
        severity: 'MEDIUM',
        description: 'Root filesystem is 85% full - clean up or investigate',
        commands: ['df -h', 'du -sh /*', 'find /tmp -type f -atime +7'],
        xpReward: 25
      },
      {
        id: 'suspicious_connections',
        title: 'Alert: Unusual Network Activity',
        severity: 'HIGH',
        description: 'Multiple connections detected to unknown external hosts',
        commands: ['netstat -tupln', 'ss -tupln', 'lsof -i'],
        xpReward: 35
      },
      {
        id: 'service_failure',
        title: 'Service Down: Critical Service Failure',
        severity: 'CRITICAL',
        description: 'A critical system service has stopped responding',
        commands: ['systemctl status', 'journalctl -xe', 'systemctl restart'],
        xpReward: 40
      }
    ]

    // Randomly activate an incident occasionally
    if (Math.random() < 0.1) { // 10% chance
      const incident = incidents[Math.floor(Math.random() * incidents.length)]
      incident.timestamp = new Date().toISOString()
      incident.active = true
      this.activeIncidents.push(incident)
    }
  }

  handleIncidentResponse(args) {
    if (!args.length) {
      return {
        output: `🚨 INCIDENT RESPONSE CENTER
        
Available incident types for training:
• 'security-breach' - Handle suspected security breach
• 'performance' - Investigate system performance issues  
• 'network' - Troubleshoot network connectivity problems
• 'suspicious-activity' - Analyze suspicious user activity
• 'data-leak' - Investigate potential data exfiltration
• 'malware' - Respond to malware detection alerts

Usage: nc-incident-response <type>
Example: nc-incident-response security-breach

Or use 'nc-incident-response simulate' to trigger a random incident.`,
        type: 'info'
      }
    }

    const incidentType = args[0].toLowerCase()
    
    switch (incidentType) {
      case 'security-breach':
        return this.simulateSecurityBreach()
      case 'performance':
        return this.simulatePerformanceIssue()
      case 'network':
        return this.simulateNetworkIssue()
      case 'suspicious-activity':
        return this.simulateSuspiciousActivity()
      case 'data-leak':
        return this.simulateDataLeak()
      case 'malware':
        return this.simulateMalwareDetection()
      case 'simulate':
        return this.simulateRandomIncident()
      default:
        return {
          output: `❌ Unknown incident type: ${incidentType}\n\nUse 'nc-incident-response' to see available types.`,
          type: 'error'
        }
    }
  }

  simulateSecurityBreach() {
    this.storyFlags.discovered_intruder_traces = true
    
    return {
      output: `🚨 SECURITY BREACH DETECTED 🚨

╔══════════════════════════════════════════════════════════════════════════════╗
║                          ⚠️  CRITICAL SECURITY INCIDENT                     ║
║                           Immediate Response Required                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔴 THREAT LEVEL: HIGH                                                       ║
║ 📅 DETECTED: ${new Date().toLocaleString().padEnd(57)} ║
║ 🎯 ALERT SOURCE: Intrusion Detection System                                 ║
║                                                                              ║
║ 🚨 INDICATORS OF COMPROMISE:                                                 ║
║ • Multiple failed SSH login attempts from foreign IP                        ║
║ • Unusual outbound network traffic detected                                  ║
║ • Privilege escalation attempts on database server                          ║
║ • Files with modified timestamps in /etc directory                          ║
║                                                                              ║
║ 🛠️  IMMEDIATE RESPONSE ACTIONS:                                             ║
║ 1. 'ps aux | grep ssh' - Check for unauthorized SSH sessions               ║
║ 2. 'netstat -tulpn' - Identify suspicious network connections              ║
║ 3. 'ls -la /etc' - Check for modified system configuration files           ║
║ 4. 'cat /var/log/auth.log' - Review authentication attempts                ║
║ 5. 'nc-scan-ports' - Scan for backdoor services                            ║
║                                                                              ║
║ 💰 INCIDENT RESOLUTION: 100 XP                                              ║
║                                                                              ║
║ 🎯 MISSION:                                                                  ║
║ Execute the response commands to contain the breach and gather evidence.    ║
║ Apply real-world incident response procedures to resolve this crisis.       ║
╚══════════════════════════════════════════════════════════════════════════════╝

⚡ PRIORITY: Execute containment measures immediately!
🔧 Follow the NIST incident response framework: Prepare, Detect, Contain, Eradicate, Recover, Learn`,
      type: 'warning'
    }
  }

  simulateRandomIncident() {
    const incidents = ['security-breach', 'performance', 'network', 'suspicious-activity', 'data-leak', 'malware']
    const randomIncident = incidents[Math.floor(Math.random() * incidents.length)]
    return this.handleIncidentResponse([randomIncident])
  }

  simulatePerformanceIssue() {
    return {
      output: `⚠️ PERFORMANCE DEGRADATION ALERT

╔══════════════════════════════════════════════════════════════════════════════╗
║                          📊 SYSTEM PERFORMANCE INCIDENT                     ║
║                           Resource Utilization Critical                      ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🟡 SEVERITY: MEDIUM                                                         ║
║ 📅 DETECTED: ${new Date().toLocaleString().padEnd(57)} ║
║ 🎯 ALERT SOURCE: System Monitoring                                          ║
║                                                                              ║
║ 📈 PERFORMANCE INDICATORS:                                                   ║
║ • CPU utilization: 95% sustained for 5+ minutes                             ║
║ • Memory usage: 87% with swap activity                                       ║
║ • Disk I/O wait times: Extremely high                                       ║
║ • User complaint: System extremely slow                                      ║
║                                                                              ║
║ 🔧 DIAGNOSTIC COMMANDS:                                                      ║
║ 1. 'top' - Monitor real-time process activity                               ║
║ 2. 'free -h' - Check memory utilization                                     ║
║ 3. 'df -h' - Examine disk space usage                                       ║
║ 4. 'ps aux --sort=-%cpu' - Identify CPU-hungry processes                    ║
║ 5. 'netstat -tulpn' - Check for network bottlenecks                         ║
║                                                                              ║
║ 💰 RESOLUTION REWARD: 75 XP                                                 ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎯 Investigate resource utilization and identify the root cause of performance degradation.`,
      type: 'warning'
    }
  }

  simulateSuspiciousActivity() {
    return {
      output: `🕵️ SUSPICIOUS USER ACTIVITY DETECTED

╔══════════════════════════════════════════════════════════════════════════════╗
║                          🔍 BEHAVIORAL ANALYSIS ALERT                       ║
║                           Anomalous User Patterns                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🟡 THREAT LEVEL: MEDIUM                                                     ║
║ 📅 DETECTED: ${new Date().toLocaleString().padEnd(57)} ║
║ 🎯 ALERT SOURCE: User Behavior Analytics                                    ║
║                                                                              ║
║ 🚩 SUSPICIOUS PATTERNS:                                                     ║
║ • After-hours system access by user 'jhansen'                               ║
║ • Unusual file access patterns in financial directories                     ║
║ • Multiple failed privilege escalation attempts                             ║
║ • Large file downloads during off-peak hours                                ║
║                                                                              ║
║ 🔍 INVESTIGATION COMMANDS:                                                   ║
║ 1. 'cat /var/log/auth.log | grep jhansen' - Check authentication history   ║
║ 2. 'ps aux | grep jhansen' - See user's current processes                   ║
║ 3. 'ls -la /home/jhansen' - Examine user's home directory                   ║
║ 4. 'cat /etc/passwd | grep jhansen' - Verify user account details           ║
║ 5. 'nc-investigate access' - Deep dive into access patterns                 ║
║                                                                              ║
║ 💰 INVESTIGATION REWARD: 85 XP                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎯 Determine if this represents a legitimate user or potential insider threat.`,
      type: 'warning'
    }
  }

  // Enhanced Story and Investigation System
  initializeStoryElements() {
    // Initialize suspect profiles with complex motivations
    this.suspectProfiles.set('external_hacker', {
      name: 'Ghost Protocol (External Threat)',
      description: 'Sophisticated external threat actor with advanced persistent threat capabilities',
      evidence: ['Suspicious foreign IP addresses', 'Advanced malware signatures', 'Zero-day exploits'],
      motivation: 'Corporate espionage and data theft',
      likelihood: 70,
      redHerring: true, // This is a false flag!
      revealed: false
    })

    this.suspectProfiles.set('insider_threat', {
      name: 'Phoenix (Internal Asset)',
      description: 'Highly skilled insider with administrative access and deep system knowledge',
      evidence: ['After-hours access logs', 'Privilege escalation attempts', 'Data exfiltration patterns'],
      motivation: 'Financial gain through corporate secrets sale',
      likelihood: 85,
      redHerring: false,
      revealed: false
    })

    this.suspectProfiles.set('corporate_conspiracy', {
      name: 'Board Level Conspiracy',
      description: 'High-level corporate conspiracy involving board members and executives',
      evidence: ['Scheduled maintenance during incident', 'Convenient security gaps', 'Missing audit logs'],
      motivation: 'Cover-up of illegal activities and regulatory violations',
      likelihood: 60,
      redHerring: false,
      revealed: false
    })

    this.suspectProfiles.set('the_architect_secret', {
      name: 'The Architect\'s Hidden Agenda',
      description: 'The Architect was not a victim but orchestrator of their own disappearance',
      evidence: ['Prepared contingencies', 'Advanced escape routes', 'Hidden cryptocurrency wallets'],
      motivation: 'Whistleblowing protection after discovering massive corruption',
      likelihood: 30,
      redHerring: false,
      revealed: false
    })

    // Initialize story timeline with narrative pacing
    this.storyElements.set('opening_mystery', {
      title: 'The Vanishing',
      content: `The Architect disappeared three days ago during what appeared to be a routine security audit. Their workstation was found locked, coffee still warm, but no signs of struggle. The only clue: a cryptic message left in the system logs.`,
      unlocked: true,
      discovered: false
    })

    this.storyElements.set('first_clue', {
      title: 'Hidden Messages',
      content: `Deep in the system logs, you discover messages that don't match The Architect's normal communication patterns. Someone - or something - has been using their credentials after the reported disappearance time.`,
      unlocked: false,
      discovered: false,
      prerequisite: ['found_admin_note']
    })

    this.storyElements.set('false_flag_revelation', {
      title: 'The Misdirection',
      content: `The "external attack" evidence is too perfect, too obvious. Real threat actors don't leave such clear calling cards. Someone wants you to believe this was an outside job. But who has the skills to fabricate evidence this sophisticated?`,
      unlocked: false,
      discovered: false,
      prerequisite: ['discovered_network', 'found_vulnerability']
    })

    this.storyElements.set('insider_discovery', {
      title: 'The Inside Job',
      content: `Access logs reveal that the attack came from within. Someone with legitimate credentials systematically dismantled security measures. The timestamps show this took months of preparation. This wasn't a simple hack - it was a carefully orchestrated inside job.`,
      unlocked: false,
      discovered: false,
      prerequisite: ['discovered_intruder_traces', 'found_encrypted_files']
    })

    this.storyElements.set('conspiracy_unveiled', {
      title: 'Corporate Corruption',
      content: `The Architect wasn't investigating a security breach - they were documenting massive corporate fraud. Millions in stolen funds, falsified reports, regulatory violations. The "attack" was actually a cover-up. Someone needed The Architect silenced.`,
      unlocked: false,
      discovered: false,
      prerequisite: ['decoded_architect_messages', 'learned_company_conspiracy']
    })

    this.storyElements.set('final_revelation', {
      title: 'The Architect\'s Gambit',
      content: `In a stunning twist, The Architect orchestrated their own disappearance. Knowing assassination was imminent, they faked their death while secretly copying evidence to secure locations. They're alive, in hiding, and still fighting to expose the truth.`,
      unlocked: false,
      discovered: false,
      prerequisite: ['architect_fate_revealed', 'true_villain_exposed']
    })
  }

  showStoryStatus() {
    const discoveredElements = Array.from(this.storyElements.values()).filter(e => e.discovered)
    const totalElements = Array.from(this.storyElements.values()).filter(e => e.unlocked)
    const investigationProgress = totalElements.length > 0 ? (discoveredElements.length / totalElements.length * 100).toFixed(1) : 0

    let storyDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📖 THE ARCHITECT INVESTIGATION                       ║
║                          Current Story Status                               ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🕵️ INVESTIGATION PROGRESS: ${investigationProgress}% COMPLETE                          ║
║ 📋 EVIDENCE COLLECTED: ${this.evidenceLog.length} items                                         ║
║ 👥 SUSPECTS IDENTIFIED: ${Array.from(this.suspectProfiles.values()).filter(s => s.revealed).length}/${this.suspectProfiles.size}                                    ║
║                                                                              ║
║ 📚 STORY TIMELINE:                                                          ║`

    Array.from(this.storyElements.values()).forEach((element, index) => {
      if (element.unlocked) {
        const status = element.discovered ? '✅' : '📖'
        storyDisplay += `
║                                                                              ║
║ ${status} ${element.title.padEnd(70)} ║`
        
        if (element.discovered) {
          // Show a preview of the content
          const preview = element.content.substring(0, 68) + (element.content.length > 68 ? '...' : '')
          storyDisplay += `
║    ${preview.padEnd(74)} ║`
        } else {
          storyDisplay += `
║    🔍 Use investigation commands to uncover this story element              ║`
        }
      }
    })

    // Add current mystery status
    storyDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 CURRENT MYSTERY STATUS:                                                  ║`

    if (this.storyFlags.conspiracy_unraveled) {
      storyDisplay += `
║ 🎉 CASE SOLVED: The conspiracy has been exposed and justice served!         ║`
    } else if (this.storyFlags.learned_company_conspiracy) {
      storyDisplay += `
║ 🔍 DEEP INVESTIGATION: Corporate corruption discovered - final truth awaits ║`
    } else if (this.storyFlags.discovered_red_herring) {
      storyDisplay += `
║ 🎭 MISDIRECTION DETECTED: The obvious suspects may not be the real culprits ║`
    } else if (this.storyFlags.found_vulnerability) {
      storyDisplay += `
║ 🕵️ EVIDENCE GATHERING: Clues are emerging - multiple suspects identified    ║`
    } else {
      storyDisplay += `
║ 🔍 INITIAL INVESTIGATION: The mystery deepens with each discovery           ║`
    }

    storyDisplay += `
║                                                                              ║
║ 💡 NEXT STEPS:                                                              ║
║ • Use 'nc-investigate' to examine specific evidence                         ║
║ • Check 'nc-suspects' to review potential culprits                          ║
║ • Try 'nc-evidence' to see collected clues                                  ║
║ • Progress through daily tasks to unlock story elements                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎭 Remember: Not everything is as it seems. Question everything.`

    return {
      output: storyDisplay,
      type: 'info'
    }
  }

  investigateEvidence(args) {
    if (!args.length) {
      return {
        output: `🔍 EVIDENCE INVESTIGATION

Usage: nc-investigate <evidence_type>

Available evidence to investigate:
• logs - Examine system and security logs
• network - Analyze network traffic patterns  
• files - Search for hidden or encrypted files
• access - Review access logs and user activity
• timeline - Reconstruct event timeline
• motives - Investigate potential motives

Example: nc-investigate logs`,
        type: 'info'
      }
    }

    const evidenceType = args[0].toLowerCase()
    
    switch (evidenceType) {
      case 'logs':
        return this.investigateSystemLogs()
      case 'network':
        return this.investigateNetworkTraffic()
      case 'files':
        return this.investigateHiddenFiles()
      case 'access':
        return this.investigateAccessLogs()
      case 'timeline':
        return this.reconstructTimeline()
      case 'motives':
        return this.investigateMotives()
      default:
        return {
          output: `❌ Unknown evidence type: ${evidenceType}\n\nUse 'nc-investigate' without arguments to see available options.`,
          type: 'error'
        }
    }
  }

  investigateSystemLogs() {
    // Progressive revelation based on player progress
    if (!this.storyFlags.found_admin_note) {
      return {
        output: `🔍 SYSTEM LOGS ANALYSIS

Initial log examination reveals standard system operations. However, there are gaps in the audit trail around the time of The Architect's disappearance. 

Several log entries appear to have been deliberately deleted or corrupted. To access deeper log analysis, complete your basic investigation first.

💡 Hint: Start by reading The Architect's administrative notes.`,
        type: 'info'
      }
    }

    if (!this.storyFlags.discovered_network) {
      this.storyFlags.discovered_intruder_traces = true
      this.addEvidence('Deleted log entries', 'Critical system logs were deliberately removed during the incident window')
      
      return {
        output: `🚨 CRITICAL DISCOVERY - LOG TAMPERING DETECTED

╔══════════════════════════════════════════════════════════════════════════════╗
║                          🔍 FORENSIC LOG ANALYSIS                          ║
║                            Evidence Classification: HIGH                     ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📅 TIMELINE GAPS IDENTIFIED:                                               ║
║ • 23:47:15 - Normal system operations                                       ║
║ • 23:47:16 - [LOG ENTRY DELETED]                                           ║
║ • 23:47:17 - [LOG ENTRY DELETED]                                           ║
║ • 23:52:03 - System resumed normal operations                               ║
║                                                                              ║
║ 🚨 SUSPICIOUS FINDINGS:                                                     ║
║ • 4 minutes and 47 seconds of missing logs                                  ║
║ • Professional deletion - no amateur could do this                          ║
║ • Logs removed using administrative privileges                              ║
║ • Deletion timestamp: 00:15:30 (after reported disappearance)              ║
║                                                                              ║
║ 💀 CHILLING DISCOVERY:                                                      ║
║ The logs were deleted AFTER The Architect's reported disappearance.        ║
║ Someone used their credentials posthumously... or they're still alive.      ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎭 Plot twist: This changes everything. The timeline doesn't add up.`,
        type: 'success'
      }
    }

    // Advanced log analysis for experienced investigators
    this.storyFlags.found_encrypted_files = true
    this.addEvidence('Encrypted message fragments', 'Hidden encrypted communications discovered in system logs')
    
    return {
      output: `🔐 ENCRYPTED COMMUNICATIONS DISCOVERED

Deep log analysis reveals hidden encrypted message fragments embedded in routine system entries. Someone was using the logging system as a covert communication channel.

Encrypted Fragment 1: "VGhlIHRydXRoIGlzIG5vdCB3aGF0IGl0IHNlZW1z"
Encrypted Fragment 2: "Qm9hcmQgbWVldGluZyBhdCBtaWRuaWdodA=="
Encrypted Fragment 3: "VGhleSBrbm93IEkga25vdw=="

🎯 These messages appear to be Base64 encoded. Use 'nc-decrypt' to attempt decryption.
💡 Warning: Decryption may trigger additional story events.`,
      type: 'warning'
    }
  }

  investigateNetworkTraffic() {
    if (!this.storyFlags.discovered_network) {
      return {
        output: `🌐 NETWORK TRAFFIC ANALYSIS

Basic network scan shows normal traffic patterns. However, deeper analysis requires advanced network discovery tools.

💡 Complete network discovery quest first: Use 'nc-discover-services' and 'nc-map-network'`,
        type: 'info'
      }
    }

    // Reveal the false flag
    this.storyFlags.suspected_external_attack = true
    this.storyFlags.found_fake_evidence = true
    this.addEvidence('Fabricated attack signatures', 'Network evidence appears artificially planted')

    return {
      output: `🎭 NETWORK FORENSICS - FABRICATED EVIDENCE DETECTED

╔══════════════════════════════════════════════════════════════════════════════╗
║                        🕵️ NETWORK TRAFFIC ANALYSIS                         ║
║                           RED HERRING IDENTIFIED                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🚨 SUSPICIOUS FINDINGS:                                                     ║
║                                                                              ║
║ 🎯 "EXTERNAL ATTACK" EVIDENCE:                                              ║
║ • IP Address: 192.168.1.666 (IMPOSSIBLE - Invalid IP range!)              ║
║ • Attack Vector: "Advanced Persistent Threat" (Too generic)                ║
║ • Malware Hash: 1234567890ABCDEF (Obviously fake)                          ║
║ • User Agent: "Super Elite Hacker Tool v1.0" (Comically fake)             ║
║                                                                              ║
║ 💡 REAL EVIDENCE HIDDEN BENEATH:                                           ║
║ • Internal IP addresses accessing restricted systems                        ║
║ • VPN connections from company executives' home networks                    ║
║ • Encrypted file transfers to offshore accounts                             ║
║ • Traffic patterns indicating coordinated insider activity                  ║
║                                                                              ║
║ 🎭 CONCLUSION:                                                              ║
║ Someone with sophisticated knowledge planted fake "external hack"           ║
║ evidence to misdirect the investigation. The real attack came from          ║
║ inside the company, possibly involving multiple high-level employees.       ║
╚══════════════════════════════════════════════════════════════════════════════╝

🕵️ Investigation Status: The "external hacker" theory is deliberately fabricated.
🎯 New Lead: Focus investigation on internal threats and corporate conspiracy.`,
      type: 'success'
    }
  }

  investigateHiddenFiles() {
    if (!this.storyFlags.found_encrypted_files) {
      return {
        output: `📁 HIDDEN FILE SEARCH

Standard file search reveals normal system files. Hidden files require advanced investigation techniques.

💡 Progress through log analysis first to discover encrypted file locations.`,
        type: 'info'
      }
    }

    this.storyFlags.decoded_architect_messages = true
    this.addEvidence('The Architect\'s secret files', 'Hidden investigation files reveal corporate fraud evidence')

    return {
      output: `📁 HIDDEN INVESTIGATION FILES DISCOVERED

╔══════════════════════════════════════════════════════════════════════════════╗
║                      💀 THE ARCHITECT'S SECRET FILES                       ║
║                           CLASSIFIED INVESTIGATION                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📂 DISCOVERED FILES:                                                        ║
║                                                                              ║
║ 🗂️  corruption_evidence.encrypted                                          ║
║    └─ Financial records showing $45M in embezzled funds                     ║
║                                                                              ║
║ 🗂️  board_communications.secure                                            ║
║    └─ Email chain discussing "The Architect Problem"                        ║
║                                                                              ║
║ 🗂️  escape_plan.backup                                                     ║
║    └─ Detailed contingency plan for witness protection                      ║
║                                                                              ║
║ 🗂️  dead_man_switch.timer                                                  ║
║    └─ Automated evidence release scheduled for 72 hours                     ║
║                                                                              ║
║ 💥 BOMBSHELL REVELATION:                                                    ║
║ The Architect wasn't investigating a security breach - they were            ║
║ documenting massive corporate fraud involving board members!                ║
║                                                                              ║
║ The "attack" was actually an assassination attempt disguised as a           ║
║ security incident. The Architect discovered the fraud and became a          ║
║ liability that needed to be eliminated.                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎯 Investigation Status: Corporate conspiracy confirmed.
⚠️  The Architect's life was in danger - but are they really dead?`,
      type: 'success'
    }
  }

  investigateAccessLogs() {
    this.addEvidence('After-hours access patterns', 'Suspicious late-night access by multiple executives')
    
    return {
      output: `🕰️ ACCESS LOG INVESTIGATION

╔══════════════════════════════════════════════════════════════════════════════╗
║                          🚨 SUSPICIOUS ACCESS PATTERNS                     ║
║                             24-HOUR TIMELINE                                ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🕐 22:30 - CEO Margaret Stone: Emergency board access                       ║
║ 🕑 22:45 - CFO Richard Blackwood: Financial systems access                  ║
║ 🕒 23:15 - CTO Sarah Phoenix: Security override authorization               ║
║ 🕓 23:30 - The Architect: Final system access (normal pattern)              ║
║ 🕔 23:47 - [INCIDENT WINDOW] - Multiple system alerts                       ║
║ 🕕 00:15 - CTO Sarah Phoenix: Log deletion and system cleanup               ║
║ 🕖 01:30 - Security Team: "Discovery" of missing Architect                  ║
║                                                                              ║
║ 🚨 DAMNING PATTERN:                                                         ║
║ Three C-level executives accessed critical systems within 45 minutes       ║
║ of The Architect's disappearance. This was coordinated, not coincidental.  ║
║                                                                              ║
║ 🎯 PRIMARY SUSPECT IDENTIFIED:                                              ║
║ CTO Sarah Phoenix deleted the logs and cleaned up evidence.                 ║
║ She had the technical skills and administrative access required.            ║
║                                                                              ║
║ 💀 CONSPIRACY SCOPE:                                                        ║
║ This goes to the top - CEO and CFO involvement confirmed.                   ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎭 The inside job theory is confirmed. This is a high-level corporate conspiracy.`,
      type: 'warning'
    }
  }

  reconstructTimeline() {
    if (this.evidenceLog.length < 3) {
      return {
        output: `⏰ TIMELINE RECONSTRUCTION

Insufficient evidence collected. Gather more clues through investigation before attempting timeline reconstruction.

Current Evidence: ${this.evidenceLog.length}/5 required`,
        type: 'warning'
      }
    }

    this.storyFlags.learned_company_conspiracy = true
    this.unlockStoryElement('conspiracy_unveiled')

    return {
      output: `⏰ COMPLETE TIMELINE RECONSTRUCTION

╔══════════════════════════════════════════════════════════════════════════════╗
║                        📅 THE ARCHITECT CONSPIRACY                         ║
║                          Complete Event Timeline                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📅 3 MONTHS AGO:                                                           ║
║ • The Architect discovers financial irregularities in quarterly reports     ║
║ • Begins covert investigation into corporate fraud                          ║
║ • Sets up encrypted communication channels and dead man switches           ║
║                                                                              ║
║ 📅 3 WEEKS AGO:                                                            ║
║ • Board becomes aware of The Architect's investigation                      ║
║ • Emergency meeting called: "The Architect Problem"                         ║
║ • Assassination plan developed and resources allocated                      ║
║                                                                              ║
║ 📅 3 DAYS AGO (THE INCIDENT):                                              ║
║ • 22:30 - Conspirators begin emergency access sequence                      ║
║ • 23:30 - The Architect's final system access (knowing danger)             ║
║ • 23:47 - Assassination attempt occurs during "security audit"             ║
║ • 00:15 - Evidence cleanup and false flag evidence planted                  ║
║ • 01:30 - "Discovery" of missing Architect reported to authorities          ║
║                                                                              ║
║ 🎭 THE CONSPIRACY:                                                          ║
║ CEO Margaret Stone, CFO Richard Blackwood, and CTO Sarah Phoenix           ║
║ orchestrated the elimination of The Architect to cover up a massive        ║
║ embezzlement scheme totaling $45 million in stolen funds.                   ║
║                                                                              ║
║ 💀 THE QUESTION REMAINS:                                                    ║
║ Did they succeed in killing The Architect, or did the escape plan work?    ║
╚══════════════════════════════════════════════════════════════════════════════╝

🕵️ Case Status: Corporate conspiracy exposed. The Architect's fate remains unknown.`,
      type: 'success'
    }
  }

  investigateMotives() {
    return {
      output: `🎯 MOTIVE ANALYSIS

╔══════════════════════════════════════════════════════════════════════════════╗
║                             💰 FINANCIAL MOTIVES                           ║
║                           Follow the Money Trail                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🏦 MARGARET STONE (CEO):                                                    ║
║ • Personal debt: $12M in gambling losses                                    ║
║ • Motive: Used company funds to cover personal debts                        ║
║ • Risk: Criminal charges, life imprisonment                                 ║
║                                                                              ║
║ 📊 RICHARD BLACKWOOD (CFO):                                                 ║
║ • Insider trading: $8M in illegal stock profits                             ║
║ • Motive: Falsified reports to manipulate stock prices                      ║
║ • Risk: SEC investigation, federal prison                                   ║
║                                                                              ║
║ 💻 SARAH PHOENIX (CTO):                                                     ║
║ • Cryptocurrency theft: $25M in stolen blockchain assets                    ║
║ • Motive: Used technical access to steal digital currencies                 ║
║ • Risk: International law enforcement, extradition                          ║
║                                                                              ║
║ 🎯 COLLECTIVE MOTIVE:                                                       ║
║ All three executives were stealing from the company using their            ║
║ positions. The Architect's investigation threatened to expose ALL           ║
║ of their crimes simultaneously.                                             ║
║                                                                              ║
║ 💀 MURDER MOTIVE:                                                           ║
║ The Architect wasn't just a whistleblower - they were an existential       ║
║ threat to three people's freedom and entire lives.                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

💡 With $45M stolen and life sentences at stake, murder became their only option.`,
      type: 'warning'
    }
  }

  showSuspectProfiles() {
    let suspectDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          👥 SUSPECT PROFILES                               ║
║                     Investigation Target Analysis                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🕵️ INVESTIGATION STATUS: Multiple suspects identified                        ║
║ 🎯 EVIDENCE RELIABILITY: Mixed - some fabricated evidence detected          ║`

    Array.from(this.suspectProfiles.values()).forEach((suspect, index) => {
      if (suspect.revealed || this.evidenceLog.length >= 2) {
        const status = suspect.redHerring ? '🎭' : suspect.likelihood > 70 ? '🚨' : '⚠️'
        const reliability = suspect.redHerring ? 'FALSE FLAG' : 'GENUINE THREAT'
        
        suspectDisplay += `
║                                                                              ║
║ ${status} ${suspect.name.padEnd(70)} ║
║    Threat Level: ${suspect.likelihood.toString().padEnd(15)} Evidence: ${reliability.padEnd(35)} ║
║    ${suspect.description.padEnd(74)} ║
║    Motivation: ${suspect.motivation.padEnd(64)} ║`
        
        if (suspect.evidence.length > 0) {
          suspectDisplay += `
║    Key Evidence:                                                            ║`
          suspect.evidence.forEach(evidence => {
            suspectDisplay += `
║    • ${evidence.padEnd(72)} ║`
          })
        }

        if (suspect.redHerring && this.storyFlags.discovered_red_herring) {
          suspectDisplay += `
║    🎭 ANALYSIS: This suspect profile appears to be a deliberate misdirection ║`
        }
      }
    })

    suspectDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 INVESTIGATION NOTES:                                                     ║
║ • Multiple suspects indicate complex conspiracy                             ║
║ • Some evidence appears deliberately fabricated                             ║
║ • Internal threats show highest probability                                  ║
║ • External threats may be red herrings                                      ║
║                                                                              ║
║ 💡 RECOMMENDATION:                                                          ║
║ Focus investigation on corporate insiders with technical capabilities       ║
║ and financial motives. The external threat evidence is suspicious.          ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎭 Remember: In a world of deception, question every piece of evidence.`

    return {
      output: suspectDisplay,
      type: 'info'
    }
  }

  showEvidenceLog() {
    if (this.evidenceLog.length === 0) {
      return {
        output: `📋 EVIDENCE LOG - EMPTY

No evidence has been collected yet. Use investigation commands to gather clues:
• nc-investigate logs
• nc-investigate network  
• nc-investigate files
• nc-investigate access`,
        type: 'info'
      }
    }

    let evidenceDisplay = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          📋 EVIDENCE COLLECTION LOG                        ║
║                        Chain of Custody Maintained                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔍 TOTAL EVIDENCE ITEMS: ${this.evidenceLog.length.toString().padEnd(56)} ║
║ 📅 INVESTIGATION START: ${new Date().toLocaleDateString().padEnd(58)} ║`

    this.evidenceLog.forEach((evidence, index) => {
      evidenceDisplay += `
║                                                                              ║
║ 📎 EVIDENCE #${(index + 1).toString().padStart(2)}: ${evidence.name.padEnd(58)} ║
║    ${evidence.description.padEnd(74)} ║
║    Collected: ${evidence.timestamp.substring(0, 19).replace('T', ' ').padEnd(62)} ║`
    })

    evidenceDisplay += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 EVIDENCE ANALYSIS:                                                       ║
║ • ${this.analyzeEvidencePatterns().padEnd(74)} ║
║                                                                              ║
║ 💡 INVESTIGATION STATUS:                                                    ║
║ • ${this.getInvestigationStatus().padEnd(74)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔍 Each piece of evidence brings us closer to the truth about The Architect.`

    return {
      output: evidenceDisplay,
      type: 'info'
    }
  }

  attemptDecryption(args) {
    if (!this.storyFlags.found_encrypted_files) {
      return {
        output: `🔐 DECRYPTION SERVICE

No encrypted files have been discovered yet. Continue investigation to find encrypted evidence.

💡 Hint: Examine system logs carefully for hidden messages.`,
        type: 'warning'
      }
    }

    if (!args.length) {
      return {
        output: `🔐 DECRYPTION ATTEMPT

Usage: nc-decrypt <message_number>

Available encrypted messages:
1. VGhlIHRydXRoIGlzIG5vdCB3aGF0IGl0IHNlZW1z
2. Qm9hcmQgbWVldGluZyBhdCBtaWRuaWdodA==
3. VGhleSBrbm93IEkga25vdw==

Example: nc-decrypt 1`,
        type: 'info'
      }
    }

    const messageNum = parseInt(args[0])
    let decryptedContent = ''
    
    switch (messageNum) {
      case 1:
        decryptedContent = 'The truth is not what it seems'
        break
      case 2:
        decryptedContent = 'Board meeting at midnight'
        this.storyFlags.uncovered_insider_threat = true
        break
      case 3:
        decryptedContent = 'They know I know'
        this.storyFlags.met_mysterious_contact = true
        break
      default:
        return {
          output: `❌ Invalid message number: ${messageNum}`,
          type: 'error'
        }
    }

    this.addEvidence(`Decrypted message ${messageNum}`, decryptedContent)

    return {
      output: `🔓 DECRYPTION SUCCESSFUL

╔══════════════════════════════════════════════════════════════════════════════╗
║                           🔓 MESSAGE DECRYPTED                             ║
║                            Base64 Decoding Complete                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📨 ORIGINAL MESSAGE: Message #${messageNum.toString().padEnd(52)} ║
║                                                                              ║
║ 🔓 DECRYPTED CONTENT:                                                       ║
║ "${decryptedContent.padEnd(74)}" ║
║                                                                              ║
║ 🕵️ ANALYSIS:                                                                ║
║ This message was hidden in system logs using steganographic techniques.    ║
║ The Architect was communicating covertly, likely aware they were being      ║
║ monitored and their life was in danger.                                     ║
║                                                                              ║
║ 🚨 SECURITY IMPLICATION:                                                    ║
║ These messages confirm The Architect knew about the conspiracy and was      ║
║ attempting to leave evidence for investigators like you.                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

💀 The Architect was in mortal danger and knew it.`,
      type: 'success'
    }
  }

  contactMysteriousFigure(args) {
    if (!this.storyFlags.met_mysterious_contact) {
      return {
        output: `📞 CONTACT ATTEMPT FAILED

No mysterious contacts have been identified yet. Continue investigation to discover communication channels.

💡 Decrypt all hidden messages to establish contact protocols.`,
        type: 'warning'
      }
    }

    return {
      output: `📞 ENCRYPTED COMMUNICATION ESTABLISHED

╔══════════════════════════════════════════════════════════════════════════════╗
║                        📱 SECURE CHANNEL OPENED                            ║
║                          Unknown Contact: "SHADOW"                          ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🕰️ CONNECTION ESTABLISHED: ${new Date().toLocaleTimeString().padEnd(54)} ║
║ 🔐 ENCRYPTION LEVEL: Military Grade                                        ║
║ 📍 LOCATION: Unknown (Anonymized)                                          ║
║                                                                              ║
║ 💬 INCOMING MESSAGE:                                                        ║
║ "I've been watching your investigation, recruit. You're getting close      ║
║  to the truth, but be careful - they have eyes everywhere.                 ║
║                                                                              ║
║  The Architect isn't dead. I helped them escape during the assassination   ║
║  attempt. But the corporate conspiracy runs deeper than you realize.       ║
║                                                                              ║
║  The board isn't just stealing money - they're covering up a massive       ║
║  data breach that exposed millions of customers. The Architect discovered  ║
║  they've been selling the stolen data to foreign governments.              ║
║                                                                              ║
║  Meet me at the old server room if you want to learn the final truth.      ║
║  But know this - once you know everything, there's no going back.          ║
║                                                                              ║
║  Trust no one. Question everything. The Architect is counting on you."     ║
║                                                                              ║
║ 🚨 CONNECTION TERMINATED                                                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎭 Plot twist: The Architect is alive! But who is "Shadow" and can they be trusted?`,
      type: 'success'
    }
  }

  triggerStoryRevelation() {
    if (!this.storyFlags.learned_company_conspiracy) {
      return {
        output: `🔒 REVELATION LOCKED

Major story revelations require sufficient investigation progress. Continue gathering evidence and exposing the conspiracy.

Current Progress: Investigation in progress...`,
        type: 'warning'
      }
    }

    this.storyFlags.architect_fate_revealed = true
    this.storyFlags.true_villain_exposed = true
    this.unlockStoryElement('final_revelation')

    return {
      output: `🎭 FINAL REVELATION - THE ARCHITECT'S GAMBIT

╔══════════════════════════════════════════════════════════════════════════════╗
║                        💀 THE ULTIMATE TRUTH REVEALED                      ║
║                          The Architect's Master Plan                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎭 THE SHOCKING TRUTH:                                                      ║
║                                                                              ║
║ The Architect orchestrated their own "death" as part of an elaborate        ║
║ sting operation. They knew about the assassination plot and turned it       ║
║ into the perfect opportunity to fake their death while gathering            ║
║ irrefutable evidence of the conspiracy.                                     ║
║                                                                              ║
║ 🕵️ THE MASTER PLAN:                                                         ║
║ • Phase 1: Discover the corporate fraud and board conspiracy               ║
║ • Phase 2: Allow conspirators to believe assassination was successful      ║
║ • Phase 3: Guide investigators (like you) to uncover the evidence          ║
║ • Phase 4: Emerge from hiding with bulletproof legal case                  ║
║                                                                              ║
║ 💀 THE ASSASSINATION ATTEMPT:                                               ║
║ The Architect used a body double and special effects to fake their death.  ║
║ They've been alive the entire time, watching from the shadows as you       ║
║ piece together their carefully planted clues.                              ║
║                                                                              ║
║ 🎯 THE FINAL TWIST:                                                         ║
║ YOU were selected specifically by The Architect. They've been monitoring   ║
║ your progress and guiding your investigation from the beginning.            ║
║                                                                              ║
║ 🏆 MISSION ACCOMPLISHED:                                                    ║
║ The conspiracy has been exposed, the evidence is overwhelming, and          ║
║ justice will finally be served. The Architect will emerge tomorrow         ║
║ to testify before Congress with your investigation as supporting evidence.  ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎉 CASE SOLVED: You've successfully completed The Architect Investigation!
🏆 The truth has been revealed and justice will be served!`,
      type: 'success'
    }
  }

  // Helper methods for story system
  addEvidence(name, description) {
    this.evidenceLog.push({
      name,
      description,
      timestamp: new Date().toISOString()
    })
  }

  unlockStoryElement(elementId) {
    const element = this.storyElements.get(elementId)
    if (element && this.checkPrerequisites(element.prerequisite)) {
      element.unlocked = true
      element.discovered = true
    }
  }

  checkPrerequisites(prerequisites) {
    if (!prerequisites) return true
    return prerequisites.every(flag => this.storyFlags[flag])
  }

  analyzeEvidencePatterns() {
    if (this.evidenceLog.length < 2) return 'Insufficient evidence for pattern analysis'
    if (this.storyFlags.discovered_red_herring) return 'Mixed evidence - some fabricated to misdirect investigation'
    if (this.storyFlags.learned_company_conspiracy) return 'Clear pattern of corporate conspiracy and cover-up'
    return 'Evidence points to sophisticated insider threat with multiple actors'
  }

  getInvestigationStatus() {
    if (this.storyFlags.conspiracy_unraveled) return 'Case solved - conspiracy exposed and justice served'
    if (this.storyFlags.learned_company_conspiracy) return 'Major breakthrough - corporate conspiracy confirmed'
    if (this.storyFlags.discovered_red_herring) return 'Misdirection detected - refocusing on internal threats'
    if (this.evidenceLog.length >= 3) return 'Solid progress - multiple leads being pursued'
    return 'Early stage investigation - gathering foundational evidence'
  }

  // Narrative pacing mechanism to prevent quest maxing
  checkStoryPacing() {
    const now = Date.now()
    const timeSinceLastEvent = now - (this.lastStoryEvent || 0)
    
    // Minimum 30 seconds between major story revelations
    if (timeSinceLastEvent < 30000) {
      return {
        blocked: true,
        message: `🕰️ INVESTIGATION PACING

Major revelations require time to process. Wait a moment before continuing the investigation.

💡 Use this time to explore other game features or complete daily tasks.`
      }
    }
    
    this.lastStoryEvent = now
    return { blocked: false }
  }

  // Hidden Systems and Discovery Mechanics
  initializeHiddenSystems() {
    // The Architect's hidden terminals scattered throughout the system
    this.hiddenTerminals.set('port_2187', {
      name: 'ARCHITECT_FORENSICS_TERMINAL',
      description: 'The Architect\'s hidden forensics workstation',
      accessCommand: 'nc-evidence',
      displayName: 'Evidence Analysis Terminal',
      discovered: false,
      requiresPassword: true,
      password: 'vanishing_admin', // Found in admin notes
      unlockMessage: 'Forensics terminal unlocked - evidence analysis capabilities enabled'
    })

    this.hiddenTerminals.set('port_3133', {
      name: 'CRYPTOGRAPHIC_ANALYSIS_NODE',
      description: 'Advanced cryptographic decryption terminal',
      accessCommand: 'nc-decrypt',
      displayName: 'Cryptographic Analysis Node',
      discovered: false,
      requiresPassword: true,
      password: 'truth_not_what_seems', // From first decrypted message
      unlockMessage: 'Cryptographic terminal activated - decryption capabilities online'
    })

    this.hiddenTerminals.set('port_5150', {
      name: 'SHADOW_COMMUNICATION_HUB',
      description: 'Encrypted communication terminal for covert contacts',
      accessCommand: 'nc-contact',
      displayName: 'Covert Communication Hub',
      discovered: false,
      requiresPassword: true,
      password: 'board_meeting_midnight', // From second decrypted message
      unlockMessage: 'Shadow communication protocols initiated - contact capabilities enabled'
    })

    this.hiddenTerminals.set('port_8080', {
      name: 'ARCHITECT_MASTER_SHELL',
      description: 'The Architect\'s primary command interface',
      accessCommand: 'nc-architect-shell',
      displayName: 'Architect Master Control',
      discovered: false,
      requiresPassword: true,
      password: 'they_know_i_know', // From third decrypted message
      unlockMessage: 'Architect master shell accessed - full investigation suite online'
    })

    this.hiddenTerminals.set('port_7734', {
      name: 'SUSPECT_ANALYSIS_MATRIX',
      description: 'Criminal profiling and suspect analysis system',
      accessCommand: 'nc-suspects',
      displayName: 'Suspect Analysis Matrix',
      discovered: false,
      requiresPassword: false, // Unlocked by finding multiple evidence pieces
      unlockMessage: 'Suspect profiling system online - criminal analysis capabilities enabled'
    })

    this.hiddenTerminals.set('port_9999', {
      name: 'SHADOW_PROTOCOL_ENDPOINT',
      description: 'Ultra-secure communication protocol for the final revelation',
      accessCommand: 'shadow-protocol',
      displayName: 'Shadow Protocol Interface',
      discovered: false,
      requiresPassword: true,
      password: 'architect_master_plan', // Discovered through investigation
      unlockMessage: 'Shadow Protocol activated - highest security clearance granted'
    })
  }

  // Initialize V1-style pattern-based discovery system
  initializeDiscoveryPatterns() {
    // Discovery patterns from V1 - these trigger when specific command patterns are detected
    this.discoveryTriggers = [
      {
        pattern: /grep.*password|grep.*secret|grep.*key/,
        commands: ['cat', 'grep'],
        triggerCount: 3,
        discovery: 'encrypted_files',
        message: '🔍 DISCOVERY: Encrypted files detected! Your password hunting has revealed hidden data.',
        storyFlag: 'found_encrypted_files'
      },
      {
        pattern: /ps.*grep|netstat.*grep|ls.*-la/,
        commands: ['ps', 'netstat', 'ls'],
        triggerCount: 5,
        discovery: 'suspicious_processes',
        message: '🕵️ DISCOVERY: Suspicious process patterns identified! Your investigation skills are improving.',
        storyFlag: 'discovered_intruder_traces'
      },
      {
        pattern: /cat.*log|tail.*log|head.*log/,
        commands: ['cat', 'tail', 'head'],
        triggerCount: 4,
        discovery: 'log_analysis',
        message: '📊 DISCOVERY: Log analysis reveals attack patterns! You\'re thinking like a true security analyst.',
        storyFlag: 'decoded_architect_messages'
      },
      {
        pattern: /nc-.*security|nc-.*scan|nc-.*discover/,
        commands: ['nc-discover-services', 'nc-scan-ports', 'nc-security-scan'],
        triggerCount: 3,
        discovery: 'advanced_investigation',
        message: '🎯 DISCOVERY: Advanced investigation methods unlocked! The Architect would be proud.',
        storyFlag: 'learned_company_conspiracy'
      }
    ]
    
    // Initialize pattern counters
    this.discoveryTriggers.forEach(trigger => {
      this.commandPatterns.set(trigger.discovery, { count: 0, triggered: false })
    })
  }

  // V1-style pattern matching for discoveries
  checkDiscoveryPatterns(command, args) {
    const fullCommand = [command, ...args].join(' ')
    
    this.discoveryTriggers.forEach(trigger => {
      if (trigger.commands.includes(command) || trigger.pattern.test(fullCommand)) {
        const patternData = this.commandPatterns.get(trigger.discovery)
        
        if (!patternData.triggered) {
          patternData.count++
          
          if (patternData.count >= trigger.triggerCount) {
            patternData.triggered = true
            this.storyFlags[trigger.storyFlag] = true
            
            // Return discovery notification
            return {
              discovered: true,
              message: trigger.message
            }
          }
        }
      }
    })
    
    return { discovered: false }
  }

  // V1-style tiered progression system
  initializeProgressionTiers() {
    this.progressionTiers.set('RECRUIT', {
      level: 1,
      title: 'Security Recruit',
      description: 'Learning basic system navigation and file operations',
      requirements: {
        commands: ['pwd', 'ls', 'cd', 'cat'],
        discoveries: 0,
        storyFlags: []
      },
      unlocks: ['Basic terminal access', 'File examination capabilities'],
      nextTier: 'ANALYST'
    })

    this.progressionTiers.set('ANALYST', {
      level: 2, 
      title: 'Junior Security Analyst',
      description: 'Conducting system investigation and process analysis',
      requirements: {
        commands: ['pwd', 'ls', 'cd', 'cat', 'ps', 'netstat'],
        discoveries: 1,
        storyFlags: ['found_admin_note']
      },
      unlocks: ['Network service discovery', 'Process investigation', 'Hidden terminal scanning'],
      nextTier: 'INVESTIGATOR'
    })

    this.progressionTiers.set('INVESTIGATOR', {
      level: 3,
      title: 'Digital Forensics Investigator', 
      description: 'Advanced investigation techniques and evidence analysis',
      requirements: {
        commands: ['nc-discover-services', 'nc-scan-ports'],
        discoveries: 3,
        storyFlags: ['found_admin_note', 'discovered_network', 'discovered_intruder_traces']
      },
      unlocks: ['Hidden terminal access', 'Evidence analysis', 'Cryptographic tools'],
      nextTier: 'SPECIALIST'
    })

    this.progressionTiers.set('SPECIALIST', {
      level: 4,
      title: 'Cybersecurity Specialist',
      description: 'Expert-level threat hunting and incident response',
      requirements: {
        commands: ['nc-evidence', 'nc-decrypt'],
        discoveries: 5,
        storyFlags: ['found_encrypted_files', 'decoded_architect_messages']
      },
      unlocks: ['Advanced investigation tools', 'Incident response capabilities', 'Suspect analysis'],
      nextTier: 'ARCHITECT'
    })

    this.progressionTiers.set('ARCHITECT', {
      level: 5,
      title: 'The New Architect',
      description: 'Master investigator with full access to The Architect\'s legacy',
      requirements: {
        commands: ['nc-suspects', 'nc-contact', 'shadow-protocol'],
        discoveries: 8,
        storyFlags: ['learned_company_conspiracy', 'conspiracy_unraveled']
      },
      unlocks: ['Complete investigation suite', 'Shadow protocol access', 'All hidden terminals'],
      nextTier: null // Maximum tier
    })
  }

  // Check and update player progression tier
  checkProgressionAdvancement() {
    const currentTier = this.getCurrentTier()
    const nextTierName = currentTier.nextTier
    
    if (!nextTierName) return null // Already at max tier
    
    const nextTier = this.progressionTiers.get(nextTierName)
    if (this.meetsRequirements(nextTier.requirements)) {
      return this.advanceToTier(nextTierName)
    }
    
    return null
  }

  getCurrentTier() {
    // Find current tier based on player progress
    const tierNames = ['RECRUIT', 'ANALYST', 'INVESTIGATOR', 'SPECIALIST', 'ARCHITECT']
    
    for (let i = tierNames.length - 1; i >= 0; i--) {
      const tier = this.progressionTiers.get(tierNames[i])
      if (this.meetsRequirements(tier.requirements)) {
        return tier
      }
    }
    
    return this.progressionTiers.get('RECRUIT') // Default fallback
  }

  meetsRequirements(requirements) {
    // Check command requirements
    const hasCommands = requirements.commands.every(cmd => 
      this.commandsLearned.has(cmd) || this.discoveredCommands.has(cmd)
    )
    
    // Check discovery count
    const hasDiscoveries = this.discoveries.length >= requirements.discoveries
    
    // Check story flags
    const hasStoryFlags = requirements.storyFlags.every(flag => 
      this.storyFlags[flag] === true
    )
    
    return hasCommands && hasDiscoveries && hasStoryFlags
  }

  advanceToTier(tierName) {
    const tier = this.progressionTiers.get(tierName)
    this.player.tier = tier.level
    this.player.title = tier.title
    
    return {
      advanced: true,
      tier: tier,
      message: `
╔══════════════════════════════════════════════════════════════════════════════╗
║                           🎖️  TIER ADVANCEMENT                              ║
║                         Congratulations, Recruit!                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 NEW RANK: ${tier.title.toUpperCase().padEnd(62)} ║
║ 📊 TIER LEVEL: ${tier.level.toString().padEnd(64)} ║
║                                                                              ║
║ 📋 DESCRIPTION:                                                             ║
║ ${tier.description.padEnd(76)} ║
║                                                                              ║
║ 🔓 NEWLY UNLOCKED CAPABILITIES:                                             ║
${tier.unlocks.map(unlock => `║ • ${unlock.padEnd(74)} ║`).join('\n')}
║                                                                              ║
║ 🎓 You have demonstrated mastery of essential cybersecurity skills and      ║
║ proven worthy of The Architect's advanced training protocols.               ║
║                                                                              ║
║ ${tier.nextTier ? `💫 NEXT GOAL: Advance to ${tier.nextTier} level` : '👑 MAXIMUM TIER ACHIEVED - You are now The New Architect!'.padEnd(70)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

🌟 Your investigation skills have evolved. New mysteries await your expertise.`
    }
  }

  // Initialize investigation journal and command reference system
  initializeJournalAndReference() {
    // Investigation journal entries
    this.investigationJournal.set('welcome', {
      title: 'Investigation Initiated',
      timestamp: new Date().toISOString(),
      content: `
📋 CASE FILE: The Architect Investigation
=====================================
Missing Person: Marcus "The Architect" Sullivan
Missing Asset: $45 million
Status: Active Investigation

Initial briefing received. Subject was last seen in digital workspace.
Evidence suggests inside job. Beginning systematic investigation.

Next Steps:
• Establish location and survey crime scene
• Document all evidence found
• Follow digital breadcrumbs left by The Architect`,
      category: 'briefing'
    })

    // Command reference system (built-in man pages)
    this.initializeCommandReference()
  }

  initializeCommandReference() {
    this.commandReference.set('pwd', {
      name: 'pwd',
      description: 'print working directory',
      synopsis: 'pwd [OPTION]...',
      explanation: `The pwd command prints the full pathname of the current working directory.
      
In cybersecurity investigations, knowing your current location is crucial for:
• Establishing chain of custody for digital evidence
• Understanding directory structures attackers may have accessed
• Navigating complex file systems during incident response`,
      examples: [
        'pwd                 # Show current directory',
        'pwd -P              # Show physical path (resolve symlinks)'
      ],
      securityContext: 'Essential first step in any digital forensics investigation'
    })

    this.commandReference.set('ls', {
      name: 'ls',
      description: 'list directory contents',
      synopsis: 'ls [OPTION]... [FILE]...',
      explanation: `List directory contents. Critical for evidence discovery and file analysis.

Useful options for investigators:
• -l : Long format (permissions, ownership, timestamps)
• -a : Show hidden files (attackers often hide files with . prefix)
• -t : Sort by modification time (find recently changed files)
• -h : Human readable file sizes`,
      examples: [
        'ls                  # Basic listing',
        'ls -la              # Detailed listing with hidden files',
        'ls -lt              # Sort by modification time (newest first)',
        'ls -lah             # Human readable, all files, detailed'
      ],
      securityContext: 'Use -la to find hidden malware and -lt to identify recently modified files'
    })

    this.commandReference.set('cat', {
      name: 'cat',
      description: 'concatenate and display file contents',
      synopsis: 'cat [OPTION]... [FILE]...',
      explanation: `Display file contents. Primary tool for examining evidence files, logs, and configuration.

Safe for read-only evidence examination. Preserves original file integrity.`,
      examples: [
        'cat filename.txt           # Display file contents',
        'cat /var/log/auth.log      # View authentication logs',
        'cat admin_notes.txt        # Read investigation notes'
      ],
      securityContext: 'Read-only operation safe for evidence preservation. Use to examine log files and configurations.'
    })

    this.commandReference.set('ps', {
      name: 'ps',
      description: 'report a snapshot of current processes',
      synopsis: 'ps [options]',
      explanation: `Display information about running processes. Critical for identifying:
• Malware and suspicious processes
• Resource-intensive attacks
• Unauthorized services
• Backdoors and persistence mechanisms`,
      examples: [
        'ps                  # Show processes for current user',
        'ps aux              # Show all processes with detailed info',
        'ps aux | grep ssh   # Find SSH-related processes',
        'ps -ef              # Full format listing'
      ],
      securityContext: 'Look for processes with unusual names, high CPU usage, or running as unexpected users'
    })

    this.commandReference.set('netstat', {
      name: 'netstat',
      description: 'print network connections, routing tables, interface statistics',
      synopsis: 'netstat [options]',
      explanation: `Display network connections and listening ports. Essential for:
• Identifying backdoors and remote access
• Finding suspicious network activity  
• Mapping active services
• Detecting unauthorized connections`,
      examples: [
        'netstat -tulpn      # Show all listening ports with process info',
        'netstat -an         # Show all connections and ports',
        'netstat -i          # Show network interface statistics'
      ],
      securityContext: 'Check for unexpected listening ports and foreign connections that may indicate compromise'
    })

    this.commandReference.set('nc-scan-ports', {
      name: 'nc-scan-ports',
      description: 'Network Chronicles advanced port scanner',
      synopsis: 'nc-scan-ports',
      explanation: `Specialized investigation tool that scans for both standard services and hidden terminals
left by The Architect. Discovers investigation capabilities beyond standard network tools.

This tool integrates your real system services with the investigation storyline,
providing context for each discovered service.`,
      examples: [
        'nc-scan-ports       # Scan for services and hidden terminals'
      ],
      securityContext: 'Use to discover hidden investigation tools and analyze real system services for threats'
    })

    this.commandReference.set('nc-investigate', {
      name: 'nc-investigate',
      description: 'investigate specific evidence types',
      synopsis: 'nc-investigate <evidence_type>',
      explanation: `Advanced investigation tool for analyzing different types of digital evidence.
      
Available evidence types:
• logs - Examine system and security logs for tampering
• network - Analyze network traffic patterns  
• files - Search for hidden or encrypted files
• access - Review access logs and user activity
• timeline - Reconstruct event timeline
• motives - Investigate potential motives`,
      examples: [
        'nc-investigate logs     # Check for deleted log entries',
        'nc-investigate network  # Analyze suspicious traffic',
        'nc-investigate access   # Review authentication logs'
      ],
      securityContext: 'Follow The Architect\'s investigation methodology to uncover evidence of the breach'
    })

    this.commandReference.set('grep', {
      name: 'grep',
      description: 'search text patterns in files',
      synopsis: 'grep [options] pattern [file...]',
      explanation: `Search for specific patterns in files. Essential for log analysis and evidence discovery.

Key security options:
• -i : Case insensitive search
• -r : Recursive search through directories
• -n : Show line numbers
• -v : Invert match (show lines that DON'T match)`,
      examples: [
        'grep "failed" /var/log/auth.log    # Find failed login attempts',
        'grep -i "error" /var/log/syslog    # Case-insensitive error search',
        'ps aux | grep ssh                  # Find SSH processes'
      ],
      securityContext: 'Critical for analyzing logs, finding attack indicators, and pattern matching in evidence'
    })

    this.commandReference.set('nc-journal', {
      name: 'nc-journal',
      description: 'investigation notebook and evidence tracker',
      synopsis: 'nc-journal [subcommand]',
      explanation: `Your digital detective notebook. Automatically tracks discoveries and provides investigation guidance.

Subcommands:
• (no args) - Show journal summary
• list - Show all journal entries
• evidence - Show collected evidence
• leads - Show active investigation leads`,
      examples: [
        'nc-journal              # Show journal summary',
        'nc-journal leads        # See what to investigate next',
        'nc-journal evidence     # Review collected evidence'
      ],
      securityContext: 'Essential tool for tracking investigation progress and maintaining evidence chain of custody'
    })
  }

  // Add journal entry
  addJournalEntry(title, content, category = 'investigation') {
    const entry = {
      title,
      timestamp: new Date().toISOString(),
      content,
      category
    }
    
    const entryId = `entry_${Date.now()}`
    this.investigationJournal.set(entryId, entry)
    
    return entryId
  }

  // Show investigation journal
  showJournal(args) {
    if (!args.length) {
      // Show journal summary
      const entries = Array.from(this.investigationJournal.values())
        .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))

      let journalOutput = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📋 INVESTIGATION JOURNAL                             ║
║                     Your Digital Detective Notebook                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📊 CASE SUMMARY:                                                            ║
║ • Total Entries: ${entries.length.toString().padEnd(63)} ║
║ • Evidence Collected: ${this.evidenceLog.length.toString().padEnd(59)} ║
║ • Investigation Progress: ${Object.values(this.storyFlags).filter(f => f).length}/15 milestones        ║
║                                                                              ║
║ 📝 RECENT ENTRIES:                                                          ║`

      entries.slice(0, 5).forEach((entry, index) => {
        const timestamp = new Date(entry.timestamp).toLocaleString()
        journalOutput += `
║ ${(index + 1).toString().padStart(2)}. ${entry.title.padEnd(67)} ║
║     ${timestamp.padEnd(71)} ║`
      })

      journalOutput += `
║                                                                              ║
║ 💡 USAGE:                                                                   ║
║ • 'nc-journal list' - Show all entries                                     ║
║ • 'nc-journal 1' - Read specific entry by number                            ║
║ • 'nc-journal evidence' - Show collected evidence                           ║
║ • 'nc-journal leads' - Show active investigation leads                      ║
╚══════════════════════════════════════════════════════════════════════════════╝

📖 Your investigation record. Use this to track clues and progress.`

      return { output: journalOutput, type: 'info' }
    }

    const subcommand = args[0].toLowerCase()
    
    // Check if it's a number (reading specific entry)
    const entryNumber = parseInt(subcommand)
    if (!isNaN(entryNumber) && entryNumber > 0) {
      return this.showJournalEntry(entryNumber)
    }
    
    switch (subcommand) {
      case 'list':
        return this.showAllJournalEntries()
      case 'evidence':
        return this.showEvidenceLog()
      case 'leads':
        return this.showActiveLeads()
      default:
        return {
          output: `Unknown journal command: ${subcommand}\n\nAvailable: list, evidence, leads, or entry number (e.g., nc-journal 1)`,
          type: 'error'
        }
    }
  }

  showJournalEntry(entryNumber) {
    const entries = Array.from(this.investigationJournal.values())
      .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp))
    
    if (entryNumber > entries.length) {
      return {
        output: `❌ Entry ${entryNumber} does not exist. You have ${entries.length} journal entries.\n\nUse 'nc-journal list' to see all entries.`,
        type: 'error'
      }
    }
    
    const entry = entries[entryNumber - 1]
    const timestamp = new Date(entry.timestamp).toLocaleString()
    
    let output = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                       📖 JOURNAL ENTRY #${entryNumber.toString().padStart(2)}                           ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ TITLE: ${entry.title.padEnd(71)} ║
║ DATE: ${timestamp.padEnd(72)} ║
║ CATEGORY: ${entry.category.padEnd(68)} ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    // Format the content with proper line wrapping
    const contentLines = entry.content.split('\n')
    contentLines.forEach(line => {
      if (line.trim()) {
        // Split long lines to fit in the box
        const words = line.trim().split(' ')
        let currentLine = '║ '
        
        words.forEach(word => {
          if (currentLine.length + word.length + 1 <= 78) {
            currentLine += (currentLine === '║ ' ? '' : ' ') + word
          } else {
            output += `\n${currentLine.padEnd(78)} ║`
            currentLine = '║ ' + word
          }
        })
        
        if (currentLine !== '║ ') {
          output += `\n${currentLine.padEnd(78)} ║`
        }
      } else {
        output += `\n║${' '.repeat(76)}║`
      }
    })

    output += `
╚══════════════════════════════════════════════════════════════════════════════╝

📝 Entry ${entryNumber} of ${entries.length}. Use 'nc-journal list' to see all entries.`

    return { output, type: 'info' }
  }

  // Show command reference (man pages)
  showCommandReference(args) {
    if (!args.length) {
      // Show available man pages
      const commands = Array.from(this.commandReference.keys())
      
      let manOutput = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📖 COMMAND REFERENCE MANUAL                          ║
║                   Built-in Documentation & Learning                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📚 AVAILABLE DOCUMENTATION:                                                 ║
║                                                                              ║`

      commands.forEach(cmd => {
        const ref = this.commandReference.get(cmd)
        manOutput += `
║ • ${cmd.padEnd(20)} - ${ref.description.padEnd(49)} ║`
      })

      manOutput += `
║                                                                              ║
║ 💡 USAGE:                                                                   ║
║ • 'man <command>' - Show detailed help for specific command                 ║
║ • 'nc-man <command>' - Alternative syntax                                   ║
║                                                                              ║
║ 🎓 EXAMPLES:                                                                ║
║ • 'man ls' - Learn about listing files and security tips                   ║
║ • 'man nc-scan-ports' - Investigation tool documentation                    ║
╚══════════════════════════════════════════════════════════════════════════════╝

📘 Your investigation reference manual. Learn commands with security context!`

      return { output: manOutput, type: 'info' }
    }

    const command = args[0].toLowerCase()
    const ref = this.commandReference.get(command)
    
    if (!ref) {
      return {
        output: `No manual entry for '${command}'\n\nUse 'man' without arguments to see available documentation.`,
        type: 'error'
      }
    }

    const manPage = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📖 MANUAL: ${ref.name.toUpperCase().padEnd(58)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ NAME                                                                         ║
║ ${ref.name} - ${ref.description.padEnd(70)} ║
║                                                                              ║
║ SYNOPSIS                                                                     ║
║ ${ref.synopsis.padEnd(76)} ║
║                                                                              ║
║ DESCRIPTION                                                                  ║
${ref.explanation.split('\n').map(line => `║ ${line.padEnd(76)} ║`).join('\n')}
║                                                                              ║
║ EXAMPLES                                                                     ║
${ref.examples.map(example => `║ ${example.padEnd(76)} ║`).join('\n')}
║                                                                              ║
║ SECURITY CONTEXT                                                             ║
║ ${ref.securityContext.padEnd(76)} ║
╚══════════════════════════════════════════════════════════════════════════════╝

📚 Part of Network Chronicles investigation training system.`

    return { output: manPage, type: 'info' }
  }

  showAllJournalEntries() {
    const entries = Array.from(this.investigationJournal.values())
      .sort((a, b) => new Date(a.timestamp) - new Date(b.timestamp))

    let output = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        📋 COMPLETE INVESTIGATION LOG                        ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    entries.forEach((entry, index) => {
      const timestamp = new Date(entry.timestamp).toLocaleString()
      output += `
║                                                                              ║
║ Entry ${(index + 1).toString().padStart(2)}: ${entry.title.padEnd(60)} ║
║ Time: ${timestamp.padEnd(68)} ║
║ Category: ${entry.category.padEnd(67)} ║
║                                                                              ║
${entry.content.split('\n').slice(0, 3).map(line => `║ ${line.trim().padEnd(76)} ║`).join('\n')}`
    })

    output += `
╚══════════════════════════════════════════════════════════════════════════════╝`

    return { output, type: 'info' }
  }

  showEvidenceLog() {
    let output = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🔍 EVIDENCE COLLECTION LOG                           ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    if (this.evidenceLog.length === 0) {
      output += `
║ No evidence collected yet.                                                   ║
║                                                                              ║
║ 💡 Evidence is discovered through investigation commands like:              ║
║ • nc-investigate logs                                                       ║
║ • nc-scan-ports                                                             ║
║ • Reading system files and admin notes                                      ║`
    } else {
      this.evidenceLog.forEach((evidence, index) => {
        output += `
║ ${(index + 1).toString().padStart(2)}. ${evidence.name.padEnd(67)} ║
║     ${evidence.description.padEnd(71)} ║`
      })
    }

    output += `
╚══════════════════════════════════════════════════════════════════════════════╝`

    return { output, type: 'info' }
  }

  showActiveLeads() {
    const leads = []
    
    // Generate leads based on current progress
    if (!this.storyFlags.found_admin_note) {
      leads.push("📋 Read The Architect's admin notes for investigation briefing")
    }
    
    if (this.storyFlags.found_admin_note && !this.storyFlags.discovered_network) {
      leads.push("🌐 Investigate 'hidden monitoring ports' mentioned in notes")
      leads.push("🔍 Use nc-scan-ports to find The Architect's hidden tools")
    }
    
    if (this.storyFlags.discovered_network && !this.storyFlags.discovered_intruder_traces) {
      leads.push("📊 Check deleted log entries: nc-investigate logs")
      leads.push("🕵️ Look for signs of insider access and unauthorized activity")
    }

    if (this.hiddenTerminals && Array.from(this.hiddenTerminals.values()).some(t => t.discovered && !this.discoveredCommands.has(t.accessCommand))) {
      leads.push("🔐 Access discovered hidden terminals with passwords from evidence")
    }

    let output = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                        🎯 ACTIVE INVESTIGATION LEADS                        ║
╠══════════════════════════════════════════════════════════════════════════════╣`

    if (leads.length === 0) {
      output += `
║ 🎉 No active leads - investigation may be complete!                         ║
║                                                                              ║
║ Check 'nc-tier' to see your investigator progression.                       ║`
    } else {
      leads.forEach(lead => {
        output += `
║ ${lead.padEnd(76)} ║`
      })
    }

    output += `
╚══════════════════════════════════════════════════════════════════════════════╝`

    return { output, type: 'info' }
  }

  async scanHiddenPorts() {
    if (!this.storyFlags.discovered_network) {
      return {
        output: `🌐 PORT SCAN BLOCKED

Network discovery capabilities required. Complete network reconnaissance first.

💡 Use 'nc-discover-services' and 'nc-map-network' to unlock advanced scanning.`,
        type: 'warning'
      }
    }

    // Get real system services for authentic integration
    const realServices = await this.systemIntegration.discoverRealServices()
    const realPortsDisplay = realServices.length > 0 ? 
      realServices.slice(0, 5).map(s => `${s.port}/${s.name}`).join(', ') : 
      'Standard services (22/SSH, 80/HTTP)'

    let scanResults = `
╔══════════════════════════════════════════════════════════════════════════════╗
║                          🔍 ADVANCED PORT SCANNER                          ║
║                    Real System + Hidden Service Discovery                   ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 TARGET: localhost + your actual system                                  ║
║ 🔍 SCAN TYPE: Deep enumeration with service fingerprinting                 ║
║ ⚡ STATUS: Scanning real services + hidden investigation terminals          ║
║                                                                              ║
║ 📊 REAL SERVICES DETECTED: ${realPortsDisplay.padEnd(45)} ║
║ 🕵️ HIDDEN ARCHITECT SERVICES:                                              ║`

    let foundNewServices = false

    Array.from(this.hiddenTerminals.entries()).forEach(([port, terminal]) => {
      const portNum = port.replace('port_', '')
      
      // Progressive discovery based on story progress
      let canDiscover = false
      
      if (portNum === '2187' && this.storyFlags.found_admin_note) canDiscover = true
      if (portNum === '3133' && this.storyFlags.found_encrypted_files) canDiscover = true
      if (portNum === '5150' && this.storyFlags.discovered_intruder_traces) canDiscover = true
      if (portNum === '8080' && this.storyFlags.decoded_architect_messages) canDiscover = true
      if (portNum === '7734' && this.evidenceLog.length >= 2) canDiscover = true
      if (portNum === '9999' && this.storyFlags.learned_company_conspiracy) canDiscover = true
      
      if (canDiscover && !terminal.discovered) {
        terminal.discovered = true
        foundNewServices = true
        
        scanResults += `
║                                                                              ║
║ 🔓 PORT ${portNum}/tcp - OPEN                                                  ║
║    Service: ${terminal.displayName.padEnd(58)} ║
║    Status: Hidden terminal discovered                                       ║
║    Access: nc-access-terminal ${portNum.padEnd(48)} ║`
      } else if (terminal.discovered) {
        const statusIcon = this.discoveredCommands.has(terminal.accessCommand) ? '✅' : '🔐'
        const statusText = this.discoveredCommands.has(terminal.accessCommand) ? 'UNLOCKED' : 'LOCKED'
        
        scanResults += `
║                                                                              ║
║ ${statusIcon} PORT ${portNum}/tcp - ${statusText.padEnd(56)} ║
║    Service: ${terminal.displayName.padEnd(58)} ║
║    Access: ${terminal.accessCommand.padEnd(62)} ║`
      }
    })

    // Add real system services section
    if (realServices.length > 0) {
      scanResults += `
║                                                                              ║
║ 🖥️  REAL SYSTEM SERVICES (your actual machine):                            ║`
      
      realServices.slice(0, 3).forEach(service => {
        const suspicionIcon = service.suspicionLevel === 'HIGH' ? '🚨' : 
                             service.suspicionLevel === 'MEDIUM' ? '⚠️' : '✅'
        scanResults += `
║ ${suspicionIcon} PORT ${service.port}/tcp - ${service.name.padEnd(52)} ║
║    Investigation: ${service.investigationNote.substring(0, 58).padEnd(58)} ║`
      })
      
      if (realServices.length > 3) {
        scanResults += `
║    └─ ${(realServices.length - 3)} more services discovered...                ║`
      }
    }

    if (!foundNewServices && Array.from(this.hiddenTerminals.values()).every(t => !t.discovered)) {
      scanResults += `
║                                                                              ║
║ ⚠️  No hidden services detected at current investigation level               ║
║ 💡 Continue investigation to unlock advanced scanning capabilities          ║`
    }

    scanResults += `
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🔐 SECURITY NOTICE:                                                         ║
║ Hidden terminals require authentication. Access credentials must be         ║
║ discovered through investigation. Each terminal contains specialized         ║
║ tools for specific aspects of The Architect investigation.                  ║
║                                                                              ║
║ 💡 NEXT STEPS:                                                              ║
║ • Use 'nc-access-terminal <port>' to attempt terminal access               ║
║ • Discover passwords through investigation evidence                          ║
║ • Each unlocked terminal provides new capabilities                          ║
╚══════════════════════════════════════════════════════════════════════════════╝

${foundNewServices ? '🎯 New hidden services discovered! The Architect\'s network is more complex than expected.' : '🔍 Continue investigating to discover more hidden systems.'}`

    return {
      output: scanResults,
      type: foundNewServices ? 'success' : 'info'
    }
  }

  accessHiddenTerminal(args) {
    if (!args.length) {
      return {
        output: `🔐 TERMINAL ACCESS

Usage: nc-access-terminal <port>

Discovered terminals:
${Array.from(this.hiddenTerminals.entries())
  .filter(([_, terminal]) => terminal.discovered)
  .map(([port, terminal]) => `• ${port.replace('port_', '')} - ${terminal.displayName}`)
  .join('\n') || '• No terminals discovered yet - use nc-scan-ports'}

Example: nc-access-terminal 2187`,
        type: 'info'
      }
    }

    const port = `port_${args[0]}`
    const terminal = this.hiddenTerminals.get(port)

    if (!terminal) {
      return {
        output: `❌ No terminal found on port ${args[0]}.\n\nUse 'nc-scan-ports' to discover hidden services.`,
        type: 'error'
      }
    }

    if (!terminal.discovered) {
      return {
        output: `🔒 Port ${args[0]} appears closed.\n\nAdvance your investigation to discover hidden services on this port.`,
        type: 'warning'
      }
    }

    if (this.discoveredCommands.has(terminal.accessCommand)) {
      return {
        output: `✅ Terminal on port ${args[0]} is already unlocked.\n\nUse '${terminal.accessCommand}' to access terminal features.`,
        type: 'info'
      }
    }

    if (!terminal.requiresPassword) {
      // Auto-unlock based on investigation progress
      this.discoveredCommands.add(terminal.accessCommand)
      this.updateHelpWithNewCommand(terminal.accessCommand, terminal.description)
      
      return {
        output: `🔓 TERMINAL ACCESS GRANTED

╔══════════════════════════════════════════════════════════════════════════════╗
║                          ✅ ACCESS SUCCESSFUL                              ║
║                         ${terminal.displayName.padEnd(48)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 TERMINAL UNLOCKED: Port ${args[0].padEnd(52)} ║
║ 🔧 NEW COMMAND AVAILABLE: ${terminal.accessCommand.padEnd(49)} ║
║                                                                              ║
║ ${terminal.unlockMessage.padEnd(76)} ║
║                                                                              ║
║ 💡 The command '${terminal.accessCommand}' is now available in your command suite.     ║
╚══════════════════════════════════════════════════════════════════════════════╝

🚀 New capabilities unlocked! Check 'help' to see updated command list.`,
        type: 'success'
      }
    }

    // Password-protected terminal
    return {
      output: `🔐 AUTHENTICATION REQUIRED

╔══════════════════════════════════════════════════════════════════════════════╗
║                        🔐 SECURE TERMINAL ACCESS                           ║
║                         ${terminal.displayName.padEnd(48)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🚨 SECURITY PROTOCOL ACTIVE                                                ║
║                                                                              ║
║ This terminal requires authentication credentials. The password must        ║
║ be discovered through investigation of The Architect's activities.          ║
║                                                                              ║
║ 🔍 AUTHENTICATION HINTS:                                                    ║
║ • Examine The Architect's notes and communications                          ║
║ • Decrypt hidden messages found in system logs                              ║
║ • Look for keywords in investigation evidence                               ║
║                                                                              ║
║ 🎯 PASSWORD PROMPT:                                                         ║
║ Enter access credentials: _                                                  ║
║                                                                              ║
║ 💡 Format: nc-access-terminal ${args[0]} <password>                                  ║
║ Example: nc-access-terminal ${args[0]} secret_phrase                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔐 Find the password through investigation to unlock advanced capabilities.`,
      type: 'warning'
    }
  }

  accessHiddenTerminal(args) {
    if (!args.length) {
      return this.accessHiddenTerminal(['help'])
    }

    if (args[0] === 'help') {
      return {
        output: `🔐 TERMINAL ACCESS

Usage: nc-access-terminal <port> [password]

Discovered terminals:
${Array.from(this.hiddenTerminals.entries())
  .filter(([_, terminal]) => terminal.discovered)
  .map(([port, terminal]) => `• ${port.replace('port_', '')} - ${terminal.displayName}`)
  .join('\n') || '• No terminals discovered yet - use nc-scan-ports'}

Example: nc-access-terminal 2187 password123`,
        type: 'info'
      }
    }

    const port = `port_${args[0]}`
    const terminal = this.hiddenTerminals.get(port)
    const providedPassword = args.slice(1).join(' ')

    if (!terminal || !terminal.discovered) {
      return {
        output: `❌ No accessible terminal found on port ${args[0]}.\n\nUse 'nc-scan-ports' to discover hidden services.`,
        type: 'error'
      }
    }

    if (this.discoveredCommands.has(terminal.accessCommand)) {
      return {
        output: `✅ Terminal on port ${args[0]} is already unlocked.\n\nUse '${terminal.accessCommand}' to access terminal features.`,
        type: 'info'
      }
    }

    // Check password if required
    if (terminal.requiresPassword) {
      if (!providedPassword) {
        return this.showPasswordPrompt(args[0], terminal)
      }

      if (providedPassword !== terminal.password) {
        return {
          output: `🚨 ACCESS DENIED

╔══════════════════════════════════════════════════════════════════════════════╗
║                           ❌ AUTHENTICATION FAILED                         ║
║                                                                              ║
║ Incorrect credentials provided for terminal on port ${args[0].padEnd(23)} ║
║                                                                              ║
║ 🔐 Security lockout initiated. Further investigation required to            ║
║    discover the correct access credentials.                                 ║
║                                                                              ║
║ 💡 Hint: The password is hidden in The Architect's investigation trail.    ║
║    Look for patterns in decrypted messages and evidence.                    ║
╚══════════════════════════════════════════════════════════════════════════════╝`,
          type: 'error'
        }
      }
    }

    // Successful access
    this.discoveredCommands.add(terminal.accessCommand)
    this.updateHelpWithNewCommand(terminal.accessCommand, terminal.description)

    if (terminal.accessCommand === 'nc-architect-shell') {
      this.architectTerminalAccess = true
    }

    return {
      output: `🔓 TERMINAL ACCESS GRANTED

╔══════════════════════════════════════════════════════════════════════════════╗
║                          ✅ AUTHENTICATION SUCCESSFUL                      ║
║                         ${terminal.displayName.padEnd(48)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 TERMINAL UNLOCKED: Port ${args[0].padEnd(52)} ║
║ 🔧 NEW COMMAND AVAILABLE: ${terminal.accessCommand.padEnd(49)} ║
║                                                                              ║
║ ${terminal.unlockMessage.padEnd(76)} ║
║                                                                              ║
║ 🚀 Advanced investigation capabilities now online.                         ║
║ 💡 Use '${terminal.accessCommand}' to access specialized features.                    ║
║                                                                              ║
║ 🎭 The Architect's digital trail grows deeper...                           ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔍 New command unlocked! Type 'help' to see updated available commands.`,
      type: 'success'
    }
  }

  showPasswordPrompt(port, terminal) {
    return {
      output: `🔐 AUTHENTICATION REQUIRED

╔══════════════════════════════════════════════════════════════════════════════╗
║                        🔐 SECURE TERMINAL ACCESS                           ║
║                         ${terminal.displayName.padEnd(48)} ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🚨 SECURITY PROTOCOL ACTIVE                                                ║
║                                                                              ║
║ This terminal requires authentication credentials. The password must        ║
║ be discovered through investigation of The Architect's activities.          ║
║                                                                              ║
║ 🔍 AUTHENTICATION HINTS:                                                    ║
║ • Examine The Architect's notes and communications                          ║
║ • Decrypt hidden messages found in system logs                              ║
║ • Look for keywords in investigation evidence                               ║
║                                                                              ║
║ 🎯 PASSWORD PROMPT:                                                         ║
║ Enter access credentials: _                                                  ║
║                                                                              ║
║ 💡 Format: nc-access-terminal ${port} <password>                                  ║
║ Example: nc-access-terminal ${port} secret_phrase                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

🔐 Find the password through investigation to unlock advanced capabilities.`,
      type: 'warning'
    }
  }

  commandNotFound(cmd) {
    return {
      output: `Command '${cmd}' not found. Type 'help' for available commands.

💡 Some advanced commands are discovered through investigation.
🔍 Use 'nc-scan-ports' to discover hidden systems and capabilities.`,
      type: 'error'
    }
  }

  updateHelpWithNewCommand(command, description) {
    // This could update the help dynamically, but for now we'll just track discovered commands
    console.log(`New command discovered: ${command} - ${description}`)
  }

  accessArchitectShell() {
    return {
      output: `🎭 THE ARCHITECT'S MASTER SHELL

╔══════════════════════════════════════════════════════════════════════════════╗
║                        👑 ARCHITECT MASTER CONTROL                         ║
║                          Highest Security Clearance                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 🎯 Welcome to The Architect's primary command interface.                   ║
║                                                                              ║
║ This terminal provides access to the complete investigation suite           ║
║ and reveals the final layers of the conspiracy.                             ║
║                                                                              ║
║ 🔧 AVAILABLE SUBSYSTEMS:                                                    ║
║ • nc-revelation - Trigger final story revelations                          ║
║ • shadow-protocol - Ultra-secure communication protocol                    ║
║ • All previously unlocked investigation tools                               ║
║                                                                              ║
║ 💀 CLASSIFIED ACCESS GRANTED:                                               ║
║ You now have access to the deepest secrets of the conspiracy.              ║
║ The final truth about The Architect's fate awaits your discovery.          ║
║                                                                              ║
║ 🎭 "Welcome, recruit. You've proven yourself worthy of the truth.          ║
║     The game is more complex than you imagined..." - The Architect         ║
╚══════════════════════════════════════════════════════════════════════════════╝

👑 Master access granted. All investigation capabilities now online.`,
      type: 'success'
    }
  }

  initiateShadowProtocol() {
    if (!this.storyFlags.learned_company_conspiracy) {
      return {
        output: `🔒 SHADOW PROTOCOL - ACCESS DENIED

Insufficient investigation progress. Complete corporate conspiracy exposure first.`,
        type: 'warning'
      }
    }

    this.storyFlags.conspiracy_unraveled = true
    
    return {
      output: `🌟 SHADOW PROTOCOL INITIATED

╔══════════════════════════════════════════════════════════════════════════════╗
║                        🌟 SHADOW PROTOCOL ACTIVATED                        ║
║                          Ultra-Secure Communication                         ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ 📡 ESTABLISHING SECURE CONNECTION...                                       ║
║ 🔐 ENCRYPTION: QUANTUM-LEVEL SECURITY                                      ║
║ 🎭 CONTACT: THE ARCHITECT (VERIFIED ALIVE)                                 ║
║                                                                              ║
║ 💬 INCOMING MESSAGE:                                                        ║
║ "Congratulations, recruit. You've successfully unraveled the entire        ║
║  conspiracy and proven yourself worthy of the final truth.                 ║
║                                                                              ║
║  I am very much alive and have been watching your investigation from       ║
║  the shadows. Every clue, every discovery was carefully orchestrated       ║
║  to test your abilities and ensure you could handle the complete truth.    ║
║                                                                              ║
║  The corruption runs deeper than even you know. The stolen $45 million     ║
║  was being used to fund a massive data trafficking operation selling       ║
║  customer information to hostile foreign governments.                      ║
║                                                                              ║
║  Your investigation has provided the evidence needed to bring down not     ║
║  just our corrupt board, but an entire international criminal network.     ║
║                                                                              ║
║  Justice will be served. Thank you for completing my life's work."         ║
║                                                                              ║
║ 🏆 MISSION STATUS: COMPLETE                                                ║
║ 🎉 THE ARCHITECT INVESTIGATION: SOLVED                                     ║
╚══════════════════════════════════════════════════════════════════════════════╝

🎊 CONGRATULATIONS! You have successfully completed The Architect Investigation!
👑 The truth has been revealed and justice will prevail!`,
      type: 'success'
    }
  }

  checkTaskCompletion(command) {
    if (!this.shiftStatus.clockedIn || this.dailyTasks.length === 0) {
      return null
    }

    // Find matching tasks
    const matchedTasks = this.dailyTasks.filter(task => {
      if (task.completed) return false
      
      // Check if the command matches the task's required command
      const taskCmd = task.command.toLowerCase().trim()
      const userCmd = command.toLowerCase().trim()
      
      // Handle specific command patterns
      if (taskCmd.includes('df -h') && userCmd.includes('df')) return true
      if (taskCmd.includes('ps aux') && userCmd.includes('ps')) return true
      if (taskCmd.includes('cat network_logs.txt') && userCmd.includes('cat') && userCmd.includes('network_logs')) return true
      if (taskCmd.includes('cat admin_notes.txt') && userCmd.includes('cat') && userCmd.includes('admin_notes')) return true
      if (taskCmd.includes('ifconfig') && userCmd.includes('ifconfig')) return true
      
      return false
    })

    if (matchedTasks.length > 0) {
      // Complete the first matched task
      const task = matchedTasks[0]
      task.completed = true
      this.shiftStatus.tasksCompleted++
      this.shiftStatus.dailyXP += task.xpReward
      this.player.xp += task.xpReward

      return {
        taskCompleted: true,
        task: task,
        xpGained: task.xpReward,
        message: `✅ Task Complete: ${task.title} (+${task.xpReward} XP)`
      }
    }

    return null
  }

  showArchitectMessage() {
    return {
      output: `╭───────────────────────── TERMINAL SESSION #9341 ─────────────────────────╮
│                                                                           │
│  > SYSTEM: DECRYPTION SEQUENCE INITIATED                                  │
│  > SYSTEM: AUTHENTICATION REQUIRED                                        │
│  > USER: ████████████████                                                 │
│  > SYSTEM: ACCESS GRANTED - READING SECURE MESSAGE                        │
│                                                                           │
│  ============= BEGIN ENCRYPTED TRANSMISSION =============                 │
│                                                                           │
│  To my successor,                                                         │
│                                                                           │
│  █ If you're reading this, I've gone dark. Not by choice. You're          │
│  █ being watched. They don't know about this backdoor channel yet.        │
│                                                                           │
│  █ I discovered something in the network traffic. Something that          │
│  █ wasn't supposed to exist. They noticed me noticing.                    │
│                                                                           │
│  █ I've scattered breadcrumbs throughout the system - encrypted files,    │
│  █ hidden directories, traffic patterns that shouldn't exist. Follow      │
│  █ them, but be careful. Make it look like routine administration.        │
│                                                                           │
│  █ First task: Map the network. Learn its structure. Find the anomalies.  │
│  █ I built in security measures they don't know about.                    │
│                                                                           │
│  █ Use 'nc-add-discovery welcome_message' to acknowledge receipt.         │
│  █ This will activate dormant protocols I've hidden in the system.        │
│                                                                           │
│  █ Trust the patterns, not the explanations.                              │
│                                                                           │
│  - The Architect                                                          │
│                                                                           │
│  P.S. They're in the DNS traffic. That's how they're watching.            │
│                                                                           │
│  ============== END ENCRYPTED TRANSMISSION ==============                 │
│                                                                           │
│  > SYSTEM: MESSAGE WILL SELF-DESTRUCT IN 30 SECONDS                       │
│  > SYSTEM: RECOMMEND COMMITTING CRITICAL INFORMATION TO MEMORY            │
│  > SYSTEM: COUNTDOWN: 10...9...8...                                       │
│  > USER: save message                                                     │
│  > SYSTEM: UNAUTHORIZED COMMAND                                           │
│  > SYSTEM: 3...2...1...                                                   │
│  > SYSTEM: CONNECTION TERMINATED                                          │
│                                                                           │
╰───────────────────────────────────────────────────────────────────────────╯

🔍 INVESTIGATION NOTE: The Architect left this as a communication test. 
🎯 This dramatic message sets the stage for your investigation training.`,
      type: 'system'
    }
  }

  getShiftStatus() {
    return this.shiftStatus
  }
}

export default GameEngine