//: ## Flanger
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var flanger = AKFlanger(player)

engine.output = flanger

try engine.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Flanger")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Feedback",
                         value: flanger.feedback,
                         range: -0.95 ... 0.95) { sliderValue in
            flanger.feedback = sliderValue
        })

        addView(AKSlider(property: "Depth", value: flanger.depth) { sliderValue in
            flanger.depth = sliderValue
        })

        addView(AKSlider(property: "Dry Wet Mix", value: flanger.dryWetMix) { sliderValue in
            flanger.dryWetMix = sliderValue
        })

        addView(AKSlider(property: "Frequency",
                         value: flanger.frequency,
                         range: 0.1 ... 10,
                         format: "%0.1f Hz"
        ) { sliderValue in
            flanger.frequency = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
