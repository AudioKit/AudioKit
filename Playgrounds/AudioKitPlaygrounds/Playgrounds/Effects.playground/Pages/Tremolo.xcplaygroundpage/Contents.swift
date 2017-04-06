//: ## Tremolo
//: ###
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var tremolo = AKTremolo(player, waveform: AKTable(.positiveSine))
tremolo.depth = 0.5
tremolo.frequency = 8

AudioKit.output = tremolo
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Tremolo")
        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Frequency",
            format: "%0.3f Hz",
            value: tremolo.frequency, maximum: 20,
            color: AKColor.green
        ) { sliderValue in
            tremolo.frequency = sliderValue
        })

        addSubview(AKPropertySlider(
            property: "Depth",
            value: tremolo.depth,
            color: AKColor.red
        ) { sliderValue in
            tremolo.depth = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
