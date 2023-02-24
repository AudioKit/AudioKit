// swift-tools-version:5.5

import PackageDescription

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
                dependencies: ["Audio", "AudioFiles", "Utilities", "MIDI", "Taps"]),
        .target(name: "Audio",
                dependencies: ["MIDI", "Utilities", .product(name: "Atomics", package: "swift-atomics")],
                swiftSettings: [
                    .unsafeFlags(["-Xfrontend", "-warn-long-expression-type-checking=50"])
                ]),
        .target(name: "AudioFiles", dependencies: ["Utilities"]),
        .target(name: "Utilities"),
        .target(name: "MIDI", dependencies: ["Utilities", .product(name: "MIDIKit", package: "MIDIKit")]),
        .target(name: "Taps", dependencies: ["Audio"]),
        .testTarget(name: "AudioKitTests", dependencies: ["AudioKit"], resources: [.copy("TestResources/")]),
    ]
)
