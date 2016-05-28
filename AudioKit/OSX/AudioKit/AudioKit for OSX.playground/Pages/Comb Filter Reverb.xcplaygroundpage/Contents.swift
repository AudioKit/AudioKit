//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Comb Filter Reverb
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var filter = AKCombFilterReverb(player, loopDuration: 0.1)

//: Set the parameters of the Comb Filter here
filter.reverbDuration = 1

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var durationLabel: Label?

    override func setup() {
        addTitle("Comb Filter Reverb")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        durationLabel = addLabel("Duration: \(filter.reverbDuration)")
        addSlider(#selector(setDuration), value: filter.reverbDuration, minimum: 0, maximum: 5)
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
  