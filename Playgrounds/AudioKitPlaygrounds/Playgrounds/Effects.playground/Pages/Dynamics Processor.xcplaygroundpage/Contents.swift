//: ## Dynamics Processor
//: The AKDynamicsProcessor is both a compressor and an expander based on
//: Apple's Dynamics Processor audio unit. threshold and headRoom (similar to
//: 'ratio' you might be more familiar with) are specific to the compressor,
//: expansionRatio and expansionThreshold control the expander.
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var effect = AKDynamicsProcessor(player)
effect.threshold
effect.headRoom
effect.expansionRatio
effect.expansionThreshold
effect.attackTime
effect.releaseTime
effect.masterGain

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Dynamics Processor")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: effect))

        addSubview(AKSlider(property: "Threshold",
                            value: effect.threshold,
                            range: -40 ... 20,
                            format: "%0.2f dB"
        ) { sliderValue in
            effect.threshold = sliderValue
        })

        addSubview(AKSlider(property: "Head Room",
                            value: effect.headRoom,
                            range: 0.1 ... 40,
                            format: "%0.2f dB"
        ) { sliderValue in
            effect.headRoom = sliderValue
        })

        addSubview(AKSlider(property: "Expansion Ratio",
                            value: effect.expansionRatio,
                            range: 1 ... 50
        ) { sliderValue in
            effect.expansionRatio = sliderValue
        })

        addSubview(AKSlider(property: "Expansion Threshold",
                            value: effect.expansionThreshold,
                            range: 1 ... 50
        ) { sliderValue in
            effect.expansionThreshold = sliderValue
        })

        addSubview(AKSlider(property: "Attack Time",
                            value: effect.attackTime,
                            range: 0.000_1 ... 0.2,
                            format: "%0.3f s"
        ) { sliderValue in
            effect.attackTime = sliderValue
        })

        addSubview(AKSlider(property: "Release Time",
                            value: effect.releaseTime,
                            range: 0.01 ... 3,
                            format: "%0.3f s"
        ) { sliderValue in
            effect.releaseTime = sliderValue
        })

        addSubview(AKSlider(property: "Master Gain",
                            value: effect.masterGain,
                            range: -40 ... 40,
                            format: "%0.2f dB"
        ) { sliderValue in
            effect.masterGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
