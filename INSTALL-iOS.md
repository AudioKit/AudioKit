# Using the AudioKit library in your iOS project
## Choose static libraries or dynamic frameworks
Starting with AudioKit 2.1, you have the option to link with the Csound and Sndfile libraries either statically (like in previous versions) or through the use of dynamic frameworks. AudioKit itself is now licensed under the liberal MIT license, allowing you to bundle it either statically or dynamically without restrictions. AudioKit also provides you with a set of precompiled, universal dynamic frameworks for the libraries it depends on.

The choice is important as both Csound and Sndfile are the basis upon which AudioKit is built and they are licensed [under the terms of the LGPL](http://opensource.org/licenses/LGPL-2.1), which means that your application's source code will need to be made freely available should you choose to link statically with them. In addition, dynamic frameworks can only be used starting with iOS 8.

In summary:

*  **Static Libraries**
	* Supports iOS 7 and above.
	* The application needs to comply with the LGPL licensing requirements by having its full source code freely available to the public.
* **Dynamic Frameworks**
	* iOS 8 is required to build and use the app.
	* No need to make the full application open-source, provided there are no further licensing restrictions; suitable for commercial and closed-source applications.

## Common Steps
* Drag and drop the `AudioKit.xcodeproj` file inside your own project in Xcode.
* In your project settings in Xcode, go to the **Build Phases** tab for your target.
	* Add a new **Target Dependency**. Pick either the iOS Static or Dynamic library under AudioKit.
	* Expand the **Link Binary With Libraries** section, and add the same library from the previous step (now with a ".a" extension).
* In the **Build Settings** tab for your target :
	* Look for the **Other Linker Flags** setting, and set it to `-ObjC`
	* Look for the **User Header Search Paths** setting, point it to the location of the `AudioKit` directory, make sure to set it to **recursive**.  If your project directory is parallel to the AudioKit repository, this path will be `../AudioKit/AudioKit`.

### Using the Static Libraries
No further steps needed, just make sure you are indeed linking with the `libAudioKit iOS Static.a` library.

Remember: *your entire application is now bound by the terms of the [GNU LGPL license](http://en.wikipedia.org/wiki/GNU_Lesser_General_Public_License)*.

### Using the Dynamic Frameworks

* Make sure your target **Deployment Target** is set to at least iOS 8.0.
* From within the AudioKit subproject, open the `AudioKit > Platforms > iOS > Dynamic Frameworks` group, then drag and drop the `CSoundLib.framework` and `libsndfile.framework` files to your own project.
* This will automatically add a "Framework Search Paths" entry for you, but it will be an absolute reference, so if you are sharing your projects with others, you should go to **Build Settings** Tab and add an entry relative to `$(SRCROOT)` that leads to `AudioKit/Platforms/iOS`.
* In your project settings, under the **General** tab, scroll down to the **Embedded Binaries** section and add the same `CsoundLib.framework` and `libsndfile.framework`. These frameworks should then also appear in the **Linked Frameworks and Libraries** just below.
* Add a new **Run Script** phase, of type `/bin/bash` that either calls the script at `AudioKit/Platforms/iOS/run-script.sh` (adjust for the location on your system), or copy its contents into the phase for your target.


## Swift Projects
* From within the AudioKit subproject in your project, open the `AudioKit > Platforms > Swift` group, and drag and drop `AudioKit.swift` to your project.
* Add `AKFoundation.h` to your Swift bridging header file.

## Optional Steps
Some of the built-in instruments require the use of some sound files, grouped in the `AKSoundFiles.bundle` in the **Resources** group in AudioKit. You may drag this bundle to your own project to have them included.

Similarly, you may want to drag and drop the `AudioKit.plist` file from the **Resources** group if you intend to change any of the settings in that file.
