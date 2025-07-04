#!/bin/bash
# Network Chronicles 2.0 Alpha - Installation Script

# Set up colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

# Print banner
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   NETWORK CHRONICLES 2.0 ALPHA: THE VANISHING ADMIN                     ║"
echo "║   React-based Interactive Terminal Installation                          ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

echo -e "${YELLOW}⚠️  ALPHA RELEASE - TESTERS WELCOME! ⚠️${RESET}"
echo -e "${CYAN}This is a complete rewrite of Network Chronicles.${RESET}"
echo -e "${CYAN}Not compatible with v1.x installations.${RESET}"
echo ""

# Check if Node.js is installed
check_nodejs() {
    if ! command -v node &> /dev/null; then
        echo -e "${RED}Error: Node.js not found${RESET}"
        echo -e "${YELLOW}Please install Node.js 16+ before continuing:${RESET}"
        echo -e "${CYAN}• Ubuntu/Debian: sudo apt install nodejs npm${RESET}"
        echo -e "${CYAN}• CentOS/RHEL: sudo yum install nodejs npm${RESET}"
        echo -e "${CYAN}• macOS: brew install node${RESET}"
        echo -e "${CYAN}• Or visit: https://nodejs.org/${RESET}"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 16 ]; then
        echo -e "${RED}Error: Node.js version 16+ required${RESET}"
        echo -e "${YELLOW}Current version: $(node --version)${RESET}"
        echo -e "${YELLOW}Please upgrade Node.js and try again${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Node.js $(node --version) found${RESET}"
}

# Check if npm is installed
check_npm() {
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}Error: npm not found${RESET}"
        echo -e "${YELLOW}Please install npm and try again${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ npm $(npm --version) found${RESET}"
}

# Check if git is installed
check_git() {
    if ! command -v git &> /dev/null; then
        echo -e "${RED}Error: git not found${RESET}"
        echo -e "${YELLOW}Please install git and try again${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ git found${RESET}"
}

# Installation options
show_installation_options() {
    echo -e "${CYAN}Choose installation method:${RESET}"
    echo -e "${YELLOW}1. Local Development (recommended for testing)${RESET}"
    echo -e "${YELLOW}2. Docker Installation${RESET}"
    echo -e "${YELLOW}3. Exit${RESET}"
    echo ""
    read -p "Enter your choice (1-3): " choice
    
    case $choice in
        1) install_local ;;
        2) install_docker ;;
        3) echo -e "${CYAN}Installation cancelled${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice${RESET}"; show_installation_options ;;
    esac
}

