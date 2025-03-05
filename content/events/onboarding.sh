#!/bin/bash
#
# onboarding.sh - Event handler for new player onboarding
#
# Part of Network Chronicles: The Vanishing Admin

# Import utilities
SCRIPT_DIR="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../.."
source "${SCRIPT_DIR}/bin/utils/config.sh"
source "${SCRIPT_DIR}/bin/utils/directory-management.sh"
source "${SCRIPT_DIR}/bin/utils/json-helpers.sh"

PLAYER_ID="$1"

# Get player profile path using utility
PLAYER_PROFILE=$(get_player_profile "$PLAYER_ID")

# No need to check if already triggered - the engine handles that now

# Ensure the story_flags object exists for backward compatibility
if ! json_get_value "$PLAYER_PROFILE" '.story_flags' > /dev/null 2>&1; then
  json_update_field "$PLAYER_PROFILE" '.story_flags' '{}'
fi

# Mark as complete in story_flags for backward compatibility
json_update_field "$PLAYER_PROFILE" '.story_flags.onboarding_complete' 'true'

# Ensure player documents directory exists using utility
ensure_player_documents "$PLAYER_ID"

# Also ensure home Documents directory exists
mkdir -p "/home/${PLAYER_ID}/Documents"
cat > "/home/${PLAYER_ID}/Documents/welcome.txt" << 'EOF'
╔═════════════════════════════════════════════════════════════════════════════╗
║                                                                             ║
║      \033[1;36m_   _ _____ _________      _____  ____  _  __     \033[0m                      ║
║     \033[1;36m| \ | | ____|_   _\ \ \ /\ / / _ \|  _ \| |/ /     \033[0m                      ║
║     \033[1;36m|  \| |  _|   | |  \ \ V  V / | | | |_) | ' /      \033[0m                      ║
║     \033[1;36m| |\  | |___  | |   \ \ /\ / /| |_| |  _/| . \     \033[0m                      ║
║     \033[1;36m|_| \_|_____| |_|    \_/  \_/  \___/|_|  |_|\_\    \033[0m                      ║
║                                                                             ║
║       \033[1;33m____ _   _ ____   ___  _   _ ___ ____ _     _____ ____     \033[0m           ║
║      \033[1;33m/ ___| | | |  _ \ / _ \| \ | |_ _/ ___| |   | ____/ ___|    \033[0m           ║
║     \033[1;33m| |   | |_| | |_) | | | |  \| || | |   | |   |  _| \___ \    \033[0m           ║
║     \033[1;33m| |___|  _  |  _ <| |_| | |\  || | |___| |___| |___ ___) |   \033[0m           ║
║      \033[1;33m\____|_| |_|_| \_\\___/|_| \_|___\____|_____|_____|____/    \033[0m           ║
║                                                                             ║
║                    \033[1;31m[ THE VANISHING ADMIN ]\033[0m                                   ║
║                                                                             ║
╚═════════════════════════════════════════════════════════════════════════════╝

\033[1;93m╭───────────────────────── URGENT BRIEFING ─────────────────────────╮\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m \033[1;97mFROM: Chief Technology Officer\033[0m                             \033[1;93m│\033[0m
\033[1;93m│\033[0m \033[1;97mTO: New System Administrator\033[0m                              \033[1;93m│\033[0m
\033[1;93m│\033[0m \033[1;97mSUBJECT: Emergency Onboarding\033[0m                             \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m Your predecessor, known only as "The Architect," has         \033[1;93m│\033[0m
\033[1;93m│\033[0m disappeared without warning. Security footage shows them     \033[1;93m│\033[0m
\033[1;93m│\033[0m entering their office three days ago at 02:37 AM, but never  \033[1;93m│\033[0m
\033[1;93m│\033[0m leaving. Their access card was found on their desk along     \033[1;93m│\033[0m
\033[1;93m│\033[0m with a half-empty cup of coffee, laptop missing.             \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m We need you to:                                              \033[1;93m│\033[0m
\033[1;93m│\033[0m  1. Take over critical system administration duties          \033[1;93m│\033[0m
\033[1;93m│\033[0m  2. Map our network infrastructure                           \033[1;93m│\033[0m
\033[1;93m│\033[0m  3. Investigate strange system behavior we've noticed        \033[1;93m│\033[0m
\033[1;93m│\033[0m  4. Determine what happened to The Architect                 \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m The company can't afford downtime. Clients rely on these     \033[1;93m│\033[0m
\033[1;93m│\033[0m systems for mission-critical operations. We've restricted    \033[1;93m│\033[0m
\033[1;93m│\033[0m news of The Architect's disappearance to senior management.  \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m We've detected unusual outgoing traffic patterns. The        \033[1;93m│\033[0m
\033[1;93m│\033[0m Architect may have left clues about what they discovered.    \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m│\033[0m Access what you need. Document everything. Trust no one.     \033[1;93m│\033[0m
\033[1;93m│\033[0m                                                               \033[1;93m│\033[0m
\033[1;93m╰───────────────────────────────────────────────────────────────────╯\033[0m

\033[1;92m▶ BEGIN YOUR INVESTIGATION\033[0m

To begin your journey:

1. Type '\033[1;36mnc-status\033[0m' to see your current status
2. Type '\033[1;36mnc-journal\033[0m' to view your journal
3. Type '\033[1;36mnc-help\033[0m' for more commands

Look for hidden files and messages. The Architect was known to hide
important information in unexpected places.

\033[1;31m"They're watching. Find the truth before they find you." - The Architect\033[0m
EOF

# Create hidden clue
mkdir -p "/home/${PLAYER_ID}/.local/share/network-chronicles"
ln -sf "${GAME_ROOT}/content/artifacts/welcome_message.txt" "/home/${PLAYER_ID}/.local/share/network-chronicles/message.txt"

# Add notification
echo -e "\n\033[1;32m[WELCOME]\033[0m Welcome to Network Chronicles: The Vanishing Admin"
echo -e "Check your Documents folder for a welcome message."
echo -e "Type 'nc-help' to see available commands.\n"

exit 0
