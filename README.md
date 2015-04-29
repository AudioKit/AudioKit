AudioKit
========

[![Build Status](https://travis-ci.org/audiokit/AudioKit.svg?branch=develop)](https://travis-ci.org/audiokit/AudioKit)

[AudioKit](http://audiokit.io/) is a powerful audio toolkit for synthesizing, processing, and analyzing sounds.  It contains several examples for iOS (iPhone & iPad) and Mac OSX, written in both Objective-C and in Swift.  A test suite is provided for many of the operations included in AudioKit.  A playground project can be used for trying out AudioKit instruments and for greatly speeding up the development of your own instruments and applications.

The "AudioKit" subfolder
------------------------
This folder contains the classes that you will need to copy or reference in your project by dragging this folder into Xcode. In addition to the audio classes, there is a Utilities folder that contains non-required, but helpful classes for binding user-interface elements to audio data, including plots of audio streams and related data.

Documentation
-------------
This folder contains information about automatically generating Xcode documentation from the AudioKit source.

For most users, the documentation you really want: installation instructions, tutorials, examples, and more can be found here: [http://audiokit.io/](http://audiokit.io/)

Examples
--------
Included with AudioKit are two examples (HelloWorld and AudioKitDemo) written in two languages (Objective-C and Swift) for two operating systems (iOS and OSX).  So, there are eight projects for each permutation.  The Hello World project is a great starting point and a walkthrough is available [here](http://audiokit.io/examples/HelloWorld/).  In Hello World, only one file is used to create a sine oscillator playing at 440Hz.  The AudioKitDemo is quite a big more complex, combining three apps into one to demostrate audio synthesis, processing, and analysis techniques.

Playgrounds
-----------
Here is where the main AudioKitPlayground project is kept and from here you can run a shell script to start the playground from a set of template playgrounds.  Refer to the README within this folder for more instructions.

Templates
---------
We have built Xcode templates for typical AudioKit classes: instrument, processor, and conductor.  Once installed, these templates will be available from within Xcode's new file wizard.

Tests
-----
Numerous tests can be run utilizing the AudioKitTest project and the `build_all.sh` and `run.sh` shell scripts provided here.
