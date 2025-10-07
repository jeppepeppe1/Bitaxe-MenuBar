import Foundation
import AppKit

// Custom view to handle sparkline layout and baseline drawing
class SparklineContainerView: NSView {
    override func layout() {
        super.layout()
        // Update baseline path when view is laid out
        updateBaselinePath()
    }
    
    private func updateBaselinePath() {
        guard let baselineLayer = layer?.sublayers?.first(where: { $0.name == "baseline" }) as? CAShapeLayer else { return }
        
        let width = bounds.width
        let height = bounds.height
        
        guard width > 0 && height > 0 else { return }
        
        let baselinePath = CGMutablePath()
        baselinePath.move(to: CGPoint(x: 0, y: height / 2)) // Center vertically
        baselinePath.addLine(to: CGPoint(x: width, y: height / 2))
        
        baselineLayer.path = baselinePath
    }
}

// MARK: - App Constants
struct AppConstants {
    // Version Management
    static let version = "1.2.0"
    
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
    case update
}



// MARK: - Button Configuration
struct ButtonConfig {
    let title: String
    let action: Selector
    let color: NSColor
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
        
        styleButton(button, color: config.color)
        
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
    
    // Sparkline Graph
    var sparklineView: NSView!
    var hashrateHistory: [Double] = []
    private let maxHistoryPoints = 30
    
    // State-specific button containers
    var notConfiguredButtonContainer: NSView!
    var networkErrorButtonContainer: NSView!
    var deviceIssueButtonContainer: NSView!
    var connectedButtonContainer: NSView!
    var updateButtonContainer: NSView!
    var versionLabel: NSTextField!
    var bottomContainerView: NSView!
    var bottomInfoContainer: NSView!
    var informationContainer: NSView!
    
    // Dynamic constraint references
    var bottomContainerToTitleConstraint: NSLayoutConstraint!
    var bottomContainerToInfoConstraint: NSLayoutConstraint!
    var hashrateToSparklineConstraint: NSLayoutConstraint!
    var hashrateToTitleConstraint: NSLayoutConstraint!
    
    // Configuration
    var config: AppConfig!
    
    // Performance optimization: String caching
    private var lastHashrate: Double?
    private var cachedHashrateString: String?
    private var lastAsicTemp: Double?
    private var cachedAsicTempString: String?
    private var lastVrTemp: Double?
    private var cachedVrTempString: String?
    private var lastFrequency: Double?
    private var cachedFrequencyString: String?
    private var lastCoreVoltage: Double?
    private var cachedCoreVoltageString: String?
    
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
    
    
    private func createSparklineView() -> NSView {
        let view = SparklineContainerView()
        view.wantsLayer = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the baseline placeholder line with same style as animated graph
        let baselineLayer = CAShapeLayer()
        baselineLayer.strokeColor = NSColor.systemGreen.cgColor
        baselineLayer.fillColor = NSColor.clear.cgColor
        baselineLayer.lineWidth = 1.5
        baselineLayer.lineCap = .round
        baselineLayer.lineJoin = .round
        baselineLayer.name = "baseline"
        view.layer?.addSublayer(baselineLayer)
        
        return view
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
        
        // Sparkline Graph
        sparklineView = createSparklineView()
        
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
        updateButtonContainer.isHidden = true
        
        // Version Label
        versionLabel = NSTextField(labelWithString: "Bitaxe MenuBar - \(getAppVersion())")
        versionLabel.font = NSFont.systemFont(ofSize: 10)
        versionLabel.textColor = .systemGray
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Information Container View (for all data fields)
        informationContainer = NSView()
        informationContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Container View
        bottomContainerView = NSView()
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Bottom Info Container (for version and update banner side by side)
        bottomInfoContainer = NSView()
        bottomInfoContainer.translatesAutoresizingMaskIntoConstraints = false
        
    }
    
