#!/bin/bash
# Network Chronicles V3 - Complete Linux Learning Terminal Game
# Single file, fully functional, no external dependencies

VERSION="3.0.0"
GAME_DIR="$HOME/.network-chronicles-v3"
PLAYER_FILE="$GAME_DIR/player.json"
SAVE_FILE="$GAME_DIR/save.dat"
LOG_FILE="$GAME_DIR/game.log"

# Colors
R='\033[0;31m'    # Red
G='\033[0;32m'    # Green  
Y='\033[1;33m'    # Yellow
B='\033[0;34m'    # Blue
P='\033[0;35m'    # Purple
C='\033[0;36m'    # Cyan
W='\033[1;37m'    # White
N='\033[0m'       # Reset

# Initialize game data
init_game() {
    mkdir -p "$GAME_DIR"
    
    if [[ ! -f "$PLAYER_FILE" ]]; then
        cat > "$PLAYER_FILE" << 'EOF'
{
  "name": "New Admin",
  "level": 1,
  "xp": 0,
  "skills": {
    "files": 0,
    "network": 0,
    "security": 0,
    "system": 0
  },
  "current_quest": "welcome",
  "completed_quests": [],
  "discoveries": [],
  "inventory": ["terminal_access"],
  "location": "home",
  "story_flags": {
    "found_admin_note": false,
    "discovered_network": false,
    "found_vulnerability": false,
    "contacted_architect": false
  }
}
EOF
    fi
}

# JSON helper functions
json_get() {
    local file="$1"
    local key="$2"
    python3 -c "
import json, sys
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    keys = '$key'.split('.')
    result = data
    for k in keys:
        if k.isdigit():
            result = result[int(k)]
        else:
            result = result[k]
    print(result)
except:
    print('')
" 2>/dev/null
}

json_set() {
    local file="$1"
    local key="$2"
    local value="$3"
    python3 -c "
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    keys = '$key'.split('.')
    target = data
    for k in keys[:-1]:
        if k.isdigit():
            target = target[int(k)]
        else:
            target = target[k]
    last_key = keys[-1]
    if last_key.isdigit():
        target[int(last_key)] = '$value'
    else:
        if '$value'.isdigit():
            target[last_key] = int('$value')
        elif '$value' in ['true', 'false']:
            target[last_key] = '$value' == 'true'
        else:
            target[last_key] = '$value'
    with open('$file', 'w') as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
"
}

json_append() {
    local file="$1"
    local key="$2"
    local value="$3"
    python3 -c "
import json
try:
    with open('$file', 'r') as f:
        data = json.load(f)
    keys = '$key'.split('.')
    target = data
    for k in keys:
        if k.isdigit():
            target = target[int(k)]
        else:
            target = target[k]
    if '$value' not in target:
        target.append('$value')
    with open('$file', 'w') as f:
        json.dump(data, f, indent=2)
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
"
}

# Logging
log() {
    echo "[$(date '+%H:%M:%S')] $1" >> "$LOG_FILE"
}

# XP and leveling system
award_xp() {
    local amount="$1"
    local reason="$2"
    
    local current_xp=$(json_get "$PLAYER_FILE" "xp")
    local current_level=$(json_get "$PLAYER_FILE" "level")
    local new_xp=$((current_xp + amount))
    
    json_set "$PLAYER_FILE" "xp" "$new_xp"
    
    # Level up every 100 XP
    local new_level=$(((new_xp / 100) + 1))
    if [[ $new_level -gt $current_level ]]; then
        json_set "$PLAYER_FILE" "level" "$new_level"
        echo -e "${Y}🎉 LEVEL UP! You are now level $new_level!${N}"
        log "LEVEL_UP: $new_level"
    fi
    
    echo -e "${G}+$amount XP${N} - $reason"
    log "XP_GAIN: $amount ($reason)"
}

# Skill system
add_skill() {
    local skill="$1"
    local amount="$2"
    
    local current=$(json_get "$PLAYER_FILE" "skills.$skill")
    local new_val=$((current + amount))
    json_set "$PLAYER_FILE" "skills.$skill" "$new_val"
    
    echo -e "${C}+$amount $skill skill${N}"
}

