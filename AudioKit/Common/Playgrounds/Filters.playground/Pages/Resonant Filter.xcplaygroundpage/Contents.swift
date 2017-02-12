//: ## Resonant Filter
//:

import AudioKit

let file = try? AKAudioFile(readFileName: filtersPlaygroundFiles[0],
                            baseDir: .resources)

let player = try AKAudioPlayer(file: file!)
player.looping = true

var filter = AKResonantFilter(player)
filter.frequency = 5_000 // Hz
filter.bandwidth = 600  // Cents

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Resonant Filter")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: filtersPlaygroundFiles))

        addSubview(AKBypassButton(node: filter))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.1f Hz",
            value: filter.frequency, minimum: 20, maximum: 22_050,
            color: AKColor.green
        ) { sliderValue in
            filter.frequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Bandwidth",
            format: "%0.1f Hz",
            value: filter.bandwidth, minimum: 100, maximum: 1_200,
            color: AKColor.red
        ) { sliderValue in
            filter.bandwidth = sliderValue
            })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
