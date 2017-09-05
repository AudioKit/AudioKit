//: ## DynaRage Tube Compressor

import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

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
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("DynaRage Tube Compressor")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Compressor") { button in
            let node = effect
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Compressor" : "Start Compressor"
        })

        addView(AKSlider(property: "Threshold",
                         value: effect.threshold,
                         range: -100.0 ... 0.0,
                         format: "%0.2f dB"
        ) { sliderValue in
            effect.threshold = sliderValue
        })

        addView(AKSlider(property: "Ratio",
                         value: effect.ratio,
                         range: 1.0 ... 20.0,
                         format: "%0.0f:1"
        ) { sliderValue in
            effect.ratio = sliderValue
        })

        addView(AKSlider(property: "Attack Time",
                         value: effect.attackTime,
                         range: 0.1 ... 500.0,
                         format: "%0.2f ms"
        ) { sliderValue in
            effect.attackTime = sliderValue
        })

        addView(AKSlider(property: "Release Time",
                         value: effect.releaseTime,
                         range: 0.01 ... 500.0,
                         format: "%0.2f ms"
        ) { sliderValue in
            effect.releaseTime = sliderValue
        })

        addView(AKSlider(property: "Rage Amount",
                         value: effect.rageAmount,
                         range: 1 ... 20,
                         format: "%0.2f"
        ) { sliderValue in
            effect.rageAmount = sliderValue
        })

        addView(AKButton(title: "Rage Off") { button in
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
PlaygroundPage.current.liveView = LiveView()
