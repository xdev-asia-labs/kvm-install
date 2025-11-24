# Docker Testing for kvm-install.sh

This directory contains Docker-based testing tools for the KVM installation script.

## Files

- `Dockerfile.test` - Docker image for testing
- `docker-test.sh` - Interactive test runner script
- `docker-compose.test.yml` - Docker Compose configuration for automated tests

## Quick Start

### Method 1: Using the test runner script (Recommended)

```bash
chmod +x docker-test.sh
./docker-test.sh
```

You'll see a menu with options:

1. **Syntax check only** - Quick validation
2. **Dry-run mode** - Shows what would be installed
3. **Interactive shell** - Manual testing
4. **Full installation test** - Actual installation (requires nested virtualization)

### Method 2: Using Docker Compose

#### Run automated tests

```bash
docker-compose -f docker-compose.test.yml run --rm kvm-test-auto
```

#### Interactive testing

```bash
docker-compose -f docker-compose.test.yml run --rm kvm-test
```

### Method 3: Manual Docker commands

#### Build the test image

```bash
docker build -f Dockerfile.test -t kvm-install-test .
```

#### Run syntax check

```bash
docker run --rm kvm-install-test bash -n /opt/kvm-install/kvm-install.sh
```

#### Interactive shell

```bash
docker run --rm -it kvm-install-test bash
# Inside container:
sudo bash /opt/kvm-install/kvm-install.sh
```

#### Dry-run mode

```bash
docker run --rm -it kvm-install-test bash -c "
  sed 's/apt-get/echo \"DRY-RUN: apt-get\"/g' /opt/kvm-install/kvm-install.sh | bash
"
```

## Test Modes Explained

### 1. Syntax Check

- Validates bash syntax
- Fast (< 1 second)
- No installation required
- Safe to run anywhere

### 2. Dry-Run Mode

- Shows what commands would be executed
- Doesn't actually install packages
- Good for understanding script flow
- Safe to run

### 3. Interactive Shell

- Manual testing environment
- Full control over execution
- Can step through script
- Best for debugging

### 4. Full Installation Test

- Actually installs KVM packages
- **Warning:** Requires nested virtualization
- May not work on macOS Docker (no KVM support)
- Best tested on Linux host with Docker

## Limitations on macOS

Docker on macOS doesn't support KVM (kernel-based virtualization) because:

- Docker Desktop on Mac uses a Linux VM
- That VM doesn't expose VT-x/AMD-V to containers
- KVM requires hardware virtualization support

**What you CAN test on macOS:**

- ✅ Script syntax
- ✅ Script logic and flow
- ✅ Package installation commands (dry-run)
- ✅ Error handling

**What you CANNOT test on macOS:**

- ❌ Actual KVM functionality
- ❌ VM creation with libvirt
- ❌ Hardware virtualization features

## Testing on Real Ubuntu

For full testing, use:

1. **Ubuntu VM** (Parallels, UTM, VirtualBox)
2. **Cloud instance** (AWS, DigitalOcean, etc.)
3. **Linux machine** with Docker

## Clean Up

Remove test image:

```bash
docker rmi kvm-install-test:latest
```

Remove all test containers:

```bash
docker-compose -f docker-compose.test.yml down
```

## Example Test Session

```bash
$ ./docker-test.sh

╔════════════════════════════════════════════════════════════════╗
║        KVM-INSTALL.SH DOCKER TEST RUNNER                      ║
╚════════════════════════════════════════════════════════════════╝

[INFO] Docker is installed
[INFO] Docker is running
[STEP] Building Docker test image...
[INFO] Docker image built successfully

Choose test mode:
  1) Syntax check only (quick)
  2) Dry-run mode (shows what would be installed)
  3) Interactive shell (manual testing)
  4) Full installation test (requires nested virtualization)

Enter choice [1-4]: 1

[STEP] Running syntax check...
=== Syntax Check ===
Syntax OK

[INFO] Test completed!
```

## Troubleshooting

### Docker not found

```bash
# Install Docker Desktop for Mac
brew install --cask docker
```

### Docker not running

- Start Docker Desktop from Applications
- Wait for Docker icon in menu bar to show "Docker Desktop is running"

### Build fails

```bash
# Clear Docker cache and rebuild
docker system prune -a
docker build --no-cache -f Dockerfile.test -t kvm-install-test .
```

### Permission denied

```bash
# Make scripts executable
chmod +x docker-test.sh kvm-install.sh
```
