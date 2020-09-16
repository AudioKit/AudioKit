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
                    .headerSearchPath("lib/kissfft"),
                    .headerSearchPath("lib/inih"),
                    .headerSearchPath("Sources/soundpipe/lib/inih"),
                    .headerSearchPath("modules"),
                    .headerSearchPath("external")
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
