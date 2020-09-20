# AudioKit MIDI

This is an implementation of CoreMIDI meant to simplify creating and responding to MIDI signals. 

Add MIDI listeners like this:
 ```
var midi = MIDI()
midi.openInput()
midi.addListener(someClass)
 ```
 ...where `someClass` conforms to the `MIDIListener` protocol

You then implement the methods you need from `MIDIListener` and use the data how you need.
