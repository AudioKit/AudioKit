# Building AudioKit as an XCFramework

This directory contains optional tooling for building AudioKit as a precompiled
XCFramework for iOS and macOS. The existing Swift Package Manager workflow
remains unchanged, and `Package.swift` is not involved in this build path.

## Requirements

- Xcode 27
- A clean checkout based on an AudioKit release tag
- iOS 15 deployment support
- macOS 12 deployment support

## Build

To build with a double-click, open `build.command` in
Finder. The wrapper uses a sibling `AudioKitBinary` directory when it exists;
otherwise it writes to `.build/xcframework-output`. Set
`AUDIOKIT_XCFRAMEWORK_OUTPUT` to override that destination.

From the repository root, run:

```sh
./XCFramework/build-xcframework.sh [output-directory]
```

When no output directory is provided, artifacts are written to
`.build/xcframework-output`.

During an interactive terminal run, the script asks for both deployment
targets and whether to include Intel Mac support. Pressing Return selects
iOS 15, macOS 12, and an arm64-only macOS slice. Non-interactive builds use
the same defaults without prompting.

Archive steps use a single updating terminal line that reports the current
build step and elapsed time. `xcodebuild` does not expose reliable per-file
progress or an exact percentage for archive operations.

The choices can also be supplied as environment variables for automation:

```sh
XCFRAMEWORK_IOS_DEPLOYMENT_TARGET=18.0 \
XCFRAMEWORK_MACOS_DEPLOYMENT_TARGET=15.0 \
XCFRAMEWORK_MACOS_ARCHITECTURES="arm64 x86_64" \
./XCFramework/build-xcframework.sh [output-directory]
```

`XCFRAMEWORK_MACOS_ARCHITECTURES` accepts `arm64` or `arm64 x86_64`.

The script produces:

- `AudioKit.xcframework`
- `BUILD_INFO.md` with source and toolchain provenance

The XCFramework contains an arm64 iOS device slice, an arm64/x86_64 iOS
Simulator slice, and a native macOS slice with the selected architectures.
The build includes stable module interfaces and matching dSYMs.

Before installing the output, the script validates architectures, dynamic
linkage, module interfaces, dSYM UUIDs, and source-free iOS and macOS consumer
links. Output replacement is atomic, so a failed build does not overwrite a
previously valid artifact.

This repository does not publish prebuilt artifacts. The generated output can
be packaged by downstream distribution infrastructure when needed.
