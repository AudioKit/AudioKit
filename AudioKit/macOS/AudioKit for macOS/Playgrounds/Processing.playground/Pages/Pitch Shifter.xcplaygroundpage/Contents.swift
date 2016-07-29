//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a
//: ### player-generated sound.  It does not work on live input or generated signals.
//:
import XCPlayground
import AudioKit


let file = try AKAudioFile(readFileName: AKPlaygroundView.defaultSourceAudio,
                           baseDir: .Resources)

//: Here we set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true

var pitchshifter = AKPitchShifter(player)

AudioKit.output = pitchshifter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Pitch Shifter")

        addButtons()

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        pitchLabel = addLabel("Pitch: \(pitchshifter.shift) Semitones")
        addSlider(#selector(setPitch), value: pitchshifter.shift, minimum: -24, maximum: 24)


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
        pitchshifter.start()
    }

    func bypass() {
        pitchshifter.bypass()
    }

    func setPitch(slider: Slider) {
        pitchshifter.shift = Double(slider.value)
        let pitch = String(format: "%0.1f", pitchshifter.shift)
        pitchLabel!.text = "Pitch: \(pitch) Semitones"
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
