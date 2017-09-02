//: ## Three-Pole Low Pass Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKThreePoleLowpassFilter(player)
filter.cutoffFrequency = 300 // Hz
filter.resonance = 0.6
filter.rampTime = 0.1

AudioKit.output = filter
AudioKit.start()

player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Three Pole Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKSlider(property: "Cutoff Frequency",
                            value: filter.cutoffFrequency,
                            range: 0 ... 5_000,
                            taper: 5,
                            format: "%0.1f Hz"
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
        })

        addSubview(AKSlider(property: "Resonance", value: filter.resonance) { sliderValue in
            filter.resonance = sliderValue
        })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
