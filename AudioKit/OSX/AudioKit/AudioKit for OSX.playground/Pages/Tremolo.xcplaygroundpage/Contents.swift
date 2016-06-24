//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tremolo
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFilename: "guitarloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var tremolo = AKTremolo(player, waveform: AKTable(.PositiveSquare))

//: Set the parameters of the tremolo here
tremolo.frequency = 8

AudioKit.output = tremolo
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var tremoloFreqLabel: Label?
    var tremoloDepthLabel: Label?

    override func setup() {
        addTitle("Tremolo")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        tremoloFreqLabel = addLabel("Frequency: \(tremolo.frequency)")
        addSlider(#selector(setFrequency), value: tremolo.frequency, minimum: 0, maximum: 20)
        tremoloDepthLabel = addLabel("Depth: \(tremolo.depth)")
        addSlider(#selector(setDepth), value: tremolo.depth, minimum: 0, maximum: 2.0)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFilename: "\(part)loop.wav", baseDir: .Resources)
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

    func setFrequency(slider: Slider) {
        tremolo.frequency = Double(slider.value)
        tremoloFreqLabel!.text = "Frequency: \(String(format: "%0.3f", tremolo.frequency))"
        printCode()
    }
    
    func setDepth(slider: Slider) {
        tremolo.depth = Double(slider.value)
        tremoloDepthLabel!.text = "Depth: \(String(format: "%0.3f", tremolo.depth))"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    frequency = \(String(format: "%0.3f", tremolo.frequency))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 400))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
