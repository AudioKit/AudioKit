AudioKit V4.0
===

[![Build Status](https://travis-ci.org/AudioKit/AudioKit.svg)](https://travis-ci.org/AudioKit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/blob/master/LICENSE)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/AudioKit.svg?style=flat)](https://cocoapods.org/pods/AudioKit)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)
<img src="https://img.shields.io/badge/in-swift4.0-orange.svg">
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitMan.svg?style=social)](http://twitter.com/AudioKitMan)

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit websites:

| [AudioKitPro.com](http://audiokitpro.com/)|[AudioKit.io](http://audiokit.io/)|
|:--:|:--:|
| Features, News, Blog, and Highlighted Apps | Developer Documentation |
| [![AudioKitPro](http://audiokit.io/images/audiokitpro.png)](http://audiokitpro.com) | [![AudioKit.io](http://audiokit.io/images/audiokitio.png)](http://audiokit.io) |

## Key Concepts

| Nodes | Operations | Taps |
|-------|------------|------|
| Nodes are interconnectable signal processing components.  Each node has an output and usually some parameters.  If the nodes processes another signal, the node will also have an `input`. | Operations are similar to nodes, except that they are signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex results. | Taps use nodes as their data source, but do not redirect the audio signal away from the source nodes output into other nodes. This allows a tap to be moved from node to node more freely and can be added after the audio signal path has started.

## Installation

Installation can be achieved in the usual ways for a framework. More details are found in the [Frameworks README file](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md).

AudioKit is also available via [CocoaPods](https://cocoapods.org/pods/AudioKit) and Carthage Package managers:

| Package Manager                                  | Config File | Contents                     |
|--------------------------------------------------|-------------|------------------------------|
| [Carthage](https://github.com/Carthage/Carthage) | `Cartfile`  | `github "audiokit/AudioKit"` |
| [Cocoapods](https://cocoapods.org/)              | `Podfile`   | `pod 'AudioKit', '~> 4.0'`   |

## Example Code
There are three Hello World projects, one for each of the Apple platforms: iOS, macOS, and tvOS. They play oscillators and display the waveform. The examples rely on the frameworks being built so you can either download the precompiled frameworks or [build them on your own](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md)    .

For Hello World you only need to understand a few lines of code:

| Code                                     | Description                  |
|------------------------------------------|------------------------------|
| `var oscillator = AKOscillator()`        | Create the sound generator   |
| `AudioKit.output = oscillator`           | Tell AudioKit what to output |
| `AudioKit.start()`                       | Start up AudioKit            |
| `oscillator.start()`                     | Start the oscillator         |
| `oscillator.frequency = random(220,880)` | Set oscillator parameters    |
| `oscillator.stop()`                      | Stop the oscillator          |

## Playgrounds

<table>
<tr>
<td>
Playgrounds contain bite-size examples of AudioKit and serve as tutorials for many of AudioKit's core concepts and capabilities.  There are over one hundred playgrounds from the most basic tutorials, to synthesis, physical modeling, file playback, MIDI, effects, filters, and analysis.

We provide all playgrounds as a macOS project ready to run in Xcode. Just download the `AudioKitPlaygrounds.zip` file from our [releases page](https://github.com/audiokit/AudioKit/releases), open and build the project, and go to the playground pages to learn the API in a fun way!

We have made videos of most of the playgrounds in action, so you don't even need to run Xcode to check them out, just go to [AudioKit Playground Videos](http://audiokit.io/playgrounds/).
</td>
<td width=320 align=right>

[![Playgrounds](http://audiokit.io/examples/playgrounds.jpg)](http://audiokit.io/playgrounds/)

</td>
</tr>
</table>

## Ray Wenderlich's AudioKit Tutorial


Check out the [AudioKit tutorial on the Ray Wenderlich site](https://www.raywenderlich.com/145770/audiokit-tutorial-getting-started). You’ll be taken on a fun and gentle journey through the framework via the history of sound synthesis and computer audio.

## Getting help

There are three methods for getting support, roughly listed in order of what you should try first:

1. Post your problem to [StackOverflow](https://stackoverflow.com/search?q=AudioKit) with the #AudioKit hashtag.

2. If you don't have a problem that you can post to StackOverflow, you may post to our [Google Group](https://groups.google.com/forum/#!forum/audiokit), but it is a moderated list and prepare to be rejected if the moderator believes your question is better suited for StackOverflow (most are).

3. If you are pretty sure the problem is not in your implementation, but in AudioKit itself, you can open a [Github Issue](https://github.com/audiokit/AudioKit/issues).


## Contributing Code

AudioKit is always being improved by our core team and our users.   [This is a rough outline of what we're working on currently.](https://github.com/audiokit/AudioKit/projects)

When you want to modify AudioKit, check out the [develop](https://github.com/audiokit/AudioKit/tree/develop) branch (as opposed to master), make your changes, and send us a [pull request](https://github.com/audiokit/AudioKit/pulls).

## About Us

AudioKit was created by [Aurelius Prochazka](https://github.com/aure) who is your life line if you need help!  [Matthew Fecher](https://github.com/swiftcodex) manages all of AudioKit's web sites and [Stephane Peter](https://github.com/megastep) is Aure's co-admin and manages AudioKit's releases.  

But, there are many other important people in our family:

| Group | Description |
|-------|-------------|
|[Core Team](https://github.com/orgs/AudioKit/people)                    | The biggest contributors to AudioKit! |
|[Slack](https://audiokit.slack.com)                                     | Pro-level developer chat group, contact a core team member for an in invitation. |
|[Contributors](https://github.com/AudioKit/AudioKit/graphs/contributors)| A list of all people who have submitted code to AudioKit.|
|[Google Group](https://groups.google.com/forum/#!forum/audiokit)        | App Announcements and mailing list for all users. |
