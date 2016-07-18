//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Morphing Oscillator
//: ### Oscillator with four different waveforms built in
import XCPlayground
import AudioKit

//: Try changing the table type to triangle or another AKTableType
//: or changing the number of points to a smaller number (has to be a power of 2)
var morph = AKMorphingOscillator(waveformArray:
    [AKTable(.Sine), AKTable(.Triangle), AKTable(.Sawtooth), AKTable(.Square)])
morph.frequency = 400
morph.amplitude = 0.1
morph.index = 0.8
morph.rampTime = 0.1

AudioKit.output = morph
AudioKit.start()
morph.start()

class PlaygroundView: AKPlaygroundView {

    var frequencyLabel: Label?
    var amplitudeLabel: Label?
    var morphIndexLabel: Label?

    override func setup() {
        let plotView = AKOutputWaveformPlot.createView(500, height: 550)
        self.addSubview(plotView)

        addTitle("Morphing Oscillator")

        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        frequencyLabel = addLabel("Frequency: \(morph.frequency)")
        addSlider(#selector(setFrequency), value: morph.frequency, minimum: 200, maximum: 800)

        amplitudeLabel = addLabel("Amplitude: 0.1")
        addSlider(#selector(setAmplitude), value: morph.amplitude)

        morphIndexLabel = addLabel("Morph Index: \(morph.index)")
        addLabel("Sine = 0")
        addLabel("Triangle = 1")
        addLabel("Sawtooth = 2")
        addLabel("Square = 3")
        addSlider(#selector(setMorphIndex), value: morph.index, minimum: 0, maximum: 3)
    }

    func start() {
        morph.play()
    }

    func stop() {
        morph.stop()
    }

    func setFrequency(slider: Slider) {
        morph.frequency = Double(slider.value)
        let frequency = String(format: "%0.1f", morph.frequency)
        frequencyLabel!.text = "Frequency: \(frequency)"
        printCode()
    }

    func setAmplitude(slider: Slider) {
        morph.amplitude = Double(slider.value)
        let amp = String(format: "%0.3f", morph.amplitude)
        amplitudeLabel!.text = "Amplitude: \(amp)"
        printCode()
    }

    func setMorphIndex(slider: Slider) {
        morph.index = Double(slider.value)
        let index = String(format: "%0.3f", morph.index)
        morphIndexLabel!.text = "Morph Index: \(index)"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        print("public func presetXXXXXX() {")
        print("    frequency = \(String(format: "%0.3f", morph.frequency))")
        print("    amplitude = \(String(format: "%0.3f", morph.amplitude))")
        print("    index = \(String(format: "%0.3f", morph.index))")
        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
