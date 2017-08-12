//: [Previous](@previous)

import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var effect = AKDynaRageCompressor(player)
effect.threshold
effect.ratio
effect.attackTime
effect.releaseTime
effect.rageIsOn
effect.rageAmount

AudioKit.output = effect
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("DynaRage Tube Compressor")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: effect))

        addSubview(AKPropertySlider(property: "Threshold",
                                    value: effect.threshold,
                                    range: -100.0 ... 0.0,
                                    format: "%0.2f dB"
        ) { sliderValue in
            effect.threshold = sliderValue
        })

        addSubview(AKPropertySlider(property: "Ratio",
                                    value: effect.ratio,
                                    range: 1.0 ... 20.0,
                                    format: "%0.0f:1"
        ) { sliderValue in
            effect.ratio = sliderValue
        })

        addSubview(AKPropertySlider(property: "Attack Time",
                                    value: effect.attackTime,
                                    range: 0.1 ... 500.0,
                                    format: "%0.2f ms"
        ) { sliderValue in
            effect.attackTime = sliderValue
        })

        addSubview(AKPropertySlider(property: "Release Time",
                                    value: effect.releaseTime,
                                    range: 0.01 ... 500.0,
                                    format: "%0.2f ms"
        ) { sliderValue in
            effect.releaseTime = sliderValue
        })

        addSubview(AKPropertySlider(property: "Rage Amount",
                                    value: effect.rageAmount,
                                    range: 1 ... 20,
                                    format: "%0.2f"
        ) { sliderValue in
            effect.rageAmount = sliderValue
        })

        addSubview(AKButton(title: "Rage Off") { button in
            effect.rageIsOn = !effect.rageIsOn
            if effect.rageIsOn {
                button.title = "Rage Off"
            } else {
                button.title = "Rage On"
            }
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: [Next](@next)
