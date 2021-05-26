// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v10_14), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "AudioKit", targets: ["AudioKit", "AudioKitEX"])],
    targets: [
        .target(name: "AudioKit"),
        .target(name: "AudioKitEX", dependencies: ["AudioKit", "CAudioKitEX"]),
        .target(name: "CAudioKitEX", cxxSettings: [.headerSearchPath(".")]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
        .testTarget(name: "AudioKitEXTests", dependencies: ["AudioKitEX"], resources: [.copy("TestResources/")])
    ],
    cxxLanguageStandard: .cxx14
)
