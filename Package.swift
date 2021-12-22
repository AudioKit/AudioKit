// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v10_13), .iOS(.v11), .tvOS(.v11)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    targets: [
        .target(name: "AudioKit"),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ],
    cxxLanguageStandard: .cxx14
)
