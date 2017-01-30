//: ## Pink and White Noise Generators
//:
import PlaygroundSupport
import AudioKit

var white = AKWhiteNoise(amplitude: 0.1)
var pink = AKPinkNoise(amplitude: 0.1)
var whitePinkMixer = AKWetDryMixer(white, pink, balance: 0.5)
AudioKit.output = whitePinkMixer
AudioKit.start()
pink.start()
white.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Pink and White Noise")

        addSubview(AKPropertySlider(
            property: "Volume",
            format: "%0.2f",
            value: pink.amplitude,
            color: AKColor.cyan
        ) { amplitude in
            pink.amplitude = amplitude
            white.amplitude = amplitude
            })

        addSubview(AKPropertySlider(
            property: "White to Pink Balance",
            format: "%0.2f",
            value: whitePinkMixer.balance,
            color: AKColor.magenta
        ) { balance in
            whitePinkMixer.balance = balance
            })
    }


}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
