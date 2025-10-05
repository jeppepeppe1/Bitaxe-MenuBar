# BitAxe MenuBar - Push Guidelines

**⚠️ INTERNAL DOCUMENT - DO NOT COMMIT TO GITHUB ⚠️**

This document outlines the rules and procedures for testing, version management, and pushing changes to the BitAxe MenuBar application.

## Table of Contents
1. [Version Management Guidelines](#version-management-guidelines)
2. [Testing Rules](#testing-rules)
3. [State Testing Procedures](#state-testing-procedures)
4. [Cleanup Checklist](#cleanup-checklist)
5. [Pre-Push Verification](#pre-push-verification)
6. [Common Testing Scenarios](#common-testing-scenarios)
7. [Troubleshooting](#troubleshooting)

---

## Version Management Guidelines

### **🎯 RULE #1: Always Update ALL Places**
When updating version, I MUST update:
1. ✅ **Swift code** (`Sources/BitAxeMenuBar/main.swift` - line 412)
2. ✅ **VERSION file** (root directory)
3. ✅ **Git tag** (create new release)
4. ✅ **Homebrew formula** (version, URL, SHA256)

### **🎯 RULE #2: Use the Update Script**
Always use: `./update-version.sh X.Y.Z`
This automatically updates:
- VERSION file
- Swift code version
- Homebrew formula version
- Homebrew formula URL
- Homebrew formula SHA256

### **🎯 RULE #3: Complete Process**
After running the script, I MUST:
1. **Commit main repo**: `git add . && git commit -m "Update to vX.Y.Z" && git push origin main`
2. **Create release tag**: `git tag vX.Y.Z && git push origin vX.Y.Z`
3. **Update Homebrew repo**: `cd /Users/jeppepeppe/Desktop/homebrew-bitaxe-menubar && git add . && git commit -m "Update to vX.Y.Z" && git push origin main`

### **🎯 RULE #4: Verify Everything**
After updates, I MUST verify:
- ✅ App displays correct version
- ✅ Homebrew installs correct version
- ✅ Both repositories are synchronized

### **🎯 RULE #5: Never Skip Steps**
I will NEVER:
- ❌ Update only one repository
- ❌ Forget to create release tags
- ❌ Skip updating Homebrew formula
- ❌ Leave version numbers mismatched

### **📋 Version Update Checklist:**
```bash
# 1. Run update script
./update-version.sh X.Y.Z

# 2. Commit main repository
git add . && git commit -m "Update to vX.Y.Z" && git push origin main

# 3. Create release tag
git tag vX.Y.Z && git push origin vX.Y.Z

# 4. Update Homebrew repository
cd /Users/jeppepeppe/Desktop/homebrew-bitaxe-menubar
git add . && git commit -m "Update to vX.Y.Z" && git push origin main

# 5. Verify installation
brew update && brew upgrade bitaxe-menubar
```

### **Key Principle:**
**NEVER update just one repository - always update BOTH repositories and ensure version numbers match everywhere!**

---

## Testing Rules

### 1. **Always Clean Up After Testing**
- **Remove all temporary overrides** before pushing
- **Clear stored configuration** between tests
- **Terminate all running instances** before starting new tests
- **No debugging print statements** in production code

### 2. **State Testing Protocol**
- **One state at a time** - test each state individually
- **Use temporary overrides** for controlled testing
- **Verify expected behavior** matches documentation
- **Clean up immediately** after each test

### 3. **Configuration Management**
- **Clear IP settings** between tests: `defaults delete com.bitaxe.menubar BitAxeIP`
- **Test fresh installs** by clearing all stored data
- **Verify default behavior** without any stored configuration

---

## State Testing Procedures

### Testing "Configure IP" State
```bash
# 1. Clear any stored IP configuration
defaults delete com.bitaxe.menubar BitAxeIP

# 2. Terminate any running instances
pkill -f bitaxe-menubar

# 3. Start fresh app
swift run

# 4. Verify: Should show "⛏️ Configure IP" in orange
# 5. Click icon: Should show Configure IP popover with orange button
```

### Testing "Network Error" State
```bash
# 1. Set an invalid/unreachable IP
defaults write com.bitaxe.menubar BitAxeIP "192.168.1.999"

# 2. Terminate and restart app
pkill -f bitaxe-menubar && swift run

# 3. Verify: Should show "⛏️ Network Error" in red
# 4. Click icon: Should show Network Error popover with red button
```

### Testing "Connected" State
```bash
# 1. Set valid BitAxe IP
defaults write com.bitaxe.menubar BitAxeIP "192.168.0.13"

# 2. Terminate and restart app
pkill -f bitaxe-menubar && swift run

# 3. Verify: Should show connected state with real data
# 4. Check temperature colors: Green below 65°C, red above 65°C
```

### Testing with Temporary Overrides
```swift
// Add temporary override in updateMinerData() function
func updateMinerData() {
    // TEMPORARY: Force [STATE] for testing
    showMenuBarState("⛏️ [STATE]", color: .system[COLOR])
    popoverViewController?.updateData(...)
    return
    
    // Original code continues here...
}
```

**⚠️ CRITICAL: Remove ALL temporary overrides before pushing!**

---

## Cleanup Checklist

### Before Every Push
- [ ] **No temporary overrides** in code
- [ ] **No debugging print statements** 
- [ ] **No unused variables** or unreachable code
- [ ] **Clean compilation** with no warnings (except expected Resources warning)
- [ ] **All app states tested** and working correctly
- [ ] **Production-ready code** only

### Code Cleanup Commands
```bash
# Check for temporary code
grep -i "temporary\|override\|fake\|debug" Sources/BitAxeMenuBar/main.swift

# Check for print statements
grep -n "print(" Sources/BitAxeMenuBar/main.swift

# Verify clean build
swift build

# Check for warnings
swift build 2>&1 | grep -i warning
```

### Configuration Cleanup
```bash
# Clear all stored configuration
defaults delete com.bitaxe.menubar BitAxeIP

# Verify no configuration remains
defaults read com.bitaxe.menubar BitAxeIP 2>/dev/null || echo "Clean - no IP configured"
```

---

## Pre-Push Verification

### 1. **Code Quality Check**
```bash
# Build and verify no warnings
swift build

# Expected output: Only "Invalid Resource 'Resources'" warning
# No warnings about unused variables, unreachable code, etc.
```

### 2. **State Verification**
```bash
# Test Configure IP state (fresh install)
defaults delete com.bitaxe.menubar BitAxeIP
pkill -f bitaxe-menubar
swift run
# Verify: Shows "⛏️ Configure IP" in orange
```

### 3. **Documentation Check**
- [ ] **README.md** is up to date
- [ ] **Installation instructions** are correct
- [ ] **Update commands** are accurate
- [ ] **Version numbers** are consistent

### 4. **Git Status Check**
```bash
# Verify only intended changes
git status
git diff --cached

# Should only show legitimate changes, no temporary code
```

---

## Common Testing Scenarios

### Scenario 1: Testing All States
```bash
# 1. Configure IP State
defaults delete com.bitaxe.menubar BitAxeIP
pkill -f bitaxe-menubar && swift run
# Verify orange "Configure IP" state

# 2. Network Error State  
defaults write com.bitaxe.menubar BitAxeIP "192.168.1.999"
pkill -f bitaxe-menubar && swift run
# Verify red "Network Error" state

# 3. Connected State
defaults write com.bitaxe.menubar BitAxeIP "192.168.0.13"
pkill -f bitaxe-menubar && swift run
# Verify green connected state with real data

# 4. Clean up
defaults delete com.bitaxe.menubar BitAxeIP
```

### Scenario 2: Testing Temperature Color Changes
```bash
# 1. Connect to real BitAxe device
defaults write com.bitaxe.menubar BitAxeIP "192.168.0.13"
pkill -f bitaxe-menubar && swift run

# 2. Monitor ASIC temperature
# - Green: ≤ 65°C
# - Red: > 65°C

# 3. Monitor VR temperature  
# - Green: ≤ 80°C
# - Red: > 80°C
```

### Scenario 3: Testing Homebrew Installation
```bash
# 1. Install via Homebrew
brew tap jeppepeppe1/bitaxe-menubar
brew install jeppepeppe1/bitaxe-menubar/bitaxe-menubar

# 2. Run installed version
bitaxe-menubar &

# 3. Verify: Should show Configure IP state initially
# 4. Test configuration and connection
```

---

## Troubleshooting

### Issue: App Shows Wrong State
**Problem**: App shows "Network Error" instead of "Configure IP"
**Solution**: 
```bash
# Clear stored IP configuration
defaults delete com.bitaxe.menubar BitAxeIP
pkill -f bitaxe-menubar
swift run
```

### Issue: Temporary Override Still Active
**Problem**: App shows fake data instead of real data
**Solution**:
```bash
# Check for temporary code
grep -i "temporary\|override" Sources/BitAxeMenuBar/main.swift

# Remove any temporary overrides
# Rebuild and test
swift build && swift run
```

### Issue: Build Warnings
**Problem**: Compilation shows warnings
**Solution**:
```bash
# Check specific warnings
swift build 2>&1 | grep -i warning

# Fix unused variables, unreachable code, etc.
# Verify clean build
swift build
```

### Issue: Configuration Not Clearing
**Problem**: `defaults delete` doesn't work
**Solution**:
```bash
# Check what's stored
defaults read com.bitaxe.menubar

# Delete entire domain if needed
defaults delete com.bitaxe.menubar

# Or delete specific key
defaults delete com.bitaxe.menubar BitAxeIP
```

---

## Testing Commands Reference

### Quick State Tests
```bash
# Configure IP State
defaults delete com.bitaxe.menubar BitAxeIP && pkill -f bitaxe-menubar && swift run

# Network Error State  
defaults write com.bitaxe.menubar BitAxeIP "192.168.1.999" && pkill -f bitaxe-menubar && swift run

# Connected State
defaults write com.bitaxe.menubar BitAxeIP "192.168.0.13" && pkill -f bitaxe-menubar && swift run
```

### Cleanup Commands
```bash
# Full cleanup
defaults delete com.bitaxe.menubar BitAxeIP && pkill -f bitaxe-menubar

# Verify clean state
defaults read com.bitaxe.menubar BitAxeIP 2>/dev/null || echo "Clean"
```

### Build Verification
```bash
# Clean build check
swift build

# Check for issues
grep -i "temporary\|override\|fake" Sources/BitAxeMenuBar/main.swift
grep -n "print(" Sources/BitAxeMenuBar/main.swift
```

---

## Best Practices

### 1. **Always Test Fresh Installs**
- Clear all configuration before testing
- Verify default behavior matches expectations
- Test the complete user journey

### 2. **Use Temporary Overrides Sparingly**
- Only for specific state testing
- Remove immediately after testing
- Never commit temporary code

### 3. **Verify Before Pushing**
- Run full cleanup checklist
- Test at least Configure IP state
- Ensure clean compilation

### 4. **Document Issues**
- Note any unexpected behavior
- Document solutions for future reference
- Update this guide as needed

---

**Remember: The goal is to maintain a clean, production-ready repository that works correctly for all users, not just during testing!**