    private func addElementsToContainer(_ containerView: NSView) {
        containerView.addSubview(titleLabel)
        containerView.addSubview(informationContainer)
        containerView.addSubview(bottomContainerView)
        
        // Add all data fields to information container
        informationContainer.addSubview(sparklineView)
        informationContainer.addSubview(hashrateLabel)
        informationContainer.addSubview(asicTempLabel)
        informationContainer.addSubview(vrTempLabel)
        informationContainer.addSubview(statusLabel)
        informationContainer.addSubview(dividerAboveFrequency)
        informationContainer.addSubview(frequencyLabel)
        informationContainer.addSubview(coreVoltageLabel)
        informationContainer.addSubview(dividerAboveIP)
        informationContainer.addSubview(ipLabel)
        
        // Add button containers to bottom container
        bottomContainerView.addSubview(notConfiguredButtonContainer)
        bottomContainerView.addSubview(networkErrorButtonContainer)
        bottomContainerView.addSubview(deviceIssueButtonContainer)
        bottomContainerView.addSubview(connectedButtonContainer)
        bottomContainerView.addSubview(updateButtonContainer)
        bottomContainerView.addSubview(versionLabel)
    }
    
    private func setupAutoLayoutConstraints(_ containerView: NSView) {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: PopoverLayout.verticalPadding),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Information Container - below title
            informationContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PopoverLayout.rowSpacing),
            informationContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: PopoverLayout.horizontalPadding),
            informationContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -PopoverLayout.horizontalPadding),
            
            // Sparkline - at top of information container
            sparklineView.topAnchor.constraint(equalTo: informationContainer.topAnchor),
            sparklineView.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            sparklineView.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            sparklineView.heightAnchor.constraint(equalToConstant: 25),
            
            // Hashrate - below sparkline
            hashrateLabel.topAnchor.constraint(equalTo: sparklineView.bottomAnchor, constant: PopoverLayout.rowSpacing),
            hashrateLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            hashrateLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // ASIC Temp - reduced spacing (6px)
            asicTempLabel.topAnchor.constraint(equalTo: hashrateLabel.bottomAnchor, constant: 6),
            asicTempLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            asicTempLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // VR Temp - reduced spacing (6px)
            vrTempLabel.topAnchor.constraint(equalTo: asicTempLabel.bottomAnchor, constant: 6),
            vrTempLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            vrTempLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // Divider above Frequency
            dividerAboveFrequency.topAnchor.constraint(equalTo: vrTempLabel.bottomAnchor, constant: 11),
            dividerAboveFrequency.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            dividerAboveFrequency.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            dividerAboveFrequency.heightAnchor.constraint(equalToConstant: 1),
            
            // Frequency - spacing below divider
            frequencyLabel.topAnchor.constraint(equalTo: dividerAboveFrequency.bottomAnchor, constant: 11),
            frequencyLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            frequencyLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // Core Voltage - reduced spacing (6px)
            coreVoltageLabel.topAnchor.constraint(equalTo: frequencyLabel.bottomAnchor, constant: 6),
            coreVoltageLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            coreVoltageLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // Divider above Status
            dividerAboveIP.topAnchor.constraint(equalTo: coreVoltageLabel.bottomAnchor, constant: 11),
            dividerAboveIP.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            dividerAboveIP.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            dividerAboveIP.heightAnchor.constraint(equalToConstant: 1),
            
            // Status - above IP Address
            statusLabel.topAnchor.constraint(equalTo: dividerAboveIP.bottomAnchor, constant: 11),
            statusLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            
            // IP Address - at bottom of information container
            ipLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 6),
            ipLabel.leadingAnchor.constraint(equalTo: informationContainer.leadingAnchor),
            ipLabel.trailingAnchor.constraint(equalTo: informationContainer.trailingAnchor),
            ipLabel.bottomAnchor.constraint(equalTo: informationContainer.bottomAnchor),
            
            // Bottom Container - positioned below information container (default)
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
            
            updateButtonContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            updateButtonContainer.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            updateButtonContainer.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor),
            updateButtonContainer.heightAnchor.constraint(equalToConstant: 32),
            
            // Version Label - positioned directly below button containers with reduced spacing (75% of rowSpacing), left aligned
            versionLabel.topAnchor.constraint(equalTo: notConfiguredButtonContainer.bottomAnchor, constant: PopoverLayout.rowSpacing * 0.75),
            versionLabel.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor)
        ])
        
        // Create dynamic constraint references
        bottomContainerToTitleConstraint = bottomContainerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PopoverLayout.rowSpacing)
        bottomContainerToInfoConstraint = bottomContainerView.topAnchor.constraint(equalTo: informationContainer.bottomAnchor, constant: PopoverLayout.rowSpacing)
        hashrateToSparklineConstraint = hashrateLabel.topAnchor.constraint(equalTo: sparklineView.bottomAnchor, constant: PopoverLayout.rowSpacing)
        hashrateToTitleConstraint = hashrateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: PopoverLayout.rowSpacing)
        
        // Set initial constraints (normal state)
        bottomContainerToInfoConstraint.isActive = true
        hashrateToSparklineConstraint.isActive = true
        
    }
    
    // MARK: - Button Container Setup
    
    private func setupButtonContainers() {
        // Not Configured Button Container
        let notConfiguredButtons = [
            ButtonConfig(title: "Configure IP", action: #selector(configureIP), color: .systemOrange)
        ]
        notConfiguredButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: notConfiguredButtons, target: self)
        
        // Network Error Button Container
        let networkErrorButtons = [
            ButtonConfig(title: "View Troubleshooting", action: #selector(viewTroubleshooting), color: .systemRed)
        ]
        networkErrorButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: networkErrorButtons, target: self)
        
        // Device Issue Button Container (two buttons side by side)
        let deviceIssueButtons = [
            ButtonConfig(title: "Open AxeOS", action: #selector(openWeb), color: .systemOrange),
            ButtonConfig(title: "Open Github", action: #selector(openGithub), color: .systemOrange)
        ]
        deviceIssueButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: deviceIssueButtons, target: self)
        
        // Connected Button Container (single button)
        let connectedButtons = [
            ButtonConfig(title: "Open AxeOS", action: #selector(openWeb), color: .systemGray)
        ]
        connectedButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: connectedButtons, target: self)
        
        // Update Button Container (single button)
        let updateButtons = [
            ButtonConfig(title: "Open Github", action: #selector(openGithubReleases), color: .systemBlue)
        ]
        updateButtonContainer = ButtonContainerFactory.createButtonContainer(buttons: updateButtons, target: self)
        
    }
    
    
    // MARK: - Helper Methods
    
    private func getAppVersion() -> String {
        // Single source of truth for version number
        // Update this number when creating new releases
        return "v\(AppConstants.version)"
    }
    
    func updateData(hashrate: Double?, asicTemp: Double?, vrTemp: Double?, state: AppState, ip: String?, model: String?, frequency: Double?, coreVoltage: Double?) {
        DispatchQueue.main.async {
            // Use actual data passed to the function
            let actualState = state
            let actualHashrate = hashrate
            let actualAsicTemp = asicTemp
            let actualVrTemp = vrTemp
            let actualIP = ip
            let actualModel = model
            let actualFrequency = frequency
            let actualCoreVoltage = coreVoltage
            // Update title with model information or configuration state
            if let model = actualModel, !model.isEmpty {
                self.titleLabel.stringValue = "Bitaxe \(model)"
            } else {
                switch actualState {
                case .notConfigured:
                    self.titleLabel.stringValue = "Configure IP"
                case .networkError:
                    self.titleLabel.stringValue = "Network Error"
                case .deviceIssue:
                    self.titleLabel.stringValue = "Device Issue"
                case .connected:
                    self.titleLabel.stringValue = "Unknown device"
                case .update:
                    self.titleLabel.stringValue = "Update Available"
                }
            }
            
            // Show/hide sparkline based on state
            let isConnected = actualState == .connected
            self.sparklineView.isHidden = !isConnected
            
            // Hide/show information container for update state
            let isUpdateState = actualState == .update
            self.informationContainer.isHidden = isUpdateState
            
            // Adjust bottom container position based on information container visibility
            if isUpdateState {
                // For update state, position bottom container directly below title
                self.bottomContainerToTitleConstraint.isActive = true
                self.bottomContainerToInfoConstraint.isActive = false
            } else {
                // For other states, position below information container (normal behavior)
                self.bottomContainerToInfoConstraint.isActive = true
                self.bottomContainerToTitleConstraint.isActive = false
            }
            
            // Adjust hashrate label position based on sparkline visibility
            if isConnected {
                // Sparkline visible - hashrate below sparkline
                self.hashrateToSparklineConstraint.isActive = true
                self.hashrateToTitleConstraint.isActive = false
                
                // Ensure baseline is visible when sparkline is shown
                self.updateBaselinePath(for: self.sparklineView)
            } else {
                // Sparkline hidden - hashrate directly below title
                self.hashrateToTitleConstraint.isActive = true
                self.hashrateToSparklineConstraint.isActive = false
            }
            
            // Update hashrate with caching
            if let hashrate = actualHashrate {
                let hashrateTH = hashrate / 1000.0
                // Use cached string formatting for better performance
                if self.lastHashrate != hashrateTH {
                    self.cachedHashrateString = "Hashrate: \(String(format: "%.3f", hashrateTH)) TH/s"
                    self.lastHashrate = hashrateTH
                }
                self.hashrateLabel.stringValue = self.cachedHashrateString ?? "Hashrate: -- TH/s"
                self.hashrateLabel.textColor = .systemGreen
                
                // Update sparkline with new data
                self.updateSparkline(with: hashrateTH)
                
            } else {
                self.hashrateLabel.stringValue = "Hashrate: -- TH/s"
                self.hashrateLabel.textColor = .systemGray
            }
            
            // Update ASIC temperature with caching
            if let asicTemp = actualAsicTemp {
                if self.lastAsicTemp != asicTemp {
                    self.cachedAsicTempString = "ASIC Temp: \(String(format: "%.0f", asicTemp))°C"
                    self.lastAsicTemp = asicTemp
                }
                self.asicTempLabel.stringValue = self.cachedAsicTempString ?? "ASIC Temp: --°C"
                self.asicTempLabel.textColor = asicTemp > AppConstants.asicTempThreshold ? .systemRed : .systemGreen
            } else {
                self.asicTempLabel.stringValue = "ASIC Temp: --°C"
                self.asicTempLabel.textColor = .systemGray
            }
            
            // Update VR temperature with caching
            if let vrTemp = actualVrTemp {
                if self.lastVrTemp != vrTemp {
                    self.cachedVrTempString = "VR Temp: \(String(format: "%.0f", vrTemp))°C"
                    self.lastVrTemp = vrTemp
                }
                self.vrTempLabel.stringValue = self.cachedVrTempString ?? "VR Temp: --°C"
                self.vrTempLabel.textColor = vrTemp > AppConstants.vrTempThreshold ? .systemRed : .systemGreen
            } else {
                self.vrTempLabel.stringValue = "VR Temp: --°C"
                self.vrTempLabel.textColor = .systemGray
            }
            
            // Update status
            let statusText: String
            switch actualState {
            case .notConfigured:
                statusText = "Not Connected"
            case .networkError:
                statusText = "Network Error"
            case .deviceIssue:
                statusText = "Device Issue"
            case .connected:
                statusText = "Connected"
            case .update:
                statusText = "Update Available"
            }
            self.statusLabel.stringValue = "Status: \(statusText)"
            self.statusLabel.textColor = .white
            
            // Update IP address
            if let ip = actualIP {
                self.ipLabel.stringValue = "IP Address: \(ip)"
                self.ipLabel.textColor = .white
            } else {
                self.ipLabel.stringValue = "IP Address: Not Configured"
                self.ipLabel.textColor = .white
            }
            
            // Update frequency with caching
            if let frequency = actualFrequency {
                if self.lastFrequency != frequency {
                    self.cachedFrequencyString = "Frequency: \(String(format: "%.0f", frequency)) MHz"
                    self.lastFrequency = frequency
                }
                self.frequencyLabel.stringValue = self.cachedFrequencyString ?? "Frequency: -- MHz"
                // Green for any available data (connected or device issue with partial data)
                self.frequencyLabel.textColor = .systemGreen
            } else {
                self.frequencyLabel.stringValue = "Frequency: -- MHz"
                self.frequencyLabel.textColor = .systemGray
            }
            
            // Update core voltage with caching
            if let coreVoltage = actualCoreVoltage {
                if self.lastCoreVoltage != coreVoltage {
                    self.cachedCoreVoltageString = "Core Voltage: \(String(format: "%.0f", coreVoltage)) mV"
                    self.lastCoreVoltage = coreVoltage
                }
                self.coreVoltageLabel.stringValue = self.cachedCoreVoltageString ?? "Core Voltage: -- mV"
                // Green for any available data (connected or device issue with partial data)
                self.coreVoltageLabel.textColor = .systemGreen
            } else {
                self.coreVoltageLabel.stringValue = "Core Voltage: -- mV"
                self.coreVoltageLabel.textColor = .systemGray
            }
            
            // Show/hide appropriate button container based on state
            // Use immediate synchronous approach to prevent blinking
            // Hide all containers first to prevent overlap
            self.hideAllButtonContainers()
            
            // Show the correct container immediately without delay
            switch actualState {
            case .notConfigured:
                self.notConfiguredButtonContainer.isHidden = false
            case .networkError:
                self.networkErrorButtonContainer.isHidden = false
            case .deviceIssue:
                self.deviceIssueButtonContainer.isHidden = false
            case .connected:
                // Show connected state with single button
                self.connectedButtonContainer.isHidden = false
            case .update:
                // Show update state with single button
                self.updateButtonContainer.isHidden = false
            }
            
            // Force immediate display update
            self.view.needsDisplay = true
        }
    }
    
    private func hideAllButtonContainers() {
        // Force immediate hiding of all button containers to prevent overlap
        notConfiguredButtonContainer?.isHidden = true
        networkErrorButtonContainer?.isHidden = true
        deviceIssueButtonContainer?.isHidden = true
        connectedButtonContainer?.isHidden = true
        updateButtonContainer?.isHidden = true
        
        // Force immediate view update
        view.needsDisplay = true
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
    
    // MARK: - Sparkline Methods
    
    private func updateBaselinePath(for view: NSView) {
        guard let baselineLayer = view.layer?.sublayers?.first(where: { $0.name == "baseline" }) as? CAShapeLayer else { return }
        
        let width = view.bounds.width
        let height = view.bounds.height
        
        guard width > 0 && height > 0 else { return }
        
        let baselinePath = CGMutablePath()
        baselinePath.move(to: CGPoint(x: 0, y: height / 2)) // Center vertically
        baselinePath.addLine(to: CGPoint(x: width, y: height / 2))
        
        baselineLayer.path = baselinePath
    }
    
    private func updateSparkline(with hashrate: Double) {
        // Add new data point
        hashrateHistory.append(hashrate)
        
        // Keep only the last maxHistoryPoints
        if hashrateHistory.count > maxHistoryPoints {
            hashrateHistory.removeFirst()
        }
        
        // Update the visual graph
        updateSparklineVisual()
    }
    
    private func updateSparklineVisual() {
        let width = sparklineView.bounds.width
        let height = sparklineView.bounds.height
        
        guard width > 0 && height > 0 else { return }
        
        // Update baseline path to full width
        updateBaselinePath(for: sparklineView)
        
        guard !hashrateHistory.isEmpty else { return }
        
        // Show baseline if we have no data or only one data point
        if let baselineLayer = sparklineView.layer?.sublayers?.first(where: { $0.name == "baseline" }) {
            baselineLayer.isHidden = hashrateHistory.count > 1
        }
        
        // Reuse existing graph layer or create new one for better performance
        if let existingGraphLayer = sparklineView.layer?.sublayers?.first(where: { $0.name == "graph" }) as? CAShapeLayer {
            // Reuse existing layer - just update the path
            let newPath = createGraphPath(data: hashrateHistory, width: width, height: height)
            existingGraphLayer.path = newPath
        } else {
            // Create new graph layer only if it doesn't exist
            let graphLayer = createGraphLayer(data: hashrateHistory, width: width, height: height)
            sparklineView.layer?.addSublayer(graphLayer)
        }
    }
    
    private func createGraphPath(data: [Double], width: CGFloat, height: CGFloat) -> CGPath {
        // Find min/max for scaling
        let minValue = data.min() ?? 0
        let maxValue = data.max() ?? 1
        let range = maxValue - minValue
        
        guard range > 0 else { return CGMutablePath() }
        
        // Create path
        let path = CGMutablePath()
        let pointWidth = width / CGFloat(data.count - 1)
        
        for (index, value) in data.enumerated() {
            let x = CGFloat(index) * pointWidth
            let normalizedValue = (value - minValue) / range
            let y = height * (1.0 - normalizedValue) // Flip Y axis
            
            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    private func createGraphLayer(data: [Double], width: CGFloat, height: CGFloat) -> CALayer {
        let layer = CAShapeLayer()
        layer.name = "graph"
        
        // Use the shared path creation method
        layer.path = createGraphPath(data: data, width: width, height: height)
        layer.strokeColor = NSColor.systemGreen.cgColor
        layer.fillColor = NSColor.clear.cgColor
        layer.lineWidth = 1.5
        layer.lineCap = .round
        layer.lineJoin = .round
        
        return layer
    }
    
    @objc func openGithub() {
        // Open GitHub repository
        let url = URL(string: AppConstants.githubBaseURL)!
        NSWorkspace.shared.open(url)
    }
    
    @objc func openGithubReleases() {
        // Open GitHub main repository page
        let url = URL(string: AppConstants.githubBaseURL)!
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
    var updateCheckTimer: Timer?
    var lastNotificationTime: Date?
    var appLaunchTime: Date = Date()
    var hasUpdateAvailable: Bool = false
    var config: AppConfig!
    var popover: NSPopover!
    var popoverViewController: BitaxePopoverViewController!
    
    // Performance optimization: App state tracking
    private var isAppActive = true
    private var currentState: AppState = .notConfigured
    
    
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
        
        // Setup app state observers for smart timer management
        setupAppStateObservers()
        
        // Start timer for periodic updates
        startUpdateTimer()
        
        // Start periodic update checking for long-running sessions
        startPeriodicUpdateCheck()
        
        // Pre-fetch data immediately on startup
        updateMinerData()
    }
    
    private func setupAppStateObservers() {
        // Listen for app becoming active/inactive
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidResignActive),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        isAppActive = true
        // Restart timer with normal interval when app becomes active
        startUpdateTimer()
    }
    
    @objc private func appDidResignActive() {
        isAppActive = false
        // Restart timer with slower interval when app goes to background
        startUpdateTimer()
    }
    
    private func startUpdateTimer() {
        // Invalidate existing timer
        timer?.invalidate()
        
        // Choose interval based on app state
        let interval: TimeInterval = isAppActive ? AppConstants.updateInterval : AppConstants.updateInterval * 2.0
        
        // Start new timer with appropriate interval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.updateMinerData()
        }
    }
    
    private func startPeriodicUpdateCheck() {
        // Invalidate existing update check timer
        updateCheckTimer?.invalidate()
        
        // Check for updates every 4 hours (14400 seconds)
        // This ensures long-running sessions get update notifications
        updateCheckTimer = Timer.scheduledTimer(withTimeInterval: 4 * 60 * 60, repeats: true) { [weak self] _ in
            self?.checkForHomebrewUpdates { hasUpdate in
                DispatchQueue.main.async {
                    self?.hasUpdateAvailable = hasUpdate
                    if hasUpdate {
                        self?.showMenuBarState("⛏️ Update Available", color: .systemBlue)
                        self?.popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .update, ip: self?.config.bitaxeIP, model: nil, frequency: nil, coreVoltage: nil)
                    }
                }
            }
        }
    }
    
    deinit {
        // Clean up observers and timers
        timer?.invalidate()
        updateCheckTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
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
            // Check for updates when popover opens (fresh check)
            checkForHomebrewUpdates { [weak self] hasUpdate in
                DispatchQueue.main.async {
                    self?.hasUpdateAvailable = hasUpdate
                    if hasUpdate {
                        // Show update state immediately
                        self?.showMenuBarState("⛏️ Update Available", color: .systemBlue)
                        self?.popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .update, ip: self?.config.bitaxeIP, model: nil, frequency: nil, coreVoltage: nil)
                    }
                    // Always show popover, even if no update (might show connected state)
                    self?.showPopover()
                }
            }
        }
    }
    
    private func showPopover() {
        // Ensure view is loaded for immediate display
        if let popoverVC = popoverViewController {
            _ = popoverVC.view
        }
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func updateMinerData() {
        // Check if update is available first - if so, don't fetch miner data
        if hasUpdateAvailable {
            showMenuBarState("⛏️ Update Available", color: .systemBlue)
            popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .update, ip: config.bitaxeIP, model: nil, frequency: nil, coreVoltage: nil)
            return
        }
        
        // Check for Homebrew updates first (takes absolute priority)
        checkForHomebrewUpdates { [weak self] hasUpdate in
            DispatchQueue.main.async {
                self?.hasUpdateAvailable = hasUpdate
                if hasUpdate {
                    // Update state takes absolute priority - block all other states
                    self?.showMenuBarState("⛏️ Update Available", color: .systemBlue)
                    self?.popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .update, ip: self?.config.bitaxeIP, model: nil, frequency: nil, coreVoltage: nil)
                    return
                }
                // Only continue with normal data fetching if no update available
                self?.fetchMinerData()
            }
        }
    }
    
    private func checkForHomebrewUpdates(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/brew")
            process.arguments = ["outdated", "--formula", "bitaxe-menubar"]
            
            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe
            
            do {
                try process.run()
                process.waitUntilExit()
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                // If output contains "bitaxe-menubar", there's an update available
                let hasUpdate = output.contains("bitaxe-menubar")
                completion(hasUpdate)
            } catch {
                // If brew command fails, assume no update (fallback to normal operation)
                completion(false)
            }
        }
    }
    
    func checkForUpdatesAfterUpgrade() {
        // Check if update is still available after running upgrade command
        checkForHomebrewUpdates { [weak self] hasUpdate in
            DispatchQueue.main.async {
                self?.hasUpdateAvailable = hasUpdate
                if !hasUpdate {
                    // No more updates available, show success message and restart app
                    self?.showMenuBarState("⛏️ Updated Successfully", color: .systemGreen)
                    
                    // After a few seconds, restart the app to start fresh
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self?.restartApp()
                    }
                } else {
                    // Update still available, keep showing update state
                    self?.showMenuBarState("⛏️ Update Available", color: .systemBlue)
                    self?.popoverViewController?.updateData(hashrate: nil, asicTemp: nil, vrTemp: nil, state: .update, ip: self?.config.bitaxeIP, model: nil, frequency: nil, coreVoltage: nil)
                }
            }
        }
    }
    
    func restartApp() {
        // Restart the app by launching a new instance and terminating the current one
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-n", Bundle.main.bundlePath]
        task.launch()
        
        // Terminate current instance
        NSApplication.shared.terminate(nil)
    }
    
    private func fetchMinerData() {
        
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
                        
                    } else {
                        // Any missing data triggers device issue state
                        state = .deviceIssue
                        self?.showMenuBarState("⛏️ Device Issue", color: .systemOrange)
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
