# Using the AudioKit library in your tvOS project
The tvOS version of AudioKit is very similar to the iOS version. Because this system is much more recent and is always able to use dynamic frameworks, we do not provide static libraries for tvOS.

## Setting up your project
* Drag and drop the `AudioKit.xcodeproj` file inside your own project in Xcode.
* In your project settings in Xcode, go to the **Build Phases** tab for your target.
	* Add a new **Target Dependency**. Pick the `AudioKit tvOS` library under AudioKit.
	* Expand the **Link Binary With Libraries** section, and add the `libAudioKit tvOS.a` library.
* In the **Build Settings** tab for your target :
	* Look for the **Other Linker Flags** setting, and set it to `-ObjC`
	* Look for the **User Header Search Paths** setting, point it to the location of the `AudioKit` directory, make sure to set it to **recursive**.  If your project directory is parallel to the AudioKit repository, this path will be `../AudioKit/AudioKit`.
* From within the AudioKit subproject, open the `AudioKit > Platforms > tvOS` group, then drag and drop the `CSoundLib.framework` and `libsndfile.framework` files to your own project.
* This will automatically add a "Framework Search Paths" entry for you, but it will be an absolute reference, so if you are sharing your projects with others, you should go to **Build Settings** Tab and add an entry relative to `$(SRCROOT)` that leads to `AudioKit/Platforms/tvOS`.
* In your project settings, under the **General** tab, scroll down to the **Embedded Binaries** section and add the same `CsoundLib.framework` and `libsndfile.framework`. These frameworks should then also appear in the **Linked Frameworks and Libraries** just below.
* Add a new **Run Script** phase, of type `/bin/bash` that either calls the script at `AudioKit/Platforms/tvOS/run-script.sh` (adjust for the location on your system), or copy its contents into the phase for your target.


## Swift Projects
* From within the AudioKit subproject in your project, open the `AudioKit > Platforms > Swift` group, and drag and drop `AudioKit.swift` to your project.
* Add `AKFoundation.h` to your Swift bridging header file.

## Optional Steps
Some of the built-in instruments require the use of some sound files, grouped in the `AKSoundFiles.bundle` in the **Resources** group in AudioKit. You may drag this bundle to your own project to have them included.

Similarly, you may want to drag and drop the `AudioKit.plist` file from the **Resources** group if you intend to change any of the settings in that file.
