import Foundation
import AppKit

// Connection states
enum ConnectionState {
    case configured    // IP set, ready to connect
    case connecting    // Attempting to connect
    case connected     // Successfully connected
    case networkError  // Network unreachable
    case timeout       // Request timed out
    case serverError   // BitAxe responded with error
}

// Configuration management
class AppConfig {
    private let userDefaults = UserDefaults(suiteName: "com.bitaxe.menubar") ?? UserDefaults.standard
    private let bitaxeIPKey = "BitAxeIP"
    
    var bitaxeIP: String? {
        get {
            return userDefaults.string(forKey: bitaxeIPKey)
        }
        set {
            if let newValue = newValue {
                userDefaults.set(newValue, forKey: bitaxeIPKey)
            } else {
                userDefaults.removeObject(forKey: bitaxeIPKey)
            }
        }
    }
    
    var apiURL: String? {
        guard let ip = bitaxeIP else { return nil }
        return "http://\(ip)/api/system/info"
    }
    
    var isConfigured: Bool {
        return bitaxeIP != nil
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var timer: Timer?
    var lastNotificationTime: Date?
    var config: AppConfig!
    var connectionState: ConnectionState = .configured
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load configuration
        config = AppConfig()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create menu with quit option
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Quit AxeBar", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Start polling miner every 5 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMinerData), userInfo: nil, repeats: true)
        updateMinerData()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    
    @objc func updateMinerData() {
        // Check if BitAxe IP is configured
        guard config.isConfigured, let apiURL = config.apiURL else {
            connectionState = .configured
            showMenuBarState(.configured)
            return
        }
        
        guard let url = URL(string: apiURL) else { 
            connectionState = .serverError
            showMenuBarState(.serverError)
            return 
        }
        
        // Set connecting state
        connectionState = .connecting
        showMenuBarState(.connecting)
        
        // Create request with timeout
        var request = URLRequest(url: url)
        request.timeoutInterval = 10.0
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Handle network errors
                if let error = error {
                    if (error as NSError).code == NSURLErrorTimedOut {
                        self.connectionState = .timeout
                        self.showMenuBarState(.timeout)
                    } else if (error as NSError).code == NSURLErrorCannotConnectToHost ||
                              (error as NSError).code == NSURLErrorNetworkConnectionLost ||
                              (error as NSError).code == NSURLErrorNotConnectedToInternet {
                        self.connectionState = .networkError
                        self.showMenuBarState(.networkError)
                    } else {
                        self.connectionState = .serverError
                        self.showMenuBarState(.serverError)
                    }
                    return
                }
                
                // Handle HTTP response errors
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode >= 400 {
                        self.connectionState = .serverError
                        self.showMenuBarState(.serverError)
                        return
                    }
                }
                
                // Parse successful response
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let hashrate = json["hashRate"] as? Double,
                   let asicTemp = json["temp"] as? Double,
                   let vrTemp = json["vrTemp"] as? Double {
                    
                    self.connectionState = .connected
                    let hashrateTH = hashrate / 1000
                    
                    // Add fire emoji for hot temperatures
                    let tText = asicTemp >= 65 ? "🔥 T \(Int(asicTemp))°C" : "T \(Int(asicTemp))°C"
                    let vrText = vrTemp >= 86 ? "🔥 VR \(Int(vrTemp))°C" : "VR \(Int(vrTemp))°C"
                    
                    let statusText = "⛏️ \(String(format: "%.3f", hashrateTH)) TH/s | \(tText) | \(vrText)"
                    
                    // Create attributed string with conditional coloring
                    let attributedString = NSMutableAttributedString(string: statusText)
                    
                    // Start with green for everything
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: NSRange(location: 0, length: statusText.utf16.count))
                    
                    // Find positions of T and VR temperatures
                    if let tRange = statusText.range(of: tText) {
                        let nsRange = NSRange(tRange, in: statusText)
                        if asicTemp >= 65 {
                            attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: nsRange)
                            self.showSystemNotification(title: "🔥 High ASIC Temperature", message: "\(Int(asicTemp))°C")
                        }
                    }
                    
                    if let vrRange = statusText.range(of: vrText) {
                        let nsRange = NSRange(vrRange, in: statusText)
                        if vrTemp >= 86 {
                            attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: nsRange)
                            self.showSystemNotification(title: "🔥 High VR Temperature", message: "\(Int(vrTemp))°C")
                        }
                    }
                    
                    // Set the attributed title
                    self.statusItem.button?.attributedTitle = attributedString
                    
                } else {
                    // Invalid response data
                    self.connectionState = .serverError
                    self.showMenuBarState(.serverError)
                }
            }
        }.resume()
    }
    
    func showMenuBarState(_ state: ConnectionState) {
        let (statusText, color) = getStateDisplay(state)
        let attributedString = NSMutableAttributedString(string: statusText)
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: statusText.utf16.count))
        self.statusItem.button?.attributedTitle = attributedString
    }
    
    func getStateDisplay(_ state: ConnectionState) -> (String, NSColor) {
        switch state {
        case .configured:
            return ("⛏️ Configure IP...", .systemOrange)
        case .connecting:
            return ("⛏️ Connecting... | T --°C | VR --°C", .systemGray)
        case .connected:
            // This will be overridden by the actual data display
            return ("⛏️ Connected", .systemGreen)
        case .networkError:
            return ("⛏️ No Connection | Check Network", .systemRed)
        case .timeout:
            return ("⛏️ Timeout | Retrying...", .systemGray)
        case .serverError:
            return ("⛏️ Server Error | Check BitAxe", .systemRed)
        }
    }
    
    func showSystemNotification(title: String, message: String) {
        // Only show notification if it's been more than 30 seconds since last one
        let now = Date()
        if let lastTime = lastNotificationTime,
           now.timeIntervalSince(lastTime) < 30 {
            return
        }
        
        // Try to find terminal-notifier in common locations
        let possiblePaths = [
            "/opt/homebrew/bin/terminal-notifier",  // Apple Silicon Homebrew
            "/usr/local/bin/terminal-notifier",      // Intel Homebrew
            "/usr/bin/terminal-notifier"             // System installation
        ]
        
        var terminalNotifierPath: String?
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                terminalNotifierPath = path
                break
            }
        }
        
        guard let notifierPath = terminalNotifierPath else {
            return
        }
        
        // Use terminal-notifier for native notifications
        let task = Process()
        task.launchPath = notifierPath
        
        // Try to find the logo in bundle resources or current directory
        let logoPath = findLogoPath()
        
        var arguments = [
            "-title", title,
            "-message", message,
            "-sound", "Sosumi",
            "-sender", "⛏️"
        ]
        
        // Add logo if found
        if let logo = logoPath {
            arguments.append(contentsOf: ["-appIcon", logo])
        }
        
        task.arguments = arguments
        task.launch()
        
        lastNotificationTime = now
    }
    
    private func findLogoPath() -> String? {
        // Try to find logo in bundle resources first
        if let bundle = Bundle.main.resourcePath {
            let bundleLogoPath = "\(bundle)/bitaxe-logo-square.png"
            if FileManager.default.fileExists(atPath: bundleLogoPath) {
                return bundleLogoPath
            }
        }
        
        // Fallback to current directory (for development)
        let currentDir = FileManager.default.currentDirectoryPath
        let currentDirLogoPath = "\(currentDir)/bitaxe-logo-square.png"
        if FileManager.default.fileExists(atPath: currentDirLogoPath) {
            return currentDirLogoPath
        }
        
        return nil
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
