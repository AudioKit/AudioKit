//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKOscillator()
oscillator.amplitude = 0.1
AudioKit.output = oscillator
AudioKit.start()
oscillator.play()

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?

    override func setup() {
        addTitle("Oscillator")

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        frequencyLabel = addLabel("Frequency: 440")
        addSlider(#selector(setFrequency), value: 440, minimum: 200, maximum: 800)

        amplitudeLabel = addLabel("Amplitude: 0.1")
        addSlider(#selector(setAmplitude), value: 0.1)
    }

    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }

    func setFrequency(slider: Slider) {
        oscillator.ramp(frequency: Double(slider.value))
        let frequency = String(format: "%0.1f", oscillator.frequency)
        frequencyLabel!.text = "Frequency: \(frequency)"
    }

    func setAmplitude(slider: Slider) {
        oscillator.ramp(amplitude: Double(slider.value))
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
