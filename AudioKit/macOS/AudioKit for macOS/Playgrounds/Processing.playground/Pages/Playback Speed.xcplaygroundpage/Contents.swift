//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Playback Speed
//: ### Here we'll use the AKVariSpeed node to change the playback speed of a file
//: ### (which also affects the pitch)
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)
let player = try AKAudioPlayer(file: file)
player.looping = true

var variSpeed = AKVariSpeed(player)

//: Set the parameters here
variSpeed.rate = 2.0

AudioKit.output = variSpeed
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var rateLabel: Label?
    var pitchLabel: Label?
    var overlapLabel: Label?

    override func setup() {
        addTitle("Playback Speed")

        addButtons()

        addLabel("VariSpeed Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        rateLabel = addLabel("Rate: \(variSpeed.rate) rate")
        addSlider(#selector(setRate), value: variSpeed.rate, minimum: 0.03125, maximum: 5.0)
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

    func process() {
        variSpeed.start()
    }

    func bypass() {
        variSpeed.bypass()
    }

    func setRate(slider: Slider) {
        variSpeed.rate = Double(slider.value)
        let rate = String(format: "%0.3f", variSpeed.rate)
        rateLabel!.text = "Rate: \(rate) rate"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    rate = \(String(format: "%0.3f", variSpeed.rate))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
