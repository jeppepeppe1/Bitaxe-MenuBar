import Foundation
import AppKit

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
    var updateAvailableView: NSView!
    var updateButton: NSButton!
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
        versionLabel = NSTextField(labelWithString: "Bitaxe MenuBar - v1.0.0")
        versionLabel.font = NSFont.systemFont(ofSize: 10)
        versionLabel.textColor = .systemGray
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Container View
        bottomContainerView = NSView()
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Info Container (for version and update banner side by side)
        bottomInfoContainer = NSView()
        bottomInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Update Available View (initially hidden)
        updateAvailableView = NSView()
        updateAvailableView.wantsLayer = true
        updateAvailableView.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.1).cgColor
        updateAvailableView.layer?.cornerRadius = 6
        updateAvailableView.translatesAutoresizingMaskIntoConstraints = false
        updateAvailableView.isHidden = true
        
        // Update Button
        updateButton = NSButton(title: "Update via Homebrew", target: self, action: #selector(updateViaHomebrew))
        updateButton.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Remove button fill and stroke, make text blue
        updateButton.isBordered = false
        updateButton.wantsLayer = true
        updateButton.layer?.backgroundColor = NSColor.clear.cgColor
        updateButton.contentTintColor = .systemBlue
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
        bottomContainerView.addSubview(updateAvailableView)
        updateAvailableView.addSubview(updateButton)
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
            
            // Update Available View - positioned below button containers with reduced spacing (75% of rowSpacing)
            updateAvailableView.topAnchor.constraint(equalTo: notConfiguredButtonContainer.bottomAnchor, constant: PopoverLayout.rowSpacing * 0.75),
            updateAvailableView.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            updateAvailableView.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            updateAvailableView.heightAnchor.constraint(equalToConstant: 32),
            
            // Version Label - positioned directly below button containers with reduced spacing (75% of rowSpacing), left aligned
            versionLabel.topAnchor.constraint(equalTo: notConfiguredButtonContainer.bottomAnchor, constant: PopoverLayout.rowSpacing * 0.75),
            versionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
            
            // Update Button - centered in update view
            updateButton.centerXAnchor.constraint(equalTo: updateAvailableView.centerXAnchor),
            updateButton.centerYAnchor.constraint(equalTo: updateAvailableView.centerYAnchor)
        ])
    }
    
    // MARK: - Button Container Setup
    
    private func setupButtonContainers() {
        // Not Configured Button Container
        notConfiguredButtonContainer = NSView()
        notConfiguredButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let configureIPButton = NSButton(title: "Configure IP", target: self, action: #selector(configureIP))
        configureIPButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(configureIPButton, color: .systemOrange)
        
        notConfiguredButtonContainer.addSubview(configureIPButton)
        NSLayoutConstraint.activate([
            configureIPButton.topAnchor.constraint(equalTo: notConfiguredButtonContainer.topAnchor),
            configureIPButton.leadingAnchor.constraint(equalTo: notConfiguredButtonContainer.leadingAnchor),
            configureIPButton.trailingAnchor.constraint(equalTo: notConfiguredButtonContainer.trailingAnchor),
            configureIPButton.heightAnchor.constraint(equalToConstant: 32),
            configureIPButton.bottomAnchor.constraint(equalTo: notConfiguredButtonContainer.bottomAnchor)
        ])
        
        // Network Error Button Container
        networkErrorButtonContainer = NSView()
        networkErrorButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let troubleshootingButton = NSButton(title: "View Troubleshooting", target: self, action: #selector(viewTroubleshooting))
        troubleshootingButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(troubleshootingButton, color: .systemRed)
        
        networkErrorButtonContainer.addSubview(troubleshootingButton)
        NSLayoutConstraint.activate([
            troubleshootingButton.topAnchor.constraint(equalTo: networkErrorButtonContainer.topAnchor),
            troubleshootingButton.leadingAnchor.constraint(equalTo: networkErrorButtonContainer.leadingAnchor),
            troubleshootingButton.trailingAnchor.constraint(equalTo: networkErrorButtonContainer.trailingAnchor),
            troubleshootingButton.heightAnchor.constraint(equalToConstant: 32),
            troubleshootingButton.bottomAnchor.constraint(equalTo: networkErrorButtonContainer.bottomAnchor)
        ])
        
        // Device Issue Button Container (two buttons side by side)
        deviceIssueButtonContainer = NSView()
        deviceIssueButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let openAxeOSButton = NSButton(title: "Open AxeOS", target: self, action: #selector(openWeb))
        openAxeOSButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(openAxeOSButton, color: .systemOrange)
        
        let openGithubButton = NSButton(title: "Open Github", target: self, action: #selector(openGithub))
        openGithubButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(openGithubButton, color: .systemOrange)
        
        deviceIssueButtonContainer.addSubview(openAxeOSButton)
        deviceIssueButtonContainer.addSubview(openGithubButton)
        
        NSLayoutConstraint.activate([
            // First button (left side)
            openAxeOSButton.topAnchor.constraint(equalTo: deviceIssueButtonContainer.topAnchor),
            openAxeOSButton.leadingAnchor.constraint(equalTo: deviceIssueButtonContainer.leadingAnchor),
            openAxeOSButton.widthAnchor.constraint(equalTo: deviceIssueButtonContainer.widthAnchor, multiplier: 0.48),
            openAxeOSButton.heightAnchor.constraint(equalToConstant: 32),
            openAxeOSButton.bottomAnchor.constraint(equalTo: deviceIssueButtonContainer.bottomAnchor),
            
            // Second button (right side)
            openGithubButton.topAnchor.constraint(equalTo: deviceIssueButtonContainer.topAnchor),
            openGithubButton.trailingAnchor.constraint(equalTo: deviceIssueButtonContainer.trailingAnchor),
            openGithubButton.widthAnchor.constraint(equalTo: deviceIssueButtonContainer.widthAnchor, multiplier: 0.48),
            openGithubButton.heightAnchor.constraint(equalToConstant: 32),
            openGithubButton.bottomAnchor.constraint(equalTo: deviceIssueButtonContainer.bottomAnchor)
        ])
        
        // Connected Button Container (two buttons side by side)
        connectedButtonContainer = NSView()
        connectedButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let connectedOpenButton = NSButton(title: "Open AxeOS", target: self, action: #selector(openWeb))
        connectedOpenButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(connectedOpenButton, color: .systemGray)
        
        let connectedUpdateButton = NSButton(title: "Update App", target: self, action: #selector(openGithub))
        connectedUpdateButton.translatesAutoresizingMaskIntoConstraints = false
        styleUpdateButton(connectedUpdateButton)
        
        connectedButtonContainer.addSubview(connectedOpenButton)
        connectedButtonContainer.addSubview(connectedUpdateButton)
        
        NSLayoutConstraint.activate([
            // First button (left side)
            connectedOpenButton.topAnchor.constraint(equalTo: connectedButtonContainer.topAnchor),
            connectedOpenButton.leadingAnchor.constraint(equalTo: connectedButtonContainer.leadingAnchor),
            connectedOpenButton.widthAnchor.constraint(equalTo: connectedButtonContainer.widthAnchor, multiplier: 0.48),
            connectedOpenButton.heightAnchor.constraint(equalToConstant: 32),
            connectedOpenButton.bottomAnchor.constraint(equalTo: connectedButtonContainer.bottomAnchor),
            
            // Second button (right side)
            connectedUpdateButton.topAnchor.constraint(equalTo: connectedButtonContainer.topAnchor),
            connectedUpdateButton.trailingAnchor.constraint(equalTo: connectedButtonContainer.trailingAnchor),
            connectedUpdateButton.widthAnchor.constraint(equalTo: connectedButtonContainer.widthAnchor, multiplier: 0.48),
            connectedUpdateButton.heightAnchor.constraint(equalToConstant: 32),
            connectedUpdateButton.bottomAnchor.constraint(equalTo: connectedButtonContainer.bottomAnchor)
        ])
        
        // Connected No Update Button Container (single button)
        connectedNoUpdateButtonContainer = NSView()
        connectedNoUpdateButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let connectedNoUpdateButton = NSButton(title: "Open AxeOS", target: self, action: #selector(openWeb))
        connectedNoUpdateButton.translatesAutoresizingMaskIntoConstraints = false
        styleButton(connectedNoUpdateButton, color: .systemGray)
        
        connectedNoUpdateButtonContainer.addSubview(connectedNoUpdateButton)
        NSLayoutConstraint.activate([
            connectedNoUpdateButton.topAnchor.constraint(equalTo: connectedNoUpdateButtonContainer.topAnchor),
            connectedNoUpdateButton.leadingAnchor.constraint(equalTo: connectedNoUpdateButtonContainer.leadingAnchor),
            connectedNoUpdateButton.trailingAnchor.constraint(equalTo: connectedNoUpdateButtonContainer.trailingAnchor),
            connectedNoUpdateButton.heightAnchor.constraint(equalToConstant: 32),
            connectedNoUpdateButton.bottomAnchor.constraint(equalTo: connectedNoUpdateButtonContainer.bottomAnchor)
        ])
    }
    
    private func styleButton(_ button: NSButton, color: NSColor) {
        button.wantsLayer = true
        button.layer?.backgroundColor = color.withAlphaComponent(0.1).cgColor
        button.layer?.cornerRadius = 6
        button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        button.contentTintColor = color
        button.isBordered = false
        button.focusRingType = .none
    }
    
    private func styleUpdateButton(_ button: NSButton) {
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
    
    // MARK: - Helper Methods
    
    func updateData(hashrate: Double?, asicTemp: Double?, vrTemp: Double?, status: String, ip: String?, model: String?, frequency: Double?, coreVoltage: Double?) {
        DispatchQueue.main.async {
            // Update title with model information or configuration state
            if let model = model, !model.isEmpty {
                self.titleLabel.stringValue = "Bitaxe \(model)"
            } else if status == "Not Connected" {
                self.titleLabel.stringValue = "Configure IP"
            } else if status == "Network Error" {
                self.titleLabel.stringValue = "Network Error"
            } else if status == "Device Issue" {
                self.titleLabel.stringValue = "Device Issue"
            } else {
                self.titleLabel.stringValue = "Unknown device"
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
                self.asicTempLabel.textColor = asicTemp > 65 ? .systemRed : .systemGreen
            } else {
                self.asicTempLabel.stringValue = "ASIC Temp: --°C"
                self.asicTempLabel.textColor = .systemGray
            }
            
            // Update VR temperature
            if let vrTemp = vrTemp {
                self.vrTempLabel.stringValue = "VR Temp: \(String(format: "%.0f", vrTemp))°C"
                self.vrTempLabel.textColor = vrTemp > 80 ? .systemRed : .systemGreen
            } else {
                self.vrTempLabel.stringValue = "VR Temp: --°C"
                self.vrTempLabel.textColor = .systemGray
            }
            
            // Update status
            self.statusLabel.stringValue = "Status: \(status)"
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
            if ip == nil {
                // Not Configured state
                self.notConfiguredButtonContainer.isHidden = false
                self.networkErrorButtonContainer.isHidden = true
                self.deviceIssueButtonContainer.isHidden = true
                self.connectedButtonContainer.isHidden = true
            } else if status == "Network Error" {
                // Network Error state
                self.notConfiguredButtonContainer.isHidden = true
                self.networkErrorButtonContainer.isHidden = false
                self.deviceIssueButtonContainer.isHidden = true
                self.connectedButtonContainer.isHidden = true
            } else if status == "Device Issue" {
                // Device Issue state - show both buttons
                self.notConfiguredButtonContainer.isHidden = true
                self.networkErrorButtonContainer.isHidden = true
                self.deviceIssueButtonContainer.isHidden = false
                self.connectedButtonContainer.isHidden = true
               } else {
                   // Connected state - show two-button layout (with update button)
                   self.notConfiguredButtonContainer.isHidden = true
                   self.networkErrorButtonContainer.isHidden = true
                   self.deviceIssueButtonContainer.isHidden = true
                   self.connectedButtonContainer.isHidden = false
                   self.connectedNoUpdateButtonContainer.isHidden = true
               }
        }
    }
    
    @objc func openWeb() {
        guard let ip = config?.bitaxeIP else { return }
        let url = URL(string: "http://\(ip)")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func configureIP() {
        // Open GitHub repository for setup instructions
        let url = URL(string: "https://github.com/jeppepeppe1/BitAxe-MenuBar")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func viewTroubleshooting() {
        // Open GitHub repository troubleshooting section
        let url = URL(string: "https://github.com/jeppepeppe1/BitAxe-MenuBar#troubleshooting")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openGithub() {
        // Open GitHub repository
        let url = URL(string: "https://github.com/jeppepeppe1/BitAxe-MenuBar")!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openGithubReleases() {
        // Open GitHub releases page
        let url = URL(string: "https://github.com/jeppepeppe1/BitAxe-MenuBar/releases")!
        NSWorkspace.shared.open(url)
    }
    
    
    
    
    @objc func updateViaHomebrew() {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = """
        A new version is available!
        
        To update via Homebrew:
        1. Open Terminal
        2. Run: brew update
        3. Run: brew upgrade bitaxe-menubar
        4. Restart this app
        
        Commands to copy:
        brew update && brew upgrade bitaxe-menubar
        """
        alert.addButton(withTitle: "Copy Commands")
        alert.addButton(withTitle: "Close")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Copy commands to clipboard
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString("brew update && brew upgrade bitaxe-menubar", forType: .string)
        }
        // "Close" button just dismisses the dialog
    }
    
    func checkForUpdates() {
        print("🔍 Checking for updates...")
        
        // Hide update banner - no longer showing update button
        DispatchQueue.main.async {
            self.updateAvailableView.isHidden = true
        }
        return
        
        guard let url = URL(string: "https://api.github.com/repos/jeppepeppe1/BitAxe-MenuBar/releases/latest") else { 
            print("❌ Invalid URL")
            return 
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("❌ API Error: \(error)")
                return
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let latestVersion = json["tag_name"] as? String else { 
                print("❌ Failed to parse response")
                return 
            }
            
            print("✅ Found version: \(latestVersion)")
            let currentVersion = "v1.0.0" // This should match the version in versionLabel
            let hasUpdate = self?.compareVersions(current: currentVersion, latest: latestVersion) ?? false
            
            DispatchQueue.main.async {
                if hasUpdate {
                    self?.showUpdateAvailable(latestVersion: latestVersion)
                } else {
                    self?.hideUpdateAvailable()
                }
            }
        }
        task.resume()
    }
    
    private func compareVersions(current: String, latest: String) -> Bool {
        // Simple version comparison - remove 'v' prefix and compare
        let currentVersion = current.replacingOccurrences(of: "v", with: "")
        let latestVersion = latest.replacingOccurrences(of: "v", with: "")
        
        return currentVersion != latestVersion
    }
    
    private func showUpdateAvailable(latestVersion: String) {
        // Only show update banner if IP is configured
        guard config?.bitaxeIP != nil else {
            hideUpdateAvailable()
            return
        }
        
        updateAvailableView.isHidden = false
        updateButton.title = "Update to \(latestVersion)"
    }
    
    private func hideUpdateAvailable() {
        updateAvailableView.isHidden = true
        
        // When hidden, remove the spacing constraint so version label is directly below button
        // The version label's bottom constraint to bottomContainerView will handle the layout
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
        return "http://\(ip)/api/system/info"
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
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateMinerData()
        }
        
        // Initial update
        updateMinerData()
    }
    
    func setupPopover() {
        print("🚀 setupPopover() called")
        popoverViewController = BitaxePopoverViewController()
        popoverViewController.config = config
        
        popover = NSPopover()
        popover.contentViewController = popoverViewController
        popover.behavior = .transient
        popover.animates = true
        
        // Ensure view is loaded
        _ = popoverViewController.view
        
        // Check for updates only if IP is configured
        if config?.bitaxeIP != nil {
            popoverViewController.checkForUpdates()
        }
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
            popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, status: "Not Connected", ip: nil, model: nil, frequency: nil, coreVoltage: nil)
            return
        }
        
        let url = URL(string: apiURL)!
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showMenuBarState("⛏️ Network Error", color: .systemRed)
                    self?.popoverViewController?.updateData(
                        hashrate: nil,
                        asicTemp: nil,
                        vrTemp: nil,
                        status: "Network Error",
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
                        status: "Device Issue",
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
                    
                    if let hashrate = hashrate, let asicTemp = asicTemp, let vrTemp = vrTemp {
                        let hashrateTH = hashrate / 1000.0
                        self?.showMenuBarState("⛏️ \(String(format: "%.3f", hashrateTH)) TH/s | A \(String(format: "%.0f", asicTemp))°C | VR \(String(format: "%.0f", vrTemp))°C", color: .systemGreen)
                    } else if let hashrate = hashrate, let asicTemp = asicTemp {
                        let hashrateTH = hashrate / 1000.0
                        self?.showMenuBarState("⛏️ \(String(format: "%.3f", hashrateTH)) TH/s | A \(String(format: "%.0f", asicTemp))°C | VR --°C", color: .systemGreen)
                    } else {
                        self?.showMenuBarState("⛏️ Connected | Partial Data", color: .systemYellow)
                    }
                    
                    self?.popoverViewController?.updateData(
                        hashrate: hashrate,
                        asicTemp: asicTemp,
                        vrTemp: vrTemp,
                        status: "Connected",
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
                        status: "Device Issue",
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
        if let lastTime = lastNotificationTime, now.timeIntervalSince(lastTime) < 300 {
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
