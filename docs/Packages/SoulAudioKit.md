# Soul AudioKit

A basis for creating AudioKit nodes with the [SOUL Sound Language](https://soul.dev).

* [Diode Clipper](https://github.com/AudioKit/SoulAudioKit/wiki) - Clips a signal to a predefined limit, in a "soft" manner, using one of three methods.

## Github URL

[https://github.com/AudioKit/SoulAudioKit](https://github.com/AudioKit/SoulAudioKit)

## TODO

Make more nodes based on soul patches!

## Installation in Xcode 13

You can AudioKit and any of the other AudioKit libraries using Collections

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://swiftpackageindex.com/AudioKit/collection.json` as the URL and click the "Load" button.
5. It will warn you that the collection is not signed, but it is fine, click "Add Unsigned Collection".
6. Now you can add any of the AudioKit Swift Packages you need and read about what they do, right from within Xcode.

## Targets

| Name           | Description | Language      |
|----------------|-------------|---------------|
| SoulAudioKit   | API Layer   | Swift         |
| CSoulAudioKit  | DSP Layer   | Objective-C++ |
