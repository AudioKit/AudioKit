//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter
//: ### One of the coolest filters available in AudioKit is the Moog Ladder. It's based off of Robert Moog's iconic ladder filter, which was the first implementation of a voltage - controlled filter used in an analog synthesizer. As such, it was the first filter that gave the ability to use voltage control to determine the cutoff frequency of the filter. As we're dealing with a software implementation, and not an analog synthesizer, we don't have to worry about dealing with voltage control directly. However, by using this node, you can emulate some of the sounds of classic analog synthesizers in your app.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var moogLadder = AKMoogLadder(player)

//: Set the parameters of the Moog Ladder Filter here.

moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6

AudioKit.output = moogLadder
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?

    override func setup() {
        addTitle("Moog Ladder Filter")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(self.start))
        addButton("Stop", action: #selector(self.stop))

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(moogLadder.cutoffFrequency)")
        addSlider(#selector(self.setCutoffFrequency(_:)), value: moogLadder.cutoffFrequency, minimum: 0, maximum: 5000)

        resonanceLabel = addLabel("Resonance: \(moogLadder.resonance)")
        addSlider(#selector(self.setResonance(_:)), value: moogLadder.resonance, minimum: 0, maximum: 0.99)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setCutoffFrequency(slider: Slider) {
        moogLadder.cutoffFrequency = Double(slider.value)
        cutoffFrequencyLabel!.text = "Cutoff Frequency: \(String(format: "%0.0f", moogLadder.cutoffFrequency))"
    }

    func setResonance(slider: Slider) {
        moogLadder.resonance = Double(slider.value)
        resonanceLabel!.text = "Resonance: \(String(format: "%0.3f", moogLadder.resonance))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
