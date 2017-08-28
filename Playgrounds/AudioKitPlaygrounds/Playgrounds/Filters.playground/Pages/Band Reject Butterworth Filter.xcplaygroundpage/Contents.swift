//: ## Band Reject Butterworth Filter
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])
let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKBandRejectButterworthFilter(player)
filter.centerFrequency = 5_000 // Hz
filter.bandwidth = 600  // Cents

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up
import AudioKitUI

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Band Reject Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(property: "Center Frequency",
                                    value: filter.centerFrequency,
                                    range: 20 ... 10_000,
                                    taper: 5,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            filter.centerFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Bandwidth",
                                    value: filter.bandwidth,
                                    range: 100 ... 12_000,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            filter.bandwidth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
