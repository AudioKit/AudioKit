// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v11), .tvOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
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
        .target(name: "TPCircularBuffer", publicHeadersPath: "include"),
        .target(name: "STK", publicHeadersPath: "include"),
        .target(name: "soundpipe",
                publicHeadersPath: "include",
                cxxSettings: [
                    .define("NO_LIBSNDFILE"),
                    .headerSearchPath("Sources/soundpipe/lib/kissfft"),
                    .headerSearchPath("Sources/soundpipe/lib/inih"),
                    .headerSearchPath("Sources/soundpipe/modules"),
                    .headerSearchPath("Sources/soundpipe/external")
                ]),
        .target(
            name: "sporth",
            dependencies: ["soundpipe"],
            publicHeadersPath: "include",
            cSettings: [.define("NO_LIBSNDFILE")]),
        .target(
            name: "CAudioKit",
            dependencies: ["TPCircularBuffer", "STK", "soundpipe", "sporth"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("Sources/CAudioKit/CoreAudio"),
                .headerSearchPath("Sources/CAudioKit/AudioKitCore/Common"),
                .headerSearchPath("Sources/CAudioKit/Devoloop/include"),
                .headerSearchPath("Sources/CAudioKit/include"),
                .headerSearchPath("Sources/CAudioKit")
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
