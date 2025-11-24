#!/bin/bash

################################################################################
# Script: kvm-install.sh
# Description: Automated KVM installation on Ubuntu 24.04 with Cockpit Web UI
# Author: xdev.asia
# Date: November 2024
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if script is run as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (sudo)"
        exit 1
    fi
}

# Function to check Ubuntu version
check_ubuntu_version() {
    print_info "Checking Ubuntu version..."
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" != "ubuntu" ]]; then
            print_error "This script only supports Ubuntu"
            exit 1
        fi
        print_info "Detected: $PRETTY_NAME"
    else
        print_error "Cannot determine operating system"
        exit 1
    fi
}

# Function to check CPU virtualization support
check_virtualization() {
    print_info "Checking CPU virtualization support..."
    
    if ! command -v kvm-ok &> /dev/null; then
        print_info "Installing cpu-checker..."
        apt-get update -qq
        apt-get install -y -qq cpu-checker
    fi
    
    if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
        VT_COUNT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
        print_info "CPU supports virtualization (detected $VT_COUNT cores with VT-x/AMD-V)"
    else
        print_error "CPU does not support virtualization or it's not enabled in BIOS"
        print_warning "Please enable Intel VT-x or AMD-V in BIOS"
        exit 1
    fi
}

# Function to update system
update_system() {
    print_info "Updating system..."
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq
}

# Function to install KVM packages
install_kvm() {
    print_info "Installing KVM and related packages..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        qemu-kvm \
        libvirt-daemon-system \
        libvirt-clients \
        bridge-utils \
        virtinst \
        virt-manager \
        cpu-checker
    
    print_info "KVM has been installed successfully"
}

# Function to start and enable libvirt service
configure_libvirt() {
    print_info "Configuring libvirt service..."
    systemctl enable libvirtd
    systemctl start libvirtd
    
    if systemctl is-active --quiet libvirtd; then
        print_info "libvirtd service is running"
    else
        print_error "Failed to start libvirtd service"
        exit 1
    fi
}

# Function to add user to required groups
add_user_to_groups() {
    if [ -n "$SUDO_USER" ]; then
        USERNAME=$SUDO_USER
    else
        print_warning "Cannot determine user. Please manually add user to libvirt and kvm groups"
        return
    fi
    
    print_info "Adding user $USERNAME to required groups..."
    usermod -aG libvirt "$USERNAME"
    usermod -aG kvm "$USERNAME"
    print_info "User $USERNAME has been added to libvirt and kvm groups"
    print_warning "Please log out and log back in for changes to take effect"
}

# Function to verify KVM installation
verify_kvm() {
    print_info "Verifying KVM installation..."
    
    if virsh list --all &> /dev/null; then
        print_info "KVM is working properly"
    else
        print_error "There's an issue with KVM installation"
        exit 1
    fi
    
    # Check if default network exists
    if virsh net-list --all | grep -q "default"; then
        print_info "Default network has been configured"
        virsh net-autostart default &> /dev/null || true
        virsh net-start default &> /dev/null || true
    fi
}

# Function to install Cockpit
install_cockpit() {
    print_info "Installing Cockpit Web UI..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        cockpit \
        cockpit-machines
    
    systemctl enable --now cockpit.socket
    
    if systemctl is-active --quiet cockpit.socket; then
        print_info "Cockpit has been installed and is running"
    else
        print_error "Failed to start Cockpit"
        exit 1
    fi
}

# Function to configure firewall
configure_firewall() {
    if command -v ufw &> /dev/null; then
        if ufw status | grep -q "Status: active"; then
            print_info "Configuring firewall for Cockpit..."
            ufw allow 9090/tcp
            print_info "Opened port 9090 for Cockpit"
        fi
    fi
}

# Function to display completion message
display_completion() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          KVM INSTALLATION COMPLETED SUCCESSFULLY!             ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    print_info "KVM and Cockpit Web UI have been installed successfully!"
    echo ""
    echo "Access Information:"
    echo "-------------------"
    echo "Cockpit Web UI: https://$(hostname -I | awk '{print $1}'):9090"
    echo "or: https://localhost:9090"
    echo ""
    echo "Login with your Ubuntu username and password."
    echo ""
    print_warning "IMPORTANT:"
    echo "  - You need to log out and log back in to use KVM without sudo"
    echo "  - Or run: newgrp libvirt"
    echo ""
    echo "Useful Commands:"
    echo "-------------------"
    echo "  virsh list --all          # List all VMs"
    echo "  virsh net-list --all      # List networks"
    echo "  systemctl status libvirtd # Check libvirt status"
    echo "  kvm-ok                    # Check KVM support"
    echo ""
}

# Main installation process
main() {
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║     KVM INSTALLATION SCRIPT FOR UBUNTU 24.04 - xdev.asia     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    check_root
    check_ubuntu_version
    check_virtualization
    
    read -p "Do you want to continue with the installation? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled."
        exit 0
    fi
    
    update_system
    install_kvm
    configure_libvirt
    add_user_to_groups
    verify_kvm
    
    read -p "Do you want to install Cockpit Web UI? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_cockpit
        configure_firewall
    fi
    
    display_completion
}

# Run main function
main "$@"
