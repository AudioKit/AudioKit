//: ## Tracking Frequency of an Audio File
//: A more real-world example of tracking the pitch of an audio stream

import AudioKit

let file = try AVAudioFile(readFileName: "leadloop.wav")

var player = AudioPlayer(audioFile: file)
player.isLooping = true
player.buffering = .always

let tracker = PitchTap(player)

engine.output = tracker
try engine.start()
player.play()

//: User Interface

class LiveView: View {

    var trackedAmplitudeSlider: Slider!
    var trackedFrequencySlider: Slider!

    override func viewDidLoad() {

        PlaygroundLoop(every: 0.1) {
            self.trackedAmplitudeSlider?.value = tracker.amplitude
            self.trackedFrequencySlider?.value = tracker.frequency
        }

        addTitle("Tracking An Audio File")

        trackedAmplitudeSlider = Slider(property: "Tracked Amplitude", range: 0 ... 0.55) { _ in
            // Do nothing, just for display
        }
        addView(trackedAmplitudeSlider)

        trackedFrequencySlider = Slider(property: "Tracked Frequency",
                                          range: 0 ... 1_000,
                                          format: "%0.3f Hz"
        ) { _ in
            // Do nothing, just for display
        }
        addView(trackedFrequencySlider)

        addView(RollingOutputPlot.createView())
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
