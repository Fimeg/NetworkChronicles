# The Architect LLM Integration

This document describes the LLM-powered Architect feature for Network Chronicles.

## Overview

The Architect is a mysterious character in the game who has "vanished" but left behind clues and can communicate with the player through a secure channel. This implementation uses an LLM (Large Language Model) to create dynamic, contextually aware interactions with the player that enhance the narrative experience.

## Components

The Architect feature includes the following components:

1. **Context Manager** (`bin/utils/context-manager.sh`)
   - Gathers player state and game information
   - Manages conversation history
   - Formats context for LLM prompting

2. **Architect Agent** (`bin/architect-agent.sh`)
   - Handles communication with the LLM API
   - Manages prompt construction
   - Processes and stylizes responses

3. **Player Interface** (`nc-contact-architect.sh`)
   - Simple wrapper script for player interactions
   - Creates immersive interface

4. **Event Trigger** (`content/events/architect_contact.sh`)
   - Introduces the secure channel to the player
   - Adds relevant journal entries

5. **Trigger Definition** (`content/triggers/architect_contact.json`)
   - Defines when the Architect can be contacted
   - Lists requirements (tier, discoveries, etc.)

## Configuration

To use this feature, you need to configure an LLM API key in `config/api_keys.conf`. The system supports:

- Anthropic's Claude API (default)
- OpenAI's GPT API (requires endpoint change)

## Testing

For development and testing, use the `bin/architect-contact-demo.sh` script to manually trigger the Architect contact event regardless of player state.

## The Architect's Character

The Architect is characterized as:

- Knowledgeable but cryptic
- Paranoid and methodical
- Technical and precise
- Mysterious but helpful

The Architect's responses are deliberately cryptic and styled to appear as if coming through a secure, unstable connection.

## Technical Implementation

The system uses a contextual prompting approach where:

1. The context manager gathers player progress, discoveries, journal entries
2. This context is combined with conversation history
3. A base character definition prompt sets The Architect's personality
4. The LLM receives the context, history, and user message
5. The response is styled to match the game's aesthetic

## Narrative Integration

The Architect serves several narrative functions:

- Provides hints when players are stuck
- Deepens the mystery of what happened in the network
- Adds a personal connection to the storyline
- Gradually reveals more information as players progress

## Future Enhancements

Planned improvements include:

- More complex reasoning about player progress
- Adaptive difficulty based on player skill
- Multi-stage puzzles/challenges from The Architect
- Integration with other game systems