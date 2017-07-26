//: ## High Pass Filter
//: A high-pass filter takes an audio signal as an input, and cuts out the
//: low-frequency components of the audio signal, allowing for the higher frequency
//: components to "pass through" the filter.
//:
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var highPassFilter = AKHighPassFilter(player)
highPassFilter.cutoffFrequency = 6_900 // Hz
highPassFilter.resonance = 0 // dB

AudioKit.output = highPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("High Pass Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: playgroundAudioFiles))

        addSubview(AKBypassButton(node: highPassFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: highPassFilter.cutoffFrequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            highPassFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Resonance",
            format: "%0.1f dB",
            value: highPassFilter.resonance, minimum: -20, maximum: 40,
            color: AKColor.red
        ) { sliderValue in
            highPassFilter.resonance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
