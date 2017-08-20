# AudioKit V3

Since version 3.0, AudioKit is now distributed as a universal dynamic framework with no further dependencies on all supported platforms. This makes it easy to integrate within your own projects.

AudioKit 3 now requires at least iOS 9.0, macOS 10.11 (El Capitan) or tvOS 9.0. The deployment target for your target needs to be set to at least one of these versions to link with AudioKit.

## Using the compiled framework in your projects

* Select the target in your Xcode project that will link with AudioKit.
* Drag and drop the `AudioKit.framework` bundle in the **Embedded Binaries** section of the **General** tab.
* If you didn't copy the framework to your project, go to the **Build Settings** tab and make sure that the **Framework Search Paths** options contains the path where the framework is located.
* For **Objective-C Projects**, make sure that the *Embedded Content Contains Swift Code* build setting is set to YES for your target. AudioKit is a Swift library that depends on the Swift runtime being available.

### Handling Bitcode on iOS and tvOS

If your project has Bitcode enabled (which is mandatory on tvOS and will soon be on iOS), then you need to add a new *Run Script* build phase to your target with the following script:

`"$BUILT_PRODUCTS_DIR/$FRAMEWORKS_FOLDER_PATH/AudioKit.framework/fix-framework.sh"`

Make sure this script is run **after** the existing *Embed Frameworks* build phase.

Calling this script is required for your App Store submissions to pass validation when using Bitcode. While optional for non-Bitcode submissions, you may still add this script as it will somewhat reduce the size of the framework embedded in your app.


## Alternative: compile the framework from source

This may be the preferred method if you need to debug code using AudioKit, as Xcode 7 is still notoriously bad at handling precompiled Swift frameworks in other projects.

You may obtain the source code archive directly from [GitHub](http://github.com/AudioKit/AudioKit), or you may also clone the official repository.

* Drag and drop the `AudioKit For {platform}.xcodeproj` file to your project in Xcode. The file is located within the `AudioKit/{platform}` subdirectory in the repository, where `{platform}` is one of **iOS**, **macOS** or **tvOS**.
* In the **General** tab, also add `AudioKit.framework` in **Embedded Binaries**.


## Building universal frameworks from scratch

If you are tinkering with AudioKit itself, you may also want to build a set of universal frameworks from source. We provide a script to do just that, which is how the actual binaries are produced for each new release of AudioKit.

Go to the `Frameworks` directory and run the `./build_framework.sh` script. You will need to have the Xcode command line tools installed. Optionally, install the `xcpretty` Ruby gem to prettify the ouput.

The built frameworks are dropped in the `Frameworks/AudioKit-{platform}` directory, where platform is one of iOS, tvOS or macOS.
