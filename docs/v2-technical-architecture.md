# Network Chronicles V2 - Technical Architecture

## Executive Summary

This document outlines the technical architecture for Network Chronicles V2, addressing scalability, security, and maintainability concerns identified in the V1 analysis. The V2 architecture transforms the current file-based, single-player system into a robust, scalable, multi-tenant platform capable of handling hundreds of concurrent players while maintaining the core gaming experience.

## Current V1 Analysis

### Strengths
- Creative gamification concept with strong narrative elements
- Well-structured content management system
- Effective shell integration for immersive experience
- Modular event/trigger system
- Docker containerization foundation

### Critical Gaps
- **Data Persistence**: JSON file storage with permission issues
- **Scalability**: Single-player design, no concurrent user support
- **Security**: Hardcoded credentials, inadequate authentication
- **State Management**: File-based state with race conditions
- **Real-time Features**: No multiplayer coordination
- **Monitoring**: Limited observability and debugging capabilities

---

## V2 System Architecture

### 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Load Balancer                            │
│                      (NGINX/HAProxy)                            │
└─────────────────┬───────────────┬─────────────────────────────────┘
                  │               │
          ┌───────▼─────┐   ┌─────▼──────┐
          │   Web UI    │   │  Game API  │
          │  (React)    │   │  (Node.js) │
          └─────────────┘   └────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
      ┌───────▼──────┐    ┌────────▼─────────┐   ┌─────▼─────┐
      │   Auth       │    │   Game Engine    │   │  LLM      │
      │  Service     │    │    Service       │   │ Service   │
      │ (Node.js)    │    │   (Node.js)      │   │(Node.js)  │
      └──────────────┘    └──────────────────┘   └───────────┘
              │                    │                    │
              │            ┌───────▼──────┐             │
              │            │   Real-time  │             │
              │            │   Service    │             │
              │            │ (Socket.IO)  │             │
              │            └──────────────┘             │
              │                    │                    │
              └────────────────────┼────────────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
      ┌───────▼──────┐    ┌────────▼─────────┐   ┌─────▼─────┐
      │  PostgreSQL  │    │     Redis        │   │   File    │
      │  (Primary)   │    │   (Sessions/     │   │  Storage  │
      │              │    │    Cache)        │   │  (S3/FS)  │
      └──────────────┘    └──────────────────┘   └───────────┘
```

### 2. Microservices Architecture

#### 2.1 Core Services

##### Authentication Service (`auth-service`)
**Responsibility**: User authentication, authorization, JWT management
**Technology**: Node.js, Express, bcrypt, JWT
**Database**: PostgreSQL (users, roles, sessions)

```typescript
interface AuthService {
  // Authentication
  login(credentials: LoginRequest): Promise<AuthResponse>
  register(userInfo: RegisterRequest): Promise<User>
  logout(token: string): Promise<void>
  refreshToken(refreshToken: string): Promise<AuthResponse>
  
  // Authorization
  validateToken(token: string): Promise<User>
  checkPermission(userId: string, resource: string, action: string): Promise<boolean>
  
  // User Management
  getUserProfile(userId: string): Promise<UserProfile>
  updateUserProfile(userId: string, updates: Partial<UserProfile>): Promise<UserProfile>
}
```

##### Game Engine Service (`game-engine-service`)
**Responsibility**: Core game logic, player state, quest management
**Technology**: Node.js, Express, event-driven architecture
**Database**: PostgreSQL (game state), Redis (temporary state)

```typescript
interface GameEngineService {
  // Player Management
  initializePlayer(userId: string): Promise<Player>
  getPlayerState(userId: string): Promise<PlayerState>
  updatePlayerState(userId: string, updates: Partial<PlayerState>): Promise<PlayerState>
  
  // Discovery System
  addDiscovery(userId: string, discoveryId: string): Promise<Discovery>
  processCommand(userId: string, command: string): Promise<CommandResult>
  
  // Quest Management
  getCurrentQuest(userId: string): Promise<Quest | null>
  completeQuest(userId: string, questId: string): Promise<QuestResult>
  checkQuestRequirements(userId: string, questId: string): Promise<boolean>
  
  // Events & Triggers
  triggerEvent(userId: string, eventId: string, context?: any): Promise<void>
  processGameTriggers(userId: string, action: string): Promise<void>
}
```

##### Real-time Service (`realtime-service`)
**Responsibility**: WebSockets, multiplayer coordination, live updates
**Technology**: Node.js, Socket.IO, Redis Pub/Sub
**Database**: Redis (real-time state, room management)

```typescript
interface RealtimeService {
  // Connection Management
  handleConnection(socket: Socket): void
  handleDisconnection(userId: string): void
  
