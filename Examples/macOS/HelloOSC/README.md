# HelloOSC / OSCSender

This project illustrates how to use the [Open Sound Control](https://en.wikipedia.org/wiki/Open_Sound_Control) (OSC) networking protocol with AudioKit, using Devin Roth's [SwiftOSC](https://github.com/devinroth/SwiftOSC) framework. It's not necessary to build the SwiftOSC framework from source; we use [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) instead. You'll need to open a terminal window and type `pod install`, then open the newly-created *HelloOSC.xcworkspace* file in Xcode (NOT the *.xcodeproj* file).

There are two macOS targets in this project. **HelloOSC** is derived from the AudioKit *HelloWorld* example. It plays two simultaneous sine tones whose frequencies are individually adjustable between 220 Hz and 880 Hz. Unlike the *HelloWorld* example, it has no GUI controls. **OSCSender** is a simple Cocoa app (not an AudioKit app) which provides a "remote GUI" for **HelloOSC**.

To test, build both targets and run both simultaneously. Click the *Play/Stop* button in **OSCSender**, and **HelloOSC** should start to produce sound. Adjust the sliders to change the oscillator frequencies.

## Bonus: using TouchOSC
[TouchOSC](https://hexler.net/software/touchosc) is a wonderful software system which makes it easy to create OSC control-panels (called *layouts*) on an iOS or Android device. The file *HelloOSC.touchosc* included here is a custom layout which works with **HelloOSC**, giving you two touch-activated sliders which you can operate at the same time, to control **HelloOSC** wirelessly from the screen of e.g. an iPhone. You'll need to know the IP address of the Mac you're running HelloOSC on; look in *System Preferences > Network*.
