# AudioKit Core

This directory is stores the core code of AudioKit. 

## Common/

This is where all of cross-platform code that is relevant to at least two of the operating systems AudioKit supports, ie. iOS, macOS, and tvOS.

## iOS/

This directory contains the "AudioKit for iOS.xcodeproj" which contains all the iOS-compatible components from the common directory as well as user interface elements based on UIKit which is accessible only to iOS.  It contains a "Dev" playground which is only intended for temporary access to playgrounds for AudioKit developers to build playgrounds before they get added to the main AudioKit Playgrounds project.

The AudioKit Test Suite for iOS is also kept here.

## macOS/

This directory contains the "AudioKit for macOS.xcodeproj" which contains all the macOS-compatible components from the common directory as well as user interface elements based on Cocoa which is accessible only to macOS.  It contains a "Dev" playground which is only intended for temporary access to playgrounds for AudioKit developers to build playgrounds before they get added to the main AudioKit Playgrounds project.

## tvOS/

The "AudioKit for tvOS.xcodeproj" contains the common elements that work on tvOS.  The most notable ommission from tvOS is any MIDI enabled components of AudioKit, since tvOS does not currenly support MIDI.

## .jazzy.yaml

This is a configuration file for the Jazzy documentation generation system that generates the [AudioKit docs](http://audiokit.io/docs/).