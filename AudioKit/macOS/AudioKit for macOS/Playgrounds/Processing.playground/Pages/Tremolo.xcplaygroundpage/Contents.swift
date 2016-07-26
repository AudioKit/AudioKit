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

    var frequencyLabel: Label?
    var depthLabel: Label?

    override func setup() {
        addTitle("Tremolo")
        addButtons()

        frequencyLabel = addLabel("Frequency: \(tremolo.frequency)")
        addSlider(#selector(setFrequency), value: tremolo.frequency, minimum: 0, maximum: 20)

        depthLabel = addLabel("Depth: \(tremolo.depth)")
        addSlider(#selector(setDepth), value: tremolo.depth, minimum: 0, maximum: 1.0)
    }

    func setFrequency(slider: Slider) {
        tremolo.frequency = Double(slider.value)
        frequencyLabel!.text = "Frequency: \(String(format: "%0.3f", tremolo.frequency))"
    }

    func setDepth(slider: Slider) {
        tremolo.depth = Double(slider.value)
        depthLabel!.text = "Depth: \(String(format: "%0.3f", tremolo.depth))"
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
