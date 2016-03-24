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
    var inertiaLabel: Label?

    override func setup() {
        addTitle("Oscillator")

        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        frequencyLabel = addLabel("Frequency: \(oscillator.frequency)")
        addSlider(#selector(self.setFrequency(_:)), value: oscillator.frequency, minimum: 200, maximum: 800)

        amplitudeLabel = addLabel("Amplitude: \(oscillator.amplitude)")
        addSlider(#selector(self.setAmplitude(_:)), value: oscillator.amplitude)

        inertiaLabel = addLabel("Inertia: \(oscillator.inertia)")
        addSlider(#selector(self.setInertia(_:)), value: oscillator.inertia)
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
    }

    func setAmplitude(slider: Slider) {
        oscillator.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }
    
    func setInertia(slider: Slider) {
        oscillator.inertia = Double(slider.value)
        let inertia = String(format: "%0.3f", oscillator.inertia)
        inertiaLabel!.text = "Inertia: \(inertia)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
