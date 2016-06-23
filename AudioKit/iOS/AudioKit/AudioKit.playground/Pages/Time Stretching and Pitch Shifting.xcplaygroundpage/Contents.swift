//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.
//:
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "mixloop.wav",  fromBaseDirectory: .resources)

//: Here we set up a player to the loop the file's playback
var player = try AKAudioPlayer(file: file)
player.looping = true


var timePitch = AKTimePitch(player)

//: Set the parameters here
timePitch.rate = 2.0
timePitch.pitch = -400.0
timePitch.overlap = 8.0

AudioKit.output = timePitch
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var rateLabel: Label?
    var pitchLabel: Label?
    var overlapLabel: Label?

    override func setup() {
        addTitle("Time/Pitch")

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

        rateLabel = addLabel("Rate: \(timePitch.rate) rate")
        addSlider(#selector(setRate), value: timePitch.rate, minimum: 0.03125, maximum: 5.0)

        pitchLabel = addLabel("Pitch: \(timePitch.pitch) Cents")
        addSlider(#selector(setPitch), value: timePitch.pitch, minimum: -2400, maximum: 2400)

        overlapLabel = addLabel("Overlap: \(timePitch.overlap)")
        addSlider(#selector(setOverlap), value: timePitch.overlap, minimum: 3.0, maximum: 32.0)

    }

    //: Handle UI Events

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(forReadingWithFileName: "\(part)loop.wav",  fromBaseDirectory: .resources)
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

    func process() {
        timePitch.start()
    }

    func bypass() {
        timePitch.bypass()
    }
    func setRate(slider: Slider) {
        timePitch.rate = Double(slider.value)
        let rate = String(format: "%0.1f", timePitch.rate)
        rateLabel!.text = "Rate: \(rate) rate"
    }

    func setPitch(slider: Slider) {
        timePitch.pitch = Double(slider.value)
        let pitch = String(format: "%0.1f", timePitch.pitch)
        pitchLabel!.text = "Pitch: \(pitch) Cents"
    }

    func setOverlap(slider: Slider) {
        timePitch.overlap = Double(slider.value)
        let overlap = String(format: "%0.1f", timePitch.overlap)
        overlapLabel!.text = "Overlap: \(overlap)"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@ne