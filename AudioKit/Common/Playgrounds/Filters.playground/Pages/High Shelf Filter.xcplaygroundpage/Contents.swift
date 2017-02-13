//: ## High Shelf Filter
//:

import AudioKit

let file = try AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var highShelfFilter = AKHighShelfFilter(player)
highShelfFilter.cutoffFrequency = 10_000 // Hz
highShelfFilter.gain = 0 // dB

AudioKit.output = highShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("High Shelf Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: highShelfFilter))

        addSubview(AKPropertySlider(
            property: "Cutoff Frequency",
            format: "%0.1f Hz",
            value: highShelfFilter.cutoffFrequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            highShelfFilter.cutoffFrequency = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Gain",
            format: "%0.1f dB",
            value: highShelfFilter.gain, minimum: -40, maximum: 40,
            color: AKColor.red
        ) { sliderValue in
            highShelfFilter.gain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
