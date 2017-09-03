//: ## MIDI Output
//: This playground is demonstrates using AudioKit to output MIDI to an external synth
import AudioKitPlaygrounds
import AudioKit

let midi = AKMIDI()

midi.openOutput()

import AudioKitUI

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func viewDidLoad() {
        addTitle("MIDI Output")

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        addView(keyboard)

        addView(AKButton(title: "Go Polyphonic") { button in
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                button.title = "Go Monophonic"
            } else {
                button.title = "Go Polyphonic"
            }
        })
    }

    func noteOn(note: MIDINoteNumber) {
        midi.sendEvent(AKMIDIEvent(noteOn: note, velocity: 80, channel: 1))
    }

    func noteOff(note: MIDINoteNumber) {
        midi.sendEvent(AKMIDIEvent(noteOff: note, velocity: 0, channel: 1))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
