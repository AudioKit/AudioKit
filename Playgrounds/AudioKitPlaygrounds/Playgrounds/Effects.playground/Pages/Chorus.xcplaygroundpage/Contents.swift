//: ## Chorus
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var chorus = AKChorus(player)

engine.output = chorus
try engine.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Chorus")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Feedback",
                         value: chorus.feedback,
                         range: -0.95 ... 0.95) { sliderValue in
                            chorus.feedback = sliderValue
        })

        addView(AKSlider(property: "Depth", value: chorus.depth) { sliderValue in
            chorus.depth = sliderValue
        })

        addView(AKSlider(property: "Dry Wet Mix", value: chorus.dryWetMix) { sliderValue in
            chorus.dryWetMix = sliderValue
        })

        addView(AKSlider(property: "Frequency",
                         value: chorus.frequency,
                         range: 0.1 ... 10,
                         format: "%0.1f Hz"
        ) { sliderValue in
            chorus.frequency = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
