//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Three-Pole Low Pass Filter
//: ##
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
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
    func st