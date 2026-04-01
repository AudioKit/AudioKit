// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v11), .iOS(.v13), .tvOS(.v13), .visionOS(.v1)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    traits: [
        .trait(name: "Swift6"),
    ],
    targets: [
        .target(
            name: "AudioKit",
            resources: [.process("Resources")],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency", .when(traits: ["Swift6"])),
            ]
        ),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ],
    swiftLanguageModes: [.v5]
)
