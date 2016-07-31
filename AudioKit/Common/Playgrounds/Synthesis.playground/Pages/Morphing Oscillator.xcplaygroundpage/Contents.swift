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

        addTitle("Morphing Oscillator")

        addSubview(AKBypassButton(node: morph))

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
            value: morph.amplitude,
            color: AKColor.magentaColor()
        ) { amplitude in
            morph.amplitude = amplitude
            })

        addLabel("Index: Sine = 0, Triangle = 1, Sawtooth = 2, Square = 3")

        addSubview(AKPropertySlider(
            property: "Morph Index",
            value: morph.index, maximum: 3,
            color: AKColor.redColor()
        ) { index in
            morph.index = index
            })

        addSubview(AKOutputWaveformPlot.createView(width: 440, height: 400))
    }

    func start() {
        morph.play()
    }
    func stop() {
        morph.stop()
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
