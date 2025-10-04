import Foundation
import AppKit

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
            // Show configuration prompt
            DispatchQueue.main.async {
                let statusText = "⛏️ Configure IP..."
                let attributedString = NSMutableAttributedString(string: statusText)
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: NSRange(location: 0, length: statusText.utf16.count))
                self.statusItem.button?.attributedTitle = attributedString
            }
            return
        }
        
        guard let url = URL(string: apiURL) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let hashrate = json["hashRate"] as? Double,
                   let asicTemp = json["temp"] as? Double,
                   let vrTemp = json["vrTemp"] as? Double {
                    
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
                    // Offline state - red color
                    let statusText = "⛏️ -- TH/s | T --°C | VR --°C"
                    let attributedString = NSMutableAttributedString(string: statusText)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: NSRange(location: 0, length: statusText.utf16.count))
                    
                    self.statusItem.button?.attributedTitle = attributedString
                }
            }
        }.resume()
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
