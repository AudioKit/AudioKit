//: ## Morphing Oscillator
//: Oscillator with four different waveforms built in.
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var morph = AKMorphingOscillator(waveformArray: [AKTable(.sine),
                                                 AKTable(.triangle),
                                                 AKTable(.sawtooth),
                                                 AKTable(.square)])
morph.frequency = 400
morph.amplitude = 0.1
morph.index = 0.8

AudioKit.output = morph
AudioKit.start()
morph.start()

class LiveView: AKLiveViewController {

    var frequencyLabel: AKLabel?
    var amplitudeLabel: AKLabel?
    var morphIndexLabel: AKLabel?

    override func viewDidLoad() {

        addTitle("Morphing Oscillator")

        addView(AKButton(title: "Stop Oscillator") { button in
            morph.isStarted ? morph.stop() : morph.play()
            button.title = morph.isStarted ? "Stop Oscillator" : "Start Oscillator"
        })

        addView(AKSlider(property: "Frequency",
                         value: morph.frequency,
                         range: 220 ... 880,
                         format: "%0.2f Hz"
        ) { frequency in
            morph.frequency = frequency
        })

        addView(AKSlider(property: "Amplitude", value: morph.amplitude) { amplitude in
            morph.amplitude = amplitude
        })

        addLabel("Index: Sine = 0, Triangle = 1, Sawtooth = 2, Square = 3")

        addView(AKSlider(property: "Morph Index", value: morph.index, range: 0 ... 3) { index in
            morph.index = index
        })

        addView(AKOutputWaveformPlot.createView(width: 440, height: 400))
    }

    func start() {
        morph.play()
    }
    func stop() {
        morph.stop()
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
