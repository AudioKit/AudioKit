//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Flat Frequency Response Reverb
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "drumloop", andExtension: "wav", fromBaseDirectory: .Resources)


//: Here we set up a player to the loop the file's playback
let player = try AKAudioPlayer(file: file)
player.looping = true

//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
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

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        durationLabel = addLabel("Duration: \(reverb.reverbDuration)")
        addSlider(#selector(setDuration), value: reverb.reverbDuration, minimum: 0, maximum: 5)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop", andExtension: "wav", fromBaseDirectory: .Resources)
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

    func setDuration(slider: Slider) {
        reverb.reverbDuration = Double(slider.value)
        durationLabel!.text = "Duration: \(String(format: "%0.3f", reverb.reverbDuration))"
        printCode()
    }

    func printCode() {
        // Here we're just printing out the preset so it can be copy and pasted into code

        print("public func presetXXXXXX() {")
        print("    reverbDuration = \(String(format: "%0.3f", reverb.reverbDuration))")
        print("}\n")
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
