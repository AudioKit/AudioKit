//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingFileName: "mixloop", withExtension: "wav", fromBaseDirectory: .resources)

let player = try AKAudioPlayer(file: file)
player.looping = true

var pitchshifter = AKPitchShifter(player)

AudioKit.output = pitchshifter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var pitchLabel: Label?

    override func setup() {
        addTitle("Pitch Shifter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("Time/Pitch Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        pitchLabel = addLabel("Pitch: \(pitchshifter.shift) Cents")
        addSlider(#selector(setPitch), value: pitchshifter.shift, minimum: -2400, maximum: 2400)


    }

    //: Handle UI Events

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

    func process() {
        pitchshifter.start()
    }

    func bypass() {
        pitchshifter.bypass()
    }

    func setPitch(slider: Slider) {
        pitchshifter.shift = Double(slider.value)
        let pitch = String(format: "%0.1f", pitchshifter.shift)
        pitchLabel!.text = "Pitch: \(pitch) Cents"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        Swift.print("public func presetXXXXXX() {")
        Swift.print("    shift = \(String(format: "%0.3f", pitchshifter.shift))")
        Swift.print("}\n")
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
