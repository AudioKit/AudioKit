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
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "STK",
                exclude: ["rawwaves", "LICENSE"],
                publicHeadersPath: "include"),
        .target(name: "soundpipe",
                exclude: ["README.md",
                          "lib/kissfft/COPYING",
                          "lib/kissfft/README",
                          "lib/inih/LICENSE.txt"],
                publicHeadersPath: "include",
                cSettings: [
                    .headerSearchPath("lib/kissfft"),
                    .headerSearchPath("lib/inih"),
                    .headerSearchPath("Sources/soundpipe/lib/inih"),
                    .headerSearchPath("modules"),
                    .headerSearchPath("external")
                ]),
        .target(
            name: "sporth",
            dependencies: ["soundpipe"],
            exclude: ["README.md"],
            publicHeadersPath: "include"),
        .target(
            name: "CAudioKit",
            dependencies: ["STK", "soundpipe", "sporth"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("CoreAudio"),
                .headerSearchPath("AudioKitCore/Common"),
                .headerSearchPath("Devoloop/include"),
                .headerSearchPath("include"),
                .headerSearchPath(".")
            ]
        ),
        .target(
            name: "AudioKit",
            dependencies: ["CAudioKit"]),
        .testTarget(
            name: "AudioKitTests",
            dependencies: ["AudioKit"]),
        .testTarget(
            name: "CAudioKitTests",
            dependencies: ["CAudioKit"])
    ],
    cxxLanguageStandard: .cxx14
)
