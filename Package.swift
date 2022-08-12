// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v10_15), .iOS(.v11), .tvOS(.v11)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    targets: [
        .target(name: "AudioKit"),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
