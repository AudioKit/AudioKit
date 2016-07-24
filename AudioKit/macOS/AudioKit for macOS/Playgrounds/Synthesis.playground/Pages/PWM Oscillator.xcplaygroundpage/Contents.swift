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

    var frequencyLabel: Label?
    var pulseWidthLabel: Label?
    var amplitudeLabel: Label?
    var rampTimeLabel: Label?

    override func setup() {
        addTitle("PWM Oscillator")

        amplitudeLabel = addLabel("Amplitude: \(currentAmplitude)")
        addSlider(#selector(setAmplitude), value: currentAmplitude)

        pulseWidthLabel = addLabel("Pulse Width: \(oscillator.pulseWidth)")
        addSlider(#selector(setPulseWidth), value: oscillator.pulseWidth, minimum: 0.5, maximum: 1)

        rampTimeLabel = addLabel("Ramp Time: \(currentRampTime)")
        addSlider(#selector(setRampTime), value: currentRampTime, minimum: 0, maximum: 5.0)

        let keyboard = AKKeyboardView(width: playgroundWidth, height: 100)
        keyboard.delegate = self

        keyboard.frame.origin.y = CGFloat(200)

        keyboard.delegate = self
        self.addSubview(keyboard)
    }

    func noteOn(note: Int) {
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

    func noteOff(note: Int) {
        oscillator.amplitude = 0
    }

    func setPulseWidth(slider: Slider) {
        oscillator.pulseWidth = Double(slider.value)
        let pw = String(format: "%0.3f", oscillator.pulseWidth)
        pulseWidthLabel!.text = "Pulse Width: \(pw)"
    }


    func setAmplitude(slider: Slider) {
        currentAmplitude = Double(slider.value)
        let amp = String(format: "%0.3f", currentAmplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }

    func setRampTime(slider: Slider) {
        currentRampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", currentRampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
