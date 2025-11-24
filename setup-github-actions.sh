#!/bin/bash

################################################################################
# Script: setup-github-actions.sh
# Description: Setup and push GitHub Actions workflows
################################################################################

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║        GITHUB ACTIONS SETUP & DEPLOYMENT                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if .github/workflows exists
if [ ! -d ".github/workflows" ]; then
    echo -e "${YELLOW}[WARNING]${NC} .github/workflows directory not found!"
    exit 1
fi

echo -e "${BLUE}[STEP 1]${NC} Checking workflow files..."
WORKFLOW_FILES=(".github/workflows/test.yml" ".github/workflows/security.yml" ".github/workflows/docs.yml" ".github/workflows/release.yml")

for file in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ Found: $file"
    else
        echo "  ❌ Missing: $file"
    fi
done

echo ""
echo -e "${BLUE}[STEP 2]${NC} Checking git status..."
git status --short

echo ""
echo -e "${BLUE}[STEP 3]${NC} Adding workflows to git..."
git add .github/

echo ""
echo -e "${BLUE}[STEP 4]${NC} Checking if workflows are staged..."
git status --short | grep ".github"

echo ""
echo -e "${YELLOW}[INFO]${NC} Ready to commit and push workflows to GitHub"
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff --cached"
echo "  2. Commit: git commit -m 'Add GitHub Actions CI/CD workflows'"
echo "  3. Push: git push origin main"
echo ""
read -p "Do you want to commit and push now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}[STEP 5]${NC} Committing workflows..."
    git commit -m "Add GitHub Actions CI/CD workflows

- Add test.yml: Main test suite with syntax check, structure validation, and Docker tests
- Add security.yml: Security scanning with ShellCheck and pattern detection
- Add docs.yml: Documentation validation
- Add release.yml: Automated release creation with tags
- Add workflow README.md: Documentation for workflows"
    
    echo ""
    echo -e "${BLUE}[STEP 6]${NC} Pushing to GitHub..."
    git push origin main
    
    echo ""
    echo -e "${GREEN}[SUCCESS]${NC} GitHub Actions workflows have been deployed!"
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    NEXT STEPS                                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1. Check Actions tab on GitHub:"
    echo "   https://github.com/xdev-asia-labs/kvm-install/actions"
    echo ""
    echo "2. Workflows will run automatically on:"
    echo "   - Push to main/develop branches"
    echo "   - Pull requests to main"
    echo "   - Manual trigger (workflow_dispatch)"
    echo ""
    echo "3. To trigger a workflow manually:"
    echo "   - Go to Actions tab"
    echo "   - Select a workflow"
    echo "   - Click 'Run workflow'"
    echo ""
    echo "4. To create a release:"
    echo "   git tag v1.0.0"
    echo "   git push origin v1.0.0"
    echo ""
else
    echo ""
    echo -e "${YELLOW}[INFO]${NC} Skipped push. You can manually push later with:"
    echo "  git commit -m 'Add GitHub Actions workflows'"
    echo "  git push origin main"
    echo ""
fi
