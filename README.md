# ⛏️ Bitaxe MenuBar

A simple macOS menu bar app that displays your Bitaxe miner's hashrate and temperature with real-time monitoring and notifications.

<img width="600" height="148" alt="bitaxe-menubar" src="https://github.com/user-attachments/assets/34c222ef-6b28-42eb-aeda-062b3d1c3009" />


## Features

- **Live Monitoring**: Displays hashrate, ASIC temperature, and VR temperature
- **High Precision**: Hashrate displayed with 3 decimal places (e.g., 1.399 TH/s)
- **Color-coded Status**: Green for normal, red for critical temperatures
- **Smart Notifications**: Alerts when temperatures exceed safe thresholds (max once per 30 seconds)
- **Fire Emojis**: Visual indicators for hot temperatures
- **Auto-refresh**: Updates every 5 seconds
- **Real-time Data**: Uses live API data from your BitAxe miner (https://osmu.wiki/bitaxe/api/)

## Temperature Thresholds

- **ASIC Temperature**: Red when ≥ 65°C
- **VR Temperature**: Red when ≥ 86°C
**Examples**
- `⛏️ 1.40 TH/s | T 62°C | VR 67°C` - Normal operation (green)
- `⛏️ 1.40 TH/s | 🔥 T 67°C | VR 67°C` - High ASIC temperature (red)
- `⛏️ 1.40 TH/s | T 62°C | 🔥 VR 88°C` - High VR temperature (red)

## Installation

### Via Homebrew (Recommended)


```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```


```bash
# Install terminal-notifier dependency first
brew install terminal-notifier

# Install BitAxe MenuBar
brew tap jeppepeppe1/bitaxe-menubar
brew install bitaxe-menubar
```

### Run it

```bash
# Set your BitAxe IP address
bitaxe-config <YOUR_BITAXE_IP_ADDRESS>

# Restart the app to apply changes
bitaxe-menubar
```

### Uninstalling

```bash
# Uninstall the app
brew uninstall bitaxe-menubar

# Remove the tap (optional)
brew untap jeppepeppe1/bitaxe-menubar
```

## Troubleshooting

### SHA-256 Hash Mismatch Error

If you encounter a SHA-256 mismatch error during installation:

```bash
# Clear Homebrew cache
brew cleanup --prune=all

# Try installation again
brew install jeppepeppe1/bitaxe-menubar/bitaxe-menubar
```

### App Not Updating

If the app seems to show old data:

```bash
# Update to latest version
brew update jeppepeppe1/bitaxe-menubar
brew upgrade bitaxe-menubar

# Restart the app
pkill -f bitaxe-menubar
bitaxe-menubar &
```

## Requirements

- macOS 13.0+
- Swift 5.8+
- Bitaxe miner on your network
- `terminal-notifier` (for notifications)

## Version History

- **v1.0.1**: Improved hashrate precision (3 decimal places)
- **v1.0.0**: Initial release with real-time monitoring

## License

MIT
