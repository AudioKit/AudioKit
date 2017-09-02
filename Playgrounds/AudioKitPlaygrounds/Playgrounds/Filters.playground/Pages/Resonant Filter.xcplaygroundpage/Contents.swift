//: ## Resonant Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKResonantFilter(player)
filter.frequency = 5_000 // Hz
filter.bandwidth = 600  // Cents

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Resonant Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKSlider(property: "Frequency",
                            value: filter.frequency,
                            range: 20 ... 22_050,
                            taper: 5,
                            format: "%0.1f Hz"
        ) { sliderValue in
            filter.frequency = sliderValue
        })

        addSubview(AKSlider(property: "Bandwidth",
                            value: filter.bandwidth,
                            range: 100 ... 1_200,
                            format: "%0.1f Hz"
        ) { sliderValue in
            filter.bandwidth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
