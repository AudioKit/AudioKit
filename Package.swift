// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    targets: [
        .target(name: "AudioKit"),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
