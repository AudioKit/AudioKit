//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator
//: ### Open the timeline view to use the controls this playground sets up.
//:
import XCPlayground
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
AudioKit.output = oscillator
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var carrierMultiplierLabel: Label?
    var modulatingMultiplierLabel: Label?
    var modulationIndexLabel: Label?

    override func setup() {
        addTitle("FM Oscillator")

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        frequencyLabel = addLabel("Base Frequency: 440")
        addSlider(#selector(setBaseFrequency), value: 440, minimum: 200, maximum: 800)

        carrierMultiplierLabel = addLabel("Carrier Multiplier: 1")
        addSlider(#selector(setCarrierMultiplier), value: 1, minimum: 0, maximum: 20)

        modulatingMultiplierLabel = addLabel("Modulating Multiplier: 1")
        addSlider(#selector(setModulatingMultiplier), value: 1, minimum: 0, maximum: 20)

        modulationIndexLabel = addLabel("Modulation Index: 1")
        addSlider(#selector(setModulationIndex), value: 1, minimum: 0, maximum: 100)

        amplitudeLabel = addLabel("Amplitude: 0.1")
        addSlider(#selector(setAmplitude), value: 0.1)
    }

    //: Handle UI Events

    func start() {
        oscillator.play()
    }
    func stop() {
        oscillator.stop()
    }

    func setBaseFrequency(slider: Slider) {
        oscillator.baseFrequency = Double(slider.value)
        let baseFrequency = String(format: "%0.1f", oscillator.baseFrequency)
        frequencyLabel!.text = "Base Frequency: \(baseFrequency)"
    }

    func setCarrierMultiplier(slider: Slider) {
        oscillator.carrierMultiplier = Double(slider.value)
        let carrierMultiplier = String(format: "%0.3f", oscillator.carrierMultiplier)
        carrierMultiplierLabel!.text = "Carrier Multiplier: \(carrierMultiplier)"
    }


    func setModulatingMultiplier(slider: Slider) {
        oscillator.modulatingMultiplier = Double(slider.value)
        let modulatingMultiplier = String(format: "%0.3f", oscillator.modulatingMultiplier)
        modulatingMultiplierLabel!.text = "Modulation Multiplier: \(modulatingMultiplier)"
    }

    func setModulationIndex(slider: Slider) {
        oscillator.modulationIndex = Double(slider.value)
        let modulationIndex = String(format: "%0.3f", oscillator.modulationIndex)
        modulationIndexLabel!.text = "Modulation Index: \(modulationIndex)"
    }


    func setAmplitude(slider: Slider) {
        oscillator.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", oscillator.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
