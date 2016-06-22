//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Three-Pole Low Pass Filter
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(forReadingWithFileName: "mixloop", andExtension: "wav", fromBaseDirectory: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var filter = AKThreePoleLowpassFilter(player)

//: Set the parameters of the Moog Ladder Filter here.
filter.cutoffFrequency = 300 // Hz
filter.resonance = 0.6
filter.rampTime = 0.1

AudioKit.output = filter
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?

    override func setup() {
        addTitle("Three Pole Low Pass Filter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(filter.cutoffFrequency)")
        addSlider(#selector(setCutoffFrequency),
                  value: filter.cutoffFrequency,
                  minimum: 0,
                  maximum: 5000)

        resonanceLabel = addLabel("Resonance: \(filter.resonance)")
        addSlider(#selector(setResonance),
                  value: filter.resonance,
                  minimum: 0,
                  maximum: 0.99)
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

    func setCutoffFrequency(slider: Slider) {
        filter.cutoffFrequency = Double(slider.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", filter.cutoffFrequency))"
    }

    func setResonance(slider: Slider) {
        filter.resonance = Double(slider.value)
        resonanceLabel!.text = "Resonance: \(String(format: "%0.3f", filter.resonance))"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@
