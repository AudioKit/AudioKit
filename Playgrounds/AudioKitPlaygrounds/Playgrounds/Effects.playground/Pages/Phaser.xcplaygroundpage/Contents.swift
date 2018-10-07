//: ## Phaser
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var phaser = AKPhaser(player)

AudioKit.output = phaser
try AudioKit.start()

player.play()

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Phaser")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKSlider(property: "Feedback", value: phaser.feedback) { _ in
                            phaser.feedback
        })

        addView(AKSlider(property: "Depth", value: phaser.depth) { _ in
            phaser.depth
        })

        addView(AKSlider(property: "Notch Minimum",
                         value: phaser.notchMinimumFrequency,
                         range: 20 ... 5_000,
                         format: "%0.1f Hz"
        ) { sliderValue in
            phaser.notchMinimumFrequency = sliderValue
        })

        addView(AKSlider(property: "Notch Maximum",
                         value: phaser.notchMaximumFrequency,
                         range: 20 ... 10_000,
                         format: "%0.1f Hz"
        ) { sliderValue in
            phaser.notchMaximumFrequency = sliderValue
        })

        addView(AKSlider(property: "Notch Width",
                         value: phaser.notchWidth,
                         range: 10 ... 5_000,
                         format: "%0.1f Hz"
        ) { sliderValue in
            phaser.notchWidth = sliderValue
        })

        addView(AKSlider(property: "Notch Frequency",
                         value: phaser.notchFrequency,
                         range: 1.1 ... 4,
                         format: "%0.2f Hz"
        ) { sliderValue in
            phaser.notchFrequency = sliderValue
        })

        addView(AKSlider(property: "LFO BPM",
                         value: phaser.lfoBPM,
                         range: 24 ... 360,
                         format: "%0.2f Hz"
        ) { sliderValue in
            phaser.lfoBPM = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
