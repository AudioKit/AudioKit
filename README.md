AudioKit V3.3
===

[![Build Status](https://travis-ci.org/audiokit/AudioKit.svg)](https://travis-ci.org/audiokit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/audiokit/AudioKit/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/AudioKit.svg?style=flat)](https://github.com/CocoaPods/Specs/tree/master/Specs/AudioKit)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitMan.svg?style=social)](http://twitter.com/AudioKitMan)

AudioKit is an audio synthesis, processing, and analysis platform for OS X, iOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit website at http://audiokit.io/

If you need support, the best thing to do is to join AudioKit's google group:

https://groups.google.com/forum/#!forum/audiokit

### Version 3
The third major revision of AudioKit has been completely rewritten to offer the following improvements over previous versions:

* Installation as a framework
* Integrated with CoreAudio audio units from Apple
* No external dependencies
* Can use opcodes from Faust, Chuck, STK, Csound, and others
* Many included Xcode Swift playgrounds

and quite a bit more. There are things that version 2 had that are not yet part of version 3, but rather than trying to support version 2, let us know what you need to do, and we'll port it over to version 3 upon request.

## Key Concepts

### Nodes
Nodes are interconnectable signal processing components.  Each node has at least an ouput and most likely also has parameters.  If it is processing another signal, the node will also have an input.

### Operations
Operations are similar to nodes, except that they are a series of signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex processing results.

### Taps
Taps use nodes as their data source, but do not redirect the audio signal away from the source nodes output into other nodes.   This allows a tap to be moved from node to node more freely and can be added after the audio signal path has started.

## Installation

Installation can be achieved in the usual ways for a framework.  This is explained in more detail in the INSTALL.md file in the Frameworks directory.

Installation with CocoaPods and Carthage is also planned but may not come with the first release.

## Example Code
There are three Hello World projects, one for each of the Apple platforms: OSX, iOS, and tvOS. They simply play an oscillator and display the waveform.

The examples rely on the frameworks being built so you can either download the precompiled frameworks or build them on your own:

```
$ cd Frameworks
$ ./build_frameworks.sh
```
Hello World basically consists of just a few sections of code:

Creating the sound, in this case an oscillator:

```
var oscillator = AKOscillator()
```
Telling AudioKit where to get its audio from (ie. the oscillator):

```
AudioKit.output = oscillator
```
Starting AudioKit:

```
AudioKit.start()
```
And then responding to the UI by changing the oscillator:

```
if oscillator.isPlaying {
    oscillator.stop()
} else {
    oscillator.amplitude = random(0.5, 1)
    oscillator.frequency = random(220, 880)
    oscillator.start()
}
```
## Playgrounds

Because Playgrounds have very different capabilities depending on whether they are for OSX or iOS, we have two sets of playgrounds for each OS.  At this point tvOS behaves very much like iOS so there is no set of playgrounds explicitly for tvOS.

### AudioKit for iOS Playgrounds
There are many playground pages within the AudioKit for iOS Playground.  Each playground includes a demo of a node or operation or an example of sound design.  The first playground is a Table of Contents in which the playgrounds are organized via markup.  The playground may also be opened up to view the playgrounds alphabetically.

### AudioKit for OS X Playgrounds
OS X Playgrounds have slightly different capabilities from iOS ones, so while most playgrounds are the same across the two platforms, a few playgrounds only exist on one or the other.  As of this writing, access to a microphone is only capable on the OS X playgrounds, for instance.

## Tests

So far, the only testing that we do automatically through Travis is to ensure that all of the projects included with AudioKit build successfully.  AudioKit version 2 was heavily tested, but at the time of this writing AudioKit 3 does not have a test suite in place.  This is high on our priority list after an initial release.

## Package Managers

You can easily add the framework to your project by using [Carthage](https://github.com/Carthage/Carthage). Just use the following in your `Cartfile`:

```
github "audiokit/AudioKit"
```

If you use CocoaPods, you can also easily get the latest AudioKit binary framework for your project. Use this in your `Podfile`:

```
pod 'AudioKit', '~> 3.2'
```

## About Us

AudioKit was created by the following team whose contributions are fully chronicled in Github, and summarized below in alphabetical order by first name:

* **[Aurelius Prochazka](https://github.com/aure)**: Primary programmer of AudioKit. Lives for this stuff.  Your life line if you need help.
* **[Brandon Barber](https://github.com/roecrew/)**: Deep diver.  Contributed a lot of great pull requests.
* **[Jeff Cooper](https://github.com/eljeff)**: Rearchitected all things MIDI, sampler, and sequencer related in AudioKit 3.
* **[Laurent Veliscek](https://github.com/laurentVeliscek/)**: Master of the AKAudioFile, AKAudioPlayer, and recording nodes.
* **[Matthew Fecher](https://github.com/swiftcodex)**: Sound design, graphic design, and programming of the Analog Synth X example.
* **[Nicholas Arner](https://github.com/narner)**: Longtime contributor to AudioKit and AudioKit's web site.
* **[Paul Batchelor](https://github.com/PaulBatchelor)**: The author of [Soundpipe](https://github.com/paulbatchelor/soundpipe), and [Sporth](https://github.com/paulbatchelor/sporth), which serve as two primary audio engines in AudioKit 3.
* **[Stephane Peter](https://github.com/megastep)**: Installation and configuration czar and code reviewer.

## Contributing Code

We welcome new contributors but we realize it can be daunting to suggest updates as a newcomer.  Here's what we are currently working on:  [AudioKit Works in Progress](http://audiokit.io/wip/)

Here are some resources that we use to develop our coding choices and core philosophies:

## Avoid code smell

* [Code Smell in Swift](http://www.bartjacobs.com/five-code-smells-in-swift-and-objective-c/)
* [Code Smell in Objective-C](http://qualitycoding.org/objective-c-code-smells/)
* [Code Smell of the Preprocessor](http://qualitycoding.org/preprocessor/)

## Be aware of how to code for an open-source framework

* [Tips for Writing a Great iOS Framework](https://medium.com/@samjarman/tips-for-writing-a-great-ios-framework-8cf3452f6c5d#.wzejktd3l)
* [Best practices running an iOS open source project on GitHub](https://www.cocoanetics.com/2014/10/best-practices-running-an-ios-open-source-project-on-github/)

