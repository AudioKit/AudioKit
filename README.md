AudioKit V3.5
===

[![Build Status](https://travis-ci.org/audiokit/AudioKit.svg)](https://travis-ci.org/audiokit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/audiokit/AudioKit/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/AudioKit.svg?style=flat)](https://github.com/CocoaPods/Specs/tree/master/Specs/AudioKit)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)
<img src="https://img.shields.io/badge/%20in-swift%203.0-orange.svg">
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitMan.svg?style=social)](http://twitter.com/AudioKitMan)

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit website at http://audiokit.io/

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

### Swift 3

As of AudioKit 3.4, we have moved to support Swift 3 exclusively. You will therefore need to use Xcode 8 (or above) to compile or use AudioKit in your projects. You will additionally need to convert your Swift 2 projects to Swift 3.

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

We have so many playground pages that it became difficult to maintain them in one playground, so we separated them into categories:

* Basics - Starting tutorials to get things up and running, making sounds, and connecting various types of components
* Synthesis - Oscillators, physical models, generative audio
* Playback - Audio files, Sequencing, Sampling
* Effects - Processing sound
* Filters - Frequency range modification
* Analysis - Pitch and loudness detection, FFT spectrum analysis

Because Playgrounds have some different capabilities on different platforms, there are a few playground pages available in OS Specific playgrounds for iOS and macOS.
At this point tvOS behaves very much like iOS so there is no set of playgrounds explicitly for tvOS.


## Tests

We ensure all the included projects build by automatically testing them using Travis Continuous Integration.  There are also unit tests for many of the nodes and operations in AudioKit, which we run locally because at this time they don't quite work on Travis (but we'd love some help if you want to figure that one out!).

## Package Managers

You can easily add the framework to your project by using [Carthage](https://github.com/Carthage/Carthage). Just use the following in your `Cartfile`:

```
github "audiokit/AudioKit"
```

If you use CocoaPods, you can also easily get the latest AudioKit binary framework for your project. Use this in your `Podfile`:

```
pod 'AudioKit', '~> 3.5'
```

## About Us

AudioKit was created by the following team whose contributions are fully chronicled in Github, and summarized below in alphabetical order by first name:

* **[Adam Nemecek](https://github.com/adamnemecek)**: Lives by the motto "No code is better than no code" and tries to apply that to AudioKit.
* **[Aurelius Prochazka](https://github.com/aure)**: Primary programmer of AudioKit. Lives for this stuff. Your life line if you need help.
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

## Interested in audio synthesis?

* check out [Syntorial](http://www.syntorial.com/#a_aid=AudioKit), it's hands down the best way to learn about synthesis interactively, your best bet if you care about synthesis from the sound design point of view; an afternoon with this will help you understand more than any book or video

* https://web.archive.org/web/20160403115835/http://www.soundonsound.com/sos/allsynthsecrets.htm very detailed, very thorough discussion of the topic of synthesis but almost too detailed on times

