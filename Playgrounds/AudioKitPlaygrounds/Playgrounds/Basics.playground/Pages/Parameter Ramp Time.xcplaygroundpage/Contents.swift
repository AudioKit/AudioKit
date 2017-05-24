//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parameter Ramp Time
//: Most AudioKit nodes have parameters that you can change.
//: Its very common need to change these parameters in a smooth way
//: to avoid pops and clicks, so you can set a ramp time to slow the
//: variation of a property from its current value to its next.
import AudioKitPlaygrounds
import AudioKit

var noise = AKWhiteNoise(amplitude: 1)
var filter = AKMoogLadder(noise)

filter.resonance = 0.94

var counter = 0

let toggling = AKPeriodicFunction(frequency: 2.66) {
    let frequencyToggle = counter % 2
    if frequencyToggle > 0 {
        filter.cutoffFrequency = 111
    } else {
        filter.cutoffFrequency = 666
    }
    counter += 1
}

AudioKit.output = filter
AudioKit.start(withPeriodicFunctions: toggling)

noise.start()
toggling.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Parameter Ramp Time")

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: filter.rampTime
        ) { sliderValue in
            filter.rampTime = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
