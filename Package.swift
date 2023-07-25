// swift-tools-version:5.5

import PackageDescription

let concurrency: SwiftSetting = .unsafeFlags(["-Xfrontend", "-strict-concurrency=complete"])

let package = Package(
    name: "AudioKit",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15)],
    products: [.library(name: "AudioKit", targets: ["AudioKit"])],
    dependencies: [
        .package(url: "https://github.com/apple/swift-atomics", from: .init(1, 0, 3)),
        .package(url: "https://github.com/orchetect/midikit", from: .init(0, 7, 3)),
    ],
    targets: [
        .target(name: "AudioKit",
                dependencies: ["Audio", "AudioFiles", "Utilities", "MIDI", "Taps"],
                swiftSettings: [concurrency]),
        .target(name: "Audio",
                dependencies: ["MIDI", "Utilities", "CAudio", .product(name: "Atomics", package: "swift-atomics")],
                swiftSettings: [
                    .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=50"]),
                    concurrency
                ]),
        .target(name: "CAudio"),
        .target(name: "AudioFiles",
                dependencies: ["Utilities"],
                swiftSettings: [concurrency]),
        .target(name: "Utilities",
                swiftSettings: [concurrency]),
        .target(name: "MIDI",
                dependencies: ["Utilities",.product(name: "MIDIKit", package: "MIDIKit")],
                swiftSettings: [concurrency]),
        .target(name: "Taps",
                dependencies: ["Audio"],
                swiftSettings: [concurrency]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
