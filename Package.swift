// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v12), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    dependencies: [.package(url: "https://github.com/apple/swift-atomics", from: "1.0.0")],
    targets: [
        .target(name: "AudioKit", dependencies: [.product(name: "Atomics", package: "swift-atomics")]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
