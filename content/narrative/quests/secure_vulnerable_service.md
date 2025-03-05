# Secure Vulnerable Service

Your investigation has revealed that an attacker targeted the system with repeated login attempts. The Architect was tracking this activity before disappearing. Now, you need to secure the vulnerable service to prevent further unauthorized access.

## Objectives

1. Identify the vulnerable service that was targeted
2. Implement a firewall rule to block the attacker's IP (45.33.22.156)
3. Configure two-factor authentication for the admin account
4. Document your security changes in your journal

## Hints

- Use `iptables` or `ufw` to configure firewall rules
- Look for authentication configuration files in `/etc/ssh` and `/etc/pam.d`
- The Architect may have left a security checklist somewhere in the system
- Test your changes to ensure they don't break legitimate access

## Rewards

- Firewall configuration tool
- Security Specialist Badge (Tier 1)
- XP towards Tier 2 access
- Increased reputation with the Security department