import Foundation
import AppKit

// MARK: - App Constants
struct AppConstants {
    // Version Management
    static let version = "1.0.9"
    
    // URLs
    static let githubBaseURL = "https://github.com/jeppepeppe1/BitAxe-MenuBar"
    static let githubReleasesURL = "\(githubBaseURL)/releases"
    static let githubTroubleshootingURL = "\(githubBaseURL)#troubleshooting"
    
    // Temperature Thresholds
    static let asicTempThreshold: Double = 65.0
    static let vrTempThreshold: Double = 80.0
    
    // API Configuration
    static let apiEndpoint = "/api/system/info"
    static let updateInterval: TimeInterval = 5.0
    static let notificationCooldown: TimeInterval = 300.0 // 5 minutes
}

// MARK: - App State Enum
enum AppState {
    case notConfigured
    case networkError
    case deviceIssue
    case connected
    case connectedPartialData
    case connectedMissingVRTemp
}

// MARK: - Button Configuration
struct ButtonConfig {
    let title: String
    let action: Selector
    let color: NSColor
    let isUpdateButton: Bool
}

// MARK: - Button Container Factory
class ButtonContainerFactory {
    static func createButtonContainer(buttons: [ButtonConfig], target: AnyObject) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        if buttons.count == 1 {
            // Single button layout
            let button = createButton(from: buttons[0], target: target)
            container.addSubview(button)
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: container.topAnchor),
                button.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                button.heightAnchor.constraint(equalToConstant: 32),
                button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        } else if buttons.count == 2 {
            // Two button side-by-side layout
            let leftButton = createButton(from: buttons[0], target: target)
            let rightButton = createButton(from: buttons[1], target: target)
            
            container.addSubview(leftButton)
            container.addSubview(rightButton)
            
            NSLayoutConstraint.activate([
                // Left button
                leftButton.topAnchor.constraint(equalTo: container.topAnchor),
                leftButton.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                leftButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.48),
                leftButton.heightAnchor.constraint(equalToConstant: 32),
                leftButton.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                
                // Right button
                rightButton.topAnchor.constraint(equalTo: container.topAnchor),
                rightButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                rightButton.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: 0.48),
                rightButton.heightAnchor.constraint(equalToConstant: 32),
                rightButton.bottomAnchor.constraint(equalTo: container.bottomAnchor)
            ])
        }
        
        return container
    }
    
    private static func createButton(from config: ButtonConfig, target: AnyObject) -> NSButton {
        let button = NSButton(title: config.title, target: target, action: config.action)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        if config.isUpdateButton {
            styleUpdateButton(button)
        } else {
            styleButton(button, color: config.color)
        }
        
        return button
    }
    
    private static func styleButton(_ button: NSButton, color: NSColor) {
        button.wantsLayer = true
        button.layer?.backgroundColor = color.withAlphaComponent(0.1).cgColor
        button.layer?.cornerRadius = 6
        button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        button.contentTintColor = color
        button.isBordered = false
        button.focusRingType = .none
    }
    
    private static func styleUpdateButton(_ button: NSButton) {
        button.wantsLayer = true
        button.layer?.backgroundColor = NSColor.clear.cgColor
        button.layer?.cornerRadius = 6
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.systemGray.cgColor
        button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        button.contentTintColor = .systemGray
        button.isBordered = false
        button.focusRingType = .none
    }
}

// MARK: - Layout Configuration
struct PopoverLayout {
    static let width: CGFloat = 280
    static let contentWidth: CGFloat = 240
    static let horizontalPadding: CGFloat = 20
    static let verticalPadding: CGFloat = 20
    static let rowSpacing: CGFloat = 20
    static let rowHeight: CGFloat = 20
    static let dividerSpacing: CGFloat = 15
    static let buttonSpacing: CGFloat = 10
}

// MARK: - Popover View Controller
class BitaxePopoverViewController: NSViewController {
    // UI Elements
    var titleLabel: NSTextField!
    var hashrateLabel: NSTextField!
    var asicTempLabel: NSTextField!
    var vrTempLabel: NSTextField!
    var statusLabel: NSTextField!
    var ipLabel: NSTextField!
    var frequencyLabel: NSTextField!
    var coreVoltageLabel: NSTextField!
    var dividerAboveIP: NSView!
    var dividerAboveFrequency: NSView!
    // State-specific button containers
    var notConfiguredButtonContainer: NSView!
    var networkErrorButtonContainer: NSView!
    var deviceIssueButtonContainer: NSView!
    var connectedButtonContainer: NSView!
    var connectedNoUpdateButtonContainer: NSView!
    var versionLabel: NSTextField!
    var bottomContainerView: NSView!
    var bottomInfoContainer: NSView!
    
