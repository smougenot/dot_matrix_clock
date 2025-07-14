#!/bin/bash
# Pre-commit hook to detect secrets in committed files
# Place this file in .git/hooks/pre-commit and make it executable

echo "🔍 Running pre-commit secret detection..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check for secrets in staged files
check_secrets_in_staged_files() {
    # Get list of staged files
    staged_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ino|cpp|h|c|py|js|ts|yml|yaml|json)$' || true)
    
    if [ -z "$staged_files" ]; then
        echo -e "${GREEN}✅ No relevant files staged for commit${NC}"
        return 0
    fi
    
    echo "Checking staged files: $staged_files"
    
    secrets_found=0
    
    # Check each staged file
    for file in $staged_files; do
        if [ -f "$file" ]; then
            echo "Checking $file..."
            
            # Check for WiFi credentials
            if git show :$file | grep -E "(ssid|password|SSID|PASSWORD)\s*[=:]\s*['\"][^'\"]{3,}['\"]" | grep -v "YOUR_" | grep -v "example" | grep -v "placeholder" >/dev/null 2>&1; then
                echo -e "${RED}❌ Found potential WiFi credentials in $file${NC}"
                git show :$file | grep -E "(ssid|password|SSID|PASSWORD)\s*[=:]\s*['\"][^'\"]{3,}['\"]" | grep -v "YOUR_" | grep -v "example"
                secrets_found=1
            fi
            
            # Check for API keys
            if git show :$file | grep -E "(api[_-]?key|token|secret)['\"]?\s*[=:]\s*['\"][a-zA-Z0-9]{16,}['\"]" >/dev/null 2>&1; then
                echo -e "${RED}❌ Found potential API key/token in $file${NC}"
                secrets_found=1
            fi
            
            # Check for real network names
            if git show :$file | grep -E "(Livebox|Freebox|SFR|Orange|Bouygues)-[A-Z0-9]+" >/dev/null 2>&1; then
                echo -e "${RED}❌ Found real network name in $file${NC}"
                secrets_found=1
            fi
            
            # Check for long hex strings (potential keys)
            if git show :$file | grep -E "['\"][a-fA-F0-9]{20,}['\"]" | grep -v "YOUR_" >/dev/null 2>&1; then
                echo -e "${YELLOW}⚠️  Found long hex string in $file (potential key)${NC}"
                secrets_found=1
            fi
        fi
    done
    
    return $secrets_found
}

# Check for .env files being committed
check_env_files() {
    env_files=$(git diff --cached --name-only | grep -E '\.env$' | grep -v '\.env\.example$' || true)
    
    if [ -n "$env_files" ]; then
        echo -e "${RED}❌ Attempting to commit .env files:${NC}"
        echo "$env_files"
        echo -e "${YELLOW}💡 Tip: Add .env to .gitignore and use .env.example instead${NC}"
        return 1
    fi
    
    return 0
}

# Main execution
secrets_found=0

# Check for .env files
if ! check_env_files; then
    secrets_found=1
fi

# Check for secrets in staged files
if ! check_secrets_in_staged_files; then
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
    exit 1
else
    echo -e "${GREEN}✅ Pre-commit security check passed!${NC}"
    exit 0
fi
