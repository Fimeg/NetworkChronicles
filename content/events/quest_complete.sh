#!/bin/bash
# quest_complete.sh - Event handler for quest completion

PLAYER_ID="$1"
QUEST_ID="$2"
GAME_ROOT="/opt/network-chronicles"
PLAYER_STATE="${GAME_ROOT}/data/players/${PLAYER_ID}"
CONTENT_DIR="${GAME_ROOT}/content"

# Get quest data
QUEST_FILE="${CONTENT_DIR}/narrative/quests/${QUEST_ID}.json"
if [ ! -f "$QUEST_FILE" ]; then
  echo "Quest file not found: ${QUEST_FILE}" >&2
  exit 1
fi

QUEST_NAME=$(jq -r '.name' "$QUEST_FILE")
QUEST_XP=$(jq -r '.xp' "$QUEST_FILE")
NEXT_QUEST=$(jq -r '.next_quest // ""' "$QUEST_FILE")

# Add journal entry
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JOURNAL_FILE="${PLAYER_STATE}/journal.json"

# Create journal entry
tmp=$(mktemp)
jq ".entries += [{
  \"id\": \"quest_${QUEST_ID}_complete\",
  \"title\": \"Quest Completed: ${QUEST_NAME}\",
  \"content\": \"I have completed the quest '${QUEST_NAME}' and earned ${QUEST_XP} XP. This brings me one step closer to understanding what happened to The Architect.\",
  \"timestamp\": \"${TIMESTAMP}\"
}]" "$JOURNAL_FILE" > "$tmp" && mv "$tmp" "$JOURNAL_FILE"

# Check for tier up
TIER=$(jq -r '.tier' "${PLAYER_STATE}/profile.json")
XP=$(jq -r '.xp' "${PLAYER_STATE}/profile.json")
NEXT_TIER_XP=$((TIER * 1000))

if [ $XP -ge $NEXT_TIER_XP ]; then
  # Trigger tier up event
  "${CONTENT_DIR}/events/tier_up.sh" "$PLAYER_ID" "$((TIER + 1))"
fi

# If there's a next quest, provide information about it
if [ -n "$NEXT_QUEST" ] && [ "$NEXT_QUEST" != "null" ]; then
  NEXT_QUEST_FILE="${CONTENT_DIR}/narrative/quests/${NEXT_QUEST}.json"
  if [ -f "$NEXT_QUEST_FILE" ]; then
    NEXT_QUEST_NAME=$(jq -r '.name' "$NEXT_QUEST_FILE")
    echo -e "\n\033[1;36m[NEW QUEST]\033[0m ${NEXT_QUEST_NAME}"
    echo -e "Type 'nc-status' to see details about your new quest.\n"
  fi
fi

exit 0
