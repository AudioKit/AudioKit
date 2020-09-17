# Sampler Audio Unit and Node

Implementation of the **Sampler** Swift class, which is built on top of the similarly-named C++ Core class.

There are *four distinct layers of code* here, as follows.

## SamplerDSP
**SamplerDSP** is a C++ class which inherits from the Core *Sampler* as well as **DSPBase**, one of the primary AudioKit base classes for DSP code.

The implementation resides in a `.mm` file rather than a `.cpp` file, because it also contains several Objective-C accessor functions which facilitate bridging between Swift code above and C++ code below.

Hence there are *two separate code layers* here: the **SamplerDSP** class below and the Objective-C accessor functions above.

## SamplerAudioUnit
The Swift **SamplerAudioUnit** class is the next level above the **Sampler** class and its Objective-C accessor functions. It wraps the DSP code within a *version-3 Audio Unit* object which exposes several dynamic *parameters* and can be connected to other Audio Unit objects to process the audio stream it generates.

## Sampler and extensions
The highest level **Sampler** Swift class wraps the Audio Unit code within an AudioKit **Node** object, which facilitates easy interconnection with other AudioKit nodes, and exposes the underlying Audio Unit parameters as Swift *properties*.

The **Sampler** class also includes utility functions to assist with loading sample data into the underlying C++ `Sampler` object (using **AVAudioFile**).

Additional utility functions are implemented in separate files as Swift *extensions*. `Sampler+SFZ.swift` adds a rudimentary facility to load whole sets of samples by interpreting a [SFZ file](https://en.wikipedia.org/wiki/SFZ_(file_format)).
