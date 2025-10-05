# ⛏️ BitAxe MenuBar

A comprehensive macOS menu bar application for monitoring your BitAxe mining device with real-time status updates, interactive popover interface, and intelligent state management.

<img width="600" height="148" alt="bitaxe-menubar" src="https://github.com/user-attachments/assets/34c222ef-6b28-42eb-aeda-062b3d1c3009" />

## 🎚️ Features

### **Core Monitoring**
- **Real-time Data**: Live hashrate, ASIC temperature, and VR temperature monitoring
- **Auto-refresh**: Updates data every 5 seconds
- **High Precision**: Hashrate displayed with 3 decimal places (e.g., 1.399 TH/s)
- **Smart Temperature Alerts**: Color-coded warnings when temperatures exceed safe thresholds
- **Model Detection**: Automatically detects BitAxe model (Gamma, Supra, Hex, Ultra, Max)

### **Update Management**
- **Homebrew Integration**: Seamless updates via Homebrew package manager
- **Update Notifications**: In-app update alerts with copy-to-clipboard commands
- **Version Tracking**: Automatic version checking and update availability

### Temperature Thresholds

- **ASIC Temperature**: 
  - 🟢 Normal: ≤ 65°C
  - 🔴 Critical: > 65°C
- **VR Temperature**: 
  - 🟢 Normal: ≤ 80°C
  - 🔴 Critical: > 80°C


## 💬 Dialog Messages

🟠  **State: Configure IP**
- **Menu Bar**: `⛏️ Configure IP`
- **Popover**: Setup guidance with "Configure IP" button
- **Action**: Opens GitHub for setup instructions

🟠 **State: Device Issue**
- **Menu Bar**: `⛏️ Device Issue`
- **Popover**: Dual-action interface with two buttons:
- "Open AxeOS" - Access BitAxe web interface
- "Open Github" - Opens Github for troubleshooting

🔴 **State: Network Error**
- **Menu Bar**: `⛏️ Network Error`
- **Popover**: Network diagnostics with "View Troubleshooting" button
- **Action**: Opens GitHub for troubleshooting

🟢 **State: Connected**
- **Menu Bar**: `⛏️ [hashrate] TH/s | A [temp]°C | VR [temp]°C`
- **Popover**: Full monitoring interface with:
  - Complete device information
  - Model detection and display
  - "Open AxeOS" button for quick access

## 🚀 Installation

### Via Homebrew (Recommended)

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install BitAxe MenuBar
brew tap jeppepeppe1/bitaxe-menubar
brew install bitaxe-menubar
```

### Configuration

```bash
# Set your BitAxe IP address
bitaxe-config <YOUR_BITAXE_IP_ADDRESS>

# Start the app
bitaxe-menubar &
```

## 🔄 Update App

The app checks for updates and displays an update banner when new versions are available. Click "Update App" to get Homebrew update instructions.

### Manual Updates
```bash
# Update via Homebrew
brew update
brew upgrade bitaxe-menubar

# Restart the app
pkill -f bitaxe-menubar
bitaxe-menubar &
```

## 🛠️ Troubleshooting

### Common Issues

#### **App Shows "Configure IP"**
- **Cause**: No IP address configured
- **Solution**: Run `bitaxe-config <YOUR_IP_ADDRESS>`

#### **App Shows "Network Error"**
- **Cause**: Cannot reach BitAxe device
- **Solutions**:
  - Verify BitAxe is powered on and connected to network
  - Check IP address is correct
  - Ensure no firewall blocking the connection
  - Verify you're on the same network as the BitAxe

#### **App Shows "Device Issue"**
- **Cause**: BitAxe device not responding properly
- **Solutions**:
  - Check BitAxe web interface directly
  - Restart BitAxe device
  - Verify BitAxe firmware is up to date
  - Check for hardware issues

#### **SHA-256 Hash Mismatch Error**
```bash
# Clear Homebrew cache
brew cleanup --prune=all

# Try installation again
brew install jeppepeppe1/bitaxe-menubar/bitaxe-menubar
```

#### **Data Not Updating**
```bash
# Update to latest version
brew upgrade bitaxe-menubar

# Restart the app
pkill -f bitaxe-menubar
bitaxe-menubar &
```

## 📋 Requirements

- **macOS**: 13.0+ (Ventura or later)
- **Swift**: 5.8+ (for building from source)
- **Network**: BitAxe device on your local network
- **Dependencies**: `terminal-notifier` (installed automatically via Homebrew)

## 🔗 Links

- **Repository**: [https://github.com/jeppepeppe1/BitAxe-MenuBar](https://github.com/jeppepeppe1/BitAxe-MenuBar)
- **Homebrew Tap**: [https://github.com/jeppepeppe1/homebrew-bitaxe-menubar](https://github.com/jeppepeppe1/homebrew-bitaxe-menubar)
- **BitAxe Documentation**: [https://osmu.wiki/bitaxe/api/](https://osmu.wiki/bitaxe/api/)
- **ESP-Miner API**: [https://github.com/bitaxeorg/ESP-Miner](https://github.com/bitaxeorg/ESP-Miner)

## 🛟 Getting Help

- **General Bitaxe Help**: https://discord.com/invite/osmu
