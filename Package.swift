// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioKit",
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
        .target(name: "Soundpipe",
                cSettings: [
                    .headerSearchPath("lib/dr_wav"),
                    .headerSearchPath("lib/faust"),
                    .headerSearchPath("lib/inih"),
                    .headerSearchPath("lib/kissfft"),
                    .define("NO_LIBSNDFILE")
        ]),
        .target(name: "SoundpipeExtension",
                dependencies: ["Soundpipe"]),
        .target(name: "STK"),
        .target(name: "TPCircularBuffer"),
        .target(name: "Devoloop"),
        .target(
            name: "EZAudio",
            dependencies: ["TPCircularBuffer"]),
        .target(name: "AudioKitCore",
                dependencies: ["Soundpipe"],
                cxxSettings: [
                    .headerSearchPath("Common")
        ]),
        .target(
            name: "CAudioKit",
            dependencies: ["STK", "Soundpipe", "SoundpipeExtension", "EZAudio", "AudioKitCore", "Devoloop"],
            cxxSettings: [
                .headerSearchPath("CoreAudio")
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
