//: ## Expander
//: ##
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = AKPlayer(audioFile: file)
player.isLooping = true

var expander = AKExpander(player)

AudioKit.output = expander
AudioKit.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Expander")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Expander") { button in
            let node = expander
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Expander" : "Start Expander"
        })

        addView(AKSlider(property: "Ratio",
                         value: expander.expansionRatio,
                         range: 1 ... 50,
                         format: "%0.2f"
        ) { sliderValue in
            expander.expansionRatio = sliderValue
        })

        addView(AKSlider(property: "Threshold",
                         value: expander.expansionThreshold,
                         range: 1 ... 50,
                         format: "%0.2f"
        ) { sliderValue in
            expander.expansionThreshold = sliderValue
        })
        addView(AKSlider(property: "Attack Time",
                         value: expander.attackTime,
                         range: 0.001 ... 0.2,
                         format: "%0.4f s"
        ) { sliderValue in
            expander.attackTime = sliderValue
        })
        addView(AKSlider(property: "Release Time",
                         value: expander.releaseTime,
                         range: 0.01 ... 3,
                         format: "%0.3f s"
        ) { sliderValue in
            expander.releaseTime = sliderValue
        })
        addView(AKSlider(property: "Master Gain",
                         value: expander.masterGain,
                         range: -40 ... 40,
                         format: "%0.2f dB"
        ) { sliderValue in
            expander.masterGain = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