# Local development installation
install_local() {
    echo -e "${CYAN}Installing Network Chronicles 2.0 for local development...${RESET}"
    
    # Create installation directory
    INSTALL_DIR="$HOME/network-chronicles-2.0"
    
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Directory $INSTALL_DIR already exists${RESET}"
        read -p "Remove existing installation? (y/N): " remove_existing
        if [[ $remove_existing =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            echo -e "${GREEN}✓ Removed existing installation${RESET}"
        else
            echo -e "${RED}Installation cancelled${RESET}"
            exit 1
        fi
    fi
    
    echo -e "${CYAN}Cloning Network Chronicles 2.0...${RESET}"
    if git clone https://github.com/Fimeg/NetworkChronicles.git "$INSTALL_DIR"; then
        echo -e "${GREEN}✓ Repository cloned successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to clone repository${RESET}"
        exit 1
    fi
    
    # Change to installation directory
    cd "$INSTALL_DIR" || exit 1
    
    echo -e "${CYAN}Installing dependencies...${RESET}"
    if npm install; then
        echo -e "${GREEN}✓ Dependencies installed successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to install dependencies${RESET}"
        exit 1
    fi
    
    echo -e "${CYAN}Building application...${RESET}"
    if npm run build; then
        echo -e "${GREEN}✓ Application built successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to build application${RESET}"
        exit 1
    fi
    
    # Create startup script
    create_startup_script "$INSTALL_DIR"
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                     INSTALLATION COMPLETE!                              ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}Installation directory: ${INSTALL_DIR}${RESET}"
    echo -e "${CYAN}To start Network Chronicles 2.0:${RESET}"
    echo -e "${YELLOW}  cd ${INSTALL_DIR}${RESET}"
    echo -e "${YELLOW}  npm run serve${RESET}"
    echo -e "${CYAN}Then open: ${YELLOW}http://localhost:3000${RESET}"
    echo ""
    echo -e "${CYAN}For development mode:${RESET}"
    echo -e "${YELLOW}  npm run dev${RESET}"
    echo ""
    echo -e "${CYAN}Read ALPHA_TESTING.md for testing guidance!${RESET}"
}

# Docker installation
install_docker() {
    echo -e "${CYAN}Installing Network Chronicles 2.0 with Docker...${RESET}"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker not found${RESET}"
        echo -e "${YELLOW}Please install Docker and try again${RESET}"
        echo -e "${CYAN}Visit: https://docs.docker.com/get-docker/${RESET}"
        exit 1
    fi
    
    # Check if docker-compose is installed
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}Error: Docker Compose not found${RESET}"
        echo -e "${YELLOW}Please install Docker Compose and try again${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker found${RESET}"
    
    # Create installation directory
    INSTALL_DIR="$HOME/network-chronicles-2.0"
    
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Directory $INSTALL_DIR already exists${RESET}"
        read -p "Remove existing installation? (y/N): " remove_existing
        if [[ $remove_existing =~ ^[Yy]$ ]]; then
            rm -rf "$INSTALL_DIR"
            echo -e "${GREEN}✓ Removed existing installation${RESET}"
        else
            echo -e "${RED}Installation cancelled${RESET}"
            exit 1
        fi
    fi
    
    echo -e "${CYAN}Cloning Network Chronicles 2.0...${RESET}"
    if git clone https://github.com/Fimeg/NetworkChronicles.git "$INSTALL_DIR"; then
        echo -e "${GREEN}✓ Repository cloned successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to clone repository${RESET}"
        exit 1
    fi
    
    # Change to installation directory
    cd "$INSTALL_DIR" || exit 1
    
    echo -e "${CYAN}Building Docker image...${RESET}"
    if docker-compose build; then
        echo -e "${GREEN}✓ Docker image built successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to build Docker image${RESET}"
        exit 1
    fi
    
    echo -e "${CYAN}Starting containers...${RESET}"
    if docker-compose up -d; then
        echo -e "${GREEN}✓ Containers started successfully${RESET}"
    else
        echo -e "${RED}Error: Failed to start containers${RESET}"
        exit 1
    fi
    
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════════════════╗"
    echo "║                     DOCKER INSTALLATION COMPLETE!                       ║"
    echo "╚══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${CYAN}Installation directory: ${INSTALL_DIR}${RESET}"
    echo -e "${CYAN}Network Chronicles 2.0 is running at: ${YELLOW}http://localhost:3000${RESET}"
    echo ""
    echo -e "${CYAN}Docker commands:${RESET}"
    echo -e "${YELLOW}  docker-compose up -d${RESET}    # Start in background"
    echo -e "${YELLOW}  docker-compose down${RESET}     # Stop containers"
    echo -e "${YELLOW}  docker-compose logs -f${RESET}  # View logs"
    echo ""
    echo -e "${CYAN}Read ALPHA_TESTING.md for testing guidance!${RESET}"
}

# Create startup script
create_startup_script() {
    local install_dir="$1"
    local script_path="$install_dir/start-network-chronicles.sh"
    
    cat > "$script_path" << 'EOF'
#!/bin/bash
# Network Chronicles 2.0 - Startup Script

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${GREEN}Starting Network Chronicles 2.0...${RESET}"

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo -e "${YELLOW}Changing to Network Chronicles directory...${RESET}"
    cd "$(dirname "$0")"
fi

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo -e "${CYAN}Installing dependencies...${RESET}"
    npm install
fi

# Start the server
echo -e "${CYAN}Starting server on http://localhost:3000${RESET}"
echo -e "${YELLOW}Press Ctrl+C to stop${RESET}"
npm run serve
EOF
    
    chmod +x "$script_path"
    echo -e "${GREEN}✓ Created startup script: ${script_path}${RESET}"
}

# Main installation process
main() {
    echo -e "${CYAN}Checking system requirements...${RESET}"
    
    check_nodejs
    check_npm
    check_git
    
    echo -e "${GREEN}✓ All requirements met${RESET}"
    echo ""
    
    show_installation_options
}

# Run main function
main "$@"