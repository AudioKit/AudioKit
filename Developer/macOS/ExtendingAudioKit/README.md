# Extending AudioKit
The **ExtendingAudioKit** example project illustrates how you can write your own Audio Unit code in a way which is compatible with the AudioKit classes, in effect creating your own *extension* to the AudioKit framework.

The example also illustrates a few useful techniques for using MIDI to control a simple music synthesizer based on **AKOscillatorBank**, including a utility class to add pedal-sustain capability to **AKPolyphonicNode**-based instruments (like **AKOscillatorBank**) which don't already have it.

**This example is for macOS.** An iOS version is available under *AudioKit/Examples/iOS*

## The basic approach: AudioKit as a sub-project
Developing new AU extensions directly in the main **AudioKit** Xcode project means you can only test your code inside the *Developer Playground*. If you want to create a more realistic client application, you have to do a full rebuild of the **AudioKit** framework(s), which takes quite a long time.

In this example, we create an Xcode project which contains:

* The *AudioKit For macOS.xcodeproj* Xcode project (a sub-project inside the main project)
* The new extension code, and
* A full-fledged macOS application, for testing the new code together with established **AudioKit** modules.

Once your new code is working, if you wish, you can then add it to the **AudioKit** framework itself, and send us a pull request to share your creation with the **AudioKit** community.

The example project itself is already complete and working. If you are in a hurry, you can simply modify and re-compile it. The rest of this page provides step-by-step instructions for how to create similar projects of your own, starting from scratch.


## Creating your own AudioKit Extension project

You will need a copy of the **AudioKit** source code. If you think there is any chance you will want to contribute new code to AudioKit, the best approach is to fork the project on GitHub, then clone your own forked copy to your Mac.

In Xcode 9, create a new Cocoa App project. It will open to the Project page. Select the Capabilities tab, and turn OFF “App Sandbox” to ensure your app will have full access to audio functions on the Mac.

In the Mac Finder, locate the *AudioKit For macOS.xcodeproj* project and drag it into the your own Xcode project:

* In the leftmost pane, make sure the Project Navigator is showing
* Drag the AudioKit project file and drop it directly under the top line which represents your new project.

In the Xcode Project page, click on the General tab, and scroll to the Embedded Binaries section. Click the + button — a “Choose items to add” dialog will pop up, in which you’ll see two copies of both *AudioKit.framework* and *AudioKitUI.framework*. Choose both frameworks (which of the duplicate copies you choose may not matter; I always choose the ones nearest the bottom) and click Add.

At this point you should Build your project to make sure everything is OK. This will take quite some time, as the whole of AudioKit must be compiled, but this will only need to happen once.

Create a bridging header file for your project:

* In the Xcode Project Navigator, right-click your project icon, select Header, name your file as *[your project name]-Bridging-Header.h*, and save it into the same folder as your project file.
* The file will be created with the old #ifndef … #endif syntax. Replace with #pragma once.

Back in your project’s Build Settings, locate the Objective-C Bridging Header item (search for “bridging”). Set it to *$(SRCROOT)/[your project name]-Bridging-Header.h*.

Next locate the Header Search Paths item (search for “search”), and set it to point to the *AudioKit/AudioKit/Common/Internals/CoreAudio* folder:

* Double-click the Header Search Paths edit field; this brings up a large multi-line edit box
* In the Mac Finder, locate the CoreAudio folder in your cloned copy of the AudioKit source tree and drag it into the edit box
* Change the default “non-recursive” setting on the right to “recursive”

Create your own AudioKit module. A simple way to start is to copy one of the simpler **AudioKit** AU source folders to your own project folder (I used **AKBooster**), change all the file/folder names (I changed “AKBooster” to “SDBooster”), then drag the whole folder into your Xcode Project Navigator pane to add it to your project.

* Leave “Create groups” selected
* Make sure the “Add to targets” box shows your project name, and that it is selected

Edit all your renamed source files, changing all class names, etc. so they no longer conflict with names already defined in AudioKit.

Edit your Bridging Header file, and add an #include line for the …DSP.hpp file in your newly-edited AU code.

Now you should be able to build and run your project on the Mac.



