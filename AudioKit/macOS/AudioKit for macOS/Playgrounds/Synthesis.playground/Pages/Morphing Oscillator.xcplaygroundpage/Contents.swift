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

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.2f Hz",
            value: morph.frequency, minimum: 220, maximum: 880,
            color: AKColor.yellowColor()
        ) { frequency in
            morph.frequency = frequency
            })
        
        addSubview(AKPropertySlider(
            property: "Amplitude",
            format: "%0.3f",
            value: morph.amplitude,
            color: AKColor.magentaColor()
        ) { amplitude in
            morph.amplitude = amplitude
            })
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

    func setMorphIndex(slider: Slider) {
        morph.index = Double(slider.value)
        let index = String(format: "%0.3f", morph.index)
        morphIndexLabel!.text = "Morph Index: \(index)"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
