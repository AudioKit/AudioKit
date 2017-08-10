//: ## Expander
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var expander = AKExpander(player)

AudioKit.output = expander
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Expander")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: expander))
        addSubview(AKPropertySlider(property: "Ratio",
                                    value: expander.expansionRatio,
                                    range: 1 ... 50,
                                    format: "%0.2f"
        ) { sliderValue in
            expander.expansionRatio = sliderValue
        })

        addSubview(AKPropertySlider(property: "Threshold",
                                    value: expander.expansionThreshold,
                                    range: 1 ... 50,
                                    format: "%0.2f"
        ) { sliderValue in
            expander.expansionThreshold = sliderValue
        })
        addSubview(AKPropertySlider(property: "Attack Time",
                                    value: expander.attackTime,
                                    range: 0.001 ... 0.2,
                                    format: "%0.4f s"
        ) { sliderValue in
            expander.attackTime = sliderValue
        })
        addSubview(AKPropertySlider(property: "Release Time",
                                    value: expander.releaseTime,
                                    range: 0.01 ... 3,
                                    format: "%0.3f s"
        ) { sliderValue in
            expander.releaseTime = sliderValue
        })
        addSubview(AKPropertySlider(property: "Master Gain",
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
PlaygroundPage.current.liveView = PlaygroundView()
