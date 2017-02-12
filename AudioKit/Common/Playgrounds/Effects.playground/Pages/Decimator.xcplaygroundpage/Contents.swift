//: ## Decimator
//: Decimation is a type of digital distortion like bit crushing,
//: but instead of directly stating what bit depth and sample rate you want,
//: it is done through setting "decimation" and "rounding" parameters.

import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a decimator
var decimator = AKDecimator(player)
decimator.decimation = 0.5 // Normalized Value 0 - 1
decimator.rounding = 0.5 // Normalized Value 0 - 1
decimator.mix = 0.5 // Normalized Value 0 - 1

AudioKit.output = decimator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Decimator")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Decimation",
            value: decimator.decimation,
            color: AKColor.green
        ) { sliderValue in
            decimator.decimation = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Rounding",
            value: decimator.rounding,
            color: AKColor.red
        ) { sliderValue in
            decimator.rounding = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Mix",
            value: decimator.mix,
            color: AKColor.cyan
        ) { sliderValue in
            decimator.mix = sliderValue
            })

    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
