# Discover Network Services

Now that you've mapped the basic network infrastructure, it's time to identify the services running on this network. The Architect must have set up various services for specific purposes, and understanding what's running could provide critical clues.

## Objectives:
- Scan the network to discover running services
- Document what you find in your journal
- Look for unusual or unexpected services

## Approach:
1. Use the `nc-discover-services` command to run an automated service discovery
2. Alternatively, use common network tools like `ss -tuln`, `netstat -tuln`, or `lsof -i` to find services
3. Examine the discovered services for anything suspicious or noteworthy

## Hints:
- Services run on specific ports (e.g., HTTP on 80, SSH on 22)
- Standard services are expected, but custom services on unusual ports could be significant
- The Architect might have left messages or clues in service configurations

Remember: Document everything you find. What seems unimportant now might be the key to solving the mystery later.