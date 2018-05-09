//: ## Output Waveform Plot
//: If you open the Assitant editor and make sure it shows the
//: "Output Waveform Plot.xcplaygroundpage (Timeline) view",
//: you should see a plot of the waveform in real time
import AudioKitPlaygrounds
import AudioKit

var oscillator = AKFMOscillator()
oscillator.amplitude = 0.1
oscillator.rampDuration = 0.1
AudioKit.output = oscillator
try AudioKit.start()
oscillator.start()

import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Output Waveform Plot")

        addView(AKSlider(property: "Frequency",
                         value: oscillator.baseFrequency,
                         range: 0 ... 800,
                         format: "%0.2f Hz"
        ) { frequency in
            oscillator.baseFrequency = frequency
        })

        addView(AKSlider(property: "Carrier Multiplier",
                         value: oscillator.carrierMultiplier,
                         range: 0 ... 3
        ) { multiplier in
            oscillator.carrierMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulating Multiplier",
                         value: oscillator.modulatingMultiplier,
                         range: 0 ... 3
        ) { multiplier in
            oscillator.modulatingMultiplier = multiplier
        })

        addView(AKSlider(property: "Modulation Index",
                         value: oscillator.modulationIndex,
                         range: 0 ... 3
        ) { index in
            oscillator.modulationIndex = index
        })

        addView(AKSlider(property: "Amplitude", value: oscillator.amplitude) { amplitude in
            oscillator.amplitude = amplitude
        })

        let plot = AKOutputWaveformPlot()
        addView(plot)
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
