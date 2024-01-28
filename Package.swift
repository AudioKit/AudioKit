// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .visionOS(.v1)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    targets: [
        .target(name: "AudioKit"),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
