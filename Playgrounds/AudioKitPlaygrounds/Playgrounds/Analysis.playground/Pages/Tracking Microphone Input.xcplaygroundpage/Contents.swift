//: ## Tracking Microphone Input
//:
import AudioKitPlaygrounds
import AudioKit

let mic = AKMicrophone()

//: Set the microphone device if you need to
if let inputs = AudioKit.availableInputs {
    try AudioKit.setInputDevice(inputs[0])
    try mic.setDevice(inputs[0])
}
let tracker = AKFrequencyTracker(mic, hopSize: 200, peakCount: 2_000)
let silence = AKBooster(tracker, gain: 0)

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = silence
AudioKit.start()

//: User Interface

class PlaygroundView: AKPlaygroundView {

    var trackedAmplitudeSlider: AKPropertySlider?
    var trackedFrequencySlider: AKPropertySlider?

    override func setup() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking Frequency")

        trackedAmplitudeSlider = AKPropertySlider(
            property: "Tracked Amplitude",
            format: "%0.3f",
            value: 0, maximum: 0.8,
            color: AKColor.green
        ) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedAmplitudeSlider)

        trackedFrequencySlider = AKPropertySlider(
            property: "Tracked Frequency",
            format: "%0.3f",
            value: 0, maximum: 2_400,
            color: AKColor.red
        ) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedFrequencySlider)

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