  // Room Management
  joinGameRoom(userId: string, roomId: string): Promise<void>
  leaveGameRoom(userId: string, roomId: string): Promise<void>
  
  // Live Updates
  broadcastPlayerUpdate(userId: string, update: PlayerUpdate): Promise<void>
  sendPersonalNotification(userId: string, notification: Notification): Promise<void>
  
  // Multiplayer Features
  shareDiscovery(fromUserId: string, toUserId: string, discoveryId: string): Promise<void>
  syncGameState(roomId: string): Promise<void>
}
```

##### LLM Service (`llm-service`)
**Responsibility**: AI-powered Architect character interactions
**Technology**: Node.js, OpenAI/Claude API, context management
**Database**: PostgreSQL (conversation history), Redis (session context)

```typescript
interface LLMService {
  // Architect Interactions
  startConversation(userId: string): Promise<ConversationSession>
  sendMessage(sessionId: string, message: string): Promise<ArchitectResponse>
  getConversationHistory(userId: string): Promise<ConversationHistory>
  
  // Context Management
  buildGameContext(userId: string): Promise<GameContext>
  updateContext(sessionId: string, updates: ContextUpdate): Promise<void>
  
  // AI Features
  generateHint(userId: string, questId: string): Promise<string>
  createPersonalizedContent(userId: string, template: ContentTemplate): Promise<string>
}
```

### 3. Database Schema Design

#### 3.1 PostgreSQL Schema

```sql
-- Users and Authentication
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) DEFAULT 'player',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true
);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(255) NOT NULL,
    refresh_token_hash VARCHAR(255),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_agent TEXT,
    ip_address INET
);

-- Game State
CREATE TABLE players (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    name VARCHAR(100) NOT NULL,
    tier INTEGER DEFAULT 1,
    xp INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE player_skills (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    skill_type VARCHAR(50) NOT NULL, -- networking, security, systems, devops
    points INTEGER DEFAULT 0,
    UNIQUE(player_id, skill_type)
);

CREATE TABLE player_reputation (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    category VARCHAR(50) NOT NULL, -- operations, security, development, management
    score INTEGER DEFAULT 0,
    UNIQUE(player_id, category)
);

-- Content Management
CREATE TABLE quests (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    tier_required INTEGER DEFAULT 1,
    xp_reward INTEGER DEFAULT 0,
    next_quest_id VARCHAR(100) REFERENCES quests(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE quest_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quest_id VARCHAR(100) REFERENCES quests(id) ON DELETE CASCADE,
    requirement_type VARCHAR(50) NOT NULL, -- discovery, quest_completion, tier
    requirement_value VARCHAR(255) NOT NULL
);

CREATE TABLE discoveries (
    id VARCHAR(100) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    tier_required INTEGER DEFAULT 1,
    xp_reward INTEGER DEFAULT 0,
    content TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Player Progress
CREATE TABLE player_quests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    quest_id VARCHAR(100) REFERENCES quests(id),
    status VARCHAR(20) DEFAULT 'active', -- active, completed, failed
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE,
    UNIQUE(player_id, quest_id)
);

CREATE TABLE player_discoveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    discovery_id VARCHAR(100) REFERENCES discoveries(id),
    discovered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    context JSONB, -- Additional context about the discovery
    UNIQUE(player_id, discovery_id)
);

CREATE TABLE player_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    triggered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal System
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    entry_type VARCHAR(50) DEFAULT 'manual', -- manual, auto, system
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- LLM Conversations
CREATE TABLE conversation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    character VARCHAR(50) DEFAULT 'architect',
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    context JSONB -- Game context at conversation start
);

CREATE TABLE conversation_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES conversation_sessions(id) ON DELETE CASCADE,
    sender VARCHAR(20) NOT NULL, -- player, architect
    message TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    metadata JSONB -- Additional message context
);

-- Multiplayer Features
CREATE TABLE game_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    max_players INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE room_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID REFERENCES game_rooms(id) ON DELETE CASCADE,
    player_id UUID REFERENCES players(id) ON DELETE CASCADE,
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    role VARCHAR(20) DEFAULT 'member', -- member, moderator, admin
    UNIQUE(room_id, player_id)
);

