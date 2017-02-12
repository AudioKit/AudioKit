//: ## 3D Panner
//: ###
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

let panner = AK3DPanner(player)

AudioKit.output = panner
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("3D Panner")

        addSubview(AKResourcesAudioFileLoaderView(
            player: player,
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "X",
            value: panner.x, minimum: -10, maximum: 10,
            color: AKColor.red
        ) { sliderValue in
            panner.x = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Y",
            value: panner.y, minimum: -10, maximum: 10,
            color: AKColor.green
        ) { sliderValue in
            panner.y = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Z",
            value: panner.z, minimum: -10, maximum: 10,
            color: AKColor.cyan
        ) { sliderValue in
            panner.z = sliderValue
            })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()
