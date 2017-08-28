//: ## Low Shelf Filter
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var lowShelfFilter = AKLowShelfFilter(player)
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

AudioKit.output = lowShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Shelf Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: lowShelfFilter))

        addSubview(AKPropertySlider(property: "Cutoff Frequency",
                                    value: lowShelfFilter.cutoffFrequency,
                                    range: 10 ... 200,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            lowShelfFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Gain",
                                    value: lowShelfFilter.gain,
                                    range: -40 ... 40,
                                    format: "%0.1f dB"
        ) { sliderValue in
            lowShelfFilter.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
