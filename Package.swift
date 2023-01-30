// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", from: .init(1, 0, 3)),
    ],
    targets: [
        .target(name: "AudioKit",
                dependencies: ["Audio", "AudioFiles", "Utilities", "Taps"]),
        .target(name: "Audio",
                dependencies: ["Utilities", .product(name: "Atomics", package: "swift-atomics")]),
        .target(name: "AudioFiles", dependencies: ["Utilities"]),
        .target(name: "Utilities"),
        .target(name: "Taps", dependencies: ["Audio"]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
