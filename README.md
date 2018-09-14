AudioKit V4.4
===

[![Build Status](https://travis-ci.org/AudioKit/AudioKit.svg)](https://travis-ci.org/AudioKit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](https://github.com/AudioKit/AudioKit/blob/master/LICENSE)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/AudioKit.svg?style=flat)](https://cocoapods.org/pods/AudioKit)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)
<img src="https://img.shields.io/badge/in-swift4.0-orange.svg">
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitMan.svg?style=social)](http://twitter.com/AudioKitMan)

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit websites:

| [AudioKitPro.com](http://audiokitpro.com/)|[AudioKit.io](http://audiokit.io/)|
|:--:|:--:|
| Features, News, Blog, and Highlighted Apps | Developer Documentation |
| [![AudioKitPro](http://audiokit.io/images/audiokitpro.png)](http://audiokitpro.com) | [![AudioKit.io](http://audiokit.io/images/audiokitio.png)](http://audiokit.io) |

## Key Concepts

| Nodes | Operations | Taps |
|-------|------------|------|
| Nodes are interconnectable signal processing components.  Each node has an output and usually some parameters.  If the nodes processes another signal, the nodes will also have an `input`. | Operations are similar to nodes, except that they are signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex results. | Taps use nodes as their data source, but do not redirect the audio signal away from the source nodes output into other nodes. This allows a tap to be moved from node to node more freely and to be added after the audio signal path has started.

## Installation

Installation details are found in the [Frameworks README file](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md).

AudioKit is also available via [CocoaPods](https://cocoapods.org/pods/AudioKit). Place the following in your `Podfile`:

```
    pod 'AudioKit', '~> 4.0'
```

If you do not need the UI components, you can select just the Core pod, like so:

```
   pod 'AudioKit/Core'
```

## Example Code
There are three Hello World projects, one for each of the Apple platforms: iOS, macOS, and tvOS. They play oscillators and display waveforms. The examples rely on AudioKit's frameworks so you can either download precompiled frameworks or [build them yourself](https://github.com/audiokit/AudioKit/blob/master/Frameworks/README.md)    .

For Hello World, you only need to understand a few lines of code:

| Code                                           | Description                  |
|------------------------------------------------|------------------------------|
| `var oscillator = AKOscillator()`              | Create the sound generator   |
| `AudioKit.output = oscillator`                 | Tell AudioKit what to output |
| `AudioKit.start()`                             | Start up AudioKit            |
| `oscillator.start()`                           | Start the oscillator         |
| `oscillator.frequency = random(in: 220...880)` | Set oscillator parameters    |
| `oscillator.stop()`                            | Stop the oscillator          |

## Playgrounds

<table>
<tr>
<td>
Playgrounds contain bite-size examples of AudioKit and serve as tutorials for many of AudioKit's core concepts and capabilities.  There are over 100 playgrounds which cover basic tutorials, synthesis, physical modeling, file playback, MIDI, effects, filters, and analysis.

We provide all playgrounds as a macOS project that is ready to run in Xcode. Just download the `AudioKitPlaygrounds.zip` file from our [releases page](https://github.com/audiokit/AudioKit/releases), open and build the project, and go to the playground pages to learn AudioKit's API in a fun way!

We have videos of most of the playgrounds in action, so you don't need to run Xcode to check them out, just go to [AudioKit Playground Videos](http://audiokit.io/playgrounds/).
</td>
<td width=320 align=right>

[![Playgrounds](http://audiokit.io/examples/playgrounds.jpg)](http://audiokit.io/playgrounds/)

</td>
</tr>
</table>

## Ray Wenderlich's AudioKit Tutorial


Check out the [AudioKit tutorial on the Ray Wenderlich site](https://www.raywenderlich.com/145770/audiokit-tutorial-getting-started). You’ll be taken on a fun and gentle journey through the framework via the history of sound synthesis and computer audio.

## Getting help

Here are three methods for getting support which are roughly listed in order of what you should try first:

1. Post your problem to [StackOverflow with the #AudioKit hashtag](https://stackoverflow.com/questions/tagged/audiokit).

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

### Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="https://github.com/AudioKit/AudioKit/graphs/contributors"><img src="https://opencollective.com/AudioKit/contributors.svg?width=890&button=false" /></a>


