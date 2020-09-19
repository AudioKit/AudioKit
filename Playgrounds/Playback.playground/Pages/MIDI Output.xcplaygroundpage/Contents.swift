//: ## MIDI Output
//: This playground is demonstrates using AudioKit to output MIDI to an external synth

import AudioKit

let midi = MIDI()

midi.openOutput()


class LiveView: View, KeyboardDelegate {

    var keyboard: KeyboardView!

    override func viewDidLoad() {
        addTitle("MIDI Output")

        keyboard = KeyboardView(width: 440, height: 100)
        keyboard.delegate = self
        addView(keyboard)

        addView(Button(title: "Go Polyphonic") { button in
            self.keyboard.polyphonicMode = !self.keyboard.polyphonicMode
            if self.keyboard.polyphonicMode {
                button.title = "Go Monophonic"
            } else {
                button.title = "Go Polyphonic"
            }
        })
    }

    func noteOn(note: MIDINoteNumber) {
        midi.sendEvent(MIDIEvent(noteOn: note, velocity: 80, channel: 1))
    }

    func noteOff(note: MIDINoteNumber) {
        midi.sendEvent(MIDIEvent(noteOff: note, velocity: 0, channel: 1))
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
