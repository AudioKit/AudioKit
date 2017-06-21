//: ## Vocal Tract
//:
import AudioKitPlaygrounds
import AudioKit

let voc = AKVocalTract()

AudioKit.output = voc
AudioKit.start()

class PlaygroundView: AKPlaygroundView {

    var current = 0
    override func setup() {
        addTitle("Vocal Tract")

        addSubview(AKButton(title: "Start") {
            if voc.isStarted {
                voc.stop()
                return "Start"
            } else {
                voc.start()
                return "Stop"
            }
        })

        addSubview(AKPropertySlider(
            property: "Frequency",
            value: voc.frequency, minimum: 0.0, maximum: 2_000) {
                sliderValue in
                voc.frequency = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Tongue Position",
            value: voc.tonguePosition, minimum: 0.0, maximum: 1) {
                sliderValue in
                voc.tonguePosition = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Tongue Diameter",
            value: voc.tongueDiameter, minimum: 0.0, maximum: 1) {
                sliderValue in
                voc.tongueDiameter = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Tenseness",
            value: voc.tenseness, minimum: 0.0, maximum: 1) {
                sliderValue in
                voc.tenseness = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Nasality",
            value: voc.nasality, minimum: 0.0, maximum: 1) {
                sliderValue in
                voc.nasality = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Ramp Time",
            format: "%0.3f s",
            value: voc.rampTime, maximum: 10,
            color: AKColor.orange
        ) { time in
            voc.rampTime = time
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
