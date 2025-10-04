# BitAxe MenuBar - Makefile
# Common development tasks

.PHONY: help build test clean install tap setup-tap push-tap status

# Default target
help:
	@echo "BitAxe MenuBar - Available Commands:"
	@echo ""
	@echo "  make build      - Build the application in release mode"
	@echo "  make test       - Test the application (runs for 10 seconds)"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make install    - Install via Homebrew (requires tap setup)"
	@echo "  make tap        - Setup Homebrew tap locally"
	@echo "  make push-tap   - Push Homebrew tap to GitHub"
	@echo "  make status     - Show project status"
	@echo "  make manage     - Run interactive project manager"
	@echo ""

# Build the application
build:
	@echo "🏗️  Building BitAxe MenuBar..."
	swift build --configuration release
	@echo "✅ Build complete!"

# Test the application
test:
	@echo "🧪 Testing BitAxe MenuBar (10 seconds)..."
	timeout 10s swift run bitaxe-menubar || true
	@echo "✅ Test complete!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf .build
	swift package clean
	@echo "✅ Clean complete!"

# Install via Homebrew
install:
	@echo "🍺 Installing via Homebrew..."
	brew tap jeppepeppe1/bitaxe-menubar
	brew install bitaxe-menubar
	@echo "✅ Installation complete!"

# Setup Homebrew tap locally
tap:
	@echo "🍺 Setting up Homebrew tap..."
	./setup-homebrew-tap.sh
	@echo "✅ Tap setup complete!"

# Push Homebrew tap to GitHub
push-tap:
	@echo "🍺 Pushing Homebrew tap to GitHub..."
	cd ../homebrew-bitaxe-menubar && git push -u origin main
	@echo "✅ Tap pushed to GitHub!"

# Show project status
status:
	@echo "📊 Project Status:"
	@echo ""
	@echo "Main Repository:"
	@echo "  📁 Local: $(PWD)"
	@echo "  🌐 GitHub: https://github.com/jeppepeppe1/BitAxe-MenuBar"
	@echo "  📊 Changes: $(shell git status --porcelain | wc -l | tr -d ' ') uncommitted"
	@echo ""
	@echo "Homebrew Tap:"
	@if [ -d "../homebrew-bitaxe-menubar" ]; then \
		echo "  📁 Local: ../homebrew-bitaxe-menubar"; \
		echo "  🌐 GitHub: https://github.com/jeppepeppe1/homebrew-bitaxe-menubar"; \
		echo "  📊 Changes: $(shell cd ../homebrew-bitaxe-menubar && git status --porcelain | wc -l | tr -d ' ') uncommitted"; \
	else \
		echo "  ❌ Not set up yet (run 'make tap')"; \
	fi
	@echo ""
	@echo "Build Status:"
	@if [ -d ".build" ]; then \
		echo "  ✅ Build artifacts exist"; \
	else \
		echo "  ⚪ No build artifacts"; \
	fi

# Run interactive project manager
manage:
	@echo "🎛️  Starting BitAxe MenuBar Project Manager..."
	./manage-project.sh
