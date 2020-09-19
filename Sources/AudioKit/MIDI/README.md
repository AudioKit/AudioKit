# AudioKit MIDI

This is an implementation of CoreMIDI meant to simplify creating and responding to MIDI signals. 

It was originally an Objective-C implementation that is now mostly in Swift.

We are planning to renovate this and release it as a separate module that AudioKit will have as an optional dependency.

You add MIDI listeners like this:
 ```
var midi = MIDI()
midi.openInput()
midi.addListener(someClass)
 ```
 ...where someClass conforms to the MIDIListener protocol

You then implement the methods you need from MIDIListener and use the data how you need.
