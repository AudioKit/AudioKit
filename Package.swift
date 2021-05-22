// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v11), .tvOS(.v11)
    ],
    products: [
        .library(
            name: "AudioKit",
            type: .static,
            targets: ["AudioKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "CAudioKit",
            exclude: [
                "Nodes/Effects/DiodeClipper.soul",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("Internals"),
                .headerSearchPath("Devoloop/include"),
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "AudioKit",
            dependencies: ["CAudioKit"],
            exclude: [
                "Internals/Table/README.md",
                "Nodes/Effects/Guitar Processors/README.md",
                "Internals/README.md",
                "MIDI/README.md",
                "Taps/README.md",
                "Nodes/Effects/README.md",
                "Nodes/README.md",
            ]),
        .testTarget(
            name: "AudioKitTests",
            dependencies: ["AudioKit"],
            resources: [.copy("TestResources/")])
    ],
    cxxLanguageStandard: .cxx14
)
