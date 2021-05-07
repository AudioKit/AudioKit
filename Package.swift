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
        .target(name: "Stk",
                exclude: ["LICENSE"],
                resources: [.copy("rawwaves")],
                publicHeadersPath: "include"),
        .target(name: "soundpipe",
                exclude: [
                    "README.md",
                    "lib/kissfft/COPYING",
                    "lib/kissfft/README",
                    "lib/inih/LICENSE.txt",
                ],
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
            dependencies: ["Stk", "soundpipe", "sporth"],
            exclude: [
                "AudioKitCore/Modulated Delay/README.md",
                "AudioKitCore/Sampler/Wavpack/license.txt",
                "AudioKitCore/Common/README.md",
                "Nodes/Effects/Distortion/DiodeClipper.soul",
                "AudioKitCore/Common/Envelope.hpp",
                "AudioKitCore/Sampler/README.md",
                "AudioKitCore/README.md",
            ],
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
            dependencies: ["CAudioKit"],
            exclude: [
                "Nodes/Generators/Physical Models/README.md",
                "Internals/Table/README.md",
                "Nodes/Playback/Samplers/Sampler/Sampler.md",
                "Nodes/Playback/Samplers/Apple Sampler/AppleSamplerNotes.md",
                "Nodes/Playback/Samplers/Samplers.md",
                "Nodes/Playback/Samplers/Sampler/README.md",
                "Nodes/Effects/Guitar Processors/README.md",
                "Nodes/Playback/Samplers/PreparingSampleSets.md",
                "Internals/README.md",
                "Nodes/Effects/Modulation/ModDelay.svg",
                "MIDI/README.md",
                "Analysis/README.md",
                "Nodes/Effects/Modulation/ModulatedDelayEffects.md",
                "Nodes/Effects/Modulation/README.md",
                "Nodes/Playback/Samplers/Apple Sampler/Skeleton.aupreset",
                "Nodes/Effects/README.md",
                "Operations/README.md",
                "Nodes/README.md",
            ]),
        .testTarget(
            name: "AudioKitTests",
            dependencies: ["AudioKit"],
            resources: [.copy("TestResources/")]),
        .testTarget(
            name: "CAudioKitTests",
            dependencies: ["CAudioKit"])
    ],
    cxxLanguageStandard: .cxx14
)
