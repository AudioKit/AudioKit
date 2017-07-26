//: ## MIDI Output
//: This playground is demonstrates using AudioKit to output MIDI to an external synth
import AudioKitPlaygrounds
import AudioKit

let midi = AKMIDI()

midi.openOutput()

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    var keyboard: AKKeyboardView!

    override func setup() {
        addTitle("MIDI Output")

        keyboard = AKKeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        addSubview(keyboard)

        addSubview(AKDynamicButton(title: "Go Polyphonic") {
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                return "Go Monophonic"
            } else {
                return "Go Polyphonic"
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
PlaygroundPage.current.liveView = PlaygroundView()
