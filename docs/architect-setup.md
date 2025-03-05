# Setting Up The Architect LLM Integration

This guide will help you configure the Architect LLM feature for Network Chronicles.

## Prerequisites

1. A Network Chronicles installation
2. An API key for an LLM service (Anthropic Claude or OpenAI GPT)
3. Basic bash scripting knowledge for customization

## Installation Steps

1. **Configure API Keys**

   Edit the `config/api_keys.conf` file and add your API key:

   ```bash
   # For Anthropic Claude (default)
   ARCHITECT_API_KEY="your_claude_api_key_here"
   
   # For OpenAI GPT (uncomment and replace)
   # ARCHITECT_API_ENDPOINT="https://api.openai.com/v1/chat/completions"
   # ARCHITECT_API_KEY="your_openai_key_here"
   ```

2. **Ensure Scripts Are Executable**

   Make sure all script files have execute permissions:

   ```bash
   chmod +x bin/utils/context-manager.sh
   chmod +x bin/architect-agent.sh
   chmod +x content/events/architect_contact.sh
   chmod +x nc-contact-architect.sh
   chmod +x bin/architect-contact-demo.sh
   ```

3. **Test The Feature**

   Run the demo script to test the Architect contact:

   ```bash
   ./bin/architect-contact-demo.sh
   ```

   Then connect to The Architect:

   ```bash
   ./nc-contact-architect.sh
   ```

4. **Customizing The Architect**

   To customize The Architect's personality or behavior:

   - Edit the system prompt in `bin/architect-agent.sh` (look for the `get_system_prompt()` function)
   - Adjust styling in the `stylize_message()` function
   - Modify trigger requirements in `content/triggers/architect_contact.json`

## Troubleshooting

If you encounter issues:

1. **API Connection Problems**
   - Verify your API key is correct
   - Check network connectivity
   - Look for error messages in the terminal

2. **Script Execution Issues**
   - Ensure all scripts have execute permissions
   - Check for proper bash path (`#!/bin/bash`)
   - Verify all dependent utilities are installed (jq, curl)

3. **Context Problems**
   - If The Architect doesn't seem aware of player progress, check `bin/utils/context-manager.sh`
   - Verify player profile and journal files exist and are readable

## Integration With Game Progression

The Architect contact is triggered when:

1. Player has reached at least Tier 2
2. Player has discovered the welcome message, network gateway, and local network
3. Player runs a journal or status command (matching the pattern in the trigger file)

You can modify these requirements by editing `content/triggers/architect_contact.json`.

## Advanced Customization

For advanced users, consider:

- Adding more complex triggering conditions
- Creating specialized conversation paths based on player discoveries
- Implementing triggers for The Architect to proactively contact the player
- Expanding context to include more game elements