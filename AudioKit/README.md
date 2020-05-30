# AudioKit

This directory stores the Apple-centric code of AudioKit (currently most of it).

## Common

This is where all of Apple-platform code that is relevant to at least two of the operating systems AudioKit supports, ie. iOS, macOS, and tvOS.

## Core

This contains the platform-independent code on which AudioKit runs. This includes DSP libraries that we leverage as well as our own custom DSP that we are striving to make cross-platform.

As of AudioKit 5.0, all platforms are managed through the single `AudioKit.xcodeproj` project file, which includes targets for each of the supported platforms (macOS, iOS, tvOS).

## iOS

This directory contains all iOS-specific components including UIKit user interface elements that are only accessible to iOS.  The AudioKit Test Suite for iOS is also kept in `iOS/`.

## macOS

This directory contains all macOS-specific components including Cocoa user interface elements that are only accessible to macOS. 

##  `Dev.playground`

The `Dev.playground` playgrounds for iOS and macOS are now included as part of the main `AudioKit.xcodeproj`, with respective dependencies on the platform targets.
Access to `Dev.playground/` allows AudioKit developers to build playgrounds before adding them into the main AudioKit Playgrounds project.


## `.jazzy.yaml`

This is a configuration file for the Jazzy documentation generation system that generates the [AudioKit docs](http://audiokit.io/docs/).
