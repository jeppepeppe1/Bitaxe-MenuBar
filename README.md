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

###🟠  **State: Configure IP**
- **Menu Bar**: `⛏️ Configure IP`
- **Popover**: Setup guidance with "Configure IP" button
- **Action**: Opens GitHub for setup instructions

####Common Issues
- **First-time setup**: App was installed and IP Address was not configured
- **Fresh installation**: App was reinstalled and lost previous IP configuration
- **Settings reset**: User cleared app data or reset to defaults
- **New BitAxe device**: User got a new BitAxe and needs to configure its IP
- **IP configuration cleared**: User manually removed the stored IP address
- **App update**: After major app updates that reset configuration
- **Multiple BitAxe devices**: User wants to switch to a different BitAxe device

#### **App Shows "Network Error"**
- **Unreachable IP**: Invalid IP address
- **Device offline**: BitAxe is powered off or disconnected from network
- **Network issues**: WiFi disconnected, router problems, internet outage
- **Wrong IP**: User configured incorrect IP address for their BitAxe
- **Firewall blocking**: Network firewall blocking the connection to BitAxe
- **Connection timeout**: BitAxe device takes too long to respond
- **Wrong network**: User is on different network than BitAxe device

#### **App Shows "Device Issue"**
- **Cause**: BitAxe device not responding properly
- **Device malfunction**: BitAxe hardware failure or software crash
- **Wrong firmware**: BitAxe running incompatible or corrupted firmware
- **API service down**: BitAxe web interface not responding or crashed
- **Device overheating**: BitAxe shut down due to thermal protection
- **Mining software crash**: BitAxe mining process stopped or crashed
- **Device booting**: BitAxe is starting up and not ready yet
- **Wrong device type**: Connected to non-BitAxe device at configured IP
- **Device maintenance**: BitAxe in maintenance mode or being updated
- **Hardware failure**: BitAxe ASIC or other components malfunctioning

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
