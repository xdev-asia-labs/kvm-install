# GitHub Actions Workflows for KVM Installation Script

This directory contains automated CI/CD workflows for testing and validating the KVM installation script.

## Workflows

### 1. `test.yml` - Main Test Suite
**Trigger:** Push to main/develop, Pull Requests, Manual dispatch

**Jobs:**
- **Syntax Check** - Validates bash syntax and runs ShellCheck
- **Structure Validation** - Verifies all required functions exist
- **Dry-Run Test** - Simulates installation without actual package installation
- **Docker Test** - Tests script in Ubuntu 24.04 container
- **Integration Test** - Runs on Ubuntu 24.04 runner
- **Test Script Runner** - Executes test-kvm-install.sh
- **Markdown Lint** - Validates documentation
- **Summary** - Generates test results summary

**Status Badge:**
```markdown
[![Test KVM Installation Script](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/test.yml/badge.svg)](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/test.yml)
```

### 2. `security.yml` - Security Scanning
**Trigger:** Push to main, Pull Requests, Weekly schedule, Manual dispatch

**Jobs:**
- **ShellCheck Security** - Security-focused static analysis
- **Script Security Check** - Checks for unsafe patterns
- **Dependency Check** - Analyzes external dependencies
- **Secrets Scan** - Looks for hardcoded credentials
- **Permissions Check** - Validates file permissions

**Status Badge:**
```markdown
[![Security Scan](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/security.yml/badge.svg)](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/security.yml)
```

### 3. `docs.yml` - Documentation Validation
**Trigger:** Push to main (when .md files change), Manual dispatch

**Jobs:**
- **Check Docs** - Verifies all documentation files exist
- **Link Validation** - Checks for broken references

**Status Badge:**
```markdown
[![Deploy Documentation](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/docs.yml/badge.svg)](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/docs.yml)
```

### 4. `release.yml` - Release Automation
**Trigger:** Git tags (v*.*.*), Manual dispatch

**Jobs:**
- **Create Release** - Runs tests, creates archive, generates checksums, publishes GitHub Release

**Usage:**
```bash
# Create a new release
git tag v1.0.0
git push origin v1.0.0
```

## Viewing Results

### In Pull Requests
- All checks run automatically
- Results appear as status checks
- Click "Details" to see full logs

### In Actions Tab
1. Go to repository → Actions tab
2. Select workflow from left sidebar
3. Click on specific run to see details
4. View job logs and artifacts

### Status Badges
Add to README.md:
```markdown
![Tests](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/test.yml/badge.svg)
![Security](https://github.com/xdev-asia-labs/kvm-install/actions/workflows/security.yml/badge.svg)
```

## Manual Workflow Dispatch

You can manually trigger workflows from GitHub:

1. Go to Actions tab
2. Select workflow
3. Click "Run workflow"
4. Choose branch
5. Click "Run workflow" button

Or using GitHub CLI:
```bash
# Trigger test workflow
gh workflow run test.yml

# Trigger security scan
gh workflow run security.yml

# Trigger with specific branch
gh workflow run test.yml --ref develop
```

## Limitations

### GitHub Actions Runners
- ❌ **No nested virtualization** - Cannot test actual KVM functionality
- ❌ **No hardware VT-x/AMD-V** - CPU virtualization not available
- ✅ **Can test** - Syntax, structure, logic, error handling
- ✅ **Can run** - Docker containers, dry-run tests

### What Gets Tested
| Feature | Tested? | How |
|---------|---------|-----|
| Bash syntax | ✅ Yes | `bash -n` + ShellCheck |
| Script structure | ✅ Yes | Function existence checks |
| OS detection | ✅ Yes | Ubuntu runner |
| Package commands | ✅ Yes | Dry-run mode |
| Error handling | ✅ Yes | Static analysis |
| Security issues | ✅ Yes | Pattern matching |
| Docker compatibility | ✅ Yes | Container tests |
| KVM functionality | ❌ No | Requires bare metal |
| VM creation | ❌ No | Requires nested virt |

## Local Testing

Before pushing, test locally:

```bash
# Run test script
./test-kvm-install.sh

# Run Docker test
./docker-test.sh

# Check syntax
bash -n kvm-install.sh

# Run ShellCheck
shellcheck kvm-install.sh
```

## Workflow Configuration

### Modify Trigger Events

Edit workflow file:
```yaml
on:
  push:
    branches: [ main, develop, feature/* ]
  pull_request:
    branches: [ main ]
```

### Add New Test Job

```yaml
jobs:
  my-new-test:
    name: My New Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run test
        run: echo "Testing..."
```

### Add Secrets

For workflows needing secrets:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add name and value
4. Reference in workflow: `${{ secrets.SECRET_NAME }}`

## Troubleshooting

### Workflow Fails

1. Check logs in Actions tab
2. Look for specific error messages
3. Test locally with same conditions
4. Check if dependencies are available

### Timeout Issues

Add timeout to job:
```yaml
jobs:
  my-job:
    runs-on: ubuntu-latest
    timeout-minutes: 10
```

### Matrix Testing

Test across multiple versions:
```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ubuntu-version: ['22.04', '24.04']
    steps:
      - uses: actions/checkout@v4
      - name: Test on Ubuntu ${{ matrix.ubuntu-version }}
        run: # test commands
```

## Best Practices

1. **Keep workflows fast** - Use caching where possible
2. **Fail fast** - Use `set -e` in bash scripts
3. **Clear names** - Use descriptive job and step names
4. **Add comments** - Explain complex logic
5. **Test locally first** - Don't debug in CI/CD
6. **Use latest actions** - Keep actions updated
7. **Secure secrets** - Never log sensitive data

## Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Available Runners](https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
