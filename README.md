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
- **Dynamic Version Display**: Shows current version automatically
- **Easy Updates**: Simple Homebrew commands for updates

### Safety Protocols

#### Temperature Thredsholds

- **ASIC Temperature**: 
  - 🟢 Normal: ≤ 65°C
  - 🔴 Critical: > 65°C
- **VR Temperature**: 
  - 🟢 Normal: ≤ 80°C
  - 🔴 Critical: > 80°C


## 🚀 Installation

### Via Homebrew (Recommended)

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add the tap (only needed once)
brew tap jeppepeppe1/bitaxe-menubar

# Install BitAxe MenuBar
brew install jeppepeppe1/bitaxe-menubar/bitaxe-menubar
```

### Configuration

```bash
# Set your BitAxe IP address
bitaxe-config <YOUR_BITAXE_IP_ADDRESS>

# Start the app
bitaxe-menubar &
```

## 🔄 Update App

### Update Commands
```bash
# Update Homebrew and upgrade BitAxe MenuBar
brew update && brew upgrade bitaxe-menubar

# Alternative - update just the app
brew upgrade jeppepeppe1/bitaxe-menubar/bitaxe-menubar

# Check current version
brew list --versions bitaxe-menubar
```

### Restart App After Update
```bash
# Stop and restart the app (allows closing terminal)
pkill -f bitaxe-menubar && bitaxe-menubar &
```

## 🛠️ Dialog Messages & Troubleshooting

### 🟠 **State: Configure IP** 
- **Menu Bar**: `⛏️ Configure IP`
- **Popover**: Setup guidance with "Configure IP" button
- **Action**: Opens GitHub for setup instructions

**Common Issues**
- **First-time setup**: App was installed and IP Address was not configured
- **Fresh installation**: App was reinstalled and lost previous IP configuration
- **Settings reset**: User cleared app data or reset to defaults
- **New BitAxe device**: User got a new BitAxe and needs to configure its IP
- **IP configuration cleared**: User manually removed the stored IP address
- **App update**: After major app updates that reset configuration
- **Multiple BitAxe devices**: User wants to switch to a different BitAxe device

### 🟠 **State: Device Issue**
- **Menu Bar**: `⛏️ Device Issue`
- **Popover**: Dual-action interface with two buttons:
  - "Open AxeOS" - Access BitAxe web interface
  - "Open Github" - Opens Github for troubleshooting

**Common Issues**
- **Unreachable IP**: Invalid IP address
- **Device offline**: BitAxe is powered off or disconnected from network
- **Network issues**: WiFi disconnected, router problems, internet outage
- **Wrong IP**: User configured incorrect IP address for their BitAxe
- **Firewall blocking**: Network firewall blocking the connection to BitAxe
- **Connection timeout**: BitAxe device takes too long to respond
- **Wrong network**: User is on different network than BitAxe device

### 🔴 **State: Network Error**
- **Menu Bar**: `⛏️ Network Error`
- **Popover**: Network diagnostics with "View Troubleshooting" button
- **Action**: Opens GitHub for troubleshooting

**Common Issues**
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

### 🟢 **State: Connected**
- **Menu Bar**: `⛏️ [hashrate] TH/s | A [temp]°C | VR [temp]°C`
- **Popover**: Full monitoring interface with:
  - Complete device information
  - Model detection and display
  - "Open AxeOS" button for quick access
  - Dynamic version display

## 📋 Requirements

- **Device:** Mac w/ macOS 13.0+ (Ventura or later)
- **Device:** Bitaxe Max, Ultra, Hex, Supra or Gamma
- **Network:** With both devices connected 

## 🔗 Links

- **Homebrew Tap**: [https://github.com/jeppepeppe1/homebrew-bitaxe-menubar](https://github.com/jeppepeppe1/homebrew-bitaxe-menubar)
- **BitAxe Documentation**: [https://osmu.wiki/bitaxe/api/](https://osmu.wiki/bitaxe/api/)
- **ESP-Miner API**: [https://github.com/bitaxeorg/ESP-Miner](https://github.com/bitaxeorg/ESP-Miner)

## 🧑‍💻 Community

- **Open Source Miners United**: https://discord.com/invite/osmu
