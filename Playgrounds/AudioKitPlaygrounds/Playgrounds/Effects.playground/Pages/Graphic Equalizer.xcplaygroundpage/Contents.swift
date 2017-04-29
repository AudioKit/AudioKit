//: ## Graphic Equalizer
//: This playground builds a graphic equalizer from a set of equalizer filters
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

let filterBand2 = AKEqualizerFilter(player, centerFrequency: 32, bandwidth: 44.7, gain: 1.0)
let filterBand3 = AKEqualizerFilter(filterBand2, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
let filterBand4 = AKEqualizerFilter(filterBand3, centerFrequency: 125, bandwidth: 141, gain: 1.0)
let filterBand5 = AKEqualizerFilter(filterBand4, centerFrequency: 250, bandwidth: 282, gain: 1.0)
let filterBand6 = AKEqualizerFilter(filterBand5, centerFrequency: 500, bandwidth: 562, gain: 1.0)
let filterBand7 = AKEqualizerFilter(filterBand6, centerFrequency: 1_000, bandwidth: 1_112, gain: 1.0)

AudioKit.output = filterBand7
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
            property: "32Hz",
            value: filterBand2.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand2.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "64Hz",
            value: filterBand3.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand3.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "125Hz",
            value: filterBand4.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand4.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "250Hz",
            value: filterBand5.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand5.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "500Hz",
            value: filterBand6.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand6.gain = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "1000Hz",
            value: filterBand7.gain, maximum: 2,
            color: AKColor.red
        ) { sliderValue in
            filterBand7.gain = sliderValue
        })

    }

}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
