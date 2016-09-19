//: ## Morphing Oscillator
//: Oscillator with four different waveforms built in.
import PlaygroundSupport
import AudioKit

var morph = AKMorphingOscillator(waveformArray:
    [AKTable(.sine), AKTable(.triangle), AKTable(.sawtooth), AKTable(.square)])
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
            color: AKColor.yellow
        ) { frequency in
            morph.frequency = frequency
            })

        addSubview(AKPropertySlider(
            property: "Amplitude",
            value: morph.amplitude,
            color: AKColor.magenta
        ) { amplitude in
            morph.amplitude = amplitude
            })

        addLabel("Index: Sine = 0, Triangle = 1, Sawtooth = 2, Square = 3")

        addSubview(AKPropertySlider(
            property: "Morph Index",
            value: morph.index, maximum: 3,
            color: AKColor.red
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

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
