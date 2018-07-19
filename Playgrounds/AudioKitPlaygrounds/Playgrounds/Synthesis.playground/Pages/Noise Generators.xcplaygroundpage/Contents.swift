//: ## Noise Generators
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var brownian = AKBrownianNoise(amplitude: 0.2)
var pink = AKPinkNoise(amplitude: 0.2)
var white = AKWhiteNoise(amplitude: 0.1)

AudioKit.output = AKMixer(brownian, pink, white)
try AudioKit.start()

brownian.start()
pink.start()
white.start()
//: User Interface Set up
class LiveView: AKLiveViewController {

    override func viewDidLoad() {

        addTitle("Noise Generators")

        addView(AKSlider(property: "Brownian Volume",
                         value: brownian.amplitude,
                         format: "%0.2f",
                         color: AKColor.brown
        ) { amplitude in
            brownian.amplitude = amplitude
        })

        addView(AKSlider(property: "Pink Volume",
                         value: pink.amplitude,
                         format: "%0.2f",
                         color: AKColor.magenta
        ) { amplitude in
            pink.amplitude = amplitude
        })

        addView(AKSlider(property: "White Volume",
                         value: white.amplitude,
                         format: "%0.2f",
                         color: AKColor.white
        ) { amplitude in
            white.amplitude = amplitude
        })

        super.viewDidLoad()
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