# Discovery system
add_discovery() {
    local discovery="$1"
    local xp_reward="${2:-25}"
    
    # Check if already discovered
    local discoveries=$(json_get "$PLAYER_FILE" "discoveries")
    if echo "$discoveries" | grep -q "$discovery"; then
        echo -e "${Y}You've already discovered this!${N}"
        return
    fi
    
    json_append "$PLAYER_FILE" "discoveries" "$discovery"
    award_xp "$xp_reward" "Discovery: $discovery"
    
    case "$discovery" in
        "admin_note")
            json_set "$PLAYER_FILE" "story_flags.found_admin_note" "true"
            echo -e "${P}📝 You found a mysterious note from the previous admin...${N}"
            ;;
        "network_map")
            json_set "$PLAYER_FILE" "story_flags.discovered_network" "true"
            add_skill "network" 2
            echo -e "${C}🌐 You've mapped the network topology!${N}"
            ;;
        "security_vulnerability")
            json_set "$PLAYER_FILE" "story_flags.found_vulnerability" "true"
            add_skill "security" 3
            echo -e "${R}🚨 Critical security vulnerability discovered!${N}"
            ;;
        "architect_contact")
            json_set "$PLAYER_FILE" "story_flags.contacted_architect" "true"
            add_skill "system" 2
            echo -e "${P}👤 You've made contact with 'The Architect'...${N}"
            ;;
    esac
}

# Quest system
get_current_quest() {
    json_get "$PLAYER_FILE" "current_quest"
}

complete_quest() {
    local quest="$1"
    local next_quest="$2"
    local xp_reward="${3:-100}"
    
    json_append "$PLAYER_FILE" "completed_quests" "$quest"
    json_set "$PLAYER_FILE" "current_quest" "$next_quest"
    award_xp "$xp_reward" "Quest completed: $quest"
    
    echo -e "${G}✅ Quest completed: $quest${N}"
    if [[ -n "$next_quest" && "$next_quest" != "none" ]]; then
        echo -e "${C}🎯 New quest available: $next_quest${N}"
    fi
}

# Teaching commands - these actually teach Linux
teach_command() {
    local cmd="$1"
    local description="$2"
    local example="$3"
    
    echo -e "${Y}💡 LINUX LESSON${N}"
    echo -e "${W}Command:${N} ${G}$cmd${N}"
    echo -e "${W}Description:${N} $description"
    echo -e "${W}Example:${N} ${C}$example${N}"
    echo
}

# Interactive command challenges
challenge_command() {
    local challenge_cmd="$1"
    local description="$2"
    local xp_reward="${3:-15}"
    
    echo -e "${Y}🎯 CHALLENGE:${N} $description"
    echo -e "Type the command: ${G}$challenge_cmd${N}"
    read -p "$(echo -e ${W}Enter command:${N} )" user_input
    
    if [[ "$user_input" == "$challenge_cmd" ]]; then
        echo -e "${G}✅ Correct!${N}"
        award_xp "$xp_reward" "Command challenge: $challenge_cmd"
        # Actually execute the command if safe
        case "$challenge_cmd" in
            "pwd"|"whoami"|"date"|"ls"|"ls -la"|"ls -l")
                echo -e "${C}Output:${N}"
                eval "$challenge_cmd"
                ;;
        esac
        return 0
    else
        echo -e "${R}❌ Incorrect. The correct command was: $challenge_cmd${N}"
        return 1
    fi
}

