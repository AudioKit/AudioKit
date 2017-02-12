//: ## Playback Speed
//: This playground uses the AKVariSpeed node to change the playback speed of a file
//: (which also affects the pitch)
//:
import AudioKit

let file = try AKAudioFile(readFileName: playbackPlaygroundFiles[0],
                           baseDir: .resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

var variSpeed = AKVariSpeed(player)
variSpeed.rate = 2.0

AudioKit.output = variSpeed
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Playback Speed")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: playbackPlaygroundFiles))

        addSubview(AKBypassButton(node: variSpeed))

        addSubview(AKPropertySlider(
            property: "Rate",
            format: "%0.3f",
            value: variSpeed.rate, minimum: 0.312_5, maximum: 5,
            color: AKColor.green
        ) { sliderValue in
            variSpeed.rate = sliderValue
            })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
