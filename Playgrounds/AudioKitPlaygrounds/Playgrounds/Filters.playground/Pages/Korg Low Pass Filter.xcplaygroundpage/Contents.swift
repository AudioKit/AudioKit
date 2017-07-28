//: ## Korg Low Pass Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0], baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowPassFilter = AKKorgLowPassFilter(player)

AudioKit.output = lowPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Korg Low Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(player: player, filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: lowPassFilter))

        addSubview(AKPropertySlider(property: "Cutoff Frequency",
                                    value: lowPassFilter.cutoffFrequency,
                                    range: 20 ... 5_000,
                                    format: "%0.1f Hz"
        ) { sliderValue in
            lowPassFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(property: "Resonance",
                                    value: lowPassFilter.resonance,
                                    range: 0 ... 2
        ) { sliderValue in
            lowPassFilter.resonance = sliderValue
        })

        addSubview(AKPropertySlider(property: "Saturation",
                                    value: lowPassFilter.saturation,
                                    range: 0 ... 2
        ) { sliderValue in
            lowPassFilter.saturation = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
