# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

AudioKit uses Swift Package Manager. The CI builds target iOS Simulator:

```bash
# Build
xcodebuild -scheme AudioKit -destination "platform=iOS Simulator,name=iPhone 16 Pro"

# Run all tests
xcodebuild -scheme AudioKit -destination "platform=iOS Simulator,name=iPhone 16 Pro" test

# Run a single test
xcodebuild -scheme AudioKit -destination "platform=iOS Simulator,name=iPhone 16 Pro" test -only-testing:AudioKitTests/DistortionTests/testDefault
```

You can also open the package in Xcode (drag the folder onto Xcode's dock icon) and run tests with Cmd-U.

## Architecture

**AudioKit** is a Swift-only audio framework wrapping AVFoundation. It targets macOS 11+, iOS 13+, tvOS 13+, and visionOS 1+. It has zero external dependencies.

### Core Abstractions

- **Node** (`Internals/Engine/Node.swift`) — Protocol wrapping `AVAudioNode`. All audio graph elements (effects, generators, players, mixers) conform to Node. Nodes connect to each other to form the signal chain.
- **AudioEngine** (`Internals/Engine/AudioEngine.swift`) — Wraps `AVAudioEngine`. Set `engine.output` to a Node to drive connections. Provides `startTest()`/`render()` methods for headless test rendering.
- **@Parameter** — Property wrapper for audio parameters on nodes.
- **Settings** (`Internals/Settings/`) — Platform-specific audio session and format configuration.

### Source Layout (Sources/AudioKit/)

- `Nodes/` — Audio graph nodes organized by category:
  - `Effects/` (Distortion, Dynamics, Filters)
  - `Generators/` (PlaygroundOscillator, PlaygroundNoiseGenerator)
  - `Mixing/` (Mixer, MatrixMixer, Mixer3D, EnvironmentalNode)
  - `Playback/` (AudioPlayer, MultiSegmentAudioPlayer, AppleSampler, VariSpeed, TimePitch)
- `MIDI/` — CoreMIDI wrapper with listener/transformer pattern, file parsing, virtual ports
- `Taps/` — Non-intrusive audio stream analysis (AmplitudeTap, FFTTap, RawDataTap, NodeRecorder)
- `Internals/` — Engine, hardware devices, settings, tables, utilities, error handling
- `Audio Files/` — FormatConverter, AVAudioFile/AVAudioPCMBuffer extensions
- `Sequencing/` — AppleSequencer (CoreAudio/MIDI-based)

### Extension Ecosystem

This repo is the **base layer only** (Swift wrapping AVFoundation). C++/DSP functionality lives in separate packages: AudioKitEX/CAudioKitEX provide the DSP layer, and packages like SoundpipeAudioKit, DunneAudioKit, STKAudioKit extend it with additional nodes.

## Testing Approach

Tests use **MD5 hash comparison** of rendered audio buffers for deterministic validation. The workflow:

1. Create an `AudioEngine`, attach nodes, call `engine.startTest(totalDuration:)`
2. Render audio with `engine.render(duration:)`
3. Validate with `testMD5(audio)` which checks against hashes in `ValidatedMD5s.swift`

During test development, use `audio.audition()` to listen to output, then capture the MD5 hash and add it to the validated dictionary. Remove `audition()` before committing.

### Testing Gotchas

- **Never use realtime engine mode (`engine.start()`) in tests.** Use `startTest()`/`render()` for offline rendering. Realtime mode hangs in headless CI runners.
- **Call `engine.stop()` before modifying the audio graph after rendering.** Graph modifications (addInput/removeInput) while the engine is running can deadlock during cleanup.
- **Nodes wired after `startTest()` produce silence in offline mode.** The rendering pipeline is already set up. Tests for post-start wiring validate "doesn't crash," not audio output.
- **Not all tests need MD5 validation.** Some tests (like wiring-after-start) just verify the operation completes without crashing or hanging.

## Style Conventions

- camelCase variables (lowercase first), uppercase Classes. No Hungarian notation.
- Descriptors before nouns: `leftOutput` not `outputLeft`
- Omit units from names: `frequency` not `frequencyInHz`
- Only collections are pluralized: `channelCount` not `numberOfChannels`
- Acronyms all CAPS or all lowercase: `enableMIDI` not `enableMidi`
- Booleans: `is` prefix with `ed`/`ing` suffix: `isLooping`, `isFilterEnabled`
- Time intervals are called "Durations" (to distinguish from moments in time)
