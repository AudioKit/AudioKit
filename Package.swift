// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "AudioKit",
            targets: ["AudioKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "CAudioKit",
            dependencies: [],
            cSettings: [
                .headerSearchPath("soundpipe/lib/dr_wav"),
                .headerSearchPath("soundpipe/lib/faust"),
                .headerSearchPath("soundpipe/lib/inih"),
                .headerSearchPath("soundpipe/lib/kissfft"),
                .headerSearchPath("soundpipe/include"),
                .headerSearchPath("sporth/include"),
                .headerSearchPath("soundpipeextension/include"),
                .headerSearchPath("TPCircularBuffer/include"),
                .define("NO_LIBSNDFILE")],
            cxxSettings: [
                .headerSearchPath("CoreAudio"),
                .headerSearchPath("Sporth Custom Ugens"),
                .headerSearchPath("AudioKitCore/Common"),
                .headerSearchPath("Devoloop/include"),
                .headerSearchPath("STK/include"),
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
    ],
    cxxLanguageStandard: .cxx14
)
