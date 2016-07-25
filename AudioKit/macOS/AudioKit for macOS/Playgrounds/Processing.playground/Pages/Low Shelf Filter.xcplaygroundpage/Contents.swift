//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Shelf Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "mixloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var lowShelfFilter = AKLowShelfFilter(player)

//: Set the parameters here
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

AudioKit.output = lowShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    var gainLabel: Label?

    override func setup() {
        addTitle("Low Shelf Filter")

        addButtons()

        addLabel("Low Shelf Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        cutoffFrequencyLabel = addLabel("Cut-off Frequency: 80 Hz")
        addSlider(#selector(setcutoffFrequency), value: 80, minimum: 10, maximum: 200)

        gainLabel = addLabel("Gain: 0 dB")
        addSlider(#selector(setgain), value: 0, minimum: -40, maximum: 40)

    }

    //: Handle UI Events

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
        lowShelfFilter.start()
    }

    func bypass() {
        lowShelfFilter.bypass()
    }

    func setcutoffFrequency(slider: Slider) {
        lowShelfFilter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", lowShelfFilter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
        printCode()
    }

    func setgain(slider: Slider) {
        lowShelfFilter.gain = Double(slider.value)
        let gain = String(format: "%0.1f", lowShelfFilter.gain)
        gainLabel!.text = "Gain: \(gain) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    cutOffFrequency = " +
            String(format: "%0.3f", lowShelfFilter.cutoffFrequency))
        Swift.print("    gain = \(String(format: "%0.3f", lowShelfFilter.gain))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
