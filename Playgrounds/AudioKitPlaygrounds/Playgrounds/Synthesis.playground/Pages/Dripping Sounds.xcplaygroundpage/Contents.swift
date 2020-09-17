//: ## Dripping Sounds
//: Physical model of a water drop letting hitting a pool.
//: What's this good for?  We don't know, but hey it's cool. :)

import AudioKit

var playRate = 2.0

let drip = Drip(intensity: 1)
drip.intensity = 100

let reverb = Reverb(drip)

let drips = PeriodicFunction(frequency: playRate) {
    drip.trigger()
}

engine.output = Fader(reverb, gain: 0.4)
try engine.start(withPeriodicFunctions: drips)
drips.start()

class LiveView: View {

    override func viewDidLoad() {

        addTitle("Dripping Sounds")

        addView(Slider(property: "Intensity", value: drip.intensity, range: 0 ... 300) { sliderValue in
            drip.intensity = sliderValue
        })

        addView(Slider(property: "Damping Factor", value: drip.dampingFactor, range: 0 ... 2) { sliderValue in
            drip.dampingFactor = sliderValue
        })
        addView(Slider(property: "Energy Return", value: drip.energyReturn range: 0 ... 5) { sliderValue in
            drip.energyReturn = sliderValue
        })
        addView(Slider(property: "Main Resonant Frequency",
                         value: drip.mainResonantFrequency,
                         range: 0 ... 800,
                         format: "%0.1f Hz"
        ) { sliderValue in
            drip.mainResonantFrequency = sliderValue
        })
        addView(Slider(property: "1st Resonant Frequency",
                         value: drip.firstResonantFrequency,
                         range: 0 ... 800,
                         format: "%0.1f Hz"
        ) { sliderValue in
            drip.firstResonantFrequency = sliderValue
        })
        addView(Slider(property: "2nd Resonant Frequency",
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
PlaygroundPage.current.liveView = LiveView()
