//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Shelf Filter
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var highShelfFilter = AKHighShelfFilter(player)

//: Set the parameters here
highShelfFilter.cutOffFrequency = 10000 // Hz
highShelfFilter.gain = 0 // dB

AudioKit.output = highShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutOffFrequencyLabel: Label?
    var gainLabel: Label?

    override func setup() {
        addTitle("High Shelf Filter")

        addButtons()

        addLabel("High Shelf Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        cutOffFrequencyLabel = addLabel("Cut-off Frequency: 10000 Hz")
        addSlider(#selector(setCutOffFrequency), value: 10000, minimum: 10000, maximum: 22050)

        gainLabel = addLabel("Gain: 0 dB")
        addSlider(#selector(setGain), value: 0, minimum: -40, maximum: 40)

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
        highShelfFilter.start()
    }

    func bypass() {
        highShelfFilter.bypass()
    }

    func setCutOffFrequency(slider: Slider) {
        highShelfFilter.cutOffFrequency = Double(slider.value)
        let cutOffFrequency = String(format: "%0.1f", highShelfFilter.cutOffFrequency)
        cutOffFrequencyLabel!.text = "Cut-off Frequency: \(cutOffFrequency) Hz"
        printCode()
    }

    func setGain(slider: Slider) {
        highShelfFilter.gain = Double(slider.value)
        let gain = String(format: "%0.1f", highShelfFilter.gain)
        gainLabel!.text = "Gain: \(gain) dB"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    cutOffFrequency = " +
            String(format: "%0.3f", highShelfFilter.cutOffFrequency))
        Swift.print("    gain = \(String(format: "%0.3f", highShelfFilter.gain))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
