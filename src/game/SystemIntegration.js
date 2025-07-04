// SystemIntegration.js - Bridge between game and real system
class SystemIntegration {
  constructor() {
    this.isWebEnvironment = typeof window !== 'undefined'
    this.commandHistory = []
    this.currentDirectory = this.getUserHome()
    this.gameFileLocations = new Map()
    this.initializeGameFiles()
  }

  async executeRealCommand(command, args = []) {
    if (this.isWebEnvironment) {
      // Always try to use backend API for real system integration
      try {
        const response = await fetch('http://localhost:3003/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ command, args })
        })
        
        if (response.ok) {
          const result = await response.json()
          
          // For cd command, update our internal tracking
          if (command === 'cd' && result.type === 'success') {
            // Get the new directory from backend
            try {
              const pwdResponse = await fetch('http://localhost:3003/api/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: 'pwd', args: [] })
              })
              
              if (pwdResponse.ok) {
                const pwdResult = await pwdResponse.json()
                this.currentDirectory = pwdResult.output
              }
            } catch (pwdError) {
              // Ignore pwd errors
            }
          }
          
          // Enhanced ls command with game files
          if (command === 'ls' && result.type === 'normal') {
            try {
              const pwdResponse = await fetch('http://localhost:3003/api/execute', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: 'pwd', args: [] })
              })
              
              if (pwdResponse.ok) {
                const pwdResult = await pwdResponse.json()
                const enhanceResponse = await fetch('http://localhost:3003/api/enhance-ls', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({ 
                    output: result.output, 
                    currentDir: pwdResult.output 
                  })
                })
                
                if (enhanceResponse.ok) {
                  const enhanced = await enhanceResponse.json()
                  return { ...result, output: enhanced.output }
                }
              }
            } catch (enhanceError) {
              // Continue with original result if enhancement fails
            }
          }
          
          return result
        } else {
          console.log('Backend response not ok:', response.status)
        }
      } catch (error) {
        console.log('Backend API error:', error.message)
      }
      
      // Fallback to enhanced simulation only if backend truly fails
      console.log('Using fallback simulation for command:', command)
      return this.enhancedSimulation(command, args)
    } else {
      // In Node.js environment, we could use child_process
      // For now, simulate but with more realistic data
      return this.enhancedSimulation(command, args)
    }
  }

  async enhancedSimulation(command, args) {
    switch (command) {
      case 'pwd':
        return this.getRealCurrentDirectory()
      
      case 'ls':
        return this.getRealDirectoryListing(args[0])
      
      case 'cd':
        return this.handleCdSimulation(args)
      
      case 'ps':
        return this.getRealProcessList()
      
      case 'netstat':
        return this.getRealNetworkConnections()
      
      case 'ifconfig':
        return this.getRealNetworkInterfaces()
      
      case 'df':
        return this.getRealDiskUsage()
      
      case 'free':
        return this.getRealMemoryUsage()
      
      default:
        return { output: `Command '${command}' not implemented in system integration`, type: 'error' }
    }
  }

  getRealCurrentDirectory() {
    return {
      output: this.currentDirectory,
      type: 'normal'
    }
  }

  handleCdSimulation(args) {
    const targetPath = args && args.length > 0 ? args[0] : '~'
    
    // Handle special paths
    if (targetPath === '~' || targetPath === '') {
      this.currentDirectory = this.getUserHome()
    } else if (targetPath === '..') {
      // Go up one directory
      const parts = this.currentDirectory.split('/')
      if (parts.length > 2) { // Don't go above root
        parts.pop()
        this.currentDirectory = parts.join('/') || '/'
      }
    } else if (targetPath.startsWith('/')) {
      // Absolute path
      this.currentDirectory = targetPath
    } else {
      // Relative path
      if (this.currentDirectory.endsWith('/')) {
        this.currentDirectory = this.currentDirectory + targetPath
      } else {
        this.currentDirectory = this.currentDirectory + '/' + targetPath
      }
    }
    
    return {
      output: '', // No output for successful cd
      type: 'success'
    }
  }

  initializeGameFiles() {
    // Distribute game files across different directories for realistic exploration
    this.gameFileLocations.set('/home/recruit/network_logs.txt', 'network_logs.txt')
    this.gameFileLocations.set('/home/recruit/Documents/admin_notes.txt', 'admin_notes.txt')
    this.gameFileLocations.set('/var/log/suspicious_activity.log', 'suspicious_activity.log')
    this.gameFileLocations.set('/etc/service_discovery.log', 'service_discovery.log')
    this.gameFileLocations.set('/home/recruit/.bashrc', '.bashrc')
  }

  getUserHome() {
    if (typeof process !== 'undefined' && process.env) {
      return process.env.HOME || process.env.USERPROFILE || '/home/recruit'
    }
    return '/home/recruit'
  }

  async getRealDirectoryListing(path) {
    const currentDir = this.currentDirectory
    const items = []
    
    // Base directory structure
    if (currentDir === '/home/recruit') {
      items.push('Documents/', 'Downloads/', 'Desktop/', 'Pictures/')
      items.push('.bashrc', '.profile', '.vimrc')
      items.push('network_logs.txt') // Game file in home directory
    } else if (currentDir === '/home/recruit/Documents') {
      items.push('admin_notes.txt', 'investigation_files/', 'training_materials/')
    } else if (currentDir === '/home/recruit/Downloads') {
      items.push('setup_files/', 'archived_logs/')
    } else if (currentDir === '/var/log') {
      items.push('auth.log', 'syslog', 'kern.log', 'suspicious_activity.log')
    } else if (currentDir === '/etc') {
      items.push('passwd', 'hosts', 'hostname', 'service_discovery.log')
    } else if (currentDir === '/' || currentDir === '') {
      items.push('bin/', 'etc/', 'home/', 'usr/', 'var/', 'tmp/', 'opt/')
    } else if (currentDir === '/home') {
      items.push('recruit/', 'architect/')
    } else {
      // Default fallback for unknown directories
      items.push('..', 'example_file.txt')
    }

    return {
      output: items.join('  '),
      type: 'normal'
    }
  }

  async getRealProcessList() {
    // Simulate realistic process list
    const processes = [
      'PID TTY          TIME CMD',
      `${Math.floor(Math.random() * 1000) + 1000} pts/0    00:00:01 bash`,
      `${Math.floor(Math.random() * 1000) + 1000} pts/0    00:00:00 systemd --user`,
      `${Math.floor(Math.random() * 1000) + 1000} ?        00:00:02 gnome-shell`,
      `${Math.floor(Math.random() * 1000) + 1000} ?        00:00:01 firefox`,
      `${Math.floor(Math.random() * 1000) + 1000} ?        00:00:00 code`,
      `${Math.floor(Math.random() * 1000) + 1000} ?        00:00:01 node`,
      `${Math.floor(Math.random() * 1000) + 1000} pts/0    00:00:00 network-chronicles`
    ]

    return {
      output: processes.join('\n'),
      type: 'normal'
    }
  }

  async getRealNetworkConnections() {
    // Get more realistic network connections
    const connections = [
      'Active Internet connections (servers and established)',
      'Proto Recv-Q Send-Q Local Address           Foreign Address         State',
      'tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN',
      'tcp        0      0 127.0.0.1:3001          0.0.0.0:*               LISTEN',
      'tcp        0      0 0.0.0.0:443             0.0.0.0:*               LISTEN',
      `tcp        0      0 ${this.getLocalIP()}:22    ${this.getGatewayIP()}:${Math.floor(Math.random() * 10000) + 50000}     ESTABLISHED`,
      'tcp6       0      0 :::80                   :::*                    LISTEN'
    ]

    return {
      output: connections.join('\n'),
      type: 'normal'
    }
  }

  getLocalIP() {
    // Return a realistic local IP
    return '192.168.1.' + (Math.floor(Math.random() * 100) + 50)
  }

  getGatewayIP() {
    return '192.168.1.1'
  }

  async getRealNetworkInterfaces() {
    const localIP = this.getLocalIP()
    const interfaces = [
      'eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500',
      `        inet ${localIP}  netmask 255.255.255.0  broadcast 192.168.1.255`,
      '        inet6 fe80::a00:27ff:fe4e:66a1  prefixlen 64  scopeid 0x20<link>',
      '        ether 08:00:27:4e:66:a1  txqueuelen 1000  (Ethernet)',
      '        RX packets 12345  bytes 1234567 (1.2 MB)',
      '        TX packets 6789   bytes 567890 (555.5 KB)',
      '',
      'lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536',
      '        inet 127.0.0.1  netmask 255.0.0.0',
      '        inet6 ::1  prefixlen 128  scopeid 0x10<host>',
      '        loop  txqueuelen 1000  (Local Loopback)'
    ]

    return {
      output: interfaces.join('\n'),
      type: 'normal'
    }
  }

  async getRealDiskUsage() {
    const diskInfo = [
      'Filesystem     1K-blocks      Used Available Use% Mounted on',
      '/dev/sda1       41943040  20971520  19354400  52% /',
      '/dev/sda2       20971520   4194304  15777216  21% /home',
      'tmpfs            8388608    102400   8286208   2% /dev/shm'
    ]

    return {
      output: diskInfo.join('\n'),
      type: 'normal'
    }
  }

  async getRealMemoryUsage() {
    const totalMem = 8 * 1024 * 1024 // 8GB in KB
    const usedMem = Math.floor(totalMem * (0.3 + Math.random() * 0.4)) // 30-70% usage
    const freeMem = totalMem - usedMem

    const memInfo = [
      '              total        used        free      shared  buff/cache   available',
      `Mem:        ${totalMem.toLocaleString()}     ${usedMem.toLocaleString()}     ${freeMem.toLocaleString()}      ${Math.floor(Math.random() * 100000)}     ${Math.floor(totalMem * 0.1).toLocaleString()}     ${Math.floor(freeMem * 0.9).toLocaleString()}`,
      'Swap:       2097148           0     2097148'
    ]

    return {
      output: memInfo.join('\n'),
      type: 'normal'
    }
  }

  // Method to discover actual running services with enhanced story integration
  async discoverRealServices() {
    if (this.isWebEnvironment) {
      // Try to get real services from backend API
      try {
        const response = await fetch('http://localhost:3003/api/discover-services')
        if (response.ok) {
          const realServices = await response.json()
          if (realServices.length > 0) {
            // Enhance services with story context
            return this.enhanceServicesWithStoryContext(realServices)
          }
        }
      } catch (error) {
        console.log('Backend API not available for service discovery')
      }
    }

    // Fallback to enhanced simulation
    const commonPorts = [22, 80, 443, 3000, 3001, 5432, 3306, 6379, 9090]
    const services = []

    for (const port of commonPorts) {
      const serviceName = this.getServiceName(port)
      const isRunning = Math.random() > 0.3 // 70% chance service is running
      
      if (isRunning) {
        services.push({
          port,
          name: serviceName,
          status: 'running',
          description: this.getServiceDescription(serviceName)
        })
      }
    }

    // Add the current dev server if it's running
    services.push({
      port: 3001,
      name: 'Network Chronicles',
      status: 'running',
      description: 'Linux Learning Terminal Web Interface'
    })

    return services
  }

  enhanceServicesWithStoryContext(realServices) {
    return realServices.map(service => {
      const enhanced = { ...service }
      
      // Add investigation context based on actual services
      if (service.port === 22) {
        enhanced.investigationNote = "The Architect used SSH for remote access - check for unusual login patterns"
      } else if (service.port === 80 || service.port === 443) {
        enhanced.investigationNote = "Web services were compromised during the breach - examine for backdoors"
      } else if (service.port === 3306 || service.port === 5432) {
        enhanced.investigationNote = "Database service - likely contains evidence of financial transactions"
      } else if (service.port === 6379) {
        enhanced.investigationNote = "Redis cache may contain session data from the breach"
      } else if (service.port === 9090) {
        enhanced.investigationNote = "Prometheus monitoring - The Architect was tracking all system metrics"
      } else {
        enhanced.investigationNote = `Port ${service.port} - unusual service requiring investigation`
      }
      
      // Add suspicion levels based on port usage
      if ([8080, 8443, 7777, 9999].includes(service.port)) {
        enhanced.suspicionLevel = 'HIGH'
        enhanced.investigationNote += " - SUSPICIOUS: Non-standard port usage detected"
      } else if ([3000, 3001, 3002, 3003].includes(service.port)) {
        enhanced.suspicionLevel = 'MEDIUM'
        enhanced.investigationNote += " - Development service potentially exploited"
      } else {
        enhanced.suspicionLevel = 'LOW'
      }
      
      return enhanced
    })
  }

  getServiceName(port) {
    const serviceMap = {
      22: 'SSH',
      80: 'HTTP',
      443: 'HTTPS',
      3000: 'Development Server',
      3001: 'Network Chronicles',
      5432: 'PostgreSQL',
      3306: 'MySQL',
      6379: 'Redis',
      9090: 'Prometheus'
    }
    return serviceMap[port] || `Unknown Service`
  }

  getServiceDescription(serviceName) {
    const descriptions = {
      'SSH': 'Secure Shell - Remote access protocol',
      'HTTP': 'Web server - Unencrypted web traffic',
      'HTTPS': 'Secure web server - Encrypted web traffic',
      'Development Server': 'Local development environment',
      'Network Chronicles': 'Linux Learning Terminal Interface',
      'PostgreSQL': 'Advanced open source database',
      'MySQL': 'Popular relational database',
      'Redis': 'In-memory data structure store',
      'Prometheus': 'Monitoring and alerting toolkit'
    }
    return descriptions[serviceName] || 'Unknown service purpose'
  }

  // Enhanced cat command that can read real game files
  async readGameFile(filename) {
    if (this.isWebEnvironment) {
      // Try to get file content from backend API
      try {
        const response = await fetch('http://localhost:3003/api/read-file', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ filename })
        })
        
        if (response.ok) {
          return await response.json()
        }
      } catch (error) {
        console.log('Backend API not available for file reading')
      }
    }

    // Check if file exists in current directory context
    const fullPath = this.getFullPath(filename)
    
    // Handle async files
    if (filename === 'admin_notes.txt' || fullPath.endsWith('/admin_notes.txt')) {
      const adminNotes = await this.generateAdminNotes()
      return {
        output: adminNotes,
        type: 'normal'
      }
    }
    
    const gameFiles = {
      '/home/recruit/network_logs.txt': this.generateNetworkLogs(),
      '/var/log/suspicious_activity.log': this.generateSuspiciousActivity(),
      '/etc/service_discovery.log': this.generateServiceDiscoveryLog(),
      '/home/recruit/.bashrc': this.generateBashrc(),
      '/etc/passwd': this.generatePasswdFile(),
      '/etc/hosts': this.generateHostsFile()
    }

    // Check both full path and just filename
    if (gameFiles[fullPath]) {
      return {
        output: gameFiles[fullPath],
        type: 'normal'
      }
    }
    
    // Check if file exists in current directory
    const filenameKey = Object.keys(gameFiles).find(path => path.endsWith('/' + filename))
    if (filenameKey && this.isFileInCurrentDirectory(filenameKey)) {
      return {
        output: gameFiles[filenameKey],
        type: 'normal'
      }
    }

    return {
      output: `cat: ${filename}: No such file or directory`,
      type: 'error'
    }
  }

  getFullPath(filename) {
    if (filename.startsWith('/')) {
      return filename
    }
    
    if (this.currentDirectory.endsWith('/')) {
      return this.currentDirectory + filename
    } else {
      return this.currentDirectory + '/' + filename
    }
  }

  isFileInCurrentDirectory(filePath) {
    const dir = filePath.substring(0, filePath.lastIndexOf('/'))
    return dir === this.currentDirectory
  }

  generateNetworkLogs() {
    const now = new Date()
    const logs = []
    
    for (let i = 5; i >= 0; i--) {
      const timestamp = new Date(now - i * 60000) // 1 minute intervals
      const timeStr = timestamp.toISOString().replace('T', ' ').split('.')[0]
      
      if (i === 0) {
        logs.push(`[${timeStr}] Network Chronicles session started`)
        logs.push(`[${timeStr}] User ${this.getCurrentUser()} logged in`)
      } else {
        logs.push(`[${timeStr}] Connection from ${this.getLocalIP()}`)
        if (Math.random() > 0.5) {
          logs.push(`[${timeStr}] Service discovery scan detected`)
        }
      }
    }
    
    return logs.join('\n')
  }

  generateSuspiciousActivity() {
    return `
WARNING: Security Analysis Report
=================================

Date: ${new Date().toLocaleDateString()}
Analyst: The Architect (MISSING)

Recent Findings:
- Unauthorized network scanning detected
- Multiple service enumeration attempts
- Unknown user activity on port 8080
- System configuration changes without approval
- Database access from unusual IP: ${this.getRandomIP()}

Current Status: INVESTIGATION ONGOING
Last Admin Contact: 3 days ago
Emergency Protocols: ACTIVATED

Note: If you're reading this, continue the investigation.
Use 'nc-discover-services' to understand the scope.
    `
  }

  async generateAdminNotes() {
    const systemContext = await this.getSystemContext()
    const personalizedStory = await this.generatePersonalizedStoryElements()
    
    return `
THE ARCHITECT'S FINAL TRANSMISSION
=================================
Personal Log - Security Chief Marcus "The Architect" Sullivan
Target System: ${systemContext.hostname}
Platform: ${systemContext.platform}
Threat Level: CRITICAL

THEY'RE WATCHING. I don't have much time.

The $45 million theft wasn't random - they knew EXACTLY which systems to hit.
I've been tracking unusual activity on ${systemContext.hostname} for weeks.

${personalizedStory.personalizedClues.length > 0 ? 
  `SMOKING GUN: ${personalizedStory.personalizedClues[0]}` :
  'Something is wrong with the network traffic patterns...'}

I've hidden investigation tools throughout the system. They'll help you 
piece this together, but you need to DISCOVER them yourself. 

The attacker made three critical mistakes:
1. Left traces in the service logs (check what's REALLY running)
2. Didn't know about my hidden monitoring ports (scan deeper than port 80)
3. Assumed I wouldn't prepare contingencies (I did)

URGENT: If you're reading this, I'm probably already gone. 
Start with the basics - map what's on this system. Look for anything 
that doesn't belong. Trust your instincts.

When you find evidence of intrusion, scan for hidden services. 
I've prepared tools for the investigation, but they're not in the manual.

The network will tell you the truth. You just have to know how to listen.

Follow the digital breadcrumbs. Question everything.

- Marcus "The Architect" Sullivan
  Security Chief (Location: UNKNOWN)
  Emergency Protocol: SHADOW-SEVEN-SEVEN
  
P.S. - Check /var/log for deleted entries. They thought they were clever.
    `
  }

  generateServiceDiscoveryLog() {
    return `
NETWORK SERVICE DISCOVERY REPORT
===============================
Generated: ${new Date().toLocaleString()}
Scanner: Network Chronicles Education System

Discovered Services:
- SSH (22/tcp): Active, authentication required
- HTTP (80/tcp): Web service running
- HTTPS (443/tcp): Encrypted web service  
- Network Chronicles (3001/tcp): Educational interface
- Unknown Service (8080/tcp): INVESTIGATING...

Risk Assessment:
HIGH: Port 8080 - Unidentified service
MEDIUM: Standard web services exposed
LOW: SSH properly configured

Recommendations:
1. Investigate port 8080 immediately
2. Review web service configurations
3. Monitor for unusual connection patterns
4. Continue education modules to understand threats

This is a learning environment. Real security practices apply.
    `
  }

  generateBashrc() {
    const user = this.getCurrentUser()
    return `
# ~/.bashrc: executed by bash(1) for non-login shells
# Network Chronicles Learning Environment

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Network Chronicles aliases (added by The Architect)
alias nc-discover='nc-discover-services'
alias nc-map='nc-map-network'
alias investigate='netstat -tulpn'
alias scan-network='nmap -sT localhost'
alias check-processes='ps aux | grep -v grep'

# Educational aliases for learning
alias learn-files='echo "Try: ls, cat, cd, pwd"'
alias learn-network='echo "Try: netstat, ifconfig, ping"'
alias learn-system='echo "Try: ps, top, df, free"'

# Custom prompt
PS1='${user}@network-chronicles:\\w\\$ '

# Welcome message
echo "Network Chronicles Learning Environment Loaded"
echo "Type 'nc-help' for available commands"
    `
  }

  generatePasswdFile() {
    return `root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
recruit:x:1000:1000:Network Chronicles Recruit:/home/recruit:/bin/bash
architect:x:1001:1001:The Architect (MISSING):/home/architect:/bin/bash
security:x:1002:1002:Security Monitor:/var/security:/bin/bash
service:x:1003:1003:Service Account:/var/service:/bin/false`
  }

  generateHostsFile() {
    return `127.0.0.1	localhost
127.0.1.1	network-chronicles
${this.getLocalIP()}	recruit-terminal
192.168.1.1	gateway.local
192.168.1.100	suspicious-device.local
192.168.1.25	architect-workstation.local

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters`
  }

  getCurrentUser() {
    if (typeof process !== 'undefined' && process.env) {
      return process.env.USER || process.env.USERNAME || 'recruit'
    }
    return 'recruit'
  }

  getRandomIP() {
    return `192.168.1.${Math.floor(Math.random() * 200) + 50}`
  }

  // Get real system context for story personalization
  async getSystemContext() {
    if (this.isWebEnvironment) {
      try {
        const response = await fetch('http://localhost:3003/api/system-context')
        if (response.ok) {
          return await response.json()
        }
      } catch (error) {
        console.log('Backend API not available for system context')
      }
    }
    
    // Fallback context
    return {
      hostname: 'recruit-terminal',
      username: 'recruit',
      platform: 'linux',
      arch: 'x64'
    }
  }

  // Generate personalized story elements based on real system
  async generatePersonalizedStoryElements() {
    const context = await this.getSystemContext()
    const services = await this.discoverRealServices()
    
    const storyElements = {
      targetHostname: context.hostname,
      suspiciousUser: context.username,
      platformContext: context.platform,
      discoveredServices: services.length,
      highRiskServices: services.filter(s => s.suspicionLevel === 'HIGH').length,
      personalizedClues: []
    }
    
    // Generate clues based on actual system
    if (services.some(s => s.port === 22)) {
      storyElements.personalizedClues.push(
        `SSH access detected on ${context.hostname} - The Architect may have used this for remote administration`
      )
    }
    
    if (services.some(s => [3000, 3001, 8080, 8443].includes(s.port))) {
      storyElements.personalizedClues.push(
        `Development services running on ${context.hostname} - potential backdoor entry points`
      )
    }
    
    if (services.some(s => [3306, 5432].includes(s.port))) {
      storyElements.personalizedClues.push(
        `Database services active - financial records likely stored on ${context.hostname}`
      )
    }
    
    return storyElements
  }
}

export default SystemIntegration