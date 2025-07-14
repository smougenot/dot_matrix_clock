#!/bin/bash
# Script to install the pre-commit hook for secret detection

echo "🔧 Installing pre-commit hook for secret detection..."

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Copy the pre-commit hook
cp .github/pre-commit-hook.sh .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now run automatically before each commit to check for secrets."
echo "To test it, try committing a file with a real password and see it get blocked."
echo ""
echo "To bypass the hook (NOT RECOMMENDED), use: git commit --no-verify"
