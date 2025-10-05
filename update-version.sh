#!/bin/bash

# Version Management Script for BitAxe MenuBar
# Usage: ./update-version.sh 1.0.9

if [ -z "$1" ]; then
    echo "Usage: ./update-version.sh <version>"
    echo "Example: ./update-version.sh 1.0.9"
    exit 1
fi

NEW_VERSION="$1"
echo "Updating version to: $NEW_VERSION"

# Update VERSION file
echo "$NEW_VERSION" > VERSION
echo "✅ Updated VERSION file"

# Update Swift code version
sed -i '' "s/let version = \"[^\"]*\"/let version = \"$NEW_VERSION\"/" Sources/BitAxeMenuBar/main.swift
echo "✅ Updated Swift code version"

# Update Homebrew formula
cd /Users/jeppepeppe/Desktop/homebrew-bitaxe-menubar
sed -i '' "s/version \"[^\"]*\"/version \"$NEW_VERSION\"/" bitaxe-menubar.rb
echo "✅ Updated Homebrew formula version"

# Get new SHA256
echo "📦 Getting SHA256 for v$NEW_VERSION..."
NEW_SHA256=$(curl -sL "https://github.com/jeppepeppe1/BitAxe-MenuBar/archive/refs/tags/v$NEW_VERSION.tar.gz" | shasum -a 256 | cut -d' ' -f1)

# Update Homebrew formula URL and SHA256
sed -i '' "s|url \"https://github.com/jeppepeppe1/BitAxe-MenuBar/archive/refs/tags/v[^\"]*\.tar\.gz\"|url \"https://github.com/jeppepeppe1/BitAxe-MenuBar/archive/refs/tags/v$NEW_VERSION.tar.gz\"|" bitaxe-menubar.rb
sed -i '' "s/sha256 \"[^\"]*\"/sha256 \"$NEW_SHA256\"/" bitaxe-menubar.rb
echo "✅ Updated Homebrew formula URL and SHA256"

echo ""
echo "🎉 Version update complete!"
echo "Next steps:"
echo "1. Commit and push main repo: git add . && git commit -m \"Update to v$NEW_VERSION\" && git push origin main"
echo "2. Create release tag: git tag v$NEW_VERSION && git push origin v$NEW_VERSION"
echo "3. Commit and push Homebrew repo: cd /Users/jeppepeppe/Desktop/homebrew-bitaxe-menubar && git add . && git commit -m \"Update to v$NEW_VERSION\" && git push origin main"
