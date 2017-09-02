//: ## Formant Filter
//: ##
import AudioKitPlaygrounds
import AudioKit

let osc = AKPWMOscillator(frequency: 220)
osc.pulseWidth = 0.1

var filter = AKFormantFilter(osc)

AudioKit.output = filter
AudioKit.start()
osc.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Formant Filter")

        addSubview(AKSlider(property: "x", format: "%0.3f", value: filter.x) { sliderValue in
            filter.x = sliderValue
        })

        addSubview(AKSlider(property: "y", format: "%0.3f", value: filter.y) { sliderValue in
            filter.y = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
