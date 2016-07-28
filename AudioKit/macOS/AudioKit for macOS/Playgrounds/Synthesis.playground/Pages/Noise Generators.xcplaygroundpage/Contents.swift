//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pink and White Noise Generators
//:
import XCPlayground
import AudioKit

var white = AKWhiteNoise(amplitude: 0.1)
var pink = AKPinkNoise(amplitude: 0.1)
var whitePinkMixer = AKDryWetMixer(white, pink, balance: 0.5)
AudioKit.output = whitePinkMixer
AudioKit.start()
pink.start()
white.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Pink and White Noise")

        self.addSubview(AKPropertySlider(
            property: "Volume",
            format: "%0.2f",
            value: pink.amplitude,
            color: AKColor.cyanColor(),
            frame: CGRect(x: 30, y: 120, width: self.bounds.width - 60, height: 60)
        ) { amplitude in
            pink.amplitude = amplitude
            white.amplitude = amplitude
            })
        
        self.addSubview(AKPropertySlider(
            property: "White to Pink Balance",
            format: "%0.2f",
            value: whitePinkMixer.balance,
            color: AKColor.magentaColor(),
            frame: CGRect(x: 30, y: 30, width: self.bounds.width - 60, height: 60)
        ) { balance in
            whitePinkMixer.balance = balance
            })
    }


}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 270))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
