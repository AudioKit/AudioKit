//: ## Clipper
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

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
            filenames: processingPlaygroundFiles))

        addSubview(AKPropertySlider(
            property: "Limit",
            value: clipper.limit,
            color: AKColor.greenColor()
        ) { sliderValue in
            clipper.limit = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()