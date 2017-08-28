//: ## Vocal Tract
//:
import AudioKitPlaygrounds
import AudioKit

let voc = AKVocalTract()

AudioKit.output = voc
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    var current = 0

    var frequencySlider: AKPropertySlider!
    var tonguePositionSlider: AKPropertySlider!
    var tongueDiameterSlider: AKPropertySlider!
    var tensenessSlider: AKPropertySlider!
    var nasalitySlider: AKPropertySlider!

    override func setup() {
        addTitle("Vocal Tract")

        addSubview(AKButton(title: "Start") { button in
            if voc.isStarted {
                voc.stop()
                button.title = "Start"
            } else {
                voc.start()
                button.title = "Stop"
            }
        })

        frequencySlider = AKPropertySlider(property: "Frequency",
                                           value: voc.frequency,
                                           range: 0 ... 2_000
        ) { sliderValue in
            voc.frequency = sliderValue
        }
        addSubview(frequencySlider)

        tonguePositionSlider = AKPropertySlider(property: "Tongue Position", value: voc.tonguePosition) { sliderValue in
            voc.tonguePosition = sliderValue
        }
        addSubview(tonguePositionSlider)

        tongueDiameterSlider = AKPropertySlider(property: "Tongue Diameter", value: voc.tongueDiameter) { sliderValue in
            voc.tongueDiameter = sliderValue
        }
        addSubview(tongueDiameterSlider)

        tensenessSlider = AKPropertySlider(property: "Tenseness", value: voc.tenseness) { sliderValue in
            voc.tenseness = sliderValue
        }
        addSubview(tensenessSlider)

        nasalitySlider = AKPropertySlider(property: "Nasality", value: voc.nasality) { sliderValue in
            voc.nasality = sliderValue
        }
        addSubview(nasalitySlider)

        addSubview(AKButton(title: "Randomize") { _ in
            voc.frequency = self.frequencySlider.randomize()
            voc.tonguePosition = self.tonguePositionSlider.randomize()
            voc.tongueDiameter = self.tongueDiameterSlider.randomize()
            voc.tenseness = self.tensenessSlider.randomize()
            voc.nasality = self.nasalitySlider.randomize()
        })

        addSubview(AKPropertySlider(property: "Ramp Time",
                                    value: voc.rampTime,
                                    range: 0 ... 10,
                                    format: "%0.3f s"
        ) { time in
            voc.rampTime = time
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
