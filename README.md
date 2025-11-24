# KVM Installation Script for Ubuntu 24.04

![Test Status](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/test.yml/badge.svg)
![Security Scan](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/security.yml/badge.svg)

Automated KVM (Kernel-based Virtual Machine) installation script with Cockpit Web UI for Ubuntu 24.04.

## Features

- ✅ Automated KVM installation
- ✅ CPU virtualization check
- ✅ Cockpit Web UI for VM management
- ✅ User permission configuration
- ✅ Network configuration
- ✅ Comprehensive error handling
- ✅ Interactive installation process

## Requirements

- Ubuntu 24.04 or later
- CPU with Intel VT-x or AMD-V support
- Root/sudo privileges
- Internet connection

## Quick Start

### Download and Run

```bash
# Download script
wget https://raw.githubusercontent.com/xdev-asia-labs/kvm-install/main/kvm-install.sh

# Make executable
chmod +x kvm-install.sh

# Run installation
sudo bash kvm-install.sh
```

### Or Clone Repository

```bash
git clone https://github.com/xdev-asia-labs/kvm-install.git
cd kvm-install
sudo bash kvm-install.sh
```

## What Gets Installed

The script installs and configures:

- **qemu-kvm** - KVM virtualization
- **libvirt-daemon-system** - Virtualization daemon
- **libvirt-clients** - Management clients
- **bridge-utils** - Network bridging
- **virtinst** - VM installation tools
- **virt-manager** - VM management GUI
- **cockpit** - Web-based management interface
- **cockpit-machines** - Cockpit VM plugin

## Testing

### Quick Syntax Check

```bash
bash -n kvm-install.sh
```

### Full Test Suite

```bash
chmod +x test-kvm-install.sh
./test-kvm-install.sh
```

### Docker Testing

```bash
chmod +x docker-test.sh
./docker-test.sh
```

See [DOCKER-TESTING.md](DOCKER-TESTING.md) for detailed testing instructions.

## CI/CD

This project uses GitHub Actions for automated testing:

- **Syntax validation** - Bash syntax and ShellCheck
- **Structure validation** - Required functions check
- **Docker testing** - Ubuntu 24.04 container tests
- **Security scanning** - Security best practices check
- **Documentation validation** - Markdown linting

See [.github/workflows/README.md](.github/workflows/README.md) for workflow details.

## Usage

After installation:

### Access Cockpit Web UI

```
https://your-server-ip:9090
```

Login with your Ubuntu username and password.

### Useful Commands

```bash
# List all VMs
virsh list --all

# List networks
virsh net-list --all

# Check libvirt status
systemctl status libvirtd

# Verify KVM support
kvm-ok

# Start a VM
virsh start vm-name

# Stop a VM
virsh shutdown vm-name
```

## Post-Installation

1. **Log out and log back in** to apply group permissions
2. Or run: `newgrp libvirt`
3. Access Cockpit at `https://localhost:9090`

## Troubleshooting

### CPU doesn't support virtualization

**Error:** CPU does not support virtualization

**Solution:** Enable Intel VT-x or AMD-V in BIOS/UEFI settings

### Permission denied

**Error:** Permission denied when creating VMs

**Solution:**


```bash
# Add user to groups
sudo usermod -aG libvirt $USER
sudo usermod -aG kvm $USER

# Log out and back in, or:
newgrp libvirt
```

### Cockpit not accessible

**Error:** Cannot access Cockpit web interface


**Solution:**

```bash
# Check if Cockpit is running
sudo systemctl status cockpit.socket

# Start Cockpit
sudo systemctl start cockpit.socket

# Open firewall port
sudo ufw allow 9090/tcp
```

### libvirtd not running

**Error:** libvirtd service not running


**Solution:**

```bash
# Start service
sudo systemctl start libvirtd

# Enable on boot
sudo systemctl enable libvirtd

# Check logs
sudo journalctl -u libvirtd
```

## Development

### Project Structure

```
kvm-install/
├── kvm-install.sh           # Main installation script
├── test-kvm-install.sh      # Local test script
├── docker-test.sh           # Docker test runner
├── Dockerfile.test          # Docker test image
├── docker-compose.test.yml  # Docker Compose config
├── README.md                # This file
├── DOCKER-TESTING.md        # Docker testing guide
└── .github/
    └── workflows/
        ├── test.yml         # Main test workflow
        ├── security.yml     # Security scanning
        ├── docs.yml         # Documentation validation
        └── release.yml      # Release automation
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests locally

5. Submit a pull request

All pull requests must pass:

- Syntax checks
- ShellCheck analysis
- Docker tests
- Security scans

## Security

- Script requires root privileges (verified at runtime)
- No hardcoded credentials
- Input validation on user prompts
- Error handling with `set -e`
- Security scanning in CI/CD

Report security issues to: [security contact]

## License

[Your License Here]

## Author

**xdev.asia**


## Changelog

### v1.0.0 (2024-11-24)

- Initial release
- KVM installation automation
- Cockpit Web UI integration
- Docker testing support
- GitHub Actions CI/CD

## Resources

- [KVM Official Documentation](https://www.linux-kvm.org/)
- [libvirt Documentation](https://libvirt.org/)
- [Cockpit Project](https://cockpit-project.org/)
- [Ubuntu KVM Guide](https://ubuntu.com/server/docs/virtualization-libvirt)

## Support

- **Issues:** [GitHub Issues](https://github.com/xdev-asia-labs/kvm-install/issues)
- **Discussions:** [GitHub Discussions](https://github.com/xdev-asia-labs/kvm-install/discussions)
- **Documentation:** [Wiki](https://github.com/xdev-asia-labs/kvm-install/wiki)

---

Made with ❤️ by xdev.asia
