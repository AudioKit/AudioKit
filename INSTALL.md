# Using the AudioKit static library in your project

## Common Steps
* Drag and drop the `AudioKit.xcodeproj` file inside your own project in Xcode.
* In your project settings in Xcode, go to the **Build Phases** tab for your target. 
	* Add a new **Target Dependency**. Pick either the iOS or OS X library under AudioKit.
	* Expand the **Link Binary With Libraries** section, and add the same library from the previous step.
	* Also add the **AVFoundation** system library.
* In the **Build Settings** tab for your target :
	* Look for the **Other Linker Flags** setting, and set it to `-ObjC`
	* Look for the **User Header Search Paths** setting, point it to the location of the `AudioKit` directory, make sure to set it to **recursive**.
* Drag and drop the `AudioKit.plist` file from the **Resources** group in the AudioKit project to your own project. You may want to make sure you have your own copy if you intend to change any of the settings in that file.

## Swift Projects
* From within the AudioKit subproject in your project, open the `AudioKit > Platforms > Swift` group, and drag and drop at least `AudioKit.swift` to your project. You may also add any of the extensions to your project if you'd like to use them.
* Add at least `AKFoundation.h` to your Swift briding header file. You may need to include some of the other header files you are using in your project if they are not covered by AKFoundation.

## OS X Projects
* From within the AudioKit subproject, open the `AudioKit > Platforms > OS X` group, then drag and drop the `CSoundLib64.framework` file to your own project.
* In your project settings, under the **Build Phases** tab, open the **Copy Files** section and add the same `CsoundLib64.framework`.

## Optional Steps
Some of the built-in instruments require the use of some sound files, grouped in the `AKSoundFiles.bundle` in the **Resources** group in AudioKit. You may drag this bundle to your own project to have them included.

