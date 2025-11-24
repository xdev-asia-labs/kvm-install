#!/bin/bash

################################################################################
# Script: test-kvm-install.sh
# Description: Test script for kvm-install.sh without actual installation
# Author: xdev.asia
################################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║              KVM-INSTALL.SH TEST SUITE                        ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Test 1: Check if script file exists
print_test "Checking if kvm-install.sh exists..."
if [ -f "kvm-install.sh" ]; then
    print_pass "Script file exists"
else
    print_fail "Script file not found"
    exit 1
fi

# Test 2: Check if script is executable
print_test "Checking if script is executable..."
if [ -x "kvm-install.sh" ]; then
    print_pass "Script is executable"
else
    print_fail "Script is not executable"
    echo "  Fix: chmod +x kvm-install.sh"
fi

# Test 3: Syntax check
print_test "Checking bash syntax..."
if bash -n kvm-install.sh 2>/dev/null; then
    print_pass "Syntax is valid"
else
    print_fail "Syntax errors found"
    bash -n kvm-install.sh
    exit 1
fi

# Test 4: Check required commands exist in script
print_test "Checking if required commands are available on system..."
REQUIRED_CMDS=("apt-get" "systemctl" "virsh" "hostname" "egrep")
for cmd in "${REQUIRED_CMDS[@]}"; do
    if grep -q "$cmd" kvm-install.sh; then
        echo "  - Script uses: $cmd"
    fi
done

# Test 5: Check for root requirement
print_test "Verifying root check function..."
if grep -q "check_root" kvm-install.sh && grep -q "EUID -ne 0" kvm-install.sh; then
    print_pass "Root check is implemented"
else
    print_fail "Root check not found"
fi

# Test 6: Check OS detection
print_test "Testing OS detection on current system..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "  Current OS: $PRETTY_NAME"
    if [[ "$ID" == "ubuntu" ]]; then
        print_pass "Running on Ubuntu (script should work)"
    else
        echo -e "${YELLOW}[WARN]${NC} Not running on Ubuntu (script is designed for Ubuntu)"
    fi
fi

# Test 7: Check CPU virtualization support
print_test "Checking CPU virtualization support..."
if [ -f /proc/cpuinfo ]; then
    if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null 2>&1; then
        VT_COUNT=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
        print_pass "CPU supports virtualization ($VT_COUNT cores)"
    else
        echo -e "${YELLOW}[WARN]${NC} CPU may not support virtualization or it's disabled in BIOS"
    fi
else
    echo -e "${YELLOW}[WARN]${NC} Cannot check /proc/cpuinfo (not on Linux?)"
fi

# Test 8: Check if running on macOS
print_test "Detecting current platform..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}[WARN]${NC} Running on macOS - this script is for Ubuntu/Linux"
    echo "  Note: KVM is not available on macOS (use QEMU, Parallels, or VirtualBox instead)"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    print_pass "Running on Linux"
else
    echo -e "${YELLOW}[WARN]${NC} Unknown OS: $OSTYPE"
fi

# Test 9: Check script structure
print_test "Checking script structure..."
FUNCTIONS=("check_root" "check_ubuntu_version" "check_virtualization" "install_kvm" "configure_libvirt" "verify_kvm" "install_cockpit")
for func in "${FUNCTIONS[@]}"; do
    if grep -q "^$func()" kvm-install.sh || grep -q "^function $func" kvm-install.sh; then
        echo "  ✓ Function found: $func"
    else
        print_fail "Function not found: $func"
    fi
done

# Test 10: Check for interactive prompts
print_test "Checking for interactive prompts..."
if grep -q "read -p" kvm-install.sh; then
    print_pass "Script has interactive prompts (user confirmation required)"
else
    echo -e "${YELLOW}[WARN]${NC} No interactive prompts found"
fi

# Test 11: ShellCheck (if available)
print_test "Running ShellCheck (if available)..."
if command -v shellcheck &> /dev/null; then
    if shellcheck -x kvm-install.sh; then
        print_pass "ShellCheck passed"
    else
        echo -e "${YELLOW}[WARN]${NC} ShellCheck found some issues (see above)"
    fi
else
    echo -e "${YELLOW}[INFO]${NC} ShellCheck not installed. Install with: brew install shellcheck"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                    TEST SUMMARY                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Script validation completed!"
echo ""
echo "To test in a safe environment:"
echo "  1. Use a VM or Docker container with Ubuntu 24.04"
echo "  2. Run: sudo bash kvm-install.sh"
echo ""
echo "To test without installation (mock mode):"
echo "  - Replace 'apt-get' with 'echo apt-get' in script"
echo "  - Replace 'systemctl' with 'echo systemctl' in script"
echo ""
