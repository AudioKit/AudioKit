//: ## Phase Distortion Oscillator
//:
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var oscillator = AKPhaseDistortionOscillator(waveform: AKTable(.sawtooth))
oscillator.phaseDistortion = 0.0
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    override func viewDidLoad() {
        addTitle("Phase Distortion Oscillator")

        addView(AKSlider(property: "Amplitude", value: currentAmplitude) { sliderValue in
            currentAmplitude = sliderValue
        })

        addView(AKSlider(property: "Phase Distortion", value: oscillator.phaseDistortion) { sliderValue in
            oscillator.phaseDistortion = sliderValue
        })

        addView(AKSlider(property: "Ramp Time",
                         value: currentRampTime,
                         range: 0 ... 10,
                         format: "%0.3f s"
        ) { time in
            currentRampTime = time
        })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60, height: 100)
        keyboard.delegate = self
        addView(keyboard)

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

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
