//: ## Oscillator
//: This oscillator can be loaded with a wavetable of your own design,
//: or with one of the defaults.
import PlaygroundSupport
import AudioKit

let square = AKTable(.square, count: 16)
for value in square { value } // Click the eye icon ->

let triangle = AKTable(.triangle, count: 4_096)
for value in triangle { value } // Click the eye icon ->

let sine = AKTable(.sine, count: 4_096)
for value in sine { value } // Click the eye icon ->

let sawtooth = AKTable(.sawtooth, count: 4_096)
for value in sawtooth { value } // Click the eye icon ->

var custom = AKTable(.sine, count: 512)
for i in custom.indices {
    custom[i] += Float(random(-0.3, 0.3) + Double(i) / 2_048.0)
}
for value in custom { value } // Click the eye icon ->

//: Try changing the table to triangle, square, sine, or sawtooth.
//: This will change the shape of the oscillator's waveform.
var oscillator = AKOscillator(waveform: custom)
AudioKit.output = oscillator
AudioKit.start()

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.2
var currentRampTime = 0.05
oscillator.rampTime = currentRampTime
oscillator.amplitude = currentAmplitude

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {

        addTitle("General Purpose Oscillator")

        addSubview(AKPropertySlider(
            property: "Amplitude",
            value: currentAmplitude,
            color: AKColor.red
        ) { amplitude in
            currentAmplitude = amplitude
            })

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            value: currentRampTime,
            color: AKColor.cyan
        ) { time in
            currentRampTime = time
            })

        let keyboard = AKKeyboardView(width: 440,
                                      height: 100,
                                      firstOctave: 4,
                                      octaveCount: 4)
        keyboard.delegate = self
        addSubview(keyboard)
        addSubview(AKOutputWaveformPlot.createView())
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
        if note == currentMIDINote {
            oscillator.amplitude = 0
        }
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