-- Indexes for Performance
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);
CREATE INDEX idx_players_user_id ON players(user_id);
CREATE INDEX idx_player_discoveries_player_id ON player_discoveries(player_id);
CREATE INDEX idx_player_quests_player_id ON player_quests(player_id);
CREATE INDEX idx_player_events_player_id ON player_events(player_id);
CREATE INDEX idx_conversation_messages_session_id ON conversation_messages(session_id);
```

#### 3.2 Redis Schema

```typescript
// Session Management
interface RedisSessionSchema {
  [`session:${sessionId}`]: {
    userId: string;
    username: string;
    role: string;
    loginTime: number;
    lastActivity: number;
  };
  
  [`user:${userId}:sessions`]: string[]; // Array of session IDs
}

// Real-time Game State
interface RedisGameStateSchema {
  [`player:${userId}:online`]: {
    status: 'online' | 'offline' | 'in-game';
    lastSeen: number;
    currentRoomId?: string;
  };
  
  [`room:${roomId}:players`]: Set<string>; // Set of user IDs
  [`room:${roomId}:state`]: {
    activeDiscoveries: Record<string, any>;
    sharedContext: Record<string, any>;
  };
}

// LLM Context Cache
interface RedisLLMSchema {
  [`llm:context:${userId}`]: {
    playerState: PlayerContextSnapshot;
    recentDiscoveries: Discovery[];
    questProgress: QuestProgress;
    conversationSummary: string;
    lastUpdated: number;
  };
  
  [`llm:session:${sessionId}`]: {
    messages: ConversationMessage[];
    context: GameContext;
    characterState: ArchitectState;
  };
}

// Rate Limiting
interface RedisRateLimitSchema {
  [`rate_limit:${userId}:api`]: number; // Request count
  [`rate_limit:${userId}:llm`]: number; // LLM request count
  [`rate_limit:${ip}:auth`]: number; // Auth attempt count
}
```

### 4. API Design

#### 4.1 REST API Endpoints

```typescript
// Authentication Endpoints
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
POST   /api/v1/auth/refresh
GET    /api/v1/auth/profile
PUT    /api/v1/auth/profile

// Player Management
GET    /api/v1/players/me
PUT    /api/v1/players/me
GET    /api/v1/players/me/stats
GET    /api/v1/players/me/achievements

// Game State
GET    /api/v1/game/state
GET    /api/v1/game/quests
GET    /api/v1/game/quests/:id
POST   /api/v1/game/quests/:id/complete
GET    /api/v1/game/discoveries
POST   /api/v1/game/discoveries
POST   /api/v1/game/commands/execute

// Journal
GET    /api/v1/journal/entries
POST   /api/v1/journal/entries
PUT    /api/v1/journal/entries/:id
DELETE /api/v1/journal/entries/:id

// LLM Interactions
POST   /api/v1/architect/conversations
POST   /api/v1/architect/conversations/:id/messages
GET    /api/v1/architect/conversations/:id/history

// Multiplayer
GET    /api/v1/rooms
POST   /api/v1/rooms
GET    /api/v1/rooms/:id
POST   /api/v1/rooms/:id/join
DELETE /api/v1/rooms/:id/leave
GET    /api/v1/rooms/:id/members

// Admin Endpoints
GET    /api/v1/admin/users
GET    /api/v1/admin/players
GET    /api/v1/admin/system/health
GET    /api/v1/admin/system/metrics
```

#### 4.2 WebSocket Events

```typescript
// Connection Events
interface SocketEvents {
  // Client to Server
  'game:join_room': (roomId: string) => void;
  'game:leave_room': (roomId: string) => void;
  'game:player_update': (update: PlayerUpdate) => void;
  'game:discovery_share': (targetUserId: string, discoveryId: string) => void;
  'architect:message': (sessionId: string, message: string) => void;
  
  // Server to Client
  'game:player_joined': (player: PlayerInfo) => void;
  'game:player_left': (playerId: string) => void;
  'game:discovery_shared': (fromPlayer: PlayerInfo, discovery: Discovery) => void;
  'game:quest_completed': (player: PlayerInfo, quest: Quest) => void;
  'game:notification': (notification: Notification) => void;
  'architect:response': (sessionId: string, response: ArchitectMessage) => void;
  'system:error': (error: ErrorInfo) => void;
}
```

### 5. Security Architecture

#### 5.1 Authentication & Authorization

```typescript
// JWT Token Structure
interface JWTPayload {
  userId: string;
  username: string;
  role: 'player' | 'moderator' | 'admin';
  tier: number;
  iat: number;
  exp: number;
  permissions: Permission[];
}

