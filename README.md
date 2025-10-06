# ⛏️ Bitaxe MenuBar

Monitor your BitAxe from the macOS menu bar with live stats, temperature alerts, and Homebrew support.

<img width="600" height="818" alt="bitaxe-menubar" src="https://github.com/user-attachments/assets/a57adfb9-7aa8-460f-bf93-f46533ea244c" />

## 🎚️ Features

- Model Detection: Automatically detects BitAxe model (Gamma, Supra, Hex, Ultra, Max)
- Real-time Data: Live hashrate, ASIC temperature, and VR temperature monitoring
- Auto-refresh: Updates data every 5 seconds
- Smart Temperature Alerts: Color-coded warnings when temperatures exceed safe thresholds
- Homebrew Integration: Seamless installation and updates via Homebrew package manager
- Dynamic Version Display: Displays the current version and notifies you when an update is available

### Safety Notifications
#### Temperature Thredsholds

- **ASIC Temperature**: 
  - 🟢 Normal: ≤ 65°C
  - 🔴 Critical: > 65°C
- **VR Temperature**: 
  - 🟢 Normal: ≤ 80°C
  - 🔴 Critical: > 80°C


## 🚀 Installation Commands

#### **First-Time Installation (Complete Setup)**
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Complete installation with IP configuration
brew tap jeppepeppe1/bitaxe-menubar && brew install jeppepeppe1/bitaxe-menubar/bitaxe-menubar && bitaxe-config <YOUR_IP> && nohup bitaxe-menubar > /dev/null 2>&1 &
```

#### **Update Existing Installation**
```bash
# Update to latest version and restart
brew update && brew upgrade bitaxe-menubar && pkill -f bitaxe-menubar && nohup bitaxe-menubar > /dev/null 2>&1 &
```

#### **Quick Restart (No Update)**
```bash
# Just restart the app (useful after configuration changes)
pkill -f bitaxe-menubar && nohup bitaxe-menubar > /dev/null 2>&1 &
```

#### **Run App Independently (Recommended)**
```bash
# Start app that survives terminal closure
nohup bitaxe-menubar > /dev/null 2>&1 &

# Stop the app
pkill -f bitaxe-menubar
```

#### **Reconfigure IP Address**
```bash
# Change IP address
bitaxe-config <YOUR_IP> 

# Restart
nohup bitaxe-menubar > /dev/null 2>&1 &
```

#### **Complete Uninstall**
```bash
# Remove everything completely
pkill -f bitaxe-menubar && brew uninstall bitaxe-menubar && brew untap jeppepeppe1/bitaxe-menubar
```

## 📋 Changelog

### **v1.1.1** - Terminal Independence & UI Fixes
- Fixed UI layering to eliminate button blinking on startup
- Updated README with terminal-independent commands
- App now runs independently of terminal closure

### **v1.1.0** - Sparkline Graph
- Added real-time hashrate sparkline graph
- 3-second update interval for faster monitoring

## 🛠️ Dialog Messages & Troubleshooting

### 🟠 **State: Configure IP** 
- **Menu Bar**: `⛏️ Configure IP`

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

## 📋 Requirements

- **HomeBrew:** Software package manager for macOS
- **macOS:** 13.0+ (Ventura or later)
- **Device:** Bitaxe Max, Ultra, Hex, Supra or Gamma

## 🔗 Links

- **Homebrew Tap**: [https://github.com/jeppepeppe1/homebrew-bitaxe-menubar](https://github.com/jeppepeppe1/homebrew-bitaxe-menubar)
- **BitAxe Documentation**: [https://osmu.wiki/bitaxe/api/](https://osmu.wiki/bitaxe/api/)
- **ESP-Miner API**: [https://github.com/bitaxeorg/ESP-Miner](https://github.com/bitaxeorg/ESP-Miner)

## ℹ️ Information

- **Disclaimer** Developed by enthusiasts, this project is not an official Bitaxe product

## 🧑‍💻 Community

- **Open Source Miners United**: https://discord.com/invite/osmu
