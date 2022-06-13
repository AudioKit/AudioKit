# Devoloop AudioKit Guitar Processors

While all of AudioKit's effects and filters can be useful for processing guitar,
this package contains AudioKit nodes that are distinctly guitaristic in their intent.

* [DynaRage Tube Compressor](https://github.com/AudioKit/DevoloopAudioKit/wiki/DynaRageCompressor) - based on DynaRage Tube Compressor RE for Reason by Mike Gazzarusso.
* [Rhino Guitar Processor](https://github.com/AudioKit/DevoloopAudioKit/wiki/RhinoGuitarProcessor) - Guitar amplifier head and cabinet simulator by Mike Gazzaruso.

<img src="https://github.com/AudioKit/DevoloopAudioKit/blob/develop/images/dynarage.jpg?raw=true" width="100%">

## Github URL

[https://github.com/AudioKit/DevoloopAudioKit](https://github.com/AudioKit/DevoloopAudioKit)

## Installation in Xcode 13

You can AudioKit and any of the other AudioKit libraries using Collections

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://swiftpackageindex.com/AudioKit/collection.json` as the URL and click the "Load" button.
5. It will warn you that the collection is not signed, but it is fine, click "Add Unsigned Collection".
6. Now you can add any of the AudioKit Swift Packages you need and read about what they do, right from within Xcode.


## Targets

| Name              | Description                     | Language      |
|-------------------|---------------------------------|---------------|
| DevoloopAudioKit  | Wrappers for Guitar Effects     | Swift         |
| CDevoloopAudioKit | Digital Signal Processing Layer | Objective-C++ |

<iframe width="560" height="315" src="https://www.youtube.com/embed/Q2Sn5wYylwI" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
