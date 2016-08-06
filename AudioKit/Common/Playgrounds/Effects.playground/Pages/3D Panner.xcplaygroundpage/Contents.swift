//: ## 3D Panner
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)
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
            color: AKColor.redColor()
        ) { sliderValue in
            panner.x = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Y",
            value: panner.y, minimum: -10, maximum: 10,
            color: AKColor.greenColor()
        ) { sliderValue in
            panner.y = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Z",
            value: panner.z, minimum: -10, maximum: 10,
            color: AKColor.cyanColor()
        ) { sliderValue in
            panner.z = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()
