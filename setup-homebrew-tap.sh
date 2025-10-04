#!/bin/bash

# BitAxe MenuBar - Homebrew Tap Setup Script
# This script sets up the Homebrew tap repository

set -e

echo "🍺 Setting up Homebrew tap for BitAxe MenuBar..."

# Configuration
MAIN_REPO="BitAxe-MenuBar"
TAP_REPO="homebrew-bitaxe-menubar"
GITHUB_USER="jeppepeppe1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 Configuration:${NC}"
echo "  Main repo: ${GITHUB_USER}/${MAIN_REPO}"
echo "  Tap repo: ${GITHUB_USER}/${TAP_REPO}"
echo ""

# Check if we're in the right directory
if [ ! -f "Package.swift" ] || [ ! -f "bitaxe-menubar.rb" ]; then
    echo -e "${RED}❌ Error: Please run this script from the BitAxe MenuBar project root${NC}"
    exit 1
fi

# Create tap directory
TAP_DIR="../${TAP_REPO}"
echo -e "${YELLOW}📁 Creating tap directory: ${TAP_DIR}${NC}"

if [ -d "$TAP_DIR" ]; then
    echo -e "${YELLOW}⚠️  Tap directory already exists. Removing...${NC}"
    rm -rf "$TAP_DIR"
fi

mkdir -p "$TAP_DIR"

# Copy formula to tap directory
echo -e "${YELLOW}📋 Copying formula to tap directory...${NC}"
cp bitaxe-menubar.rb "$TAP_DIR/"

# Create tap README
echo -e "${YELLOW}📝 Creating tap README...${NC}"
cat > "$TAP_DIR/README.md" << EOF
# Homebrew BitAxe MenuBar

This is a [Homebrew](https://brew.sh) tap for the BitAxe MenuBar application.

## Installation

\`\`\`bash
# Add this tap
brew tap ${GITHUB_USER}/bitaxe-menubar

# Install BitAxe MenuBar
brew install bitaxe-menubar
\`\`\`

## What's Included

- **bitaxe-menubar**: macOS menu bar app for monitoring BitAxe miners
- **bitaxe-config**: CLI tool for configuring BitAxe IP address

## Usage

After installation:

\`\`\`bash
# Configure your BitAxe IP
bitaxe-config 192.168.1.100

# Run the app
bitaxe-menubar
\`\`\`

## Documentation

For complete documentation, visit the main repository:
https://github.com/${GITHUB_USER}/${MAIN_REPO}

## License

MIT
EOF

# Create tap .gitignore
echo -e "${YELLOW}📝 Creating tap .gitignore...${NC}"
cat > "$TAP_DIR/.gitignore" << EOF
# Homebrew tap specific ignores
*.rb.bak
*.rb.orig
EOF

# Initialize git repository
echo -e "${YELLOW}🔧 Initializing git repository...${NC}"
cd "$TAP_DIR"
git init
git add .
git commit -m "Initial Homebrew tap for BitAxe MenuBar

- Formula for bitaxe-menubar application
- CLI configuration tool included
- Complete installation instructions"

# Add remote (user will need to create the GitHub repo first)
echo -e "${YELLOW}🔗 Setting up git remote...${NC}"
git remote add origin "https://github.com/${GITHUB_USER}/${TAP_REPO}.git"

cd ..

echo ""
echo -e "${GREEN}✅ Homebrew tap setup complete!${NC}"
echo ""
echo -e "${BLUE}📋 Next steps:${NC}"
echo "1. Create GitHub repository: ${GITHUB_USER}/${TAP_REPO}"
echo "2. Push the tap:"
echo "   cd ${TAP_DIR}"
echo "   git push -u origin main"
echo ""
echo -e "${BLUE}🧪 Test installation:${NC}"
echo "   brew tap ${GITHUB_USER}/bitaxe-menubar"
echo "   brew install bitaxe-menubar"
echo ""
echo -e "${GREEN}🎉 Your BitAxe MenuBar is ready for Homebrew distribution!${NC}"
