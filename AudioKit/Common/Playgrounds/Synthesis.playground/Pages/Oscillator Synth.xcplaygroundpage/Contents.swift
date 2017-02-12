//: ## Oscillator Synth
//:

import AudioKit

//: Choose the waveform shape here

let waveform = AKTable(.sawtooth) // .triangle, etc.

var oscillator = AKOscillator(waveform: waveform)

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Oscillator Synth")

        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: oscillator.amplitude,
            color: AKColor.purple
        ) { amplitude in
            currentAmplitude = amplitude
            })

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: oscillator.rampTime, maximum: 1,
            color: AKColor.orange
        ) { time in
            currentRampTime = time
            })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60,
                                height: 100, firstOctave: 3, octaveCount: 3)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
        currentMIDINote = note
        // start from the correct note if amplitude is zero
        if oscillator.amplitude == 0 {
            oscillator.rampTime = 0
        }
        oscillator.frequency = note.midiNoteToFrequency()

        // Still use rampTime for volume
        oscillator.rampTime = currentRampTime
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
PlaygroundPage.current.liveView = PlaygroundView()
