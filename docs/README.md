# Home 

## What is AudioKit?

AudioKit is an entire audio development ecosystem of code repositories, packages, libraries, algorithms, applications, playgorunds, tests, and scripts, built and used by a community of audio programmers, app developers, engineers, researchers, scientists, musicians, gamers, and even people new to programming.

AudioKit has several underlying goals that motivate its development.

1. First, we hope that learning to program with AudioKit is easy for anybody. In order to get people started we provide Swift Playgrounds, demonstration applications, and access to a supportive Slack group of AudioKit Professionals.

2. Next, we want AudioKit to be extensible to allow more advanced developers to create their own custom apps and libraries built on top of AudioKit. Most of what used to be part of AudioKit has been moved to separate packages to ensure AudioKit is extensible and to give developers several examples of different approaches to extending AudioKit.

3. An important goal for AudioKit is to allow it to grow and be maintainable by a handful of volunteers. For this reason we have extensive tests that are run whenever changes are made to any AudioKit code repository. We accept and encourage Github sponsorship of the people who spend a lot of time supporting AudioKit.

4. We want to inspire the next generation of audio app developers and we do that by highlighting AudioKit-powered apps and by creating our own apps under the "AudioKit Pro" brand including the world's most downloaded synth "AudioKit Synth One" and a host of other AudioKit Pro apps.

## Migration Guide

The [Migration Guide](MigrationGuide.md) contains a lot of good information on converting your app from Version 4 to 5 and beyond.

## Examples

The primary source for AudioKit examples is the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook). This app contains all of the mini-examples that used to be included with AudioKit.

Larger examples have been moved to their own repositories:

* [Analog Synth X](https://github.com/AudioKit/AnalogSynthX)
* [AudioKit Synth One](https://github.com/AudioKit/AudioKitSynthOne)
* [Audio Unit Manager](https://github.com/AudioKit/AudioUnitManager)
* [File Converter](https://github.com/AudioKit/FileConverter) - Updated for AudioKit 5
* [Flanger and Chorus](https://github.com/AudioKit/FlangerAndChorus) - Updated for AudioKit 5
* [MIDI File Edit And Sync](https://github.com/AudioKit/MIDIFileEditAndSync)
* [MIDI Sequencer](https://github.com/AudioKit/MIDISequencer)
* [MIDI Track View](https://github.com/AudioKit/MIDITrackView)
* [Nodality](https://github.com/AudioKit/Nodality)
* [Output Splitter](https://github.com/AudioKit/OutputSplitter)
* [Particles](http://github.com/AudioKit/Particles/)
* [Player Demo](https://github.com/AudioKit/PlayerDemo)
* [ROM Player](https://github.com/AudioKit/ROMPlayer)
* [SamplerDemo](http://github.com/AudioKit/SamplerDemo/)
* [Simple Audio Unit](https://github.com/AudioKit/SimpleAudioUnit)
* [Song Processor](http://github.com/AudioKit/SongProcessor)

# Nodes

Nodes are interconnectable components that work with the audio stream. For a node to work, audio has to be pulled through it. For audio to be pulled through a node, the audio signal chain that includes the node has to eventually reach an output. 

AudioKit has several kinds of nodes:

## Analysis 

These nodes do not change the audio at all.  They examine the audio stream and extract information about the stream.  For example, the two most common uses for this are determining the audio's pitch and loudness.

## Effects

These nodes do change the audio stream.  They require an input to process.

## Generators

Generators create audio signal from scratch and as such they do not require an input signal.

## Input 

Like generator nodes, input nodes create audio, but in this case the audio that is create is retrieved from an input like a microphone or another app's output.

## Mixing

These nodes are about managing more than one sound simultaneously. Sounds can be combined, placed spatially, have their volumes changed, etc.

## Offline Rendering

This is for processing an audio quickly and saving it, rather than playing it in realtime through a speaker.

## Playback

Playback nodes are about playing and working with audio files.  We also include metronome nodes here.

