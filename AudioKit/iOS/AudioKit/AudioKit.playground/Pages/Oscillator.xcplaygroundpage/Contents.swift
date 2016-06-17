//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKOscillator()
oscillator.amplitude = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var rampTimeLabel: Label?

    override func setup() {
        addTitle("Oscillator")

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        frequencyLabel = addLabel("Frequency: \(oscillator.frequency)")
        addSlider(#selector(setFrequency), value: oscillator.frequency, minimum: 200, maximum: 800)

        amplitudeLabel = addLabel("Amplitude: \(oscillator.amplitude)")
        addSlider(#selector(setAmplitude), value: oscillator.amplitude)

        rampTimeLabel = addLabel("Ramp Time: \(oscillator.rampTime)")
        addSlider(#selector(setRampTime), value: oscillator.rampTime)
    }

    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }

    func setFrequency(slider: Slider) {
        oscillator.frequency = Double(slider.value)
        let frequency = String(format: "%0.1f", oscillator.frequency)
        frequencyLabel!.text = "Frequency: \(frequency)"
        printCode()
    }

    func setAmplitude(slider: Slider) {
        oscillator.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
        printCode()
    }
    
    func setRampTime(slider: Slider) {
        oscillator.rampTime = Double(slider.value)
        let rampTime = String(format: "%0.3f", oscillator.rampTime)
        rampTimeLabel!.text = "Ramp Time: \(rampTime)"
        printCode()
    }
    
    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code
        
        print("public func presetXXXXXX() {")
        print("    frequency = \(String(format: "%0.3f", oscillator.frequency))")
        print("    amplitude = \(String(format: "%0.3f", oscillator.amplitude))")
        print("    rampTime = \(String(format: "%0.3f", oscillator.rampTime))")
        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
