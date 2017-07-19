AudioKit V3.7
===

[![Build Status](https://travis-ci.org/AudioKit/AudioKit.svg)](https://travis-ci.org/AudioKit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/AudioKit.svg?style=flat)](https://cocoapods.org/pods/AudioKit)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)
<img src="https://img.shields.io/badge/%20in-swift%203.0-orange.svg">
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitMan.svg?style=social)](http://twitter.com/AudioKitMan)

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit websites:

* [AudioKitPro.com](http://audiokitpro.com/) - AudioKit Features, Blog, and Highlighted Apps
* [AudioKit.io](http://audiokit.io/) - AudioKit Developer Documentation

Did you already build an app with AudioKit?  Let us know and we'll highlight it on AudioKitPro.com.

If you need support, the best thing to do is to join [AudioKit's google group](https://groups.google.com/forum/#!forum/audiokit).

### AudioKit Version 3, Swift 3
The third major revision of AudioKit has been completely rewritten to offer the following improvements over previous versions:

* Installation as a framework
* Integrated with CoreAudio audio units from Apple
* No external dependencies
* Can use opcodes from Faust, Chuck, STK, Csound, and others
* Many included Xcode Swift playgrounds

As of AudioKit 3.4, we have moved to support Swift 3 exclusively. You will therefore need to use Xcode 8 (or above) to compile or use AudioKit in your projects and convert your Swift 2 projects to Swift 3.

## Key Concepts

| Nodes | Operations | Taps |
|-------|------------|------|
| Nodes are interconnectable signal processing components.  Each node has at least an output and most likely also has parameters.  If it is processing another signal, the node will also have an input. | Operations are similar to nodes, except that they are a series of signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex processing results. | Taps use nodes as their data source, but do not redirect the audio signal away from the source nodes output into other nodes.   This allows a tap to be moved from node to node more freely and can be added after the audio signal path has started.

## Installation

Installation can be achieved in the usual ways for a framework. More details are found in the [Frameworks README file](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md).

AudioKit is also available via [CocoaPods](https://cocoapods.org/pods/AudioKit) and Carthage Package managers:

| Package Manager | Config File | Contents |
|-----------------|-------------|----------|
| [Carthage](https://github.com/Carthage/Carthage) | `Cartfile` | `github "audiokit/AudioKit"` |
| [Cocoapods](https://cocoapods.org/)              | `Podfile`  | `pod 'AudioKit', '~> 3.7'`   |

## Example Code
There are three Hello World projects, one for each of the Apple platforms: iOS, macOS, and tvOS. They simply play an oscillator and display the waveform.

The examples rely on the frameworks being built so you can either download the precompiled frameworks or [build them on your own](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md)    .

Hello World basically consists of just a few sections of code:

| Code                                     | Description                  |
|------------------------------------------|------------------------------|
| `var oscillator = AKOscillator()`        | Create the sound generator   |
| `AudioKit.output = oscillator`           | Tell AudioKit what to output |
| `AudioKit.start()`                       | Start up AudioKit            |
| `oscillator.start()`                     | Start the oscillator         |
| `oscillator.frequency = random(220,880)` | Set oscillator parameters    |
| `oscillator.start()`                     | Start the oscillator         |

## Playgrounds

We have so many playground pages that it became difficult to maintain them in one playground, so we separated them into categories:

| Playgrounds |    |
|--------|------------------------------------------------------------------------------------------------------------|
| Basics | Making your first sounds and connecting components |
| Synthesis | Oscillators, physical models, generative audio |
| Playback | Audio files, Sequencing, Sampling |
| Effects | Processing sound |
| Filters | Frequency range modification |
| Analysis | Pitch and loudness detection, FFT spectrum analysis|

Since AudioKit 3.6, we provide all playgrounds as a macOS project ready to run in Xcode. Just download the `AudioKitPlaygrounds.zip` file from our [releases page](https://github.com/audiokit/AudioKit/releases), open and build the project, and go to the playground pages to learn the API in a fun way!


## Ray Wenderlich's AudioKit Tutorial

Check out the [AudioKit tutorial on the Ray Wenderlich site](https://www.raywenderlich.com/145770/audiokit-tutorial-getting-started). You’ll be taken on a fun and gentle journey through the framework via the history of sound synthesis and computer audio.

## Contributing Code

We welcome new contributors but we realize it can be daunting to suggest updates as a newcomer.  Here's what we are currently working on:  [AudioKit Works in Progress](https://github.com/audiokit/AudioKit/projects)

Ready to send us a pull request? Please make sure your request is based on the [develop](https://github.com/audiokit/AudioKit/tree/develop) branch of the repository as `master` only holds stable releases.

## About Us

AudioKit was created by the following team whose contributions are fully chronicled in Github, and summarized below in alphabetical order by first name:

| Contributors | |
|--------------|-|
| **[Adam Nemecek](https://github.com/adamnemecek)**| Lives by the motto "No code is better than no code" and tries to apply |hat to AudioKit.|
| **[Aurelius Prochazka](https://github.com/aure)**| Primary programmer of AudioKit. Lives for this stuff. Your life line if |ou need help.|
| **[Brandon Barber](https://github.com/roecrew)**| Deep diver.  Contributed a lot of great pull requests. |
| **[Jeff Cooper](https://github.com/eljeff)**| Rearchitected all things MIDI, sampler, and sequencer related in AudioKit 3.|
| **[Laurent Veliscek](https://github.com/laurentVeliscek)**| Creator of the AKAudioFile, AKAudioPlayer, and recording nodes.|
| **[Matthew Fecher](https://github.com/swiftcodex)**|  Synth examples including AudioKit Synth One & Analog Synth X, both websites, evangelist.|
| **[Marcus Hobbs](https://github.com/marcussatellite)**| Created all the microtonal aspects of AudioKit. |
| **[Nicholas Arner](https://github.com/narner)**| Longtime contributor to AudioKit and AudioKit's web site. |
| **[Paul Batchelor](https://github.com/PaulBatchelor)**| The author of [Soundpipe](https://github.com/paulbatchelor/soundpipe) and [Sporth](https://github.com/paulbatchelor/sporth), which serve as two primary audio engines in AudioKit 3.|
| **[Stephane Peter](https://github.com/megastep)**| Installation and configuration czar and code reviewer. |

