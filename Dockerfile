FROM ubuntu:22.04

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    jq \
    openssl \
    git \
    nodejs \
    npm \
    vim \
    nano \
    curl \
    wget \
    iputils-ping \
    net-tools \
    iproute2 \
    bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create API keys directory and sample config
RUN mkdir -p /opt/network-chronicles/config \
    && echo '# API Keys for Network Chronicles\nARCHITECT_API_KEY="your_api_key_here"' > /opt/network-chronicles/config/api_keys.conf

# Create a non-root user with appropriate groups
RUN useradd -m -s /bin/bash player \
    && echo "player:discover" | chpasswd

# Set up Network Chronicles directory structure
RUN mkdir -p /opt/network-chronicles/bin \
    && mkdir -p /opt/network-chronicles/src \
    && mkdir -p /opt/network-chronicles/content \
    && mkdir -p /opt/network-chronicles/docs \
    && mkdir -p /opt/network-chronicles/config \
    && mkdir -p /opt/network-chronicles/logs \
    && mkdir -p /opt/network-chronicles/data/players/player \
    && mkdir -p /opt/network-chronicles/data/global \
    && mkdir -p /opt/network-chronicles/content/narrative/quests \
    && mkdir -p /opt/network-chronicles/content/narrative/messages \
    && mkdir -p /opt/network-chronicles/content/challenges \
    && mkdir -p /opt/network-chronicles/content/discoveries \
    && mkdir -p /opt/network-chronicles/content/events \
    && mkdir -p /opt/network-chronicles/content/triggers \
    && mkdir -p /opt/network-chronicles/content/artifacts \
    && mkdir -p /opt/network-chronicles/src/engine \
    && mkdir -p /opt/network-chronicles/src/ui \
    && mkdir -p /opt/network-chronicles/src/challenges \
    && mkdir -p /opt/network-chronicles/src/utils

# Set ownership of player-specific directories to the player user
RUN chown -R player:player /opt/network-chronicles/data/players/player \
    && chown -R player:player /home/player

# Copy installation files and critical scripts
COPY install.sh /opt/network-chronicles/
COPY install-user.sh /opt/network-chronicles/
COPY docker-entrypoint.sh /opt/network-chronicles/
COPY bin/network-chronicles-engine.sh /opt/network-chronicles/bin/
COPY bin/journal.sh /opt/network-chronicles/bin/
COPY bin/nc-shell-integration.sh /opt/network-chronicles/bin/
COPY bin/architect-agent.sh /opt/network-chronicles/bin/
COPY bin/utils/context-manager.sh /opt/network-chronicles/bin/utils/
COPY nc-contact-architect.sh /opt/network-chronicles/
COPY bin/install-commands.sh /opt/network-chronicles/bin/
COPY content/events/architect_contact.sh /opt/network-chronicles/content/events/
COPY content/triggers/architect_contact.json /opt/network-chronicles/content/triggers/

# Set permissions on all directories and files
RUN chmod -R 755 /opt/network-chronicles/bin \
    && chmod -R 755 /opt/network-chronicles/content \
    && chmod -R 777 /opt/network-chronicles/logs \
    && chmod -R 777 /opt/network-chronicles/data \
    && chmod +x /opt/network-chronicles/*.sh

# Set shell integration for the player user
RUN echo '# Network Chronicles Integration' >> /home/player/.bashrc \
    && echo 'if [ -f "/opt/network-chronicles/bin/nc-shell-integration.sh" ]; then' >> /home/player/.bashrc \
    && echo '  source "/opt/network-chronicles/bin/nc-shell-integration.sh"' >> /home/player/.bashrc \
    && echo 'fi' >> /home/player/.bashrc

# Set working directory
WORKDIR /opt/network-chronicles

# Create initial player files
RUN echo '{"id":"player","name":"player","tier":1,"xp":0,"discoveries":[],"quests":{"current":"initial_access","completed":[]},"created_at":"2025-03-04T12:00:00Z","last_login":"2025-03-04T12:00:00Z"}' > /opt/network-chronicles/data/players/player/profile.json \
    && echo '{"entries":[{"id":"welcome","title":"First Day","content":"Today is my first day as the new system administrator. The previous admin, known only as \"The Architect\", has disappeared without a trace. I have been tasked with maintaining the system and figuring out what happened.","timestamp":"2025-03-04T12:00:00Z"}]}' > /opt/network-chronicles/data/players/player/journal.json \
    && chown player:player /opt/network-chronicles/data/players/player/profile.json \
    && chown player:player /opt/network-chronicles/data/players/player/journal.json \
    && chmod 666 /opt/network-chronicles/data/players/player/profile.json \
    && chmod 666 /opt/network-chronicles/data/players/player/journal.json

# Set entrypoint
ENTRYPOINT ["/opt/network-chronicles/docker-entrypoint.sh"]