# Real Linux discovery simulation
simulate_discovery() {
    local cmd="$1"
    
    case "$cmd" in
        *"ls -la"*|*"ls -a"*)
            if [[ $(get_current_quest) == "file_basics" ]]; then
                echo -e "${G}🔍 You discovered hidden files!${N}"
                add_discovery "hidden_files" 20
            fi
            ;;
        *"ps aux"*|*"ps -ef"*)
            echo -e "${C}📋 Process list discovered${N}"
            add_skill "system" 1
            award_xp 10 "Process monitoring"
            ;;
        *"netstat"*|*"ss -"*)
            echo -e "${C}🌐 Network connections analyzed${N}"
            add_skill "network" 1
            award_xp 15 "Network analysis"
            ;;
        *"sudo"*)
            echo -e "${R}⚡ Administrative command used${N}"
            add_skill "security" 1
            award_xp 20 "Administrative access"
            ;;
        *"grep"*|*"find"*|*"locate"*)
            echo -e "${Y}🔎 Search command mastered${N}"
            add_skill "files" 1
            award_xp 10 "File searching"
            ;;
    esac
}

# Quest implementations
quest_welcome() {
    echo -e "${P}═══ QUEST: The Vanishing Admin ═══${N}"
    echo -e "${Y}You've just been hired as a junior systems administrator.${N}"
    echo -e "${Y}The previous admin, known only as 'The Architect', has vanished.${N}"
    echo -e "${Y}Your first task: learn basic Linux commands to investigate.${N}"
    echo
    
    teach_command "pwd" "Print working directory - shows where you are" "pwd"
    
    if challenge_command "pwd" "Find your current location"; then
        teach_command "whoami" "Shows your current username" "whoami"
        if challenge_command "whoami" "Identify yourself"; then
            complete_quest "welcome" "file_basics" 50
            echo -e "${C}You're getting the hang of this! Time to learn file operations.${N}"
        fi
    fi
}

quest_file_basics() {
    echo -e "${P}═══ QUEST: File System Mastery ═══${N}"
    echo -e "${Y}The Architect left files scattered around the system.${N}"
    echo -e "${Y}Learn file commands to uncover clues.${N}"
    echo
    
    teach_command "ls" "List files in current directory" "ls"
    teach_command "ls -la" "List all files including hidden ones" "ls -la"
    
    if challenge_command "ls" "List files in current directory"; then
        if challenge_command "ls -la" "Show all files including hidden ones"; then
            echo
            teach_command "cat" "Display file contents" "cat filename.txt"
            teach_command "less" "View file contents page by page" "less filename.txt"
            
            # Simulate finding the admin note
            echo -e "${Y}💡 TIP: Look for hidden files (starting with .) in your home directory${N}"
            echo -e "${Y}When you find something interesting, use the 'discover' command!${N}"
            
            complete_quest "file_basics" "network_discovery" 75
        fi
    fi
}

quest_network_discovery() {
    echo -e "${P}═══ QUEST: Network Investigation ═══${N}"
    echo -e "${Y}The Architect's notes mention network anomalies.${N}"
    echo -e "${Y}Time to learn network commands.${N}"
    echo
    
    teach_command "ip addr" "Show network interfaces and IP addresses" "ip addr show"
    teach_command "ping" "Test network connectivity" "ping -c 3 google.com"
    teach_command "netstat -tuln" "Show listening network services" "netstat -tuln"
    
    if challenge_command "ip addr" "Check your network configuration"; then
        echo
        teach_command "ss -tuln" "Modern replacement for netstat" "ss -tuln"
        
        if challenge_command "ping -c 3 8.8.8.8" "Test internet connectivity"; then
            echo -e "${G}🌐 Network connectivity confirmed!${N}"
            add_discovery "network_map" 50
            complete_quest "network_discovery" "security_audit" 100
        fi
    fi
}

quest_security_audit() {
    echo -e "${P}═══ QUEST: Security Assessment ═══${N}"
    echo -e "${Y}Something's not right with the system security.${N}"
    echo -e "${Y}Learn security commands to investigate.${N}"
    echo
    
    teach_command "sudo" "Execute commands as administrator" "sudo command"
    teach_command "ps aux" "List all running processes" "ps aux"
    teach_command "systemctl status" "Check service status" "systemctl status servicename"
    
    if challenge_command "ps aux" "List all running processes"; then
        echo -e "${Y}🔍 Examining processes for anomalies...${N}"
        echo -e "${R}⚠️  Suspicious process detected: unknown_service${N}"
        
        teach_command "kill" "Terminate a process" "kill PID"
        teach_command "systemctl stop" "Stop a system service" "sudo systemctl stop servicename"
        
        echo -e "${Y}💡 You've discovered a security vulnerability!${N}"
        add_discovery "security_vulnerability" 75
        complete_quest "security_audit" "architect_contact" 150
    fi
}

