//: ## Formant Filter
//: ##
import PlaygroundSupport
import AudioKit

let osc = AKPWMOscillator(frequency: 220)
osc.pulseWidth = 0.1

var filter = AKFormantFilter(osc)

AudioKit.output = filter
AudioKit.start()
osc.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Formant Filter")

        addSubview(AKPropertySlider(
            property: "x",
            format: "%0.3f",
            value: filter.x,
            color: AKColor.yellow
        ) { sliderValue in
            filter.x = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "y",
            format: "%0.3f",
            value: filter.y,
            color: AKColor.green
        ) { sliderValue in
            filter.y = sliderValue
        })
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
