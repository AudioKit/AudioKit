# AudioKit Developer Resources

These are projects specifically designed for people who are working on the 
internals of AudioKit, not just using the AudioKit framework for their own project.

Reasons you might want to use these projects include:

* Developing a new DSP algorithm for eventual inclusion in AudioKit
* Fixing a bug in AudioKit
* Extending some AudioKit functionality 

## iOSDevelopment and macOSDevelopment

This project provides a small sample app to test code in as well as providing access to a development playground.

Use the iOS project if you need to target iOS either on a real device or a simulated one. Or use the macOS project if you need to target macOS or just prefer the speed of working directly with your OS.

## Extending AudioKit (For both iOS and macOS)

An example of creating a node outside of AudioKit.

### Using the AudioKit Framework or Using AudioKit Source code directly

Inside the project folders for both OSes you will find two xcodeproj files, one 
that has AudioKit included as a framework, and the other has AudioKit as source
code in the form a subproject.  Using the framework will give you fast compilation 
times, but using the source code will allow you to easily look into AudioKit for 
examples. Since you theoretically won't have to compile AudioKit more than once, 
you probably should use the version as subproject, but if you find that Xcode
needs to compile AudioKit all the time, the framework might be better, and you can
always look at the source on Github or another editor.