// Permission System
interface Permission {
  resource: string; // players, quests, rooms, admin
  actions: string[]; // read, write, delete, moderate
  conditions?: Record<string, any>; // Additional constraints
}

// Role-Based Access Control
const ROLE_PERMISSIONS: Record<string, Permission[]> = {
  player: [
    { resource: 'players', actions: ['read'], conditions: { self: true } },
    { resource: 'quests', actions: ['read', 'complete'] },
    { resource: 'discoveries', actions: ['read', 'create'] },
    { resource: 'journal', actions: ['read', 'write'], conditions: { self: true } },
    { resource: 'architect', actions: ['interact'] },
    { resource: 'rooms', actions: ['read', 'join', 'leave'] }
  ],
  moderator: [
    // ... includes all player permissions plus:
    { resource: 'rooms', actions: ['read', 'write', 'moderate'] },
    { resource: 'players', actions: ['read', 'moderate'] }
  ],
  admin: [
    // ... includes all permissions
    { resource: '*', actions: ['*'] }
  ]
};
```

#### 5.2 Input Validation & Sanitization

```typescript
// Request Validation Schemas (using Joi)
const schemas = {
  registerUser: Joi.object({
    username: Joi.string().alphanum().min(3).max(30).required(),
    email: Joi.string().email().required(),
    password: Joi.string().min(8).pattern(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/),
  }),
  
  executeCommand: Joi.object({
    command: Joi.string().max(1000).pattern(/^[a-zA-Z0-9\s\-\._\/\\:]*$/).required(),
    context: Joi.object().optional()
  }),
  
  architectMessage: Joi.object({
    message: Joi.string().max(2000).required(),
    sessionId: Joi.string().uuid().required()
  })
};

// Security Middleware
const securityMiddleware = [
  helmet(), // Security headers
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP'
  }),
  express.json({ limit: '10mb' }),
  cors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true
  })
];
```

#### 5.3 Docker Security

```dockerfile
# Multi-stage build for security
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runtime
# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs . .

# Security settings
USER nodejs
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node healthcheck.js

CMD ["node", "src/index.js"]
```

### 6. Performance & Scalability

#### 6.1 Caching Strategy

```typescript
// Multi-layer Caching Architecture
interface CachingLayers {
  // L1: Application-level cache (in-memory)
  applicationCache: Map<string, CacheEntry>;
  
  // L2: Redis cache (distributed)
  redisCache: {
    playerStates: TTL_1_HOUR;
    questData: TTL_24_HOURS;
    discoveryContent: TTL_12_HOURS;
    llmContexts: TTL_30_MINUTES;
  };
  
  // L3: CDN cache (static assets)
  cdnCache: {
    staticAssets: TTL_30_DAYS;
    gameContent: TTL_1_DAY;
  };
}

// Cache Implementation
class GameCacheManager {
  async getPlayerState(userId: string): Promise<PlayerState> {
    // Try L1 cache first
    let state = this.appCache.get(`player:${userId}`);
    if (state) return state;
    
    // Try L2 cache (Redis)
    state = await this.redis.get(`player:${userId}:state`);
    if (state) {
      this.appCache.set(`player:${userId}`, JSON.parse(state));
      return JSON.parse(state);
    }
    
    // Fallback to database
    state = await this.database.getPlayerState(userId);
    
    // Update caches
    await this.redis.setex(`player:${userId}:state`, 3600, JSON.stringify(state));
    this.appCache.set(`player:${userId}`, state);
    
    return state;
  }
}
```

#### 6.2 Database Optimization

```sql
-- Query Optimization Examples
-- Use proper indexing for common queries
CREATE INDEX CONCURRENTLY idx_player_discoveries_player_discovery 
ON player_discoveries(player_id, discovery_id);

CREATE INDEX CONCURRENTLY idx_player_quests_active 
ON player_quests(player_id, status) WHERE status = 'active';

