#!/bin/bash
# Network Chronicles 2.0 - Docker Test Script

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${CYAN}Network Chronicles 2.0 - Docker Compatibility Test${RESET}"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker not found. Please install Docker first.${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Docker found${RESET}"

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}✗ Docker Compose not found. Please install Docker Compose.${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose found${RESET}"

# Test 1: Build the Docker image
echo -e "\n${CYAN}Test 1: Building Docker image...${RESET}"
if docker build -t network-chronicles-2.0-test . &> build.log; then
    echo -e "${GREEN}✓ Docker image built successfully${RESET}"
else
    echo -e "${RED}✗ Docker image build failed. Check build.log for details.${RESET}"
    tail -20 build.log
    exit 1
fi

# Test 2: Run container health check
echo -e "\n${CYAN}Test 2: Testing container startup...${RESET}"
CONTAINER_ID=$(docker run -d -p 3001:3000 --name nc-test network-chronicles-2.0-test)

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Container started successfully (ID: ${CONTAINER_ID:0:12})${RESET}"
    
    # Wait for startup
    echo -e "${CYAN}Waiting for application startup...${RESET}"
    sleep 10
    
    # Test health endpoint
    echo -e "\n${CYAN}Test 3: Health check...${RESET}"
    if curl -s http://localhost:3001/health > /dev/null; then
        echo -e "${GREEN}✓ Health check passed${RESET}"
        
        # Get health response
        HEALTH_RESPONSE=$(curl -s http://localhost:3001/health)
        echo -e "${CYAN}Health response: ${HEALTH_RESPONSE}${RESET}"
    else
        echo -e "${RED}✗ Health check failed${RESET}"
        echo -e "${YELLOW}Container logs:${RESET}"
        docker logs nc-test | tail -20
    fi
    
    # Test web interface
    echo -e "\n${CYAN}Test 4: Web interface availability...${RESET}"
    if curl -s http://localhost:3001/ > /dev/null; then
        echo -e "${GREEN}✓ Web interface accessible${RESET}"
    else
        echo -e "${RED}✗ Web interface not accessible${RESET}"
    fi
    
    # Cleanup
    echo -e "\n${CYAN}Cleaning up test container...${RESET}"
    docker stop nc-test &> /dev/null
    docker rm nc-test &> /dev/null
    echo -e "${GREEN}✓ Test container removed${RESET}"
    
else
    echo -e "${RED}✗ Container failed to start${RESET}"
    exit 1
fi

# Test 5: Docker Compose
echo -e "\n${CYAN}Test 5: Docker Compose compatibility...${RESET}"
if docker-compose config &> /dev/null || docker compose config &> /dev/null; then
    echo -e "${GREEN}✓ Docker Compose configuration is valid${RESET}"
else
    echo -e "${RED}✗ Docker Compose configuration has errors${RESET}"
    docker-compose config 2>&1 || docker compose config 2>&1
fi

# Cleanup
echo -e "\n${CYAN}Cleaning up test image...${RESET}"
docker rmi network-chronicles-2.0-test &> /dev/null
echo -e "${GREEN}✓ Test image removed${RESET}"

# Remove build log
rm -f build.log

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════════╗"
echo -e "║                     DOCKER COMPATIBILITY TEST COMPLETE                  ║"
echo -e "╚══════════════════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "${CYAN}Quick start commands:${RESET}"
echo -e "• Build and run: ${YELLOW}docker-compose up --build${RESET}"
echo -e "• Run in background: ${YELLOW}docker-compose up -d${RESET}"
echo -e "• Stop: ${YELLOW}docker-compose down${RESET}"
echo -e "• View logs: ${YELLOW}docker-compose logs -f${RESET}"
echo ""
echo -e "${CYAN}Access the application:${RESET}"
echo -e "• Web interface: ${YELLOW}http://localhost:3000${RESET}"
echo -e "• Health check: ${YELLOW}http://localhost:3000/health${RESET}"