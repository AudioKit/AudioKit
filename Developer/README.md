# AudioKit Developer Resources

These are projects specifically designed for developers who are working on the 
internals of AudioKit and are not only using AudioKit's framework for personal projects.

Reasons you might want to use these projects include:

* To develop a new DSP algorithm for eventual inclusion in AudioKit
* To fix a bug in AudioKit
* To extend AudioKit's functionality 

## iOSDevelopment and macOSDevelopment

This project provides a small sample app that you can use to test code and/or access a development playground.

Use the iOS project if you need to target iOS on a real or simulated device. Use the macOS project if you need to target macOS or prefer the speed of working with your OS directly.

## Extending AudioKit (For both iOS and macOS)

An example of creating a node outside of AudioKit.

### Using the AudioKit Framework or Using AudioKit Source code directly

Inside the project folders for both OSes, you will find two xcodeproj files: one 
that has AudioKit included as a framework, and one that uses AudioKit's source code as a subproject.  
Using the AudioKit framework will give you fast compilation, but using AudioKit as a subproject will allow you to conveniently look into AudioKit's source code. Since you theoretically won't have to compile AudioKit more than once, 
you should use the xcodeproj file that uses AudioKit as a subproject. If you find that Xcode
needs to compile AudioKit all the time, you may want to use the AudioKit framework. You can
always look at AudioKit's source code on Github or in an editor.
