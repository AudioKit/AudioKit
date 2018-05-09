//: ## Oscillator
//: This oscillator can be loaded with a wavetable of your own design,
//: or with one of the defaults.
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let square = AKTable(.square, count: 256)
let triangle = AKTable(.triangle, count: 256)
let sine = AKTable(.sine, count: 256)
let sawtooth = AKTable(.sawtooth, count: 256)

//: Try changing the table to triangle, square, sine, or sawtooth.
//: This will change the shape of the oscillator's waveform.
var oscillator = AKOscillator(waveform: square)
AudioKit.output = oscillator
try AudioKit.start()

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.2
var currentRampDuration = 0.05
oscillator.rampDuration = currentRampDuration
oscillator.amplitude = currentAmplitude

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    override func viewDidLoad() {

        addTitle("General Purpose Oscillator")

        addView(AKSlider(property: "Amplitude", value: currentAmplitude) { amplitude in
            currentAmplitude = amplitude
        })

        addView(AKSlider(property: "Ramp Duration", value: currentRampDuration) { time in
            currentRampDuration = time
        })

        let keyboard = AKKeyboardView(width: 440,
                                      height: 100,
                                      firstOctave: 4,
                                      octaveCount: 4)
        keyboard.delegate = self
        addView(keyboard)
        addView(AKOutputWaveformPlot.createView())
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
        if note == currentMIDINote {
            oscillator.amplitude = 0
        }
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
