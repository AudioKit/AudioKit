//: ## Dripping Sounds
//: Physical model of a water drop letting hitting a pool.
//: What's this good for?  We don't know, but hey it's cool. :)
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var playRate = 2.0

let drip = AKDrip(intensity: 1)
drip.intensity = 100

let reverb = AKReverb(drip)

let drips = AKPeriodicFunction(frequency: playRate) {
    drip.trigger()
}

AudioKit.output = AKBooster(reverb, gain: 0.4)
AudioKit.start(withPeriodicFunctions: drips)
drips.start()

class PlaygroundView: AKPlaygroundView {

    override func setup() {

        addTitle("Dripping Sounds")

        addSubview(AKSlider(property: "Intensity",
                            value: drip.intensity,
                            range: 0 ... 300
        ) { sliderValue in
            drip.intensity = sliderValue
        })

        addSubview(AKSlider(property: "Damping Factor",
                            value: drip.dampingFactor,
                            range: 0 ... 2
        ) { sliderValue in
            drip.dampingFactor = sliderValue
        })
        addSubview(AKSlider(property: "Energy Return",
                            value: drip.energyReturn,
                            range: 0 ... 5
        ) { sliderValue in
            drip.energyReturn = sliderValue
        })
        addSubview(AKSlider(property: "Main Resonant Frequency",
                            value: drip.mainResonantFrequency,
                            range: 0 ... 800,
                            format: "%0.1f Hz"
        ) { sliderValue in
            drip.mainResonantFrequency = sliderValue
        })
        addSubview(AKSlider(property: "1st Resonant Frequency",
                            value: drip.firstResonantFrequency,
                            range: 0 ... 800,
                            format: "%0.1f Hz"
        ) { sliderValue in
            drip.firstResonantFrequency = sliderValue
        })
        addSubview(AKSlider(property: "2nd Resonant Frequency",
                            value: drip.secondResonantFrequency,
                            range: 0 ... 800,
                            format: "%0.1f Hz"
        ) { sliderValue in
            drip.secondResonantFrequency = sliderValue
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
