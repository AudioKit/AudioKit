//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var reverb = AKFlatFrequencyResponseReverb(player, loopDuration: 0.1)

//: Set the parameters of the delay here
reverb.reverbDuration = 1

AudioKit.output = reverb
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var durationLabel: Label?

    override func setup() {
        addTitle("Flat Frequency Response Reverb")

        addButtons()

        durationLabel = addLabel("Duration: \(reverb.reverbDuration)")
        addSlider(#selector(setDuration), value: reverb.reverbDuration, minimum: 0, maximum: 5)
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

    func setDuration(slider: Slider) {
        reverb.reverbDuration = Double(slider.value)
        durationLabel!.text = "Duration: \(String(format: "%0.3f", reverb.reverbDuration))"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    reverbDuration = \(String(format: "%0.3f", reverb.reverbDuration))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
