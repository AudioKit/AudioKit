# Sporth AudioKit Operations

This extension to AudioKit allows for complex, interconnected DSP. 

## Installation in Xcode 13

You can AudioKit and any of the other AudioKit libraries using Collections

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://swiftpackageindex.com/AudioKit/collection.json` as the URL and click the "Load" button.
5. It will warn you that the collection is not signed, but it is fine, click "Add Unsigned Collection".
6. Now you can add any of the AudioKit Swift Packages you need and read about what they do, right from within Xcode.

## Targets

| Name            | Description                                 | Language      |
|-----------------|---------------------------------------------|---------------|
| SporthAudioKit  | API for creating Sporth-powered Audio Units | Swift         |
| CSporthAudioKit | Audio Unit for Operation DSP                | Objective-C++ |
| Sporth          | Stack-based DSP language                    | C             |

## Documentation

The Github [Wiki](https://github.com/AudioKit/SporthAudioKit/wiki) hosts the documentation for this project.

## Examples

See the [AudioKit Cookbook](https://github.com/AudioKit/Cookbook/) for complete examples.
