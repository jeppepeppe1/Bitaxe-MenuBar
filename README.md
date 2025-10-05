# ⛏️ BitAxe MenuBar

A comprehensive macOS menu bar application for monitoring your BitAxe mining device with real-time status updates, interactive popover interface, and intelligent state management.

<img width="600" height="148" alt="bitaxe-menubar" src="https://github.com/user-attachments/assets/34c222ef-6b28-42eb-aeda-062b3d1c3009" />

## ✨ Features

### 🎯 **Core Monitoring**
- **Real-time Data**: Live hashrate, ASIC temperature, and VR temperature monitoring
- **High Precision**: Hashrate displayed with 3 decimal places (e.g., 1.399 TH/s)
- **Smart Temperature Alerts**: Color-coded warnings when temperatures exceed safe thresholds
- **Auto-refresh**: Updates every 5 seconds for real-time monitoring
- **Model Detection**: Automatically detects BitAxe model (Gamma, Supra, Hex, Ultra, Max)

### 🎨 **Interactive Interface**
- **Popover UI**: Click the menu bar icon to open a detailed status popover
- **State-specific Actions**: Different buttons and actions based on connection status
- **Visual Status Indicators**: Color-coded menu bar text and popover elements
- **Responsive Layout**: Clean, modern interface with proper spacing and typography

### 🔧 **Smart State Management**
- **Not Configured**: Setup guidance with direct GitHub repository access
- **Network Error**: Troubleshooting assistance with network diagnostics
- **Device Issue**: Dual-action interface (web access + GitHub support)
- **Connected**: Full monitoring with update management
- **Partial Data**: Graceful handling of incomplete API responses

### 🚀 **Update Management**
- **Homebrew Integration**: Seamless updates via Homebrew package manager
- **Update Notifications**: In-app update alerts with copy-to-clipboard commands
- **Version Tracking**: Automatic version checking and update availability

## 🌡️ Temperature Thresholds

- **ASIC Temperature**: 
  - 🟢 Normal: ≤ 65°C
  - 🔴 Critical: > 65°C
- **VR Temperature**: 
  - 🟢 Normal: ≤ 80°C
  - 🔴 Critical: > 80°C

### Menu Bar Display Examples
- `⛏️ 1.234 TH/s | A 62°C | VR 58°C` - Normal operation (green)
- `⛏️ 1.234 TH/s | A 67°C | VR 58°C` - High ASIC temperature (red)
- `⛏️ 1.234 TH/s | A 62°C | VR 82°C` - High VR temperature (red)
- `⛏️ Configure IP` - Setup required (orange)
- `⛏️ Network Error` - Connection issues (red)
- `⛏️ Device Issue` - Device problems (orange)

## 📱 App States & Interface

### **Not Configured State**
- **Menu Bar**: `⛏️ Configure IP` (orange)
- **Popover**: Setup guidance with "Configure IP" button
- **Action**: Opens GitHub repository for setup instructions

### **Network Error State**
- **Menu Bar**: `⛏️ Network Error` (red)
- **Popover**: Network diagnostics with "View Troubleshooting" button
- **Action**: Opens GitHub troubleshooting section

### **Device Issue State**
- **Menu Bar**: `⛏️ Device Issue` (orange)
- **Popover**: Dual-action interface with two buttons:
  - "Open AxeOS" - Access BitAxe web interface
  - "Open Github" - Get support and documentation

### **Connected State**
- **Menu Bar**: `⛏️ [hashrate] TH/s | A [temp]°C | VR [temp]°C` (green)
- **Popover**: Full monitoring interface with:
  - Complete device information
  - Model detection and display
  - "Open AxeOS" button for web access
  - "Update App" button (when updates available)

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

### From Source

```bash
# Clone the repository
git clone https://github.com/jeppepeppe1/BitAxe-MenuBar.git
cd BitAxe-MenuBar

# Build the application
swift build --configuration release

# Run the application
.build/release/bitaxe-menubar
```

## 🔧 Configuration

### IP Address Setup
The app requires your BitAxe device's IP address to function. You can configure it in several ways:

1. **Command Line** (Recommended):
   ```bash
   bitaxe-config 192.168.1.100
   ```

2. **Manual Configuration**:
   - The app will show "Configure IP" in the menu bar
   - Click to open setup instructions
   - Follow the GitHub repository guidance

### API Endpoint
The app connects to your BitAxe device using:
```
http://YOUR_BITAXE_IP/api/system/info
```

## 🔄 Updates

### Automatic Updates
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

#### **App Not Updating Data**
```bash
# Update to latest version
brew upgrade bitaxe-menubar

# Restart the app
pkill -f bitaxe-menubar
bitaxe-menubar &
```

### Getting Help
- **GitHub Issues**: [Report bugs or request features](https://github.com/jeppepeppe1/BitAxe-MenuBar/issues)
- **Documentation**: Check the repository for detailed setup guides
- **Community**: Join BitAxe community discussions

## 📋 Requirements

- **macOS**: 13.0+ (Ventura or later)
- **Swift**: 5.8+ (for building from source)
- **Network**: BitAxe device on your local network
- **Dependencies**: `terminal-notifier` (installed automatically via Homebrew)

## 🏗️ Architecture

### **State Management**
The app uses a sophisticated state management system with:
- **Configuration States**: IP setup and validation
- **Connection States**: Network connectivity monitoring
- **Data States**: API response quality assessment
- **UI States**: Popover visibility and update availability

### **Button Container System**
State-specific button containers ensure proper UI behavior:
- **Not Configured Container**: Single "Configure IP" button
- **Network Error Container**: Single "View Troubleshooting" button
- **Device Issue Container**: Dual "Open AxeOS" + "Open Github" buttons
- **Connected Container**: Context-aware button layout

### **API Integration**
- **Endpoint**: `http://YOUR_BITAXE_IP/api/system/info`
- **Field Mapping**: Proper JSON field extraction and display
- **Error Handling**: Graceful degradation for network and data issues
- **Model Detection**: Automatic BitAxe model identification

## 📊 Version History

- **v1.0.2**: Complete UI overhaul with state-specific button containers
  - Interactive popover interface
  - Enhanced error handling and state management
  - Improved model detection and display
  - Fixed update banner positioning
  - Updated Homebrew integration
- **v1.0.1**: Improved hashrate precision (3 decimal places)
- **v1.0.0**: Initial release with real-time monitoring

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
```bash
# Clone the repository
git clone https://github.com/jeppepeppe1/BitAxe-MenuBar.git
cd BitAxe-MenuBar

# Build and run
swift build
swift run
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: [https://github.com/jeppepeppe1/BitAxe-MenuBar](https://github.com/jeppepeppe1/BitAxe-MenuBar)
- **Homebrew Tap**: [https://github.com/jeppepeppe1/homebrew-bitaxe-menubar](https://github.com/jeppepeppe1/homebrew-bitaxe-menubar)
- **BitAxe Documentation**: [https://osmu.wiki/bitaxe/api/](https://osmu.wiki/bitaxe/api/)
- **ESP-Miner API**: [https://github.com/bitaxeorg/ESP-Miner](https://github.com/bitaxeorg/ESP-Miner)

---

**Made with ⛏️ for the BitAxe mining community**