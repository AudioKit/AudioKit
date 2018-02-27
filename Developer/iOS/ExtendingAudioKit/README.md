# Extending AudioKit
The **ExtendingAudioKit** example projects illustrate how you can write your own Audio Unit code in a way which is compatible with the AudioKit classes, in effect creating your own *extension* to the AudioKit framework, in the context of a full AudioKit *application* for testing your new code.

The example also illustrates a few useful techniques for using MIDI to control a simple music synthesizer based on **AKOscillatorBank**, including a utility class to add pedal-sustain capability to **AKPolyphonicNode**-based instruments (like **AKOscillatorBank**) which don't already have it.

**This example is for iOS.** A macOS version is available under *AudioKit/Developer/macOS/ExtendingAudioKit*.

## The basic approach
In this example, we create an Xcode project which contains:

* The AudioKit frameworks, either the pre-compiled versions, or the entire *AudioKit For macOS.xcodeproj* Xcode project (a sub-project inside the main project)
* The new extension code, and
* A full-fledged macOS application, for testing the new code together with established **AudioKit** modules.

Once your new code is working, if you wish, you can then add it to the **AudioKit** framework itself, and send us a pull request to share your creation with the **AudioKit** community.

Two Xcode example projects are provided here, which differ only in how the AudioKit framework code is accessed.

1. In *ExtendingAudioKitUsingFramework.xcodeproj*, the pre-compiled frameworks are used.
2. In *ExtendingAudioKitUsingSource.xcodeproj*, the entire 

The example projects are already complete and working. If you are in a hurry, you can simply modify one of them and re-compile. The rest of this page provides step-by-step instructions for how to create similar projects of your own, starting from scratch.

Even if you only plan to use the pre-compiled AudioKit frameworks, you will need a copy of the **AudioKit** source code, because your new code will need to refer to header files which aren't in the pre-compiled frameworks. If you think there is any chance you will want to contribute new code to AudioKit, the best approach is to fork the project on GitHub, then clone your own forked copy to your Mac.

### Using the AudioKit source vs. frameworks
Using the pre-compiled AudioKit frameworks has the advantage that your project will compile fairly quickly. However, when developing new audio-units, you will often want to dive into the AudioKit source code, to understand base classes, *enum* definitions, etc. Bringing the whole of AudioKit as a sub-project into your own project will allow you to right-click on any AudioKit class name in Xcode and choose "Jump to Definition". The cost for this is that your project will take much longer to compile the first time (only the first time), because you actually have to compile the whole of AudioKit.

### Create your project
In Xcode 9, create a new Cocoa App project. It will open to the Project page. Select the Capabilities tab, and turn OFF “App Sandbox” to ensure your app will have full access to audio functions on the Mac.

### Option 1: Add AudioKit pre-compiled frameworks
In the Xcode Project page, click on the General tab, and scroll to the Linked Frameworks and Libraries section. Click the **+** button — a “Choose frameworks and libraries to add” dialog will pop up. Click on **Add Other...** to replace it with a standard file-open dialog. Navigate to wherever your copies of the macOS *AudioKit* and *AudioKitUI* frameworks are (if you have copmiled them within your copy of the AudioKit source, you'll find them in the *AudioKit/Frameworks/AudioKit-iOS* folder). Select both *AudioKit.framework* and *AudioKitUI.framework* and click **Open**.

Just adding the frameworks isn't quite enough; you also need to add the containing folder to your project's Framework Search Paths, because Xcode does not do this automatically. Go to your project's Build Settings and enter "search" in the search box at the top. Find the entry for "Framework Search Paths". The simplest way to fill this in is to locate the folder you want in the Mac Finder, and drag it into this field.

At this point you should build your project to make sure everything is OK. This should happen quite quickly.

### Option 2: Add AudioKit as a sub-project

In the Mac Finder, locate the *AudioKit For iOS.xcodeproj* project and drag it into the your own Xcode project:

* In the leftmost pane, make sure the Project Navigator is showing
* Drag the AudioKit project file and drop it directly under the top line which represents your new project.

In the Xcode Project page, click on the General tab, and scroll to the Linked Frameworks and Libraries section. Click the + button — a “Choose frameworks and libraries to add” dialog will pop up, in which you’ll see *AudioKit.framework* and *AudioKitUI.framework*, right at the top under "Workspace". Select both frameworks and click Add.

At this point you should Build your project to make sure everything is OK. This will take quite some time, as the whole of AudioKit must be compiled, but this will only need to happen once.

### Create a bridging header file for your project:

* In the Xcode Project Navigator, right-click your project icon and choose "New File...", select Header File, name your file as *[your project name]-Bridging-Header.h*, and save it into the same folder as your project file.
* The file will be created with the old #ifndef … #endif syntax. Replace with #pragma once.

Back in your project’s Build Settings, locate the Objective-C Bridging Header item (search for “bridging”). Set it to *$(SRCROOT)/[your project name]-Bridging-Header.h*.

### Prepare to use AudioKit core header files
Before you can build your own extensions to AudioKit, you need to ensure that your Xcode project can make use of some of AudioKit's core header files.

Locate the Header Search Paths item (search for “search”), and set it to point to the *AudioKit/AudioKit/Common/Internals/CoreAudio* folder:

* Double-click the Header Search Paths edit field; this brings up a large multi-line edit box
* In the Mac Finder, locate the CoreAudio folder in your cloned copy of the AudioKit source tree and drag it into the edit box
* Change the default “non-recursive” setting on the right to “recursive”

### Create your own AudioKit module

A simple way to start is to copy one of the simpler **AudioKit** AU source folders to your own project folder (I used **AKBooster**), change all the file/folder names (I changed “AKBooster” to “SDBooster”), then drag the whole folder into your Xcode Project Navigator pane to add it to your project.

* Leave “Create groups” selected
* Make sure the “Add to targets” box shows your project name, and that it is selected

Edit all your renamed source files, changing all class names, etc. so they no longer conflict with names already defined in AudioKit.

Edit your Bridging Header file, and add an #include line for the …DSP.hpp file in your newly-edited AU code.

Now you should be able to build and run your project on the iOS simulator.

## Using MIDI
To play sound polyphonically using an external MIDI keyboard, you have to run on an actual iPhone or iPad, not the iOS simulator. This requires that you have a Developer account with Apple, in order to be able to sign your app. You must also make three changes to your app:

1. In the Xcode project page, Capabilities tab, turn on Background Modes, and check the box for "Audio, AirPlay, and Picture in Picture". This is necessary to allow MIDI to work.
2. In General tab, under "Signing", check "Automatically manage signing" and select your Team from the pop-up. It's a good idea to also set the "Deployment Target" to 10.0, as Xcode will default that setting to the very latest iOS version.
3. Choose your iOS device as the product Destination, build and run.

You'll need an iOS USB adapter such as the [Apple Lightning to USB Camera Adapter](https://www.apple.com/shop/product/MD821AM/A/lightning-to-usb-camera-adapter) to connect a "class-compliant" MIDI controller. (Most recent USB MIDI keyboards are class-compliant, meaning they work with standard drivers embedded in iOS and other operating systems.)