-- Partitioning for large tables
CREATE TABLE player_events_2024 PARTITION OF player_events
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- Read replicas for scaling reads
-- (Configured at infrastructure level)
```

#### 6.3 Horizontal Scaling

```yaml
# Kubernetes Deployment Example
apiVersion: apps/v1
kind: Deployment
metadata:
  name: game-engine-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: game-engine-service
  template:
    spec:
      containers:
      - name: game-engine
        image: network-chronicles/game-engine:v2.0.0
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: database-credentials
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
```

### 7. Integration Points

#### 7.1 Shell Script to API Communication

```bash
#!/bin/bash
# Enhanced nc-shell-integration.sh for V2

API_BASE_URL="${NC_API_URL:-http://localhost:3000/api/v1}"
AUTH_TOKEN_FILE="$HOME/.nc_token"

# Authenticate with API
nc_api_auth() {
    local username="$1"
    local password="$2"
    
    local response=$(curl -s -X POST "$API_BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"$username\",\"password\":\"$password\"}")
    
    local token=$(echo "$response" | jq -r '.token // empty')
    if [ -n "$token" ]; then
        echo "$token" > "$AUTH_TOKEN_FILE"
        chmod 600 "$AUTH_TOKEN_FILE"
        echo "Authentication successful"
    else
        echo "Authentication failed"
        return 1
    fi
}

# Execute command through API
nc_execute_command() {
    local command="$1"
    local token=""
    
    if [ -f "$AUTH_TOKEN_FILE" ]; then
        token=$(cat "$AUTH_TOKEN_FILE")
    fi
    
    if [ -z "$token" ]; then
        echo "Not authenticated. Run 'nc-login' first."
        return 1
    fi
    
    curl -s -X POST "$API_BASE_URL/game/commands/execute" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"command\":\"$command\"}" | jq -r '.output // .error'
}

# Integration with shell commands
command_not_found_handle() {
    local cmd="$1"
    
    # Process command through Network Chronicles API
    nc_execute_command "$*" &
    
    # Continue with normal command execution
    return 127  # Command not found
}
```

#### 7.2 LLM Service Integration

```typescript
// LLM Service Implementation
class LLMService {
  private openai: OpenAI;
  private contextManager: ContextManager;
  
  async processArchitectInteraction(
    userId: string, 
    message: string, 
    sessionId: string
  ): Promise<ArchitectResponse> {
    // Build context from game state
    const gameContext = await this.contextManager.buildContext(userId);
    
    // Construct prompt with character constraints
    const prompt = this.buildArchitectPrompt(gameContext, message);
    
    // Rate limiting check
    await this.checkRateLimit(userId);
    
    try {
      const response = await this.openai.chat.completions.create({
        model: "gpt-4",
        messages: [
          { role: "system", content: this.getArchitectPersona() },
          { role: "system", content: `Game Context: ${JSON.stringify(gameContext)}` },
          { role: "user", content: message }
        ],
        max_tokens: 500,
        temperature: 0.7
      });
      
      const architectMessage = response.choices[0].message.content;
      
      // Store conversation
      await this.storeConversationMessage(sessionId, 'architect', architectMessage);
      
      // Check for special commands or hints
      const specialActions = await this.processSpecialCommands(architectMessage, userId);
      
      return {
        message: architectMessage,
        specialActions,
        timestamp: new Date().toISOString()
      };
      
    } catch (error) {
      this.logger.error('LLM API error:', error);
      throw new Error('The Architect seems to be experiencing connection issues...');
    }
  }
  
  private getArchitectPersona(): string {
    return `You are "The Architect" - a mysterious former system administrator who disappeared from a network infrastructure. You communicate in a cryptic, paranoid but helpful manner. You believe you're being monitored and speak as if the system itself might be listening. You guide players through network discovery and security challenges without giving direct answers. You're knowledgeable about networking, security, and system administration but always speak in riddles and metaphors. Keep responses under 100 words and maintain an air of mystery.`;
  }
}
```

### 8. Development & Deployment

#### 8.1 CI/CD Pipeline

```yaml
# .github/workflows/deploy.yml
name: Network Chronicles V2 CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      redis:
        image: redis:6.2
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run unit tests
      run: npm run test:unit
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
        REDIS_URL: redis://localhost:6379
    
    - name: Run integration tests
      run: npm run test:integration
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
        REDIS_URL: redis://localhost:6379
    
    - name: Build application
      run: npm run build

  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Run security audit
      run: npm audit --audit-level moderate
    - name: Run Snyk security scan
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}

  deploy-staging:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    steps:
    - name: Deploy to staging
      run: |
        # Deployment logic for staging environment
        echo "Deploying to staging..."

  deploy-production:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Deploy to production
      run: |
        # Deployment logic for production environment
        echo "Deploying to production..."
