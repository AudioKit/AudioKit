//: ## Tracking Frequency of an Audio File
//: A more real-world example of tracking the pitch of an audio stream
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: "leadloop.wav")

var player = AKPlayer(audioFile: file)
player.isLooping = true
player.buffering = .always

let tracker = AKPitchTap(player)

engine.output = tracker
try engine.start()
player.play()

//: User Interface
import AudioKitUI

class LiveView: AKLiveViewController {

    var trackedAmplitudeSlider: AKSlider!
    var trackedFrequencySlider: AKSlider!

    override func viewDidLoad() {

        AKPlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking An Audio File")

        trackedAmplitudeSlider = AKSlider(property: "Tracked Amplitude", range: 0 ... 0.55) { _ in
            // Do nothing, just for display
        }
        addView(trackedAmplitudeSlider)

        trackedFrequencySlider = AKSlider(property: "Tracked Frequency",
                                          range: 0 ... 1_000,
                                          format: "%0.3f Hz"
        ) { _ in
            // Do nothing, just for display
        }
        addView(trackedFrequencySlider)

        addView(AKRollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
