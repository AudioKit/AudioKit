# AudioKit SenderSynth 

![Sender Synth](http://audiokit.io/audiobus/sender-synth/sender-synth.png)

Starting the Synth Project
--------------------------

We're going to build this from scratch, so in order to not spend much time with UI issues, we are going to make use of AudioKit's built-in UI elements that are normally used in playgrounds and our example apps.

From within Xcode, create a new project with the single view application template.  Give it a product name of "SenderSynth" (no spaces) and make it a Universal Swift application as shown below:

![Project Start](http://audiokit.io/audiobus/sender-synth/project-start.png)

Since Audiobus is most easily installed uing Cocoapods, we could use Cocoapods to install AudioKit, and eventually this tutorial will be updated as such, but for now, add AudioKit's iOS project from the develop branch as a subproject.

Set Up the Synth (easy!)
------------------------

Inside the ViewController.swift, first import AudioKit:

```
import AudioKit
```

Create the oscillator by adding it as an instance variable,

```
class ViewController: UIViewController {

    let oscillator = AKOscillatorBank()
```

and then use oscillator as AudioKit's output and start things up:

```
    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = oscillator
        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
```

User Interface
--------------

This tutorial will not use storyboards because they require too much mouse activity to describe, so instead we'll build the UI programmatically.

Next, build the views:

```
    override func viewDidLoad() {
        super.viewDidLoad()

        AudioKit.output = oscillator
        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }

        setupUI()
    }

    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let adsrView = AKADSRView()
        stackView.addArrangedSubview(adsrView)

        let keyboardView = AKKeyboardView()

        stackView.addArrangedSubview(keyboardView)

        view.addSubview(stackView)

        stackView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: view.frame.height).isActive = true

        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
```

While this may seem like a lot of code, its a lot more reliable than describing how to do this with storyboards.

The last step is to hook up controls.  For the keyboard, make the view controller conform to the AKKeyboardDelegate protocol:

```
class ViewController: UIViewController, AKKeyboardDelegate {
```
and add these functions:

```
    func noteOn(note: MIDINoteNumber) {
        oscillator.play(noteNumber: note, velocity: 80)
    }

    func noteOff(note: MIDINoteNumber) {
        oscillator.stop(noteNumber: note)
    }
```

and make the view controller the delegate for the keyboard inside viewDidLoad, right after the instantiation:

```
let keyboardView = AKKeyboardView()
keyboardView.delegate = self
```

If you run your app now, it will respond to the keys, but the ADSR envelope won't do anything.  Replace the ADSR creation step with this one defining a code block:

```
        let adsrView = AKADSRView() { att, dec, sus, rel in
            self.oscillator.attackDuration = att
            self.oscillator.decayDuration = dec
            self.oscillator.sustainLevel = sus
            self.oscillator.releaseDuration = rel
        }
```

Now you're really done with all the AudioKit stuff.  From here, it's all inter-app audio.

Installing Audiobus
-------------------

You will need Cocoapods to do this step.  Close the project you created and open up a terminal and go to the projects folder and type:

> pod init

Add a pod 'Audiobus' line to the Podfile that was just created in this folder:

```
    # Uncomment the next line to define a global platform for your project
    # platform :ios, '9.0'

    target 'SenderSynth' do
      # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
      use_frameworks!

      # Pods for SenderSynth
      pod 'Audiobus'
    end
```

Back on the commandline,
```
> pod install
```

This should work as follows:

```
    Analyzing dependencies
    Downloading dependencies
    Installing Audiobus (2.3.1)
    Generating Pods project
    Integrating client project
```

It may also produce some warning messages which can be ignored for now.  There are alternative installation instructions on the Audiobus integration page if you do not want to use Cocoapods.

From now on, we will be working with the SenderSynth.xcworkspace file instead of the project file, so open that in Xcode now.

Add the Audiobus Files
----------------------

Since Audiobus is not a Swift framework, we need to import the Audiobus header into a bridging header.  There are a few ways to create a bridging header, but the way I recommend is to go to your app's target Build Settings tab and search for "Bridging".  All of the settings will be filtered and you'll be left with one remaining "Objective-C Bridging Header" setting in which you can paste "$(SRCROOT)/SenderSynth/SenderSynth-BridgingHeader.h" so that it looks like the following screenshot.

![Bridging Header](http://audiokit.io/audiobus/sender-synth/bridging-header.png)

Then create a new file, of type "Header File", name it "SenderSynth-BridgingHeader.h" and add the import line so that it looks like:

```
#ifndef SenderSynth_BridgingHeader_h
#define SenderSynth_BridgingHeader_h

#import "Audiobus.h"

#endif /* SenderSynth_BridgingHeader_h */
```

Next grab the [Audiobus.swift](https://github.com/audiokit/AudioKit/blob/master/AudioKit/iOS/Audiobus/Audiobus.swift) file from the AudioKit repository and place it in your project, creating a copy.

Back in your ViewController.swift file:

```
        AudioKit.output = oscillator
        do {
            try AudioKit.start()         
        } catch {
            AKLog("AudioKit did not start!")
        }
        Audiobus.start()
```

Project Settings
----------------

You need to enable background audio and inter-app audio.  Follow these steps to do so:

1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's Project Navigator, and selecting your app from under the "TARGETS" heading.

2. Select the "Capabilities" tab.

3. Underneath the "Background Modes" section, make sure you have "Audio, AirPlay, and Picture in Picture" ticked.

4. To the right of the "Inter-App Audio" title, turn the switch to the "ON" position – this will cause Xcode to update your App ID with Apple's "Certificates, Identifiers & Profiles" portal, and create or update an Entitlements file.

Next, set up a launch URL:

1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's Project Navigator, and selecting your app from under the "TARGETS" heading.

2. Select the "Info" tab.

3. Open the "URL types" group at the bottom.

4. Click the "Add" button at the bottom left. Then enter this identifier for the URL: io.audiokit.sendersynth

5. Enter the new Audiobus URL scheme for your app, generally the name of the app, a dash, and then a version number: "SenderSynth-1.0.audiobus".

Of course when you do all this for a new app, you'll need to have your new app's name in these fields.

Here is one step that is not documented on the Audiobus web site:

1. Give your app a bundle name.  In the Info tab, you might see grayed out default text in the Identity section's display name field.  Go ahead and type or re-type the app's name.  Here I just added a space to call the app "Sender Synth".

More Project Settings (for Sender apps)
--------------------------------------

Create your sender port by following these steps:

1. Open your app target screen within Xcode by selecting your project entry at the top of Xcode's Project Navigator, and selecting your app from under the "TARGETS" heading.

2. Select the "Info" tab.

3. If you don't already have an "AudioComponents" group, then under the "Custom iOS Target Properties" group, right-click and select "Add Row", then name it "AudioComponents". Set the type to "Array" in the second column.

4. Open up the "AudioComponents" group by clicking on the disclosure triangle, then right-click on "AudioComponents" and select "Add Row". Set the type of the row in the second column to "Dictionary". Now make sure the new row is selected, and open up the new group using its disclosure triangle.

5. Create five different new rows, by pressing Enter to create a new row and editing its properties:

6. "manufacturer" (of type String): This is a four letter code that you should make up for yourself.  For us at AudioKit, we use "AuKt", but you will need to have your own.

7. "type" (of type String): set this to "aurg", which means a "Remote Generator" unit.

8. "subtype" (of type String): set this to "sndx", which just means "Sender Example".

9. "name" (of type String): set this to "AudioKit: Sender"

10. "version" (of type Number): set this to an integer. "1" is a good place to start.

In the end your Info.plist should now have the following:

![AudioComponents in Info.plist](http://audiokit.io/audiobus/sender-synth/audiocomponents.png)


Audiobus and Registration
-------------------------

Perhaps it goes without saying, but you need to have the Audiobus application installed on your device.  Next, you'll need create a user at developer.audiob.us.  Next, back in Xcode, build the SenderSynth project and right click on the app in the Products directory, and "Show in Finder".  In the Finder, right click on the app and "Show Package Contents".  Using a web browser, go to the Audiobus [Temporary Registration](https://developer.audiob.us/temporary-registration) and drag the Info.plist file from this directory into the web page.

Complete the temporary registration by choosing the SDK version you're using, adding an icon to the sender port, and adding a title as shown:

![Temporary Registration](http://audiokit.io/audiobus/sender-synth/temporary-registration.png)


You will be given an API Key that will be good for 14 days.  Copy the text of the key and create a new document of type "Other / Empty" and call it "Audiobus.txt".  Paste the API Key in that file.

You should also click the "email this to me" link on the Audiobus registration page so that you can open up the email on your device and tap the link to add an entry to your local Audiobus app for the Sender Synth.

When you're ready to submit to the App Store and you have and App Store ID, make sure you get a new, permanent registration with Audiobus.

Build the app to your device
----------------------------

This is pretty straightforward, but you do need to make sure to give your app app icons.

![App Icons](http://audiokit.io/audiobus/sender-synth/app-icons.png)

Conclusion (for Sender Apps)
----------------------------
There, that wasn't so hard was it?  The next example is a Filter Effects app.  I recommend that you work through that as well, even if you're not going to build an effects/filter app, just to solidify some of the concepts.
