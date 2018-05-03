//: ## PWM Oscillator
//:
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var oscillator = AKPWMOscillator()
oscillator.pulseWidth = 0.5

var currentMIDINote: MIDINoteNumber = 0
var currentAmplitude = 0.1
var currentRampDuration = 0.0

AudioKit.output = oscillator
try AudioKit.start()

let playgroundWidth = 500

class LiveView: AKLiveViewController, AKKeyboardDelegate {

    override func viewDidLoad() {
        addTitle("PWM Oscillator")

        addView(AKSlider(property: "Amplitude", value: currentAmplitude) { sliderValue in
            currentAmplitude = sliderValue
        })

        addView(AKSlider(property: "Pulse Width", value: oscillator.pulseWidth) { sliderValue in
            oscillator.pulseWidth = sliderValue
        })

        addView(AKSlider(property: "Ramp Duration",
                         value: currentRampDuration,
                         range: 0 ... 2,
                         format: "%0.3f s"
        ) { sliderValue in
            currentRampDuration = sliderValue
        })

        let keyboard = AKKeyboardView(width: playgroundWidth - 60, height: 100)
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
