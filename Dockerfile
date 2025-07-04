FROM node:18-alpine

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    jq \
    git \
    vim \
    nano \
    shadow

# Create application directory
WORKDIR /app

# Create a non-root user
RUN addgroup -g 1001 -S player && \
    adduser -S player -u 1001 -G player

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy application files
COPY . .

# Build the application
RUN npm run build

# Create data and logs directories with proper permissions
RUN mkdir -p /app/data /app/logs /app/user-data && \
    chown -R player:player /app

# Expose port
EXPOSE 3000

# Switch to non-root user
USER player

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["npm", "run", "serve"]