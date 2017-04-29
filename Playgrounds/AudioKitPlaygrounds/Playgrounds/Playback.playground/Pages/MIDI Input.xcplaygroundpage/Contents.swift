//: ## MIDI Input
//: This playground is kind of a basic MIDI Monitor. Make sure you've got the console view open, and then start pounding on the MIDI devices you have hooked up to your computer and you should see output.
import AudioKitPlaygrounds
import AudioKit

let midi = AKMIDI()

//: The input names list all of the MIDI devices currently hooked up
midi.inputNames
//: By opening up MIDI Input without specifying a particular port, we open up all ports.
midi.openInput()

//: By defining a class that is a MIDI Listener, but with no functions overridden, we just get the default behavior which is to print to the console.
class PlaygroundMIDIReceiver: AKMIDIListener {
}

let receiver = PlaygroundMIDIReceiver()

//: Add the new class to the list of MIDI listeners
midi.addListener(receiver)

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
