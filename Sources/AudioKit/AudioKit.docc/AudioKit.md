# ``AudioKit``

Swift audio synthesis, processing, & analysis platform for iOS, macOS and tvOS

## Overview

AudioKit is an entire audio development ecosystem of code repositories, packages, libraries, algorithms, applications, playgrounds, tests, and scripts, built and used by a community of audio programmers, app developers, engineers, researchers, scientists, musicians, gamers, and people new to programming.

AudioKit has several underlying goals that motivate its development.

1. First, we hope that learning to program with AudioKit is easy for anybody. In order to get people started we provide Swift Playgrounds, demonstration applications, and access to a supportive Discord group of AudioKit Professionals.

2. Next, we want AudioKit to be extensible to allow more advanced developers to create their own custom apps and libraries built on top of AudioKit. Most of what used to be part of AudioKit has been moved to separate packages to ensure AudioKit is extensible and to give developers several examples of different approaches to extending AudioKit.

3. An important goal for AudioKit is to allow it to grow and be maintainable by a handful of volunteers. For this reason we have extensive tests that are run whenever changes are made to any AudioKit code repository. We accept and encourage Github sponsorship of the people who spend a lot of time supporting AudioKit.

4. We want to inspire the next generation of audio app developers and we do that by highlighting AudioKit-powered apps and by creating our own apps under the "AudioKit Pro" brand including the world's most downloaded synth "AudioKit Synth One" and a host of other AudioKit Pro apps.

## Packages / Layer Diagram

![Layer Diagram](AudioKitLayers)

The AudioKit Layer itself contains three frameworks you can import from:

| Framework Name | Description                                                             |
|----------------|-------------------------------------------------------------------------|
| AudioKit       | Swift-only base layer for AudioKit, usable in the Swift Playgrounds app |
| AudioKitEX     | Swift API for extension to AudioKit written in C++                      |
| CAudioKitEX    | The DSP and other lower level code supporting AudioKitEX functionality  |

The Cookbook demo app layer is an example of where your app would be in this diagram. It could depend on any subset of the packages below it.

Packages can depend on other packages, and this is shown in the example of SporthAudioKit depending on (on top of) SoundpipeAudioKit.

The <i>AAA</i>AudioKit...<i>ZZZ</i>AudioKit blocks in the layer diagram above are placeholders for the many different packages that extend AudioKit.


| Package Name                                                        | Description                                   |
|---------------------------------------------------------------------|-----------------------------------------------|
| [AudioKitUI](https://github.com/AudioKit/AudioKitUI)                | Waveform visualization and UI components      |
| [Devoloop AudioKit](https://github.com/AudioKit/DevoloopAudioKit)   | Guitar processors                             |
| [Dunne AudioKit](https://github.com/AudioKit/DunneAudioKit)         | Chorus, Flanger, Sampler, Stereo Delay, Synth |
| [Soundpipe AudioKit](https://github.com/AudioKit/SoundpipeAudioKit) | Oscillators, Effects, Filters, and more       |
| [Sporth AudioKit](https://github.com/AudioKit/SporthAudioKit)       | Operations for complex DSP with simple syntax |
| [STK AudioKit](https://github.com/AudioKit/STKAudioKit/)            | Stanford Synthesis Toolkit physical models    |

## AudioKit.io (this website)

This web site is created from the main AudioKit Docc style content. 

## Installation

Use Swift Package Manager and point to the URL:  [https://github.com/AudioKit/AudioKit/](https://github.com/AudioKit/AudioKit/)

## Targets

| Name        | Description                                                      | Language      |
|-------------|------------------------------------------------------------------|---------------|
| AudioKit    | Wrappers for AVFoundation Effects                                | Swift         |
| AudioKitEX  | Nodes, Parameters, Automation, Sequencing                        | Swift         |
| CAudioKitEX | DSP and other low level code supporting AudioKitEX functionality | Objective-C++ |

## Examples

The primary source for AudioKit examples is the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook). This app contains all of the mini-examples that used to be included with AudioKit.

## Format Converter

FormatConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
```swift
let options = FormatConverter.Options()
// any options left nil will assume the value of the input file
options.format = "wav"
options.sampleRate = 48000
options.bitDepth = 24

let converter = FormatConverter(inputURL: oldURL, outputURL: newURL, options: options)
converter.start { error in
// check to see if error isn't nil, otherwise you're good
})
```

## MIDI

AudioKit MIDI is an implementation of CoreMIDI meant to simplify creating and responding to MIDI signals. 

Add MIDI listeners like this:
 ```
var midi = MIDI()
midi.openInput()
midi.addListener(someClass)
 ```
 ...where `someClass` conforms to the `MIDIListener` protocol

You then implement the methods you need from `MIDIListener` and use the data how you need.


## Tables

Tables are just arrays of float data. They are most often used to store waveform data and they have some defaults for the most common cases:

* sine wave
* triangle wave
* square wave
* sawtooth wave
* reverse sawtooth wave
* positive sine
* positive triangle
* positive square
* positive sawtooth
* positive reverse sawtooth

Tables can also store audio or control data.

## Sequencing

The `AppleSequencer` is based on tried-and-true CoreAudio/MIDI sequencing.

## Taps

Taps are a way to get access to the audio stream at a given point in the signal chain without 
inserting a node into the signal chain, but instead sort of syphoning off audio "tapping" it and using
the data for some side purpose like plotting or running analysis of the stream at that point.


## Topics

### <!--@START_MENU_TOKEN@-->Group<!--@END_MENU_TOKEN@-->

- <!--@START_MENU_TOKEN@-->``Symbol``<!--@END_MENU_TOKEN@-->
