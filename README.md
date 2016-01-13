AudioKit V3
===
*This document was last updated: January 2, 2016*

AudioKit is an audio synthesis, processing, and analysis platform for OS X, iOS, and tvOS. This document serves as a one-page introduction to AudioKit, but we have much more information available on the AudioKit website at http://audiokit.io/

### Version 3.0
The third major revision of AudioKit has been completely rewritten to offer the following improvements over previous versions:

* Installation as a framework
* Integrated with CoreAudio audio units from Apple
* No dependencies on Csound or libsndfile
* Can use opcodes from Faust, Chuck, STK, Csound, and others
* Many included Xcode Swift playgrounds

and quite a bit more. There are things that version 2 had that are not yet part of version 3, so you should compare and contrast your options at http://audiokit.io/v3/

## Key Concepts

### Nodes
Nodes are interconnectable signal processing components.  Each node has at least an ouput and most likely also has parameters.  If it is processing another signal, the node will also have an input.

### Operations
Operations are similar to nodes, except that they are a series of signal processing components that exist inside of a single node.  Operations can be used as parameters to other operations to create very complex processing results.

## Installation

Installation can be achieved in the usual ways for a framewok.  You can drag AudioKit.framework from the AudioKit project from whatever OS you are targeting into your project.  Alternatively, you can drag the AudioKit project file into your project and then when you build your project, Xcode will autotomatically build AudioKit for you.  You need to add the AudioKit framework to the Build Phases "Link Bundle with Binaries" section.

Installation with CocoaPods and Carthage is also planned but may not come with the first release.

## Example Code
There are three Hello World projects, one for each of the Apple platforms: OSX, iOS, and tvOS. They simply play an oscillator and display the waveform.  Hello World basically consists of just a few sections of code:

Setting up AudioKit:

    let audiokit = AKManager.sharedInstance

Creating the sound, in this case an oscillator:

    var oscillator = AKOscillator()

Telling AudioKit where to get its audio from (ie. the oscillator):

    audiokit.audioOutput = oscillator

Starting AudioKit:

        audiokit.start()

And then responding to the UI by changing the oscillator:

        if oscillator.isPlaying {
            oscillator.stop()
        } else {
            oscillator.amplitude = random(0.5, 1)
            oscillator.frequency = random(220, 880)
            oscillator.start()
        }

## Playgrounds

Because Playgrounds have very different capabilities depending on whether they are for OSX or iOS, we have two sets of playgrounds for each OS.  At this point tvOS behaves very much like iOS so there is no set of playgrounds explicitly for tvOS.

### AudioKit for iOS Playgrounds
There are many playground pages within the AudioKit for iOS Playground.  Each playground includes a demo of a node or operation or an example of sound design.  The first playground is a Table of Contents and the second one is just a Hello World to prove whether or not you have things set up correctly on your machine.  After the first few playgrounds, you should consider jumping around to whatever interests you.  Since Apple doesn't provide much of a way to organize playgrounds, the best place to see how playgrounds are grouped together is to look at the http://audiokit.io/playgrounds/ where you can also see videos of the playgrounds in action.

### AudioKit for OSX Playgrounds
OSX Playgrounds are able to launch NSWindows that can be used to control the AudioKit effects processors, so these playgrounds have a UI that allow you to adjust the parameters of an effect very easily.  However, OSX playgrounds at this point do not support AudioKit nodes that do not use Apple AudioUnit processors, so there are fewer things that we can demonstrate in OSX playgrounds.  Hopefully this will be fixed in the future - it is unclear whether the problem is in AudioKit or within the Xcode playground audio implementation.

## Developer Tools

These are tools for the developers of AudioKit itself, not tools for developers making apps with AudioKit.  This folder contains scripts and templates that generate nodes and operations from meta data contained in yaml or interface files.

## Tests

So far, the only testing that we do automatically through Travis is to ensure that all of the projects included with AudioKit build successfully.  AudioKit version 2 was heavily tested, but at the time of this writing AudioKit 3 does not have a test suite in place.  This is high on our priority list after an initial release.

## About Us

AudioKit was primarily written by Aurelius Prochazka with major contributions from others whose contributions are fully chronicled in Github, and summarized below in alphabetical order by first name:

* Jeff Cooper: Rearchitected all things MIDI, sampler, and sequencer related in AudioKit 3.
* Matthew Fecher: Sound design, graphic design, and programming of the Swift Synth example (as well as AK2's Swift examples).
* Nicholas Arner: Wrote many tests and presets as well as tutorials for AudioKit Versions 1 and 2.
* Paul Batchelor: The author of Soundpipe, and Sporth, which serve as two primary audio engines in AudioKit 3.
* Simon Gladman: Contributed his AudioKitParticles example project, previously built using AudioKit 2, to the repo for AudioKit 3.
* Stephane Peter: Vastly improved AudioKit 2 to be a dynamic framework and many other improvements to the code.
* Syed Haris Ali: The author of EZAudio which is AudioKit's included waveform plotter and FFT analysis engine.
