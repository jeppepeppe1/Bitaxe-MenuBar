import Foundation
import AppKit

// Configuration management
class AppConfig {
    private let userDefaults = UserDefaults.standard
    private let bitaxeIPKey = "BitAxeIP"
    private let defaultIP = "192.168.0.13"
    
    var bitaxeIP: String {
        get {
            return userDefaults.string(forKey: bitaxeIPKey) ?? defaultIP
        }
        set {
            userDefaults.set(newValue, forKey: bitaxeIPKey)
        }
    }
    
    var apiURL: String {
        return "http://\(bitaxeIP)/api/system/info"
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var timer: Timer?
    var lastNotificationTime: Date?
    var config: AppConfig!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load configuration
        config = AppConfig()
        
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Create menu with configuration and quit options
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Configure BitAxe IP...", action: #selector(showConfig), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit AxeBar", action: #selector(quit), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Start polling miner every 5 seconds
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMinerData), userInfo: nil, repeats: true)
        updateMinerData()
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func showConfig() {
        let alert = NSAlert()
        alert.messageText = "Configure BitAxe IP Address"
        alert.informativeText = "Enter the IP address of your BitAxe miner:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = config.bitaxeIP
        alert.accessoryView = input
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            let newIP = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if !newIP.isEmpty {
                config.bitaxeIP = newIP
                print("BitAxe IP updated to: \(newIP)")
            }
        }
    }
    
    @objc func updateMinerData() {
        // SIMULATION MODE - Comment out this block to use real API
        DispatchQueue.main.async {
            // Simulate different temperature scenarios
            let scenarios = [
                (hashrate: 1399.0, asicTemp: 62.0, vrTemp: 67.0), // Normal - all green
                (hashrate: 1399.0, asicTemp: 67.0, vrTemp: 67.0), // T hot - T red
                (hashrate: 1399.0, asicTemp: 62.0, vrTemp: 88.0), // VR hot - VR red
                (hashrate: 1399.0, asicTemp: 70.0, vrTemp: 90.0), // Both hot - both red
            ]
            
            let scenarioIndex = Int(Date().timeIntervalSince1970) % scenarios.count
            let scenario = scenarios[scenarioIndex]
            
            let hashrate = scenario.hashrate
            let asicTemp = scenario.asicTemp
            let vrTemp = scenario.vrTemp
            
            // REAL API MODE - Uncomment this block to use real API
            /*
            guard let url = URL(string: self.config.apiURL) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let hashrate = json["hashRate"] as? Double,
                       let asicTemp = json["temp"] as? Double,
                       let vrTemp = json["vrTemp"] as? Double {
            */
                    
                    let hashrateTH = hashrate / 1000
                    
                    // Add fire emoji for hot temperatures
                    let tText = asicTemp >= 65 ? "🔥 T \(Int(asicTemp))°C" : "T \(Int(asicTemp))°C"
                    let vrText = vrTemp >= 86 ? "🔥 VR \(Int(vrTemp))°C" : "VR \(Int(vrTemp))°C"
                    
                    let statusText = "⛏️ \(String(format: "%.2f", hashrateTH)) TH/s | \(tText) | \(vrText)"
                    
                    // Create attributed string with conditional coloring
                    let attributedString = NSMutableAttributedString(string: statusText)
                    
                    // Start with green for everything
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: NSRange(location: 0, length: statusText.utf16.count))
                    
                    // Find positions of T and VR temperatures
                    
                    if let tRange = statusText.range(of: tText) {
                        let nsRange = NSRange(tRange, in: statusText)
                        if asicTemp >= 65 {
                            attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: nsRange)
                            print("🔥 High ASIC Temperature: \(Int(asicTemp))°C")
                            self.showSystemNotification(title: "🔥 High ASIC Temperature", message: "\(Int(asicTemp))°C")
                        }
                    }
                    
                    if let vrRange = statusText.range(of: vrText) {
                        let nsRange = NSRange(vrRange, in: statusText)
                        if vrTemp >= 86 {
                            attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: nsRange)
                            print("🔥 High VR Temperature: \(Int(vrTemp))°C")
                            self.showSystemNotification(title: "🔥 High VR Temperature", message: "\(Int(vrTemp))°C")
                        }
                    }
                    
                    // Set the attributed title
                    self.statusItem.button?.attributedTitle = attributedString
                    
            // SIMULATION MODE - Comment out this block to use real API
            }
            
            // REAL API MODE - Uncomment this block to use real API
            /*
                } else {
                    // Offline state - red color
                    let statusText = "⛏️ -- TH/s | T --°C | VR --°C"
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: NSRange(location: 0, length: statusText.utf16.count))
                    
                    self.statusItem.button?.attributedTitle = attributedString
                }
            }
        }.resume()
            */
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
            print("Warning: terminal-notifier not found. Install with: brew install terminal-notifier")
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
