// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BitAxeMenuBar",
    platforms: [.macOS(.v13)],
    version: "1.0.4",
    products: [
        .executable(name: "bitaxe-menubar", targets: ["BitAxeMenuBar"]),
    ],
    targets: [
        .executableTarget(
            name: "BitAxeMenuBar",
            path: "Sources/BitAxeMenuBar",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)