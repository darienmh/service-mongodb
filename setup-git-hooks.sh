#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "${YELLOW}Setting up Git hooks for conventional commits...${NC}"

# Check if .git directory exists
if [ ! -d ".git" ]; then
    echo "❌ Error: This is not a Git repository"
    echo "Please run 'git init' first"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy commit-msg hook
cp commit-msg .git/hooks/
chmod +x .git/hooks/commit-msg

echo "${GREEN}✅ Git hooks installed successfully!${NC}"
echo ""
echo "Now all your commits will be validated to follow conventional commit format:"
echo "  <type>(<scope>): <description>"
echo ""
echo "Types: feat, fix, docs, style, refactor, perf, test, chore"
echo ""
echo "Examples:"
echo "  feat: add new feature"
echo "  fix: resolve bug"
echo "  refactor: improve code structure"
echo ""
echo "The hook will prevent commits that don't follow this format." 