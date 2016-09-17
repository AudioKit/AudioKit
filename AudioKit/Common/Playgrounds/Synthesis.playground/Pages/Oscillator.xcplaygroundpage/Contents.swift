//: ## Oscillator
//: This oscillator can be loaded with a wavetable of your own design,
//: or with one of the defaults.
import PlaygroundSupport
import AudioKit

let square = AKTable(.Square, size: 16)
for value in square.values { value } // Click the eye icon ->

let triangle = AKTable(.Triangle, size: 4096)
for value in triangle.values { value } // Click the eye icon ->

let sine = AKTable(.Sine, size: 4096)
for value in sine.values { value } // Click the eye icon ->

let sawtooth = AKTable(.Sawtooth, size: 4096)
for value in sawtooth.values { value } // Click the eye icon ->

var custom = AKTable(.Sine, size: 512)
for i in 0..<custom.values.count {
    custom.values[i] += Float(random(-0.3, 0.3) + Double(i)/2048.0)
}
for value in custom.values { value } // Click the eye icon ->

//: Try changing the table to triangle, square, sine, or sawtooth.
//: This will change the shape of the oscillator's waveform.
var oscillator = AKOscillator(waveform: sine)
AudioKit.output = oscillator
AudioKit.start()

var currentMIDINote = 0
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
