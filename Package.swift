// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [
        .macOS(.v10_15), .iOS(.v12), .tvOS(.v12)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "AudioKit",
            targets: ["AudioKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        .target(name: "TPCircularBuffer"),
        .target(name: "STK"),
        .target(name: "soundpipe", cSettings: [.define("NO_LIBSNDFILE")]),
        .target(
            name: "sporth",
            dependencies: ["soundpipe"],
            cSettings: [.define("NO_LIBSNDFILE")]),
        .target(
            name: "CAudioKit",
            dependencies: ["TPCircularBuffer", "STK", "soundpipe", "sporth"],
            cxxSettings: [
                .headerSearchPath("CoreAudio"),
                .headerSearchPath("Sporth Custom Ugens"),
                .headerSearchPath("AudioKitCore/Common"),
                .headerSearchPath("Devoloop/include"),
                .headerSearchPath("EZAudio/include"),
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