```

#### 8.2 Environment Management

```typescript
// config/environment.ts
interface EnvironmentConfig {
  NODE_ENV: 'development' | 'staging' | 'production';
  PORT: number;
  
  // Database
  DATABASE_URL: string;
  DATABASE_POOL_SIZE: number;
  DATABASE_SSL: boolean;
  
  // Redis
  REDIS_URL: string;
  REDIS_CLUSTER_MODE: boolean;
  
  // Authentication
  JWT_SECRET: string;
  JWT_EXPIRES_IN: string;
  REFRESH_TOKEN_EXPIRES_IN: string;
  
  // LLM Service
  OPENAI_API_KEY: string;
  LLM_MODEL: string;
  LLM_MAX_TOKENS: number;
  LLM_RATE_LIMIT_PER_USER: number;
  
  // File Storage
  STORAGE_PROVIDER: 's3' | 'local';
  AWS_S3_BUCKET?: string;
  AWS_REGION?: string;
  LOCAL_STORAGE_PATH?: string;
  
  // Monitoring
  LOG_LEVEL: 'debug' | 'info' | 'warn' | 'error';
  METRICS_ENABLED: boolean;
  SENTRY_DSN?: string;
  
  // Features
  MULTIPLAYER_ENABLED: boolean;
  LLM_ENABLED: boolean;
  RATE_LIMITING_ENABLED: boolean;
}

// Environment-specific configurations
export const config: EnvironmentConfig = {
  NODE_ENV: process.env.NODE_ENV as any || 'development',
  PORT: parseInt(process.env.PORT || '3000'),
  
  DATABASE_URL: process.env.DATABASE_URL || 'postgresql://localhost:5432/network_chronicles',
  DATABASE_POOL_SIZE: parseInt(process.env.DATABASE_POOL_SIZE || '10'),
  DATABASE_SSL: process.env.DATABASE_SSL === 'true',
  
  REDIS_URL: process.env.REDIS_URL || 'redis://localhost:6379',
  REDIS_CLUSTER_MODE: process.env.REDIS_CLUSTER_MODE === 'true',
  
  JWT_SECRET: process.env.JWT_SECRET || 'your-secret-key',
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h',
  REFRESH_TOKEN_EXPIRES_IN: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d',
  
  OPENAI_API_KEY: process.env.OPENAI_API_KEY || '',
  LLM_MODEL: process.env.LLM_MODEL || 'gpt-4',
  LLM_MAX_TOKENS: parseInt(process.env.LLM_MAX_TOKENS || '500'),
  LLM_RATE_LIMIT_PER_USER: parseInt(process.env.LLM_RATE_LIMIT_PER_USER || '10'),
  
  STORAGE_PROVIDER: (process.env.STORAGE_PROVIDER as any) || 'local',
  AWS_S3_BUCKET: process.env.AWS_S3_BUCKET,
  AWS_REGION: process.env.AWS_REGION || 'us-east-1',
  LOCAL_STORAGE_PATH: process.env.LOCAL_STORAGE_PATH || './storage',
  
  LOG_LEVEL: (process.env.LOG_LEVEL as any) || 'info',
  METRICS_ENABLED: process.env.METRICS_ENABLED !== 'false',
  SENTRY_DSN: process.env.SENTRY_DSN,
  
  MULTIPLAYER_ENABLED: process.env.MULTIPLAYER_ENABLED !== 'false',
  LLM_ENABLED: process.env.LLM_ENABLED !== 'false',
  RATE_LIMITING_ENABLED: process.env.RATE_LIMITING_ENABLED !== 'false'
};
```

#### 8.3 Testing Framework

```typescript
// tests/setup/testSetup.ts
import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { RedisContainer } from '@testcontainers/redis';

export class TestEnvironment {
  private postgres: PostgreSqlContainer;
  private redis: RedisContainer;
  
  async setup() {
    // Start test containers
    this.postgres = await new PostgreSqlContainer()
      .withDatabase('test_nc')
      .withUsername('test')
      .withPassword('test')
      .start();
    
    this.redis = await new RedisContainer().start();
    
    // Set environment variables
    process.env.DATABASE_URL = this.postgres.getConnectionUri();
    process.env.REDIS_URL = this.redis.getConnectionUrl();
    
    // Run migrations
    await this.runMigrations();
  }
  
