//: ## Oscillator Synth
//:
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

//: Choose the waveform shape here

let waveform = AKTable(.sawtooth) // .triangle, etc.

var oscillator = AKOscillator(waveform: waveform)

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.1
var currentRampDuration = 0.0

AudioKit.output = oscillator
try AudioKit.start()

let playgroundWidth = 500

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    override func viewDidLoad() {
        addTitle("Oscillator Synth")

        addView(AKSlider(property: "Amplitude",
                         value: oscillator.amplitude,
                         format: "%0.3f"
        ) { amplitude in
            currentAmplitude = amplitude
        })

        addView(AKSlider(property: "Ramp Duration",
                         value: oscillator.rampDuration,
                         format: "%0.3f s"
        ) { time in
            currentRampDuration = time
        })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60, height: 100, firstOctave: 3, octaveCount: 3)
        keyboard.delegate = self
        addView(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        currentMIDINote = note
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampDuration = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampDuration for volume
        oscillator.rampDuration = currentRampDuration
        oscillator.amplitude = currentAmplitude
        oscillator.play()
    }

    func noteOff(note: MIDINoteNumber) {
        if currentMIDINote == note {
            oscillator.amplitude = 0
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
