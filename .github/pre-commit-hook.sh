#!/bin/bash
# Pre-commit hook to detect secrets in committed files using git-leaks
# Place this file in .git/hooks/pre-commit and make it executable

echo "🔍 Running pre-commit secret detection with git-leaks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if git-leaks is installed
if ! command -v gitleaks &> /dev/null; then
    echo -e "${YELLOW}⚠️  git-leaks not found. Installing...${NC}"
    
    # Try to install git-leaks
    if command -v brew &> /dev/null; then
        brew install gitleaks
    elif command -v apt-get &> /dev/null; then
        # For Ubuntu/Debian - download binary
        GITLEAKS_VERSION="8.18.0"
        wget "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O /tmp/gitleaks.tar.gz
        tar -xzf /tmp/gitleaks.tar.gz -C /tmp/
        sudo mv /tmp/gitleaks /usr/local/bin/
        rm /tmp/gitleaks.tar.gz
    else
        echo -e "${RED}❌ Could not install git-leaks automatically. Please install manually:${NC}"
        echo "  - GitHub: https://github.com/gitleaks/gitleaks"
        echo "  - or run: brew install gitleaks"
        exit 1
    fi
fi

# Function to check for .env files being committed
check_env_files() {
    # Only check for added or modified .env files, not deleted ones
    env_files=$(git diff --cached --name-only --diff-filter=AM | grep -E '\.env$' | grep -v '\.env\.example$' || true)
    
    if [ -n "$env_files" ]; then
        echo -e "${RED}❌ Attempting to commit .env files:${NC}"
        echo "$env_files"
        echo -e "${YELLOW}💡 Tip: Add .env to .gitignore and use .env.example instead${NC}"
        return 1
    fi
    
    return 0
}

# Run git-leaks on staged files
run_gitleaks() {
    echo "Running git-leaks scan on staged files..."
    
    # Use git-leaks to scan staged files
    if gitleaks protect --staged --config=.gitleaks.toml --verbose 2>/dev/null; then
        echo -e "${GREEN}✅ git-leaks scan passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ git-leaks detected potential secrets!${NC}"
        echo -e "${YELLOW}💡 Run 'gitleaks protect --staged --config=.gitleaks.toml' for details${NC}"
        return 1
    fi
}

# Additional quick checks for common IoT secrets
quick_iot_checks() {
    echo "Running additional IoT-specific checks..."
    
    # Get staged files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ino|cpp|h|c)$' || true)
    
    if [ -z "$staged_files" ]; then
        return 0
    fi
    
    secrets_found=0
    
    # Check each staged file for common IoT patterns
    for file in $staged_files; do
        if [ -f "$file" ]; then
            # Quick check for real network names (not caught by standard patterns)
            if git show :$file | grep -i -E "(livebox|freebox|sfr|orange|bouygues|bbox)-[a-z0-9]+" >/dev/null 2>&1; then
                echo -e "${RED}❌ Found potential real ISP network name in $file${NC}"
                secrets_found=1
            fi
            
            # Check for hardcoded WiFi credentials that look real
            if git show :$file | grep -E 'ssid.*=.*"[A-Za-z0-9-_]{6,}"' | grep -v -E "(YOUR_|TEST|DEMO|EXAMPLE)" >/dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Found potential real SSID in $file${NC}"
                secrets_found=1
            fi
        fi
    done
    
    if [ $secrets_found -eq 1 ]; then
        echo -e "${YELLOW}💡 Please review the findings above. Use placeholders like 'YOUR_WIFI_SSID'.${NC}"
        return 1
    fi
    
    return 0
}

# Main execution
secrets_found=0

# Check for .env files
echo "Checking for .env files..."
if ! check_env_files; then
    secrets_found=1
fi

# Run git-leaks
if ! run_gitleaks; then
    secrets_found=1
fi

# Run additional IoT checks
if ! quick_iot_checks; then
    secrets_found=1
fi

# Final result
if [ $secrets_found -eq 1 ]; then
    echo ""
    echo -e "${RED}❌ Pre-commit check failed: Potential secrets detected!${NC}"
    echo -e "${YELLOW}💡 Please review and remove any real credentials before committing.${NC}"
    echo -e "${YELLOW}💡 Use placeholder values like 'YOUR_WIFI_SSID' instead.${NC}"
    echo ""
    echo "To bypass this check (NOT RECOMMENDED), use: git commit --no-verify"
    echo "To see detailed git-leaks output: gitleaks protect --staged --config=.gitleaks.toml"
    exit 1
else
    echo -e "${GREEN}✅ Pre-commit security check passed!${NC}"
    exit 0
fi