  async teardown() {
    await this.postgres?.stop();
    await this.redis?.stop();
  }
}

// tests/integration/gameEngine.test.ts
describe('Game Engine Integration Tests', () => {
  let gameEngine: GameEngineService;
  let testEnv: TestEnvironment;
  
  beforeAll(async () => {
    testEnv = new TestEnvironment();
    await testEnv.setup();
    gameEngine = new GameEngineService();
  });
  
  afterAll(async () => {
    await testEnv.teardown();
  });
  
  describe('Player Management', () => {
    it('should initialize a new player', async () => {
      const userId = 'test-user-1';
      const player = await gameEngine.initializePlayer(userId);
      
      expect(player).toBeDefined();
      expect(player.tier).toBe(1);
      expect(player.xp).toBe(0);
    });
    
    it('should add discovery and award XP', async () => {
      const userId = 'test-user-2';
      await gameEngine.initializePlayer(userId);
      
      const discovery = await gameEngine.addDiscovery(userId, 'welcome_message');
      
      expect(discovery).toBeDefined();
      
      const player = await gameEngine.getPlayerState(userId);
      expect(player.xp).toBeGreaterThan(0);
      expect(player.discoveries).toContain('welcome_message');
    });
  });
});
```

### 9. Monitoring & Observability

#### 9.1 Logging Strategy

```typescript
// utils/logger.ts
import winston from 'winston';
import { config } from '../config/environment';

const logger = winston.createLogger({
  level: config.LOG_LEVEL,
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { 
    service: 'network-chronicles-v2',
    version: process.env.npm_package_version 
  },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    ...(config.NODE_ENV !== 'production' ? [
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.colorize(),
          winston.format.simple()
        )
      })
    ] : [])
  ]
});

// Structured logging helpers
export const gameLogger = {
  playerAction: (userId: string, action: string, details: any) => {
    logger.info('Player action', {
      userId,
      action,
      details,
      category: 'player_action'
    });
  },
  
  questCompletion: (userId: string, questId: string, xpAwarded: number) => {
    logger.info('Quest completed', {
      userId,
      questId,
      xpAwarded,
      category: 'quest_completion'
    });
  },
  
  llmInteraction: (userId: string, sessionId: string, messageLength: number, responseTime: number) => {
    logger.info('LLM interaction', {
      userId,
      sessionId,
      messageLength,
      responseTime,
      category: 'llm_interaction'
    });
  },
  
  error: (operation: string, error: Error, context?: any) => {
    logger.error('Operation failed', {
      operation,
      error: error.message,
      stack: error.stack,
      context,
      category: 'error'
    });
  }
};
```

#### 9.2 Metrics Collection

```typescript
// utils/metrics.ts
import { Counter, Histogram, Gauge, register } from 'prom-client';

// Application metrics
export const metrics = {
  httpRequests: new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code']
  }),
  
  httpDuration: new Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route']
  }),
  
  activeUsers: new Gauge({
    name: 'active_users_total',
    help: 'Number of currently active users'
  }),
  
  questCompletions: new Counter({
    name: 'quest_completions_total',
    help: 'Total number of completed quests',
    labelNames: ['quest_id', 'tier']
  }),
  
  discoveries: new Counter({
    name: 'discoveries_total',
    help: 'Total number of discoveries made',
    labelNames: ['discovery_id', 'player_tier']
  }),
  
  llmRequests: new Counter({
    name: 'llm_requests_total',
    help: 'Total number of LLM requests',
    labelNames: ['model', 'status']
  }),
  
  llmLatency: new Histogram({
    name: 'llm_request_duration_seconds',
    help: 'Duration of LLM requests in seconds',
    labelNames: ['model']
  }),
  
  databaseConnections: new Gauge({
    name: 'database_connections_active',
    help: 'Number of active database connections'
  }),
  
  redisConnections: new Gauge({
    name: 'redis_connections_active',
    help: 'Number of active Redis connections'
  })
};

