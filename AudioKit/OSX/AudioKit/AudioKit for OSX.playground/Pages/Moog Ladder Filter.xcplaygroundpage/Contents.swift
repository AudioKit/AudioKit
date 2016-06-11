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
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        cutoffFrequencyLabel = addLabel("Cutoff Frequency: \(moogLadder.cutoffFrequency)")
        addSlider(#selector(setCutoffFrequency), value: moogLadder.cutoffFrequency, minimum: 0, maximum: 5000)

        resonanceLabel = addLabel("Resonance: \(moogLadder.resonance)")
        addSlider(#selector(setResonance), value: moogLadder.resonance, minimum: 0, maximum: 0.99)
    }

    func startLoop(part: String) {
        player.stop()
        let file = bundle.pathForResource("\(part)loop", ofType: "wav")
        player.replaceFile(file!)
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
    func stop()