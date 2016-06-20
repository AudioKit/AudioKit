//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Wave Oscillator
//:
import XCPlayground
import AudioKit

var oscillator = AKSawtoothOscillator()
var currentAmplitude = 0.5
var currentRampTime = 0.0

AudioKit.output = oscillator
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView, KeyboardDelegate {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var rampTimeLabel: Label?

    override func setup() {
        addTitle("Sawtooth Wave Oscillator")

        amplitudeLabel = addLabel("Amplitude: \(currentAmplitude)")
        addSlider(#selector(setAmplitude), value: currentAmplitude)

        rampTimeLabel = addLabel("Ramp Time: \(currentRampTime)")
        addSlider(#selector(setRampTime), value: currentRampTime, minimum: 0, maximum: 0.1)

        let keyboard = KeyboardView(width: playgroundWidth, height: 100, delegate: self)
        keyboard.frame.origin.y = CGFloat(yPosition)

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

    func setAmplitude(slider: Slider) {
        currentAmplitude = Double(slider.value)
        let amp = String(format: "%0.3f", currentAmplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
        printCode()
    }

    func setRampTime(slider: Slider) {
        currentRampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", currentRampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    currentAmplitude = \(String(format: "%0.3f", currentAmplitude))")
        Swift.print("    currentRampTime = \(String(format: "%0.3f", currentRampTime))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
