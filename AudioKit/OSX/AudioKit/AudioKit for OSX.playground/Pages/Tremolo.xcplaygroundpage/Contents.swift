//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tremolo
//: ###
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingFileName: "guitarloop", withExtension: "wav", fromBaseDirectory: .resources)

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

    var tremoloLabel: Label?

    override func setup() {
        addTitle("Tremolo")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        tremoloLabel = addLabel("Frequency: \(tremolo.frequency)")
        addSlider(#selector(setFrequency), value: tremolo.frequency, minimum: 0, maximum: 20)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingFileName: "\(part)loop", withExtension: "wav", fromBaseDirectory: .resources)
        player.replaceAudioFile(file!)
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
        tremoloLabel!.text = "Frequency: \(String(format: "%0.3f", tremolo.frequency))"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    frequency = \(String(format: "%0.3f", tremolo.frequency))")
        Swift.print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
