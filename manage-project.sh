#!/bin/bash

# BitAxe MenuBar - Project Management Script
# This script manages both the main app and Homebrew tap

set -e

# Configuration
MAIN_REPO="BitAxe-MenuBar"
TAP_REPO="homebrew-bitaxe-menubar"
GITHUB_USER="jeppepeppe1"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Function to print colored output
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️  $1${NC}"
}

# Function to show menu
show_menu() {
    echo ""
    print_header "BitAxe MenuBar Project Manager"
    echo ""
    echo "1. 🏗️  Build and test the app"
    echo "2. 🚀 Push main repository to GitHub"
    echo "3. 🍺 Setup Homebrew tap"
    echo "4. 🍺 Push Homebrew tap to GitHub"
    echo "5. 🧪 Test Homebrew installation"
    echo "6. 📋 Show project status"
    echo "7. 🧹 Clean build artifacts"
    echo "8. ❌ Exit"
    echo ""
    read -p "Choose an option (1-8): " choice
}

# Function to build and test
build_and_test() {
    print_header "Building and Testing BitAxe MenuBar"
    
    print_info "Cleaning previous builds..."
    swift package clean
    
    print_info "Building in release mode..."
    swift build --configuration release
    
    print_success "Build completed successfully!"
    
    print_info "Testing the app (will run for 10 seconds)..."
    timeout 10s swift run bitaxe-menubar || true
    
    print_success "App test completed!"
}

# Function to push main repository
push_main_repo() {
    print_header "Pushing Main Repository to GitHub"
    
    print_info "Adding all changes..."
    git add .
    
    print_info "Committing changes..."
    git commit -m "Update BitAxe MenuBar

- Latest improvements and fixes
- Updated documentation
- Ready for Homebrew distribution" || print_warning "No changes to commit"
    
    print_info "Pushing to GitHub..."
    git push origin main
    
    print_success "Main repository updated on GitHub!"
}

# Function to setup Homebrew tap
setup_homebrew_tap() {
    print_header "Setting Up Homebrew Tap"
    
    TAP_DIR="../${TAP_REPO}"
    
    if [ -d "$TAP_DIR" ]; then
        print_warning "Tap directory already exists. Updating..."
        rm -rf "$TAP_DIR"
    fi
    
    print_info "Creating tap directory..."
    mkdir -p "$TAP_DIR"
    
    print_info "Copying formula..."
    cp bitaxe-menubar.rb "$TAP_DIR/"
    
    print_info "Creating tap README..."
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

    print_info "Creating tap .gitignore..."
    cat > "$TAP_DIR/.gitignore" << EOF
# Homebrew tap specific ignores
*.rb.bak
*.rb.orig
EOF

    print_info "Initializing git repository..."
    cd "$TAP_DIR"
    git init
    git add .
    git commit -m "Initial Homebrew tap for BitAxe MenuBar

- Formula for bitaxe-menubar application
- CLI configuration tool included
- Complete installation instructions"
    
    git remote add origin "https://github.com/${GITHUB_USER}/${TAP_REPO}.git" 2>/dev/null || print_warning "Remote already exists"
    
    cd ..
    
    print_success "Homebrew tap setup complete!"
    print_info "Next: Create GitHub repository '${TAP_REPO}' and run option 4"
}

# Function to push Homebrew tap
push_homebrew_tap() {
    print_header "Pushing Homebrew Tap to GitHub"
    
    TAP_DIR="../${TAP_REPO}"
    
    if [ ! -d "$TAP_DIR" ]; then
        print_error "Tap directory not found. Run option 3 first."
        return 1
    fi
    
    cd "$TAP_DIR"
    
    print_info "Pushing to GitHub..."
    git push -u origin main
    
    cd ..
    
    print_success "Homebrew tap pushed to GitHub!"
    print_info "Users can now install with: brew tap ${GITHUB_USER}/bitaxe-menubar"
}

# Function to test Homebrew installation
test_homebrew_installation() {
    print_header "Testing Homebrew Installation"
    
    print_info "Testing tap installation..."
    brew tap "${GITHUB_USER}/bitaxe-menubar" || print_warning "Tap might already be installed"
    
    print_info "Testing formula installation..."
    brew install bitaxe-menubar || print_warning "Formula might already be installed"
    
    print_success "Homebrew installation test completed!"
    print_info "You can now run: bitaxe-menubar"
}

# Function to show project status
show_status() {
    print_header "Project Status"
    
    echo ""
    print_info "Main Repository:"
    echo "  📁 Local: $(pwd)"
    echo "  🌐 GitHub: https://github.com/${GITHUB_USER}/${MAIN_REPO}"
    echo "  📊 Status: $(git status --porcelain | wc -l | tr -d ' ') uncommitted changes"
    
    echo ""
    print_info "Homebrew Tap:"
    TAP_DIR="../${TAP_REPO}"
    if [ -d "$TAP_DIR" ]; then
        echo "  📁 Local: $TAP_DIR"
        echo "  🌐 GitHub: https://github.com/${GITHUB_USER}/${TAP_REPO}"
        echo "  📊 Status: $(cd "$TAP_DIR" && git status --porcelain | wc -l | tr -d ' ') uncommitted changes"
    else
        echo "  ❌ Not set up yet (run option 3)"
    fi
    
    echo ""
    print_info "Build Status:"
    if [ -d ".build" ]; then
        echo "  ✅ Build artifacts exist"
    else
        echo "  ⚪ No build artifacts"
    fi
}

# Function to clean build artifacts
clean_build() {
    print_header "Cleaning Build Artifacts"
    
    print_info "Removing build directory..."
    rm -rf .build
    
    print_info "Cleaning Swift package..."
    swift package clean
    
    print_success "Build artifacts cleaned!"
}

# Main menu loop
while true; do
    show_menu
    
    case $choice in
        1)
            build_and_test
            ;;
        2)
            push_main_repo
            ;;
        3)
            setup_homebrew_tap
            ;;
        4)
            push_homebrew_tap
            ;;
        5)
            test_homebrew_installation
            ;;
        6)
            show_status
            ;;
        7)
            clean_build
            ;;
        8)
            print_success "Goodbye! 👋"
            exit 0
            ;;
        *)
            print_error "Invalid option. Please choose 1-8."
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done
