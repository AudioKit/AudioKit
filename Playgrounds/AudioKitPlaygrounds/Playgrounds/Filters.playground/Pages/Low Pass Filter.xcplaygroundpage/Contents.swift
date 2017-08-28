//: ## Low Pass Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0])

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowPassFilter = AKLowPassFilter(player)
lowPassFilter.cutoffFrequency = 6_900 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: lowPassFilter))

        addSubview(AKPropertySlider(property: "Cutoff Frequency",
                                    value: lowPassFilter.cutoffFrequency,
                                    range: 20 ... 22_050,
                                    taper: 5,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            lowPassFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Resonance",
                                    value: lowPassFilter.resonance,
                                    range: -20 ... 40,
                                    format: "%0.1f dB"
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
