//: ## Low Pass Butterworth Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKLowPassButterworthFilter(player)
filter.cutoffFrequency = 500 // Hz

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Low Pass Butterworth Filter")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop") { button in
            filter.isStarted ? filter.stop() : filter.play()
            button.title = filter.isStarted ? "Stop" : "Start"
        })

        addView(AKSlider(property: "Cutoff Frequency",
                         value: filter.cutoffFrequency,
                         range: 20 ... 10_000,
                         taper: 5,
                         format: "%0.1f Hz"
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
