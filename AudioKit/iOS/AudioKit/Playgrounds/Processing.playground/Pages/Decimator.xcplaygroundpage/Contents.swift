//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Decimator
//: ### Decimation is a type of digital distortion like bit crushing,
//: ### but instead of directly stating what bit depth and sample rate you want,
//: ### it is done through setting "decimation" and "rounding" parameters.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

//: Next, we'll connect the audio sources to a decimator
var decimator = AKDecimator(player)

//: Set the parameters of the decimator here
decimator.decimation =  0.5 // Normalized Value 0 - 1
decimator.rounding = 0.5 // Normalized Value 0 - 1
decimator.mix = 0.5 // Normalized Value 0 - 1

AudioKit.output = decimator
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var decimationLabel: Label?
    var roundingLabel: Label?
    var mixLabel: Label?

    override func setup() {
        addTitle("Decimator")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        decimationLabel = addLabel("Decimation: \(decimator.decimation)")
        addSlider(#selector(setDecimation), value: decimator.decimation)

        roundingLabel = addLabel("Rounding: \(decimator.rounding)")
        addSlider(#selector(setRounding), value: decimator.rounding)

        mixLabel = addLabel("Mix: \(decimator.mix)")
        addSlider(#selector(setMix), value: decimator.mix)
    }

    //: Handle UI Events

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(part)loop.wav", baseDir: .Resources)
        try? player.replaceFile(file!)
        player.play()
    }

    func startDrumLoop() {
        startLoop("drum")
    }

    func startBassLoop() {
        startLoop("bass")
    }

    func startGuitarLoop() {
        startLoop("guitar")
    }

    func startLeadLoop() {
        startLoop("lead")
    }

    func startMixLoop() {
        startLoop("mix")
    }
    func stop() {
        player.stop()
    }

    func setDecimation(slider: Slider) {
        decimator.decimation = Double(slider.value)
        let decimation = String(format: "%0.3f", decimator.decimation)
        decimationLabel!.text = "Decimation: \(decimation)"
        printCode()
    }

    func setRounding(slider: Slider) {
        decimator.rounding = Double(slider.value)
        let rounding = String(format: "%0.3f", decimator.rounding)
        roundingLabel!.text = "Rounding: \(rounding)"
        printCode()
    }

    func setMix(slider: Slider) {
        decimator.mix = Double(slider.value)
        let mix = String(format: "%0.3f", decimator.mix)
        mixLabel!.text = "Mix: \(mix)"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    decimation = \(String(format: "%0.3f", decimator.decimation))")
        Swift.print("    rounding = \(String(format: "%0.3f", decimator.rounding))")
        Swift.print("    mix = \(String(format: "%0.3f", decimator.mix))")

        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
