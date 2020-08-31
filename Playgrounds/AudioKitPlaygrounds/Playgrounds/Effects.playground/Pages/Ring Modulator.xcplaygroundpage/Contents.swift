//: ## Ring Modulator
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var ringModulator = AKRingModulator(player)
ringModulator.frequency1 = 440 // Hz
ringModulator.frequency2 = 660 // Hz
ringModulator.balance = 0.5
ringModulator.mix = 0.5

engine.output = ringModulator
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Ring Modulator")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addView(AKButton(title: "Stop Ring Modulator") { button in
            let node = ringModulator
            node.isStarted ? node.stop() : node.play()
            button.title = node.isStarted ? "Stop Ring Modulator" : "Start Ring Modulator"
        })

        addView(AKSlider(property: "Frequency 1",
                         value: ringModulator.frequency1,
                         range: 0.5 ... 8_000,
                         format: "%0.2f Hz"
        ) { sliderValue in
            ringModulator.frequency1 = sliderValue
        })

        addView(AKSlider(property: "Frequency 2",
                         value: ringModulator.frequency2,
                         range: 0.5 ... 8_000,
                         format: "%0.2f Hz"
        ) { sliderValue in
            ringModulator.frequency2 = sliderValue
        })

        addView(AKSlider(property: "Balance", value: ringModulator.balance) { sliderValue in
            ringModulator.balance = sliderValue
        })

        addView(AKSlider(property: "Mix", value: ringModulator.mix) { sliderValue in
            ringModulator.mix = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
