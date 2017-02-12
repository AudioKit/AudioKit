//: ## Low Pass Butterworth Filter
//: A low-pass filter takes an audio signal as an input, and cuts out the
//: high-frequency components of the audio signal, allowing for the
//: lower frequency components to "pass through" the filter.
//:

import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var filter = AKLowPassButterworthFilter(player)
filter.cutoffFrequency = 500 // Hz

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Low Pass Butterworth Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: filter.cutoffFrequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            filter.cutoffFrequency = sliderValue
            })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
