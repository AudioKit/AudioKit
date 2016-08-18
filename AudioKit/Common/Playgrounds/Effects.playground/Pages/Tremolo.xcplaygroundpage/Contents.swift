//: ## Tremolo
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: processingPlaygroundFiles[0],
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var tremolo = AKTremolo(player, waveform: AKTable(.PositiveSine))
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
            color: AKColor.greenColor()
        ) { sliderValue in
            tremolo.frequency = sliderValue
            })

        addSubview(AKPropertySlider(
            property: "Depth",
            value: tremolo.depth,
            color: AKColor.redColor()
        ) { sliderValue in
            tremolo.depth = sliderValue
            })
    }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = PlaygroundView()

