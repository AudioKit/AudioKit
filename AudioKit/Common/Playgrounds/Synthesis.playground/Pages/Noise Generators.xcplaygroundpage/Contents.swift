//: ## Noise Generators
//:

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

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Noise Generators")

        addSubview(AKPropertySlider(
            property: "Brownian Volume",
            format: "%0.2f",
            value: brownian.amplitude,
            color: AKColor.brown
        ) { amplitude in
            brownian.amplitude = amplitude
        })

        addSubview(AKPropertySlider(
            property: "Pink Volume",
            format: "%0.2f",
            value: pink.amplitude,
            color: AKColor.magenta
        ) { amplitude in
            pink.amplitude = amplitude
        })
        addSubview(AKPropertySlider(
            property: "White Volume",
            format: "%0.2f",
            value: white.amplitude,
            color: AKColor.white
        ) { amplitude in
            white.amplitude = amplitude
        })

    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
