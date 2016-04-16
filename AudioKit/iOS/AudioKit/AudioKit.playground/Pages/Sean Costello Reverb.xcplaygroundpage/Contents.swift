//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb
//: ### This is a great sounding reverb that we just love.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var reverb = AKCostelloReverb(player)

//: Set the parameters of the reverb here
reverb.cutoffFrequency = 9900 // Hz
reverb.feedback = 0.92

AudioKit.output = reverb
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencyLabel: Label?
    var feedbackLabel: Label?

    override func setup() {
        addTitle("Sean Costello Reverb")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(reverb.cutoffFrequency)")
        addSlider(#selector(setCutoffFrequency), value: reverb.cutoffFrequency, minimum: 0, maximum: 5000)

        feedbackLabel = addLabel("Feedback: \(reverb.feedback)")
        addSlider(#selector(setFeedback), value: reverb.feedback, minimum: 0, maximum: 0.99)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setCutoffFrequency(slider: Slider) {
        reverb.cutoffFrequency = Double(slider.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", reverb.cutoffFrequency))"
    }

    func setFeedback(slider: Slider) {
        reverb.feedback = Double(slider.value)
        feedbackLabel!.text = "Feedback: \(String(format: "%0.3f", reverb.feedback))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
