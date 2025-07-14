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

# Check if a pre-commit hook already exists
if [ -f ".git/hooks/pre-commit" ]; then
    echo "⚠️ Warning: A pre-commit hook already exists. Backing it up to .git/hooks/pre-commit.bak..."
    mv .git/hooks/pre-commit .git/hooks/pre-commit.bak
fi

# Copy the new pre-commit hook
cp .github/pre-commit-hook.sh .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

echo "✅ Pre-commit hook installed successfully!"
echo ""
echo "The hook will now:"
echo "  🔧 Auto-install git-leaks if needed (Linux/macOS)"
echo "  🔍 Scan staged files for secrets before each commit"
echo "  🚫 Block commits containing potential secrets"
echo "  💡 Provide helpful guidance for fixing issues"
echo ""
echo "To test it, try committing a file with a real password and see it get blocked."
echo ""
echo "To bypass the hook (NOT RECOMMENDED), use: git commit --no-verify"
