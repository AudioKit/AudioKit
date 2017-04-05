//: ## Compressor
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var compressor = AKCompressor(player)

AudioKit.output = compressor
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Compressor")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKBypassButton(node: compressor))
        addSubview(AKPropertySlider(
            property: "Threshold",
            format: "%0.2f dB",
            value: compressor.threshold, minimum: -40, maximum: 20
        ) { sliderValue in
            compressor.threshold = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Headroom",
            format: "%0.2f dB",
            value: compressor.headRoom, minimum: 0.1, maximum: 40
        ) { sliderValue in
            compressor.headRoom = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Attack Time",
            format: "%0.4f s",
            value: compressor.attackTime, minimum: 0.001, maximum: 0.2
        ) { sliderValue in
            compressor.attackTime = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Release Time",
            format: "%0.3f s",
            value: compressor.releaseTime, minimum: 0.01, maximum: 3
        ) { sliderValue in
            compressor.releaseTime = sliderValue
        })
        addSubview(AKPropertySlider(
            property: "Master Gain",
            format: "%0.2f dB",
            value: compressor.masterGain, minimum: -40, maximum: 40
        ) { sliderValue in
            compressor.masterGain = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
