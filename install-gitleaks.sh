#!/bin/bash
# Script to install git-leaks for local development

echo "🔧 Installing git-leaks for secret detection..."

# Detect OS and install accordingly
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Detected Linux system"
    
    # Check if running on Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        echo "Installing git-leaks via direct download..."
        GITLEAKS_VERSION="8.18.0"
        wget "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O /tmp/gitleaks.tar.gz
        tar -xzf /tmp/gitleaks.tar.gz -C /tmp/
        sudo mv /tmp/gitleaks /usr/local/bin/
        rm /tmp/gitleaks.tar.gz
        
    # Check if running on CentOS/RHEL/Fedora
    elif command -v yum &> /dev/null || command -v dnf &> /dev/null; then
        echo "Installing git-leaks via direct download..."
        GITLEAKS_VERSION="8.18.0"
        curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" | tar -xzC /tmp/
        sudo mv /tmp/gitleaks /usr/local/bin/
        
    else
        echo "Unsupported Linux distribution. Please install manually:"
        echo "https://github.com/gitleaks/gitleaks"
        exit 1
    fi
    
elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS system"
    
    if command -v brew &> /dev/null; then
        echo "Installing git-leaks via Homebrew..."
        brew install gitleaks
    else
        echo "Homebrew not found. Installing git-leaks via direct download..."
        GITLEAKS_VERSION="8.18.0"
        curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_darwin_x64.tar.gz" | tar -xzC /tmp/
        sudo mv /tmp/gitleaks /usr/local/bin/
    fi
    
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Detected Windows system"
    echo "Please install git-leaks manually from:"
    echo "https://github.com/gitleaks/gitleaks/releases"
    echo "Or use: winget install gitleaks"
    exit 1
    
else
    echo "Unsupported operating system: $OSTYPE"
    echo "Please install git-leaks manually from:"
    echo "https://github.com/gitleaks/gitleaks"
    exit 1
fi

# Verify installation
if command -v gitleaks &> /dev/null; then
    echo "✅ git-leaks installed successfully!"
    echo "Version: $(gitleaks version)"
    echo ""
    echo "You can now:"
    echo "  - Run './install-hooks.sh' to install the pre-commit hook"
    echo "  - Run 'gitleaks detect --config=.gitleaks.toml' to scan the entire repository"
    echo "  - Run 'gitleaks protect --staged --config=.gitleaks.toml' to scan staged files"
else
    echo "❌ Installation failed. Please install manually from:"
    echo "https://github.com/gitleaks/gitleaks"
    exit 1
fi
