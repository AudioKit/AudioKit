//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## String Resonator
//: ##
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true
var stringResonator = AKStringResonator(player)

//: Set the parameters of the String Resonator here.
stringResonator.feedback = 0.9
stringResonator.fundamentalFrequency = 100
stringResonator.rampTime = 0.1

AudioKit.output = stringResonator
AudioKit.start()

player.play()

//: User Interface Set up
class PlaygroundView: AKPlaygroundView {

    var fundamentalFrequencyLabel: Label?
    var feedbackLabel: Label?

    override func setup() {
        addTitle("String Resonator")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        fundamentalFrequencyLabel = addLabel("Fundamental Frequency: \(stringResonator.fundamentalFrequency)")
        addSlider(#selector(setFundamentalFrequency), value: stringResonator.fundamentalFrequency, minimum: 0, maximum: 400)

        feedbackLabel = addLabel("Feedback: \(stringResonator.feedback)")
        addSlider(#selector(setFeedback), value: stringResonator.feedback, minimum: 0, maximum: 0.99)
    }

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

    func setFundamentalFrequency(slider: Slider) {
        stringResonator.fundamentalFrequency = Double(slider.value)
        fundamentalFrequencyLabel!.text = "Fundamental Frequency: \(String(format: "%0.0f", stringResonator.fundamentalFrequency))"
    }

    func setFeedback(slider: Slider) {
        stringResonator.feedback = Double(slider.value)
        feedbackLabel!.text = "Feedback: \(String(format: "%0.3f", stringResonator.feedback))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@
