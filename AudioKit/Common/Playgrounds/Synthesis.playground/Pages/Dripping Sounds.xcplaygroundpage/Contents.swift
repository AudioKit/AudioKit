//: ## Dripping Sounds
//: Physical model of a water drop letting hitting a pool.
//: What's this good for?  We don't know, but hey it's cool. :)
import AudioKit
import XCPlayground

var playRate = 2.0

let drip = AKDrip(intensity: 1)
drip.intensity = 100

let reverb = AKReverb(drip)

AudioKit.output = reverb
AudioKit.start()

AKPlaygroundLoop(frequency: playRate) {
    drip.trigger()
}

class PlaygroundView: AKPlaygroundView {

    override func setup() {

        addTitle("Dripping Sounds")

        addSubview(AKPropertySlider(
            property: "Intensity",
            value: drip.intensity, maximum: 300,
            color: AKColor.redColor()
        ) { sliderValue in
            drip.intensity = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Damping Factor",
            value: drip.dampingFactor, maximum: 2,
            color: AKColor.greenColor()
        ) { sliderValue in
            drip.dampingFactor = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Energy Return",
            value: drip.energyReturn, maximum: 5,
            color: AKColor.yellowColor()
        ) { sliderValue in
            drip.energyReturn = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "Main Resonant Frequency",
            format: "%0.1f Hz",
            value: drip.mainResonantFrequency, maximum: 800,
            color: AKColor.cyanColor()
        ) { sliderValue in
            drip.mainResonantFrequency = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "1st Resonant Frequency",
            format: "%0.1f Hz",
            value: drip.firstResonantFrequency, maximum: 800,
            color: AKColor.cyanColor()
        ) { sliderValue in
            drip.firstResonantFrequency = sliderValue
            })
        addSubview(AKPropertySlider(
            property: "2nd Resonant Frequency",
            format: "%0.1f Hz",
            value: drip.secondResonantFrequency, maximum: 800,
            color: AKColor.cyanColor()
        ) { sliderValue in
            drip.secondResonantFrequency = sliderValue
            })
    }

}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()