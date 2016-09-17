//: ## Phase Distortion Oscillator
//:
import PlaygroundSupport
import AudioKit

var oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.Sawtooth))
oscillator.phaseDistortion = 0.0
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("Phase Distortion Oscillator")

        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: currentAmplitude,
            color: AKColor.purple
        ) { amplitude in
            currentAmplitude = amplitude
            })

        addSubview(AKPropertySlider(
            property: "Phase Distortion",
            value: oscillator.phaseDistortion,
            color: AKColor.red
        ) { amount in
            oscillator.phaseDistortion = amount
            })

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: currentRampTime, maximum: 10,
            color: AKColor.orange
        ) { time in
            currentRampTime = time
            })

        let keyboard = AKKeyboardView(width: playgroundWidth - 660, height: 100)
        keyboard.delegate = self
        addSubview(keyboard)
    }

    func noteOn(note: MIDINoteNumber) {
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
        oscillator.amplitude = 0
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