// Metrics middleware
export const metricsMiddleware = (req: Request, res: Response, next: NextFunction) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    metrics.httpRequests.inc({
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    });
    
    metrics.httpDuration.observe({
      method: req.method,
      route: req.route?.path || req.path
    }, duration);
  });
  
  next();
};
```

### 10. Migration Strategy from V1 to V2

#### 10.1 Data Migration Plan

```typescript
// scripts/migrate-v1-to-v2.ts
class V1ToV2Migrator {
  async migratePlayerData(v1DataDir: string) {
    const playersDir = path.join(v1DataDir, 'players');
    const players = await fs.readdir(playersDir);
    
    for (const playerId of players) {
      try {
        // Read V1 player profile
        const v1Profile = await this.readV1Profile(playersDir, playerId);
        
        // Create V2 user account
        const user = await this.createV2User(playerId, v1Profile);
        
        // Migrate player state
        await this.migratePlayerState(user.id, v1Profile);
        
        // Migrate journal entries
        await this.migrateJournalEntries(user.id, playersDir, playerId);
        
        // Migrate discoveries
        await this.migrateDiscoveries(user.id, v1Profile.discoveries);
        
        this.logger.info(`Migrated player: ${playerId}`);
      } catch (error) {
        this.logger.error(`Failed to migrate player ${playerId}:`, error);
      }
    }
  }
  
  private async createV2User(playerId: string, v1Profile: any) {
    const hashedPassword = await bcrypt.hash('temp-password-' + Date.now(), 10);
    
    return await this.database.user.create({
      data: {
        username: playerId,
        email: `${playerId}@migrated.local`,
        passwordHash: hashedPassword,
        role: 'player',
        player: {
          create: {
            name: v1Profile.name || playerId,
            tier: v1Profile.tier || 1,
            xp: v1Profile.xp || 0
          }
        }
      },
      include: { player: true }
    });
  }
}

// Migration command
async function runMigration() {
  const migrator = new V1ToV2Migrator();
  await migrator.migratePlayerData('/opt/network-chronicles/data');
  console.log('Migration completed');
}
```

#### 10.2 Backward Compatibility

```bash
#!/bin/bash
# Legacy shell command wrapper for V2 API

# V1 commands that need to work in V2
case "$1" in
  "nc-status")
    curl -s -H "Authorization: Bearer $(cat ~/.nc_token)" \
      "$NC_API_URL/api/v1/players/me" | jq -r '.status'
    ;;
  "nc-add-discovery")
    curl -s -X POST -H "Authorization: Bearer $(cat ~/.nc_token)" \
      -H "Content-Type: application/json" \
      -d "{\"discoveryId\":\"$2\"}" \
      "$NC_API_URL/api/v1/game/discoveries"
    ;;
  "nc-journal")
    curl -s -H "Authorization: Bearer $(cat ~/.nc_token)" \
      "$NC_API_URL/api/v1/journal/entries" | jq -r '.entries[]'
    ;;
  *)
    echo "Command not recognized in V2. Please check documentation."
    exit 1
    ;;
esac
```

---

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-4)
- Set up PostgreSQL database schema
- Implement basic authentication service
- Create core API endpoints
- Set up Docker development environment
- Implement basic game engine service

### Phase 2: Core Features (Weeks 5-8)
- Complete player management system
- Implement quest and discovery systems
- Add journal functionality
- Create basic web UI
- Set up Redis integration

### Phase 3: Advanced Features (Weeks 9-12)
- Implement LLM service integration
- Add real-time multiplayer features
- Create comprehensive shell integration
- Implement caching and performance optimizations
- Add monitoring and logging

### Phase 4: Production Readiness (Weeks 13-16)
- Security hardening and auditing
- Complete test coverage
- Performance optimization
- CI/CD pipeline setup
- Migration tools and documentation

### Phase 5: Launch & Scale (Weeks 17-20)
- Production deployment
- V1 to V2 migration
- User acceptance testing
- Performance monitoring
- Horizontal scaling setup

---

## Conclusion

This technical architecture provides a comprehensive blueprint for transforming Network Chronicles from a proof-of-concept file-based system into a production-ready, scalable platform. The V2 architecture addresses all major limitations of V1 while maintaining the core gaming experience that makes the system unique.

Key benefits of this architecture:

1. **Scalability**: Supports hundreds of concurrent users
2. **Security**: Enterprise-grade authentication and authorization
3. **Maintainability**: Clean separation of concerns and microservices architecture
4. **Performance**: Multi-layer caching and database optimization
5. **Extensibility**: Plugin architecture for new features
6. **Reliability**: Comprehensive monitoring, logging, and error handling
7. **Developer Experience**: Modern tooling, testing, and deployment practices

The implementation roadmap provides a realistic timeline for development while ensuring each phase delivers working, testable functionality. This approach minimizes risk while enabling continuous feedback and iteration.