# BitAxe MenuBar

A simple macOS menu bar app that displays your Bitaxe miner's hashrate and temperature with real-time monitoring and notifications.

## Features

- **Live Monitoring**: Displays hashrate, ASIC temperature, and VR temperature
- **Color-coded Status**: Green for normal, red for critical temperatures
- **Smart Notifications**: Alerts when temperatures exceed safe thresholds
- **Fire Emojis**: Visual indicators for hot temperatures
- **Auto-refresh**: Updates every 5 seconds

## Installation

### Via Homebrew (Recommended)

```bash
# Install terminal-notifier dependency first
brew install terminal-notifier

# Install BitAxe MenuBar
brew tap jeppepeppe1/bitaxe-menubar
brew install bitaxe-menubar
```

### Manual Installation

```bash
# Install terminal-notifier dependency first
brew install terminal-notifier

# Clone and build
git clone https://github.com/jeppepeppe1/BitAxe-MenuBar.git
cd BitAxe-MenuBar
swift build --configuration release
./.build/release/bitaxe-menubar
```

## Usage

Just run `bitaxe-menubar` and you'll see your miner's status in the menu bar:

- `⛏️ 1.40 TH/s | T 62°C | VR 67°C` - Normal operation (green)
- `⛏️ 1.40 TH/s | 🔥 T 67°C | VR 67°C` - High ASIC temperature (red)
- `⛏️ 1.40 TH/s | T 62°C | 🔥 VR 88°C` - High VR temperature (red)

## Configuration

### Via CLI (Recommended)
```bash
# Set your BitAxe IP address
bitaxe-config 192.168.1.100

# Restart the app to apply changes
bitaxe-menubar
```

### Via Menu (Alternative)
1. Run the app
2. Click the menu bar icon (⛏️)
3. Select "Configure BitAxe IP..."
4. Enter your BitAxe's IP address

### Via Source Code (Advanced)
Edit `Sources/BitAxeMenuBar/main.swift` and change the default IP address:

```swift
private let defaultIP = "YOUR_BITAXE_IP"  // Line 8
```

### Enable Real API Mode
The app runs in simulation mode by default. To connect to your actual BitAxe:
1. Uncomment the "REAL API MODE" section in `main.swift`
2. Comment out the "SIMULATION MODE" section
3. Rebuild the app

## Temperature Thresholds

- **ASIC Temperature**: Red when ≥ 65°C
- **VR Temperature**: Red when ≥ 86°C
- **Notifications**: Sent when thresholds are exceeded (max once per 30 seconds)

## Requirements

- macOS 13.0+
- Swift 5.8+
- Bitaxe miner on your network
- `terminal-notifier` (for notifications)

## License

MIT