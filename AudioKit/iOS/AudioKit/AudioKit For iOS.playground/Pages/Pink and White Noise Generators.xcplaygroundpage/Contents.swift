//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pink and White Noise Generators
//:
import PlaygroundSupport
import AudioKit

var pink = AKPinkNoise(amplitude: 0.1)
var white = AKWhiteNoise(amplitude: 0.1)
var pinkWhiteMixer = AKDryWetMixer(pink, white, balance: 0)
AudioKit.output = pinkWhiteMixer
AudioKit.start()
pink.start()
white.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var volumeLabel: Label?
    var balanceLabel: Label?

    override func setup() {
        addTitle("Pink and White Noise")
        volumeLabel = addLabel("Volume: \(pink.amplitude)")
        addSlider(#selector(setVolume), value: pink.amplitude)

        balanceLabel = addLabel("Pink to White Noise Balance: \(pinkWhiteMixer.balance)")
        addSlider(#selector(setBalance), value: pinkWhiteMixer.balance)
    }


    func setBalance(slider: Slider) {
        pinkWhiteMixer.balance = Double(slider.value)
        balanceLabel!.text = "Pink to White Noise Balance: \(String(format: "%0.3f", pinkWhiteMixer.balance))"
        pinkWhiteMixer.balance // to plot value history
    }
    func setVolume(slider: Slider) {
        pink.amplitude = Double(slider.value)
        white.amplitude = Double(slider.value)
        volumeLabel!.text = "Volume: \(String(format: "%0.3f", pink.amplitude))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
