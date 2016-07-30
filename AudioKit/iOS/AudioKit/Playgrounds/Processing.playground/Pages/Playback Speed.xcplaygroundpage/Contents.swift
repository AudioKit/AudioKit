//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Playback Speed
//: ### This playground uses the AKVariSpeed node to change the playback speed of a file
//: ### (which also affects the pitch)
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.audioResourceFileNames[0],
                           baseDir: .Resources)
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
            filenames: AKPlaygroundView.audioResourceFileNames))
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        addSubview(AKPropertySlider(
            property: "Rate",
            format: "%0.3f",
            value: variSpeed.rate, minimum: 0.3125, maximum: 5,
            color: AKColor.greenColor()
        ) { sliderValue in
            variSpeed.rate = sliderValue
            })

    }


    func process() {
        variSpeed.start()
    }

    func bypass() {
        variSpeed.bypass()
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
