// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .visionOS(.v1)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    targets: [
        .target(
            name: "AudioKit",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "AudioKitTests",
            dependencies: ["AudioKit"],
            resources: [.copy("TestResources/")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
