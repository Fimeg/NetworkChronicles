/**
 * Service Narrative Template
 * Add this to src/game/GameEngine.js in the initializeServiceNarratives() method
 */

// PORT-BASED NARRATIVES
// Add these to the main service narratives object:
{
  // Your service port number
  8080: "Service description - The Architect's connection or usage pattern",
  
  // Examples:
  8080: "Development server detected - The Architect tested custom tools here",
  5432: "PostgreSQL database found - Critical investigation data was stored here", 
  6379: "Redis cache detected - The Architect optimized for high-performance queries",
  9200: "Elasticsearch found - Log analysis and search capabilities were crucial"
}

// NAME-BASED NARRATIVES  
// Add these to the getServiceNarrative() method:

// Template:
if (name.includes('your_service_name')) {
  return "Service narrative - How The Architect interacted with this service"
}

// Examples:
if (name.includes('grafana')) {
  return "Grafana dashboard - The Architect monitored system health obsessively"
}

if (name.includes('jenkins')) {
  return "Jenkins CI/CD detected - The Architect automated deployment pipelines"
}

if (name.includes('portainer')) {
  return "Portainer found - The Architect managed containers through this interface"
}

if (name.includes('nextcloud')) {
  return "Nextcloud instance - The Architect's personal file synchronization system"
}

/**
 * NARRATIVE GUIDELINES:
 * 
 * 1. Keep under 80 characters total
 * 2. Reference The Architect specifically
 * 3. Maintain past tense (they're missing)
 * 4. Focus on purpose/usage, not just identification
 * 5. Add personality hints when possible
 * 
 * GOOD EXAMPLES:
 * - "MySQL detected - The Architect stored encrypted logs here"
 * - "Redis cache found - Performance optimization was a priority"
 * - "VPN server detected - The Architect valued secure remote access"
 * 
 * AVOID:
 * - "Service running on port 8080" (too generic)
 * - "Database server found" (no connection to story)
 * - Present tense references
 * - Technical jargon without context
 */

/**
 * INVESTIGATION LEADS INTEGRATION:
 * 
 * For major services, also add investigation leads in generateInvestigationLeads():
 */

// Template for investigation leads:
if (detectedPorts.includes(YOUR_PORT)) {
  leads.push("Service found - Check for configuration anomalies")
  leads.push("The Architect may have left custom settings or logs")
}

// Example:
if (detectedPorts.includes(5432)) {
  leads.push("PostgreSQL database found - Investigate query logs and schemas")
  leads.push("Database may contain The Architect's research and findings")
}

/**
 * SUBMISSION CHECKLIST:
 * 
 * □ Service narrative under 80 characters
 * □ References The Architect specifically  
 * □ Maintains mystery/investigation tone
 * □ Uses past tense appropriately
 * □ Adds to character development
 * □ Provides educational context
 * □ Fits existing narrative style
 * □ Tested in-game if possible
 */