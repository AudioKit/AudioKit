//: ## Graphic Equalizer
//: This playground builds a graphic equalizer from a set of equalizer filters

import AudioKit

let file = try AVAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AudioPlayer(file: file)
player.looping = true

let filterBand2 = EqualizerFilter(player, centerFrequency: 32, bandwidth: 44.7, gain: 1.0)
let filterBand3 = EqualizerFilter(filterBand2, centerFrequency: 64, bandwidth: 70.8, gain: 1.0)
let filterBand4 = EqualizerFilter(filterBand3, centerFrequency: 125, bandwidth: 141, gain: 1.0)
let filterBand5 = EqualizerFilter(filterBand4, centerFrequency: 250, bandwidth: 282, gain: 1.0)
let filterBand6 = EqualizerFilter(filterBand5, centerFrequency: 500, bandwidth: 562, gain: 1.0)
let filterBand7 = EqualizerFilter(filterBand6, centerFrequency: 1_000, bandwidth: 1_112, gain: 1.0)

engine.output = filterBand7
try engine.start()
player.play()

//: User Interface Set up

class LiveView: View {

    override func viewDidLoad() {
        addTitle("Graphic Equalizer")

        addLabel("Equalizer Gains")

        addView(Slider(property: "32Hz", value: filterBand2.gain, range: 0 ... 2) { sliderValue in
            filterBand2.gain = sliderValue
        })

        addView(Slider(property: "64Hz", value: filterBand3.gain, range: 0 ... 2) { sliderValue in
            filterBand3.gain = sliderValue
        })

        addView(Slider(property: "125Hz", value: filterBand4.gain, range: 0 ... 2) { sliderValue in
            filterBand4.gain = sliderValue
        })

        addView(Slider(property: "250Hz", value: filterBand5.gain, range: 0 ... 2) { sliderValue in
            filterBand5.gain = sliderValue
        })

        addView(Slider(property: "500Hz", value: filterBand6.gain, range: 0 ... 2) { sliderValue in
            filterBand6.gain = sliderValue
        })

        addView(Slider(property: "1000Hz", value: filterBand7.gain, range: 0 ... 2) { sliderValue in
            filterBand7.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()
