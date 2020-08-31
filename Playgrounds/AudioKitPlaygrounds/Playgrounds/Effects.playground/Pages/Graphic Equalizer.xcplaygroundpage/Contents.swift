//: ## Graphic Equalizer
//: This playground builds a graphic equalizer from a set of equalizer filters
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

let filterBand2 = AKEqualizerFilter(player, centerFrequency: 32, bandwidth: 44.7, gain: 1.0)
let filterBand3 = AKEqualizerFilter(filterBand2, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
let filterBand4 = AKEqualizerFilter(filterBand3, centerFrequency: 125, bandwidth: 141, gain: 1.0)
let filterBand5 = AKEqualizerFilter(filterBand4, centerFrequency: 250, bandwidth: 282, gain: 1.0)
let filterBand6 = AKEqualizerFilter(filterBand5, centerFrequency: 500, bandwidth: 562, gain: 1.0)
let filterBand7 = AKEqualizerFilter(filterBand6, centerFrequency: 1_000, bandwidth: 1_112, gain: 1.0)

engine.output = filterBand7
try engine.start()
player.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Graphic Equalizer")

        addView(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addLabel("Equalizer Gains")

        addView(AKSlider(property: "32Hz", value: filterBand2.gain, range: 0 ... 2) { sliderValue in
            filterBand2.gain = sliderValue
        })

        addView(AKSlider(property: "64Hz", value: filterBand3.gain, range: 0 ... 2) { sliderValue in
            filterBand3.gain = sliderValue
        })

        addView(AKSlider(property: "125Hz", value: filterBand4.gain, range: 0 ... 2) { sliderValue in
            filterBand4.gain = sliderValue
        })

        addView(AKSlider(property: "250Hz", value: filterBand5.gain, range: 0 ... 2) { sliderValue in
            filterBand5.gain = sliderValue
        })

        addView(AKSlider(property: "500Hz", value: filterBand6.gain, range: 0 ... 2) { sliderValue in
            filterBand6.gain = sliderValue
        })

        addView(AKSlider(property: "1000Hz", value: filterBand7.gain, range: 0 ... 2) { sliderValue in
            filterBand7.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