    // Configuration
    var config: AppConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Create main container
        let containerView = createContainerView()
        
        // Create all UI elements
        createUIElements()
        
        // Add all elements to container
        addElementsToContainer(containerView)
        
        // Set up Auto Layout constraints
        setupAutoLayoutConstraints(containerView)
        
        // Set container size
        containerView.frame = NSRect(x: 0, y: 0, width: PopoverLayout.width, height: 400) // Fixed height for now
        
        self.view = containerView
    }
    
    // MARK: - UI Creation Methods
    
    private func createContainerView() -> NSView {
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        containerView.layer?.cornerRadius = 8
        return containerView
    }
    
    private func createUIElements() {
        // Title
        titleLabel = NSTextField(labelWithString: "Bitaxe Status")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Data labels
        hashrateLabel = NSTextField(labelWithString: "-- TH/s")
        hashrateLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        hashrateLabel.textColor = .systemGreen
        hashrateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        asicTempLabel = NSTextField(labelWithString: "--°C")
        asicTempLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        asicTempLabel.textColor = .systemGreen
        asicTempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        vrTempLabel = NSTextField(labelWithString: "--°C")
        vrTempLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        vrTempLabel.textColor = .systemGreen
        vrTempLabel.translatesAutoresizingMaskIntoConstraints = false
        
        statusLabel = NSTextField(labelWithString: "Disconnected")
        statusLabel.font = NSFont.systemFont(ofSize: 12)
        statusLabel.textColor = .systemRed
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        ipLabel = NSTextField(labelWithString: "Not configured")
        ipLabel.font = NSFont.systemFont(ofSize: 12)
        ipLabel.textColor = .white
        ipLabel.translatesAutoresizingMaskIntoConstraints = false
        
        frequencyLabel = NSTextField(labelWithString: "-- MHz")
        frequencyLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        frequencyLabel.textColor = .white
        frequencyLabel.translatesAutoresizingMaskIntoConstraints = false
        
        coreVoltageLabel = NSTextField(labelWithString: "-- mV")
        coreVoltageLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        coreVoltageLabel.textColor = .white
        coreVoltageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Dividers
        dividerAboveIP = NSView()
        dividerAboveIP.wantsLayer = true
        dividerAboveIP.layer?.backgroundColor = NSColor.separatorColor.cgColor
        dividerAboveIP.translatesAutoresizingMaskIntoConstraints = false
        
        dividerAboveFrequency = NSView()
        dividerAboveFrequency.wantsLayer = true
        dividerAboveFrequency.layer?.backgroundColor = NSColor.separatorColor.cgColor
        dividerAboveFrequency.translatesAutoresizingMaskIntoConstraints = false
        
        // Create state-specific button containers
        setupButtonContainers()
        
        // Hide all button containers by default
        notConfiguredButtonContainer.isHidden = true
        networkErrorButtonContainer.isHidden = true
        deviceIssueButtonContainer.isHidden = true
        connectedButtonContainer.isHidden = true
        connectedNoUpdateButtonContainer.isHidden = true
        
        // Version Label
        versionLabel = NSTextField(labelWithString: "Bitaxe MenuBar - \(getAppVersion())")
        versionLabel.font = NSFont.systemFont(ofSize: 10)
        versionLabel.textColor = .systemGray
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Container View
        bottomContainerView = NSView()
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Info Container (for version and update banner side by side)
        bottomInfoContainer = NSView()
        bottomInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func addElementsToContainer(_ containerView: NSView) {
        containerView.addSubview(titleLabel)
        containerView.addSubview(hashrateLabel)
        containerView.addSubview(asicTempLabel)
        containerView.addSubview(vrTempLabel)
        containerView.addSubview(statusLabel)
        containerView.addSubview(dividerAboveFrequency)
        containerView.addSubview(frequencyLabel)
        containerView.addSubview(coreVoltageLabel)
        containerView.addSubview(dividerAboveIP)
        containerView.addSubview(ipLabel)
        containerView.addSubview(bottomContainerView)
        bottomContainerView.addSubview(notConfiguredButtonContainer)
        bottomContainerView.addSubview(networkErrorButtonContainer)
        bottomContainerView.addSubview(deviceIssueButtonContainer)
        bottomContainerView.addSubview(connectedButtonContainer)
        bottomContainerView.addSubview(connectedNoUpdateButtonContainer)
        bottomContainerView.addSubview(versionLabel)
    }
    
    private func setupAutoLayoutConstraints(_ containerView: NSView) {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: PopoverLayout.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Hashrate - single spacing below headline
            hashrateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PopoverLayout.rowSpacing),
            hashrateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            hashrateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // ASIC Temp - reduced spacing (6px)
            asicTempLabel.topAnchor.constraint(equalTo: hashrateLabel.bottomAnchor, constant: 6),
            asicTempLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            asicTempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // VR Temp - reduced spacing (6px)
            vrTempLabel.topAnchor.constraint(equalTo: asicTempLabel.bottomAnchor, constant: 6),
            vrTempLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            vrTempLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Divider above Frequency
            dividerAboveFrequency.topAnchor.constraint(equalTo: vrTempLabel.bottomAnchor, constant: 11),
            dividerAboveFrequency.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            dividerAboveFrequency.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            dividerAboveFrequency.heightAnchor.constraint(equalToConstant: 1),
            
            // Frequency - spacing below divider
            frequencyLabel.topAnchor.constraint(equalTo: dividerAboveFrequency.bottomAnchor, constant: 11),
            frequencyLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            frequencyLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Core Voltage - reduced spacing (6px)
            coreVoltageLabel.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 6),
            coreVoltageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            coreVoltageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Divider above Status
            dividerAboveIP.topAnchor.constraint(equalTo: coreVoltageLabel.bottomAnchor, constant: 11),
            dividerAboveIP.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            dividerAboveIP.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            dividerAboveIP.heightAnchor.constraint(equalToConstant: 1),
            
            // Status - above IP Address
            statusLabel.topAnchor.constraint(equalTo: dividerAboveIP.bottomAnchor, constant: 11),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            statusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // IP Address - at bottom of information
            ipLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            ipLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            ipLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Bottom Container - positioned below IP address with same spacing as below headline
            bottomContainerView.topAnchor.constraint(equalTo: ipLabel.bottomAnchor, constant: PopoverLayout.rowSpacing),
            bottomContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            bottomContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            bottomContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -PopoverLayout.verticalPadding),
            
            // Button containers - positioned at top of bottom container, full width
            notConfiguredButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            notConfiguredButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            notConfiguredButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            notConfiguredButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            networkErrorButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            networkErrorButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            networkErrorButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            networkErrorButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            deviceIssueButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            deviceIssueButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            deviceIssueButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            deviceIssueButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            connectedButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            connectedButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            connectedButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            connectedButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            connectedNoUpdateButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            connectedNoUpdateButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            connectedNoUpdateButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            connectedNoUpdateButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            // Version Label - positioned directly below button containers with reduced spacing (75% of rowSpacing), left aligned
            versionLabel.topAnchor.constraint(equalTo: notConfiguredButtonContainer.bottomAnchor, constant: PopoverLayout.rowSpacing * 0.75),
            versionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
    }
    
    // MARK: - Button Container Setup
    
    private func setupButtonContainers() {
        // Not Configured Button Container
        let notConfiguredButtons = [
            ButtonConfig(title: "Configure IP", action: #selector(configureIP), color: .systemOrange, isUpdateButton: false)
        ]
        notConfiguredButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: notConfiguredButtons, target: self)
        
        // Network Error Button Container
        let networkErrorButtons = [
            ButtonConfig(title: "View Troubleshooting", action: #selector(viewTroubleshooting), color: .systemRed, isUpdateButton: false)
        ]
        networkErrorButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: networkErrorButtons, target: self)
        
        // Device Issue Button Container (two buttons side by side)
        let deviceIssueButtons = [
            ButtonConfig(title: "Open AxeOS", action: #selector(openWeb), color: .systemOrange, isUpdateButton: false),
            ButtonConfig(title: "Open Github", action: #selector(openGithub), color: .systemOrange, isUpdateButton: false)
        ]
        deviceIssueButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: deviceIssueButtons, target: self)
        
        // Connected Button Container (two buttons side by side)
        let connectedButtons = [
            ButtonConfig(title: "Open AxeOS", action: #selector(openWeb), color: .systemGray, isUpdateButton: false),
            ButtonConfig(title: "Update App", action: #selector(openGithub), color: .systemGray, isUpdateButton: true)
        ]
        connectedButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: connectedButtons, target: self)
        
        // Connected No Update Button Container (single button)
        let connectedNoUpdateButtons = [
            ButtonConfig(title: "Open AxeOS", action: #selector(openWeb), color: .systemGray, isUpdateButton: false)
        ]
        connectedNoUpdateButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: connectedNoUpdateButtons, target: self)
    }
    
    
    // MARK: - Helper Methods
    
    private func getAppVersion() -> String {
        // Single source of truth for version number
        // Update this number when creating new releases
        return "v\(AppConstants.version)"
    }
    
    func updateData(hashrate: Double?, asicTemp: Double?, vrTemp: Double?, state: AppState, ip: String?, model: String?, frequency: Double?, coreVoltage: Double?) {
        DispatchQueue.main.async {
            // Update title with model information or configuration state
            if let model = model, !model.isEmpty {
                self.titleLabel.stringValue = "Bitaxe \(model)"
            } else {
                switch state {
                case .notConfigured:
                    self.titleLabel.stringValue = "Configure IP"
                case .networkError:
                    self.titleLabel.stringValue = "Network Error"
                case .deviceIssue:
                    self.titleLabel.stringValue = "Device Issue"
                case .connected, .connectedPartialData, .connectedMissingVRTemp:
                    self.titleLabel.stringValue = "Unknown device"
                }
            }
            
            // Update hashrate
            if let hashrate = hashrate {
                let hashrateTH = hashrate / 1000.0
                self.hashrateLabel.stringValue = "Hashrate: \(String(format: "%.3f", hashrateTH)) TH/s"
                self.hashrateLabel.textColor = .systemGreen
            } else {
                self.hashrateLabel.stringValue = "Hashrate: -- TH/s"
                self.hashrateLabel.textColor = .systemGray
            }
            
            // Update ASIC temperature
            if let asicTemp = asicTemp {
                self.asicTempLabel.stringValue = "ASIC Temp: \(String(format: "%.0f", asicTemp))°C"
                self.asicTempLabel.textColor = asicTemp > AppConstants.asicTempThreshold ? .systemRed : .systemGreen
            } else {
                self.asicTempLabel.stringValue = "ASIC Temp: --°C"
                self.asicTempLabel.textColor = .systemGray
            }
            
            // Update VR temperature
            if let vrTemp = vrTemp {
                self.vrTempLabel.stringValue = "VR Temp: \(String(format: "%.0f", vrTemp))°C"
                self.vrTempLabel.textColor = vrTemp > AppConstants.vrTempThreshold ? .systemRed : .systemGreen
            } else {
                self.vrTempLabel.stringValue = "VR Temp: --°C"
                self.vrTempLabel.textColor = .systemGray
            }
            
            // Update status
            let statusText: String
            switch state {
            case .notConfigured:
                statusText = "Not Connected"
            case .networkError:
                statusText = "Network Error"
            case .deviceIssue:
                statusText = "Device Issue"
            case .connected, .connectedPartialData, .connectedMissingVRTemp:
                statusText = "Connected"
            }
            self.statusLabel.stringValue = "Status: \(statusText)"
            self.statusLabel.textColor = .white
            
            // Update IP address
            if let ip = ip {
                self.ipLabel.stringValue = "IP Address: \(ip)"
                self.ipLabel.textColor = .white
            } else {
                self.ipLabel.stringValue = "IP Address: Not Configured"
                self.ipLabel.textColor = .white
            }
            
            // Update frequency
            if let frequency = frequency {
                self.frequencyLabel.stringValue = "Frequency: \(String(format: "%.0f", frequency)) MHz"
                self.frequencyLabel.textColor = .systemGreen
            } else {
                self.frequencyLabel.stringValue = "Frequency: -- MHz"
                self.frequencyLabel.textColor = .systemGray
            }
            
            // Update core voltage
            if let coreVoltage = coreVoltage {
                self.coreVoltageLabel.stringValue = "Core Voltage: \(String(format: "%.0f", coreVoltage)) mV"
                self.coreVoltageLabel.textColor = .systemGreen
            } else {
                self.coreVoltageLabel.stringValue = "Core Voltage: -- mV"
                self.coreVoltageLabel.textColor = .systemGray
            }
            
            // Show/hide appropriate button container based on state
            // Force immediate hiding of all containers first
            self.hideAllButtonContainers()
            
            // Ensure UI updates are processed before showing new container
            DispatchQueue.main.async {
                switch state {
                case .notConfigured:
                    self.notConfiguredButtonContainer.isHidden = false
                case .networkError:
                    self.networkErrorButtonContainer.isHidden = false
                case .deviceIssue:
                    self.deviceIssueButtonContainer.isHidden = false
                case .connected, .connectedPartialData, .connectedMissingVRTemp:
                    // For now, always show single-button layout (no update available)
                    self.connectedNoUpdateButtonContainer.isHidden = false
                }
            }
        }
    }
    
    private func hideAllButtonContainers() {
        // Force immediate hiding of all button containers to prevent overlap
        notConfiguredButtonContainer.isHidden = true
        networkErrorButtonContainer.isHidden = true
        deviceIssueButtonContainer.isHidden = true
        connectedButtonContainer.isHidden = true
        connectedNoUpdateButtonContainer.isHidden = true
        
        // Force immediate UI update to ensure hiding takes effect
        notConfiguredButtonContainer.needsDisplay = true
        networkErrorButtonContainer.needsDisplay = true
        deviceIssueButtonContainer.needsDisplay = true
        connectedButtonContainer.needsDisplay = true
        connectedNoUpdateButtonContainer.needsDisplay = true
    }
    
    @objc func openWeb() {
        guard let ip = config?.bitaxeIP else { return }
        let url = URL(string: "http://\(ip)")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func configureIP() {
        // Open GitHub repository for setup instructions
        let url = URL(string: AppConstants.githubBaseURL)!
        NSWorkspace.shared.open(url)
    }
    
    @objc func viewTroubleshooting() {
        // Open GitHub repository troubleshooting section
        let url = URL(string: AppConstants.githubTroubleshootingURL)!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openGithub() {
        // Open GitHub repository
        let url = URL(string: AppConstants.githubBaseURL)!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openGithubReleases() {
        // Open GitHub releases page
        let url = URL(string: AppConstants.githubReleasesURL)!
        NSWorkspace.shared.open(url)
    }
    
    
    
    
    
    
    
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
        return "http://\(ip)\(AppConstants.apiEndpoint)"
    }
    
    var isConfigured: Bool {
        return bitaxeIP != nil
    }
}

class BitaxeAppDelegate: NSObject, NSApplicationDelegate {
    
    var statusItem: NSStatusItem!
    var timer: Timer?
    var lastNotificationTime: Date?
    var config: AppConfig!
    var popover: NSPopover!
    var popoverViewController: BitaxePopoverViewController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load configuration
        config = AppConfig()
        
        // Create status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up popover
        setupPopover()
        
        // Set up click handler
        statusItem.button?.action = #selector(togglePopover)
        statusItem.button?.target = self
        
        // Start timer for periodic updates
        timer = Timer.scheduledTimer(withTimeInterval: AppConstants.updateInterval, repeats: true) { _ in
            self.updateMinerData()
        }
        
        // Initial update
        updateMinerData()
    }
    
    func setupPopover() {
        popoverViewController = BitaxePopoverViewController()
        popoverViewController.config = config
        
        popover = NSPopover()
        popover.contentViewController = popoverViewController
        popover.behavior = .transient
        popover.animates = true
        
        // Ensure view is loaded
        _ = popoverViewController.view
        
    }
    
    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else {
            if let button = statusItem.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    func updateMinerData() {
        guard let apiURL = config.apiURL else {
            showMenuBarState("⛏️ Configure IP", color: .systemOrange)
            popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .notConfigured, ip: nil, model: nil, frequency: nil, coreVoltage: nil)
            return
        }
        
        let url = URL(string: apiURL)!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if error != nil {
                    self?.showMenuBarState("⛏️ Network Error", color: .systemRed)
                    self?.popoverViewController?.updateData(
                        hashrate: nil,
                        asicTemp: nil,
                        vrTemp: nil,
                        state: .networkError,
                        ip: self?.config.bitaxeIP,
                        model: nil,
                        frequency: nil,
                        coreVoltage: nil
                    )
                    return
                }
                
                guard let data = data else {
                    self?.showMenuBarState("⛏️ Device Issue", color: .systemOrange)
                    self?.popoverViewController?.updateData(
                        hashrate: nil,
                        asicTemp: nil,
                        vrTemp: nil,
                        state: .deviceIssue,
                        ip: self?.config.bitaxeIP,
                        model: nil,
                        frequency: nil,
                        coreVoltage: nil
                    )
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    let hashrate = json?["hashRate"] as? Double
                    let asicTemp = json?["temp"] as? Double
                    let vrTemp = json?["vrTemp"] as? Double
                    let boardVersion = json?["boardVersion"] as? String
                    let frequency = json?["frequency"] as? Double
                    let coreVoltage = json?["coreVoltage"] as? Double
                    
                    let model = self?.getModelName(from: boardVersion)
                    
                    // Determine state based on data availability
                    let state: AppState
                    if let hashrate = hashrate, let asicTemp = asicTemp, let vrTemp = vrTemp {
                        state = .connected
                        let hashrateTH = hashrate / 1000.0
                        self?.showMenuBarState("⛏️ \(String(format: "%.3f", hashrateTH)) TH/s | A \(String(format: "%.0f", asicTemp))°C | VR \(String(format: "%.0f", vrTemp))°C", color: .systemGreen)
                    } else if let hashrate = hashrate, let asicTemp = asicTemp {
                        state = .connectedMissingVRTemp
                        let hashrateTH = hashrate / 1000.0
                        self?.showMenuBarState("⛏️ \(String(format: "%.3f", hashrateTH)) TH/s | A \(String(format: "%.0f", asicTemp))°C | VR --°C", color: .systemGreen)
                    } else {
                        state = .connectedPartialData
                        self?.showMenuBarState("⛏️ Connected | Partial Data", color: .systemYellow)
                    }
                    
                    self?.popoverViewController?.updateData(
                        hashrate: hashrate,
                        asicTemp: asicTemp,
                        vrTemp: vrTemp,
                        state: state,
                        ip: self?.config.bitaxeIP,
                        model: model,
                        frequency: frequency,
                        coreVoltage: coreVoltage
                    )
                    
                } catch {
                    self?.showMenuBarState("⛏️ Device Issue", color: .systemOrange)
                    self?.popoverViewController?.updateData(
                        hashrate: nil,
                        asicTemp: nil,
                        vrTemp: nil,
                        state: .deviceIssue,
                        ip: self?.config.bitaxeIP,
                        model: nil,
                        frequency: nil,
                        coreVoltage: nil
                    )
                }
            }
        }
        task.resume()
    }
    
    func getModelName(from boardVersion: String?) -> String? {
        guard let versionString = boardVersion,
              let version = Int(versionString) else { return nil }
        
        switch version {
        case 600...699:
            return "Gamma"
        case 400...499:
            return "Supra"
        case 300...399:
            return "Hex"
        case 200...299:
            return "Ultra"
        case 100...199:
            return "Max"
        default:
            return nil
        }
    }
    
    func showMenuBarState(_ text: String, color: NSColor) {
        let attributedString = NSAttributedString(string: text, attributes: [
            .foregroundColor: color,
            .font: NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        ])
        statusItem.button?.attributedTitle = attributedString
    }
    
    func showNotification(title: String, message: String) {
        let now = Date()
        if let lastTime = lastNotificationTime, now.timeIntervalSince(lastTime) < AppConstants.notificationCooldown {
            return // Don't spam notifications (max once every 5 minutes)
        }
        lastNotificationTime = now
        
        let process = Process()
        process.launchPath = "/usr/bin/osascript"
        process.arguments = [
            "-e", "display notification \"\(message)\" with title \"\(title)\""
        ]
        process.launch()
    }
}

// Main application
let app = NSApplication.shared
let delegate = BitaxeAppDelegate()
app.delegate = delegate
app.run()
