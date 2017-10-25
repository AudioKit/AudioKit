# AudioKit iOS Projects

## AudioKit For iOS Xcode project

This project is used to build the AudioKit and AudioKitUI frameworks. It can also be used directly by dragging the .xcodeproj into your Xcode project and adding the two AudioKit frameworks as embedded binaries (under the "General" tab).

The AudioKit folder here contains code specific to iOS that would not work on the macOS platform.  Mostly these are UIKit based User Interface elements.

## AudioKit Test Suite

In addition to the AudioKit iOS Framework, we have a test suite that puts AudioKit through its paces on every build.  It is currently only implemented on iOS, so the Xcode project exists here. The tests are conceivably cross platform, so they exist in the Common folder.

