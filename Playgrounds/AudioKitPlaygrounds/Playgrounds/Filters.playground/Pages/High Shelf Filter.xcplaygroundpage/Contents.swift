//: ## High Shelf Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var highShelfFilter = AKHighShelfFilter(player)
highShelfFilter.cutoffFrequency = 10_000 // Hz
highShelfFilter.gain = 0 // dB

AudioKit.output = highShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("High Shelf Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: highShelfFilter))

        addSubview(AKPropertySlider(property: "Cutoff Frequency",
                                    value: highShelfFilter.cutoffFrequency,
                                    range: 20 ... 22_050,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            highShelfFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Gain",
                                    value: highShelfFilter.gain,
                                    range: -40 ... 40,
                                    format: "%0.1f dB"
        ) { sliderValue in
            highShelfFilter.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
