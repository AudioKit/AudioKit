//: ## Clipper
//: ##
import AudioKitPlaygrounds
import AudioKit

let file = try AKAudioFile(readFileName: playgroundAudioFiles[0],
                           baseDir: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var clipper = AKClipper(player)
clipper.limit = 0.1

AudioKit.output = clipper
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Clipper")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: playgroundAudioFiles))

        addSubview(AKPropertySlider(
            property: "Limit",
            value: clipper.limit,
            color: AKColor.green
        ) { sliderValue in
            clipper.limit = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
