AudioKit
========

[![Build Status](https://travis-ci.org/audiokit/AudioKit.svg)](https://travis-ci.org/audiokit/AudioKit)
[![License](https://img.shields.io/cocoapods/l/AudioKit.svg?style=flat)](http://cocoadocs.org/docsets/AudioKit)

[AudioKit](http://audiokit.io/) is a powerful audio toolkit for synthesizing, processing, and analyzing sounds.  It contains several examples for iOS (iPhone & iPad) and Mac OSX, written in both Objective-C and in Swift.  A test suite is provided for many of the operations included in AudioKit.  A playground project can be used for trying out AudioKit instruments and for greatly speeding up the development of your own instruments and applications.

Apps Using AudioKit
------------------------
If you release an app that uses AudioKit, please feel free to add it to the list!

* [Guitar Score Trainer](https://itunes.apple.com/us/app/guitar-score-trainer-lite/id1008613919?mt=8&ign-mpt=uo%3D4)
* [Well Tempered](https://itunes.apple.com/us/app/well-tempered/id303514313?mt=8#)
* [VR TOEIC] (https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=975407337)

The "AudioKit" subfolder
------------------------
This folder contains the actual AudioKit toolkit classes.

* [Core Classes](http://audiokit.io/core-classes/) - the foundation of AudioKit, the manager, the orchestra, settings, and MIDI.
* [Instruments](http://audiokit.io/instruments/) - the instrument and instrument property classes.
* [Notes](http://audiokit.io/notes/) - the note and note property classes.
* [Operations](http://audiokit.io/operations/) - all of the synthesis and processing algorithms.
* [Parameters](http://audiokit.io/parameters/) - types of arguments that can be passed to operations.
* [Platforms](http://audiokit.io/platforms/) - audio engine and files specific to iOS, OSX, tvOS, and Swift.
* [Resources](http://audiokit.io/resources/) - default audio files including a good general MIDI Sound Font and the AudioKit.plist settings file.
* [Sequencing](http://audiokit.io/sequencing/) -  phrases of notes and sequences of events.
* [Tables](http://audiokit.io/tables/) - lookup tables for waveforms and other tabular data.
* [Utilities](http://audiokit.io/utilities/) - prebuilt instruments, waveform plotting classes, and UI elements.

Documentation
-------------
This folder contains information about automatically generating Xcode documentation from the AudioKit source.

For most users, the documentation you really want: installation instructions, tutorials, examples, and more can be found here: [http://audiokit.io/docs/](http://audiokit.io/docs/)

Examples
--------
Included with AudioKit are two examples (HelloWorld and AudioKitDemo) written in two languages (Objective-C and Swift) for two operating systems (iOS and OSX).  So, there are eight projects for each permutation.  The Hello World project is a great starting point and a walk-through is available [here](http://audiokit.io/examples/HelloWorld/).  In Hello World, only one file is used to create a sine oscillator playing at 440Hz.  The AudioKitDemo is quite a bit more complex, combining three apps into one to demonstrate audio synthesis, processing, and analysis techniques.  More info: [http://audiokit.io/examples/](http://audiokit.io/examples/)

Playgrounds
-----------
Here is where the main AudioKitPlayground project is kept, and from here you can run a shell script to start the playground from a set of template playgrounds. Playgrounds allow for rapid audio prototyping, giving you the ability to quickly hear the results of your work without recompiling after every change. Refer to the [README within the Playgrounds folder](https://github.com/audiokit/AudioKit/tree/master/Playgrounds) for more instructions. More info: [http://audiokit.io/playgrounds/](http://audiokit.io/playgrounds/)

Templates
---------
We have built Xcode templates for typical AudioKit classes: instrument, processor, and conductor.  Once installed, these templates will be available from within Xcode's new file wizard.  More info: [http://audiokit.io/templates/](http://audiokit.io/templates/)

Tests
-----
Numerous tests can be run utilizing the AudioKitTest project and the `build_all.sh` and `run.sh` shell scripts provided here.  More info: [http://audiokit.io/tests/](http://audiokit.io/tests/)
