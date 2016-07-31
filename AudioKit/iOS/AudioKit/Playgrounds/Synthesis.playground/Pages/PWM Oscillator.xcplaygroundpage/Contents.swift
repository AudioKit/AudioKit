//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## PWM Oscillator
//:
import XCPlayground
import AudioKit

var oscillator = AKPWMOscillator()
oscillator.pulseWidth = 0.5
var currentAmplitude = 0.1
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, AKKeyboardDelegate {

    override func setup() {
        addTitle("PWM Oscillator")

        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: currentAmplitude, 
            color: AKColor.purpleColor()
        ) { amplitude in
            currentAmplitude = amplitude
            })

        addSubview(AKPropertySlider(
            property: "Pulse Width",
            value: oscillator.pulseWidth,
            color: AKColor.redColor()
        ) { amount in
            oscillator.pulseWidth = amount
            })

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: currentRampTime, maximum: 10,
            color: AKColor.orangeColor()
        ) { time in
            currentRampTime = time
            })

        let keyboard = AKKeyboardView(width: playgroundWidth, height: 100)
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

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
