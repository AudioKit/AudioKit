//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tremolo
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
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
        addButtons()

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

    override func startLoop(name: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(name)", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }

    override func stop() {
        player.stop()
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
