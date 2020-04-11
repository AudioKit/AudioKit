# AudioKit

This directory stores the Apple-centric code of AudioKit (currently most of it).

## Common

This is where all of Apple-platform code that is relevant to at least two of the operating systems AudioKit supports, ie. iOS, macOS, and tvOS.

## Core

This contains the platform-independent code on which AudioKit runs. This includes DSP libraries that we leverage as well as our own custom DSP that we are striving to make cross-platform.

## iOS

This directory contains the "AudioKit for iOS.xcodeproj" which contains all iOS-compatible components from `Common/` and UIKit user interface elements that are only accessible to iOS. `iOS/` contains `Dev.playground/` which gives AudioKit developers temporary access to playgrounds. Access to `Dev.playground/` allows AudioKit developers to build playgrounds before adding them into the main AudioKit Playgrounds project. The AudioKit Test Suite for iOS is also kept in `iOS/`.

## macOS

This directory contains the "AudioKit for macOS.xcodeproj" which contains all macOS-compatible components from `Common/` as well as Cocoa user interface elements that are only accessible to macOS. `macOS/` contains `Dev.playground/` which gives AudioKit developers temporary access to playgrounds. Access to `Dev.playground/` allows AudioKit developers to build playgrounds before adding them into the main AudioKit Playgrounds project.

## tvOS

The "AudioKit for tvOS.xcodeproj" contains components from `Common/` that work on tvOS.  Since tvOS does not currently support MIDI, AudioKit's MIDI enabled components are omitted.

## .jazzy.yaml

This is a configuration file for the Jazzy documentation generation system that generates the [AudioKit docs](http://audiokit.io/docs/).
