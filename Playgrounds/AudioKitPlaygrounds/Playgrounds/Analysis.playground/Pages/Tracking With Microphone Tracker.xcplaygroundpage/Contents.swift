//: ## Tracking With Microphone Tracker
//:
//: AKMicrophoneTracker is a standalone microphone tracking class
//: that doesn't require you to set up an audio signal chain.
import AudioKitPlaygrounds
import AudioKit

let tracker = AKMicrophoneTracker()
tracker.start()

//: User Interface
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    var trackedAmplitudeSlider: AKPropertySlider?
    var trackedFrequencySlider: AKPropertySlider?

    override func setup() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking With Microphone Tracker")

        trackedAmplitudeSlider = AKPropertySlider(property: "Tracked Amplitude", range: 0 ... 0.8) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedAmplitudeSlider)

        trackedFrequencySlider = AKPropertySlider(property: "Tracked Frequency",
                                                  range: 0 ... 2_400,
                                                  format: "%0.3f Hz"
        ) { _ in
            // Do nothing, just for display
        }
        addSubview(trackedFrequencySlider)

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
