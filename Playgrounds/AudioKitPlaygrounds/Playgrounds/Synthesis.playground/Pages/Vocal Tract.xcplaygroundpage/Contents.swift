//: ## Vocal Tract
//:
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let voc = AKVocalTract()

AudioKit.output = voc
try AudioKit.start()

class LiveView: AKLiveViewController {

    var current = 0

    var frequencySlider: AKSlider!
    var tonguePositionSlider: AKSlider!
    var tongueDiameterSlider: AKSlider!
    var tensenessSlider: AKSlider!
    var nasalitySlider: AKSlider!

    override func viewDidLoad() {
        addTitle("Vocal Tract")

        addView(AKButton(title: "Start") { button in
            if voc.isStarted {
                voc.stop()
                button.title = "Start"
            } else {
                voc.start()
                button.title = "Stop"
            }
        })

        frequencySlider = AKSlider(property: "Frequency",
                                   value: voc.frequency,
                                   range: 0 ... 2_000
        ) { sliderValue in
            voc.frequency = sliderValue
        }
        addView(frequencySlider)

        tonguePositionSlider = AKSlider(property: "Tongue Position", value: voc.tonguePosition) { sliderValue in
            voc.tonguePosition = sliderValue
        }
        addView(tonguePositionSlider)

        tongueDiameterSlider = AKSlider(property: "Tongue Diameter", value: voc.tongueDiameter) { sliderValue in
            voc.tongueDiameter = sliderValue
        }
        addView(tongueDiameterSlider)

        tensenessSlider = AKSlider(property: "Tenseness", value: voc.tenseness) { sliderValue in
            voc.tenseness = sliderValue
        }
        addView(tensenessSlider)

        nasalitySlider = AKSlider(property: "Nasality", value: voc.nasality) { sliderValue in
            voc.nasality = sliderValue
        }
        addView(nasalitySlider)

        addView(AKButton(title: "Randomize") { _ in
            voc.frequency = self.frequencySlider.randomize()
            voc.tonguePosition = self.tonguePositionSlider.randomize()
            voc.tongueDiameter = self.tongueDiameterSlider.randomize()
            voc.tenseness = self.tensenessSlider.randomize()
            voc.nasality = self.nasalitySlider.randomize()
        })

        addView(AKSlider(property: "Ramp Duration",
                         value: voc.rampDuration,
                         range: 0 ... 10,
                         format: "%0.3f s"
        ) { time in
            voc.rampDuration = time
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
