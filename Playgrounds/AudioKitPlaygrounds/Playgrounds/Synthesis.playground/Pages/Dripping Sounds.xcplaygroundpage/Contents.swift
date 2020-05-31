//: ## Dripping Sounds
//: Physical model of a water drop letting hitting a pool.
//: What's this good for?  We don't know, but hey it's cool. :)
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

var playRate = 2.0

let drip = AKDrip(intensity: 1)
drip.intensity.value = 100

let reverb = AKReverb(drip)

let drips = AKPeriodicFunction(frequency: playRate) {
    drip.trigger()
}

AKManager.output = AKBooster(reverb, gain: 0.4)
try AKManager.start(withPeriodicFunctions: drips)
drips.start()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {

        addTitle("Dripping Sounds")

        addView(AKSlider(property: "Intensity", value: drip.intensity.value, range: 0 ... 300) { sliderValue in
            drip.intensity.value = sliderValue
        })

        addView(AKSlider(property: "Damping Factor", value: drip.dampingFactor.value, range: 0 ... 2) { sliderValue in
            drip.dampingFactor.value = sliderValue
        })
        addView(AKSlider(property: "Energy Return", value: drip.energyReturn.value, range: 0 ... 5) { sliderValue in
            drip.energyReturn.value = sliderValue
        })
        addView(AKSlider(property: "Main Resonant Frequency",
                         value: drip.mainResonantFrequency.value,
                         range: 0 ... 800,
                         format: "%0.1f Hz"
        ) { sliderValue in
            drip.mainResonantFrequency.value = sliderValue
        })
        addView(AKSlider(property: "1st Resonant Frequency",
                         value: drip.firstResonantFrequency.value,
                         range: 0 ... 800,
                         format: "%0.1f Hz"
        ) { sliderValue in
            drip.firstResonantFrequency.value = sliderValue
        })
        addView(AKSlider(property: "2nd Resonant Frequency",
                         value: drip.secondResonantFrequency.value,
                         range: 0 ... 800,
                         format: "%0.1f Hz"
        ) { sliderValue in
            drip.secondResonantFrequency.value = sliderValue
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
