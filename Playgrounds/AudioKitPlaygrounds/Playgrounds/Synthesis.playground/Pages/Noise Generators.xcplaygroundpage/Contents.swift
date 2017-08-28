//: ## Noise Generators
//:
import AudioKitPlaygrounds
import AudioKit

var brownian = AKBrownianNoise(amplitude: 0.2)
var pink = AKPinkNoise(amplitude: 0.2)
var white = AKWhiteNoise(amplitude: 0.1)

AudioKit.output = AKMixer(brownian, pink, white)
AudioKit.start()

brownian.start()
pink.start()
white.start()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Noise Generators")

        addSubview(AKPropertySlider(property: "Brownian Volume",
                                    value: brownian.amplitude,
                                    format: "%0.2f",
                                    color: AKColor.brown
        ) { amplitude in
            brownian.amplitude = amplitude
        })

        addSubview(AKPropertySlider(property: "Pink Volume",
                                    value: pink.amplitude,
                                    format: "%0.2f",
                                    color: AKColor.magenta
        ) { amplitude in
            pink.amplitude = amplitude
        })
        addSubview(AKPropertySlider(property: "White Volume",
                                    value: white.amplitude,
                                    format: "%0.2f",
                                    color: AKColor.white
        ) { amplitude in
            white.amplitude = amplitude
        })

    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
