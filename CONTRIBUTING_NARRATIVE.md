# Contributing Narrative Content to Network Chronicles 2.0

Welcome to the Network Chronicles community! We're excited to have you contribute to The Architect's mystery.

## 🎭 Content Types You Can Contribute

### 1. Service Narratives
Add backstory for network services discovered during investigation.

**Location**: `src/game/GameEngine.js` → `initializeServiceNarratives()`

**Format**:
```javascript
// Port-based detection
8080: "Service description - The Architect's connection to this service",

// Name-based detection (in getServiceNarrative method)
if (name.includes('your-service')) {
  return "Service narrative - How The Architect used this tool"
}
```

**Guidelines**:
- Keep it under 80 characters
- Reference The Architect's usage/purpose
- Maintain cyberpunk/investigation tone
- Focus on system administration context

### 2. Ambient Messages
Background messages that appear during terminal usage.

**Location**: `src/components/Terminal.jsx` → `generateAmbientMessage()`

**Format**:
```javascript
{ 
  type: 'security', 
  message: '[SEC] Your security message here',
  weight: 3  // Higher = more frequent
},
```

**Message Types**:
- `security` - Security alerts and monitoring
- `network` - Network activity and changes  
- `system` - System status and processes
- `investigation` - Investigation-related discoveries

### 3. Quest Content
Complete investigation missions with objectives and rewards.

**Location**: `content/narrative/quests/`

**Required Files**:
- `quest_id.json` - Quest metadata and configuration
- `quest_id.md` - Detailed quest description and lore

**JSON Structure**:
```json
{
  "id": "your_quest_id",
  "title": "Quest Title",
  "description": "Brief quest description",
  "tier": 2,
  "prerequisites": ["previous_quest_id"],
  "objectives": [
    "Discover hidden service on port 8080",
    "Analyze network traffic patterns"
  ],
  "rewards": {
    "xp": 100,
    "discoveries": ["hidden_service_found"],
    "narrative": "What The Architect was trying to accomplish"
  },
  "hints": [
    "Check for non-standard ports",
    "The Architect left logs in /var/log/"
  ]
}
```

### 4. Discovery Lore
Backstory revealed when players find specific evidence.

**Location**: `content/discoveries/`

**Format**:
```json
{
  "id": "discovery_id",
  "title": "Discovery Name",
  "category": "evidence|personal|technical|conspiracy",
  "rarity": "common|uncommon|rare|legendary",
  "content": {
    "summary": "Brief discovery description",
    "details": "Detailed lore and implications",
    "clues": ["What this reveals about the mystery"],
    "questions": ["What new questions this raises"]
  },
  "triggers": {
    "commands": ["command that reveals this"],
    "files": ["file that contains this"],
    "ports": [8080, 9000]
  }
}
```

### 5. Character Backstory
Information about The Architect and other characters.

**Location**: `content/characters/`

**Structure**:
```json
{
  "character_id": "the_architect",
  "name": "The Architect",
  "role": "Senior System Administrator",
  "personality": {
    "traits": ["methodical", "paranoid", "brilliant"],
    "motivations": ["system perfection", "hidden agenda"],
    "fears": ["data loss", "surveillance", "betrayal"]
  },
  "timeline": [
    {
      "date": "2024-01-15",
      "event": "Started implementing new security protocols",
      "evidence": ["log_entries", "config_changes"]
    }
  ],
  "relationships": {
    "ceo": "strained - disagreed on security policies",
    "team": "respected but distant",
    "contacts": ["mysterious_outsider"]
  }
}
```

## 🎯 Content Guidelines

### Writing Style
- **Tone**: Cyberpunk investigation thriller
- **Era**: 80s/90s retro-futurism with modern tech
- **Perspective**: You're investigating after The Architect
- **Mood**: Mystery, paranoia, discovery

### Technical Accuracy
- Use real Linux commands and concepts
- Reference actual network services and ports
- Include realistic system administration scenarios
- Maintain educational value for learning

### Narrative Consistency
- The Architect was brilliant but secretive
- Evidence suggests both internal and external threats
- Multiple layers of mystery (personal, corporate, technical)
- Red herrings and misdirection are encouraged

## 📂 File Organization

```
content/
├── narrative/
│   ├── quests/           # Investigation missions
│   ├── messages/         # Terminal messages and logs
│   └── chapters/         # Story progression
├── discoveries/          # Evidence and lore
├── characters/           # Character backstories  
├── events/              # Triggered story events
├── triggers/            # Conditions for content
└── documentation/       # In-world manuals and guides
```

## 🚀 Contribution Process

### 1. Prepare Your Content
- Choose your content type
- Follow the appropriate format
- Test locally if possible
- Write clear, engaging narrative

### 2. Submit Your Contribution
- **Small additions**: Direct PR with files
- **Major content**: Open an issue first to discuss
- **Quest chains**: Propose overall arc before implementation

### 3. Content Review
We'll review for:
- Narrative consistency with existing lore
- Technical accuracy for learning value
- Writing quality and engagement
- Integration complexity

### 4. Community Feedback
- Alpha testers will experience your content
- Feedback will be shared for improvements
- Popular content may inspire expansions

## 🛠️ Technical Integration

### Adding Service Narratives
1. Edit `src/game/GameEngine.js`
2. Add your service to `initializeServiceNarratives()`
3. Test with `nc-investigation` command
4. Submit PR with rationale

### Adding Quest Content
1. Create JSON metadata file
2. Write detailed markdown description
3. Add any required discovery files
4. Test quest progression logic
5. Submit with walkthrough notes

### Adding Ambient Messages
1. Edit `src/components/Terminal.jsx`
2. Add to appropriate message category
3. Adjust weight based on frequency desired
4. Test message distribution

## 🎨 Content Ideas We Need

### High Priority
- **Enterprise services**: SharePoint, Exchange, Oracle, SAP narratives
- **Security tools**: Nessus, Metasploit, Wireshark backstories  
- **DevOps tools**: Jenkins, GitLab, Kubernetes narratives
- **Database systems**: PostgreSQL, Redis, InfluxDB stories

### Medium Priority
- **IoT devices**: Smart home integration mysteries
- **Cloud services**: AWS/Azure/GCP investigation angles
- **Monitoring tools**: Nagios, Zabbix, Datadog narratives
- **Backup systems**: The Architect's data protection schemes

### Community Requests
- More character development for The Architect
- Corporate conspiracy storylines
- Technical deep-dives into specific tools
- Easter eggs and hidden content

## 💡 Pro Tips for Contributors

### Make It Personal
- Reference The Architect's habits and preferences
- Include emotional depth in technical discoveries
- Create connections between different evidence pieces

### Layer the Mystery
- Plant questions that aren't immediately answered
- Include red herrings and false leads
- Build toward multiple revelation moments

### Educational Value
- Teach real system administration skills
- Include practical Linux/networking knowledge
- Explain complex concepts through narrative

### Community Building
- Reference other contributors' content when possible
- Build on existing storylines
- Leave hooks for future expansion

## 🙏 Attribution

All contributors will be:
- Listed in game credits
- Referenced in README acknowledgments
- Eligible for special community recognition
- Invited to alpha testing priority access

Thank you for helping build the Network Chronicles universe! 🚀