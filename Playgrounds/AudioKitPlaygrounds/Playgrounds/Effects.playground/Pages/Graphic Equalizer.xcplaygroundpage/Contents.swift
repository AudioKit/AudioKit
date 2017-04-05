//: ## Graphic Equalizer
//: This playground builds a graphic equalizer from a set of equalizer filters
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowFilter = AKEqualizerFilter(player, centerFrequency: 50, bandwidth: 100, gain: 1.0)
var midFilter = AKEqualizerFilter(lowFilter, centerFrequency: 350, bandwidth: 300, gain: 1.0)
var highFilter = AKEqualizerFilter(midFilter, centerFrequency: 5_000, bandwidth: 1_000, gain: 1.0)

AudioKit.output = highFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Graphic Equalizer")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addLabel("Equalizer Gains")

        addSubview(AKPropertySlider(
            property: "Low",
            value: lowFilter.gain, maximum: 10,
            color: AKColor.red
        ) { sliderValue in
            lowFilter.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Mid",
            value: midFilter.gain, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            midFilter.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "High",
            value: highFilter.gain, maximum: 10,
            color: AKColor.cyan
        ) { sliderValue in
            highFilter.gain = sliderValue
        })
    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
