#!/bin/bash

################################################################################
# Script: docker-test.sh
# Description: Test kvm-install.sh in Docker container
# Author: xdev.asia
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        KVM-INSTALL.SH DOCKER TEST RUNNER                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if Docker is installed
print_step "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    echo "Install: https://docs.docker.com/desktop/install/mac-install/"
    exit 1
fi
print_info "Docker is installed"

# Check if Docker is running
print_step "Checking if Docker is running..."
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker Desktop."
    exit 1
fi
print_info "Docker is running"

# Build the test image
print_step "Building Docker test image..."
docker build -f Dockerfile.test -t kvm-install-test:latest . || {
    print_error "Failed to build Docker image"
    exit 1
}
print_info "Docker image built successfully"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    TEST OPTIONS                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Choose test mode:"
echo "  1) Syntax check only (quick)"
echo "  2) Dry-run mode (shows what would be installed)"
echo "  3) Interactive shell (manual testing)"
echo "  4) Full installation test (requires nested virtualization)"
echo ""
read -p "Enter choice [1-4]: " choice

case $choice in
    1)
        print_step "Running syntax check..."
        docker run --rm kvm-install-test:latest bash -c "
            echo '=== Syntax Check ==='
            bash -n /opt/kvm-install/kvm-install.sh && echo 'Syntax OK' || echo 'Syntax Error'
        "
        ;;
    
    2)
        print_step "Running dry-run mode..."
        docker run --rm -it kvm-install-test:latest bash -c "
            echo '=== Dry-Run Mode ==='
            echo 'This will show what the script would do without actually installing.'
            echo ''
            # Create a dry-run version
            sed 's/apt-get update/echo \"[DRY-RUN] apt-get update\"/g; 
                 s/apt-get install/echo \"[DRY-RUN] apt-get install\"/g; 
                 s/apt-get upgrade/echo \"[DRY-RUN] apt-get upgrade\"/g;
                 s/systemctl/echo \"[DRY-RUN] systemctl\"/g;
                 s/usermod/echo \"[DRY-RUN] usermod\"/g;
                 s/ufw/echo \"[DRY-RUN] ufw\"/g' /opt/kvm-install/kvm-install.sh > /tmp/kvm-install-dryrun.sh
            
            chmod +x /tmp/kvm-install-dryrun.sh
            echo 'y' | sudo bash /tmp/kvm-install-dryrun.sh || true
        "
        ;;
    
    3)
        print_step "Starting interactive shell..."
        print_info "You can now test the script manually"
        echo ""
        echo "Available commands in container:"
        echo "  sudo bash kvm-install.sh    # Run the script"
        echo "  bash -n kvm-install.sh      # Check syntax"
        echo "  cat kvm-install.sh          # View script"
        echo "  exit                        # Exit container"
        echo ""
        docker run --rm -it kvm-install-test:latest bash
        ;;
    
    4)
        print_step "Running full installation test..."
        echo -e "${YELLOW}[WARNING]${NC} This requires nested virtualization support"
        echo "This may not work on macOS Docker (no KVM support)"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Test cancelled"
            exit 0
        fi
        
        docker run --rm -it --privileged kvm-install-test:latest bash -c "
            echo '=== Full Installation Test ==='
            echo 'y' | sudo bash /opt/kvm-install/kvm-install.sh
        "
        ;;
    
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

echo ""
print_info "Test completed!"
echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    ADDITIONAL COMMANDS                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Re-run specific tests:"
echo "  docker run --rm kvm-install-test bash -n /opt/kvm-install/kvm-install.sh"
echo "  docker run --rm -it kvm-install-test bash"
echo ""
echo "Clean up test image:"
echo "  docker rmi kvm-install-test:latest"
echo ""