quest_architect_contact() {
    echo -e "${P}═══ QUEST: The Architect's Message ═══${N}"
    echo -e "${Y}Your investigation has triggered an automated response...${N}"
    echo
    
    # Simulate encrypted message
    echo -e "${C}╔═══════════════════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${N} ${R}ENCRYPTED MESSAGE FROM THE ARCHITECT${N}                        ${C}║${N}"
    echo -e "${C}╠═══════════════════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${N} Well done, junior admin. You've proven your worth.           ${C}║${N}"
    echo -e "${C}║${N} The system breach was deliberate - a test I designed.        ${C}║${N}"
    echo -e "${C}║${N} You've demonstrated mastery of essential Linux skills:       ${C}║${N}"
    echo -e "${C}║${N} - File system navigation and manipulation                    ${C}║${N}"
    echo -e "${C}║${N} - Network configuration and troubleshooting                  ${C}║${N}"
    echo -e "${C}║${N} - Security assessment and threat detection                   ${C}║${N}"
    echo -e "${C}║${N} - Process management and system administration               ${C}║${N}"
    echo -e "${C}║${N}                                                              ${C}║${N}"
    echo -e "${C}║${N} You are ready for the real challenges ahead.                ${C}║${N}"
    echo -e "${C}║${N} Welcome to the team, Administrator.                         ${C}║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════════════════╝${N}"
    
    add_discovery "architect_contact" 100
    complete_quest "architect_contact" "none" 200
    
    echo
    echo -e "${G}🎉 CONGRATULATIONS! You've completed Network Chronicles V3!${N}"
    echo -e "${Y}You've learned essential Linux administration skills through gameplay.${N}"
}

# Status display
show_status() {
    local name=$(json_get "$PLAYER_FILE" "name")
    local level=$(json_get "$PLAYER_FILE" "level")
    local xp=$(json_get "$PLAYER_FILE" "xp")
    local quest=$(json_get "$PLAYER_FILE" "current_quest")
    
    local file_skill=$(json_get "$PLAYER_FILE" "skills.files")
    local network_skill=$(json_get "$PLAYER_FILE" "skills.network")
    local security_skill=$(json_get "$PLAYER_FILE" "skills.security")
    local system_skill=$(json_get "$PLAYER_FILE" "skills.system")
    
    local xp_next=$((level * 100))
    local xp_progress=$((xp % 100))
    local progress_bar=""
    for i in $(seq 1 20); do
        if [[ $i -le $((xp_progress / 5)) ]]; then
            progress_bar+="█"
        else
            progress_bar+="░"
        fi
    done
    
    echo -e "${C}╔═══════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${N}              ${Y}NETWORK CHRONICLES V3${N}              ${C}║${N}"
    echo -e "${C}╠═══════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${N} ${W}Player:${N} ${G}$name${N}"
    echo -e "${C}║${N} ${W}Level:${N} ${Y}$level${N} | ${W}XP:${N} ${C}$xp${N}/${xp_next}"
    echo -e "${C}║${N} ${W}Progress:${N} [${G}$progress_bar${N}] ${xp_progress}%"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${W}Skills:${N}"
    echo -e "${C}║${N}   ${Y}Files:${N} $file_skill | ${Y}Network:${N} $network_skill"
    echo -e "${C}║${N}   ${Y}Security:${N} $security_skill | ${Y}System:${N} $system_skill"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${W}Current Quest:${N} ${P}$quest${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════╝${N}"
}

# Discovery system for real commands
discover() {
    local item="$1"
    
    case "$item" in
        "admin_note")
            echo -e "${P}📝 You found a hidden note in ~/.local/share/admin_notes/${N}"
            echo -e "${Y}It reads: 'The system has been compromised. Look for unusual network activity.'${N}"
            add_discovery "admin_note" 30
            ;;
        "hidden_files")
            echo -e "${G}🔍 You discovered the power of hidden files!${N}"
            add_discovery "hidden_files" 25
            ;;
        *)
            echo -e "${R}Unknown discovery: $item${N}"
            ;;
    esac
}

