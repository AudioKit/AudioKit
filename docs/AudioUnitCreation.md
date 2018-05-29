# Audio Unit creation with AudioKit

## Overview

Apple’s Core Audio system has undergone major changes since its introduction. One aspect of this is a complete rework of the Audio Unit infrastructure with version 3 audio units. While Apple published a good guide to Audio Unit creation for an earlier version of Audio Units, this guide has not at present been updated for version 3 Audio Units, and the original guide is not that helpful for creation of version 3 Audio Units. For example, previously Apple furnished base classes which one could inherit from in order to create Audio Units. In version 3, this approach is absent.

Instead, Apple provides a sample project which has a working version of a version 3 Audio Unit and an Audio Unit Host, on both iOS and OSX. While this is useful, there isn’t much accompanying documentation. Furthermore, the Audio Unit example doesn’t follow good software practice in that it does not demonstrate how to create an Audio Unit in such a way that the plumbing needed by all Audio Units can be reused via inheritance. Because of this, AudioKit tries to provide a framework to make Audio Unit creation less painful. This includes base classes both in Objective C and C++, as well as working Audio Units which use this infrastructure.

## Class Diagram

The diagram below shows a typical implementation of an AudioKit based Audio Unit. 

<a href="http://audiokit.io/images/AudioKit AU class diagram.svg"><img src="http://audiokit.io/images/AudioKit AU class diagram.svg?cache=no" width=100%></a>

## C++ classes

Both Swift and Objective C are unsuitable to run in the real time render thread, for various reasons not enumerated. Because of this, all code that needs to run on the render thread needs to be written in generic C or C++. These classes are described below.

### `AKDSPBase`

In order to take advantage of reuse via inheritance, a base class is provided which supports the operations expected of any DSP block by the Audio Unit classes which are written in Objective C and Swift.

### `MyDSP`

This C++ class contains the DSP code specific to this particular Audio Unit. It contains a specific processing method which the host calls from the render thread. It also contains functions to interpret any SetParameter or GetParameter calls which provide AUParameter access from sources outside the audio unit itself. Finally, if any direct access is needed to the DSP code which does not need to be exposed outside the AU itself, those access methods will also be found here. 

This class inherits from `AKDSPBase` and can override virtual methods provided by `AKDSPBase`.

## Objective C classes

An original wish for the design of this system of components was to minimize or completely eliminate Objective C code. Unfortunately, this is not possible for two reasons.

First, the interface to audio units specified by Apple is an Objective C interface, specifically the interface between the host code which calls the processing code on the render thread. Also the modification and changed notification of parameters published by the AU is done using KVO techniques. This code is inconvenient to implement in Swift (although it may be possible).

Second, and maybe more important, is that Swift does not support interoperability with C++. There are various techniques to address this, but arguably the simplest way to provide interoperability between Swift and C++ is via a shim layer written in Objective C.

The objective C classes are described below.

### `AKAudioUnitBase`

This class provides the functionality needed by any AU, as well as property access to the DSP which is expected from AudioKit Nodes. Importantly, it provides the render block which is called on the render thread.

### `MyObjcAU`

This class inherits from AKAudioUnitBase, and is not strictly necessary, as it is possible for a Swift object inherit directly from `AKAudioUnitBase`. However, it provides an interoperability layer between the Swift AU object and the underlying C++ DSP. There are all kinds of reasons why this is useful, including providing easy to use access to parameters in the C++ code which are not exposed outside the AU.

## Swift classes

### `MySwiftAU`

Aspects of AU functionality which are inconvenient to implement in the Objective C layer can be implemented in a Swift AU which inherits from either `MyObjcAU` or `AKAudioUnitBase`. An example of this is setting up the `AUParameterTree`, which is much more convenient to do from Swift. 

### `MyNode`

TBD

## Audio Unit Operation

Before an AU can be used, it must be registered. Alternatively, it can be accessed directly as an AKNode, which is what I describe here.

### Instantiation

First `MyNode` is instantiated, which results in an instantiation of `MySwiftAU`. 

`MySwiftAU` will typically calls the constructor of the superclass `MyObjcAU` from its constructor, which will in turn call its superclass `AKAudioUnitBase`.

Upon instantiation by its constructor `initWithComponentDescription`, `AKAudioUnitBase` will attempt to get a pointer to the underlying C++ by calling its method `initDSPWithSampleRate`. `MyObjAU` (or `MySwiftAU`) is expected to override this method so that it can create and return an instance of the C++ `MyDSP` “DSP Kernel”. 

The C++ DSP block is stored as a void pointer in `AKAudioUnitBase` because `AKAudionUnitBase` cannot know anything about the specifics of `MyDSP` or any other specialized C++ DSP code. We could use a pointer to `AKDSPBase` instead, but that would make it impossible for Swift to furnish this pointer.

### `allocateRenderResources` and `internalRenderBlock`

At some point after the instantiation of the AU, the host code will call `allocateRenderResources`, to ready the AU to process audio samples. The base class will do some error checking and preparation of the input and output busses, and then call the init and reset functions of `MyDSP`.

The final step is for the host to call the method `internalRenderBlock`. As its name implies, this method creates an objective C block (i.e. closure) which the host can subsequently call to process blocks of audio data and “events”.

At this point the AU and DSP are ready to rock and roll.

### Unfinished work

There is functionality that must be add to the base classes over time. The most important example of this is that we don’t really understand at present how to create AUs which have polymorphic input and output busses. That is, an AU with might for example support mono, stereo, and multichannel operation. This is fundamentally because the Apple documentation on how this is supposed to work is essentially non-existent. I undoubtedly leverages the fact that the input and output busses are KVO compliant, but this is about as much as we know. We will have to figure it out via experimentation


