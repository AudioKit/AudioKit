<div align=center>
<img src="https://github.com/AudioKit/Cookbook/raw/main/Cookbook/Cookbook/Assets.xcassets/audiokit-icon.imageset/audiokit-icon.png" width="20%"/>
  
# AudioKit
  
[![Build Status](https://github.com/AudioKit/AudioKit/workflows/CI/badge.svg)](https://github.com/AudioKit/AudioKit/actions?query=workflow%3ACI)
[![License](https://img.shields.io/cocoapods/l/AudioKit)](https://github.com/AudioKit/AudioKit/blob/main/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/AudioKit)](https://github.com/AudioKit/AudioKit/wiki)
[![Reviewed by Hound](https://img.shields.io/badge/Reviewed_by-Hound-8E64B0.svg)](https://houndci.com)
[![Twitter Follow](https://img.shields.io/twitter/follow/AudioKitPro.svg?style=social)](https://twitter.com/AudioKitPro)

</div>

AudioKit is an audio synthesis, processing, and analysis platform for iOS, macOS (including Catalyst), and tvOS.

## Installation

### In Xcode 13:

You can add AudioKit and any of the other AudioKit libraries using Collections

1. Select File -> Add Packages...
2. Click the `+` icon on the bottom left of the Collections sidebar on the left.
3. Choose `Add Swift Package Collection` from the pop-up menu.
4. In the `Add Package Collection` dialog box, enter `https://swiftpackageindex.com/AudioKit/collection.json` as the URL and click the "Load" button.
5. It will warn you that the collection is not signed, but it is fine, click "Add Unsigned Collection".
6. Now you can add any of the AudioKit Swift Packages you need and read about what they do, right from within Xcode.

### In Xcode 11 & 12:

To add AudioKit to your Xcode project

1. Select File -> Swift Packages -> Add Package Dependency.
2. Enter `https://github.com/AudioKit/AudioKit` for the URL.  You can define which version range you want, or which branch to use, or even which exact commit you would like use. 

## Documentation

You can generate the documentation in XCode13+ by pulling down the Product menu and choosing "Build Documentation". It also appears on the [AudioKit.io Web Site](https://audiokit.io/) and the [Github wiki](https://github.com/AudioKit/AudioKit/wiki).

## Examples

The [AudioKit Cookbook](https://github.com/AudioKit/Cookbook) contains many recipes for simple uses for AudioKit components.

## Getting help

1. Post your problem to [StackOverflow with the #AudioKit hashtag](https://stackoverflow.com/questions/tagged/audiokit).

2. Once you are sure the problem is not in your implementation, but in AudioKit itself, you can open a [Github Issue](https://github.com/audiokit/AudioKit/issues).

3. If you, your team or your company is using AudioKit, please consider [sponsoring Aure on Github Sponsors](https://github.com/sponsors/aure).