# Help system
show_help() {
    echo -e "${C}═══════════════════════════════════════════════════════════════════${N}"
    echo -e "${Y}                    NETWORK CHRONICLES V3 - HELP${N}"
    echo -e "${C}═══════════════════════════════════════════════════════════════════${N}"
    echo
    echo -e "${W}GAME COMMANDS:${N}"
    echo -e "  ${G}start${N}       - Start or continue your current quest"
    echo -e "  ${G}status${N}      - Show your character status and progress"
    echo -e "  ${G}help${N}        - Show this help message"
    echo -e "  ${G}discover <item>${N} - Record a discovery"
    echo -e "  ${G}skills${N}      - Show detailed skill breakdown"
    echo -e "  ${G}journal${N}     - View your progress journal"
    echo -e "  ${G}quit${N}        - Exit the game"
    echo
    echo -e "${W}LINUX COMMANDS YOU'LL LEARN:${N}"
    echo -e "  ${C}pwd${N}         - Print working directory"
    echo -e "  ${C}ls${N}          - List directory contents"
    echo -e "  ${C}cat${N}         - Display file contents"
    echo -e "  ${C}grep${N}        - Search text in files"
    echo -e "  ${C}ps${N}          - List running processes"
    echo -e "  ${C}netstat${N}     - Show network connections"
    echo -e "  ${C}sudo${N}        - Execute as administrator"
    echo
    echo -e "${W}TIPS:${N}"
    echo -e "  • Pay attention to the command lessons"
    echo -e "  • Practice the commands in your real terminal"
    echo -e "  • Look for hidden files with ${C}ls -la${N}"
    echo -e "  • Use ${G}discover${N} when you find something interesting"
    echo
}

# Skills breakdown
show_skills() {
    local file_skill=$(json_get "$PLAYER_FILE" "skills.files")
    local network_skill=$(json_get "$PLAYER_FILE" "skills.network")
    local security_skill=$(json_get "$PLAYER_FILE" "skills.security")
    local system_skill=$(json_get "$PLAYER_FILE" "skills.system")
    
    echo -e "${C}╔═══════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${N}                 ${Y}SKILL BREAKDOWN${N}                 ${C}║${N}"
    echo -e "${C}╠═══════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}📁 File Operations:${N} Level $file_skill"
    echo -e "${C}║${N}    Navigation, viewing, editing files"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}🌐 Network Skills:${N} Level $network_skill"
    echo -e "${C}║${N}    IP configuration, connectivity, analysis"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}🔒 Security Knowledge:${N} Level $security_skill"
    echo -e "${C}║${N}    Threat detection, access control"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}⚙️  System Administration:${N} Level $system_skill"
    echo -e "${C}║${N}    Process management, services"
    echo -e "${C}║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════╝${N}"
}

# Journal system
show_journal() {
    local completed=$(json_get "$PLAYER_FILE" "completed_quests")
    local discoveries=$(json_get "$PLAYER_FILE" "discoveries")
    
    echo -e "${C}╔═══════════════════════════════════════════════════╗${N}"
    echo -e "${C}║${N}                  ${Y}JOURNAL${N}                      ${C}║${N}"
    echo -e "${C}╠═══════════════════════════════════════════════════╣${N}"
    echo -e "${C}║${N} ${W}Learning Log - Linux Administration${N}"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}Today I learned:${N}"
    echo -e "${C}║${N} • How to navigate the Linux filesystem"
    echo -e "${C}║${N} • File viewing and manipulation commands"
    echo -e "${C}║${N} • Network configuration analysis"
    echo -e "${C}║${N} • Process monitoring and management"
    echo -e "${C}║${N} • Security threat detection"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}Commands mastered:${N}"
    echo -e "${C}║${N} pwd, whoami, ls, cat, ps, netstat, ping"
    echo -e "${C}║${N}"
    echo -e "${C}║${N} ${Y}The mystery:${N}"
    echo -e "${C}║${N} The Architect created this challenge to test"
    echo -e "${C}║${N} my Linux skills. Mission accomplished!"
    echo -e "${C}║${N}"
    echo -e "${C}╚═══════════════════════════════════════════════════╝${N}"
}

# Command simulator for learning
simulate_linux_command() {
    local cmd="$1"
    shift
    local args="$@"
    
    echo -e "${C}💻 Simulating: $cmd $args${N}"
    
    case "$cmd" in
        "pwd")
            echo "/home/$(whoami)"
            ;;
        "whoami")
            echo "$(whoami)"
            ;;
        "ls")
            if [[ "$args" == *"-a"* ]]; then
                echo -e ".  ..  .bashrc  .profile  Documents  .admin_notes"
            else
                echo -e "Documents  Downloads  Desktop"
            fi
            ;;
        "ps")
            echo -e "PID   USER     COMMAND"
            echo -e "1     root     /sbin/init"
            echo -e "1234  user     bash"
            echo -e "5678  root     unknown_service"
            ;;
        "netstat")
            echo -e "Proto Local Address    State"
            echo -e "tcp   127.0.0.1:22     LISTEN"
            echo -e "tcp   0.0.0.0:80       LISTEN"
            echo -e "tcp   192.168.1.100:8080 SUSPICIOUS"
            ;;
        *)
            echo -e "${Y}Command executed successfully${N}"
            ;;
    esac
    
    simulate_discovery "$cmd $args"
}

# Main game loop
main() {
    init_game
    
    echo -e "${G}╔════════════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}║${N}                                                               ${G}║${N}"
    echo -e "${G}║${N}           ${Y}🖥️  NETWORK CHRONICLES V3 🖥️${N}                    ${G}║${N}"
    echo -e "${G}║${N}                                                               ${G}║${N}"
    echo -e "${G}║${N}              ${W}Linux Learning Adventure${N}                     ${G}║${N}"
    echo -e "${G}║${N}                                                               ${G}║${N}"
    echo -e "${G}╚════════════════════════════════════════════════════════════════╝${N}"
    echo
    echo -e "${Y}Welcome to the most comprehensive Linux learning game!${N}"
    echo -e "${C}Type 'help' for commands or 'start' to begin your journey.${N}"
    echo
    
    while true; do
        echo -en "${W}chronicles> ${N}"
        read -r input
        
        case "$input" in
            "start")
                local quest=$(get_current_quest)
                case "$quest" in
                    "welcome") quest_welcome ;;
                    "file_basics") quest_file_basics ;;
                    "network_discovery") quest_network_discovery ;;
                    "security_audit") quest_security_audit ;;
                    "architect_contact") quest_architect_contact ;;
                    "none") echo -e "${G}🎉 You've completed all quests! Congratulations, Administrator!${N}" ;;
                    *) echo -e "${R}Unknown quest: $quest${N}" ;;
                esac
                ;;
            "status")
                show_status
                ;;
            "help")
                show_help
                ;;
            "skills")
                show_skills
                ;;
            "journal")
                show_journal
                ;;
            "discover "*)
                discover "${input#discover }"
                ;;
            "quit"|"exit")
                echo -e "${G}Thanks for playing Network Chronicles V3!${N}"
                echo -e "${Y}Keep practicing those Linux commands! 🐧${N}"
                exit 0
                ;;
            "")
                continue
                ;;
            # Hidden feature: allow real command simulation
            "sim "*)
                cmd_line="${input#sim }"
                simulate_linux_command $cmd_line
                ;;
            *)
                echo -e "${R}Unknown command: $input${N}"
                echo -e "${Y}Type 'help' for available commands.${N}"
                ;;
        esac
        echo
    done
}

# Run the game
main "$@"