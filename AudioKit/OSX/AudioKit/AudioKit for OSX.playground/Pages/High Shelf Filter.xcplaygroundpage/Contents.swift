//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Shelf Filter
//: ### A high-Shelf filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "Shelf through" the filter.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var highShelfFilter = AKHighShelfFilter(player)

//: Set the parameters here
highShelfFilter.cutOffFrequency = 10000 // Hz
highShelfFilter.gain = 0 // dB

AudioKit.output = highShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    //: UI Elements we'll need to be able to access
    var cutOffFrequencyLabel: Label?
    var gainLabel: Label?

    override func setup() {
        addTitle("High Shelf Filter")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLabel("High Shelf Filter Parameters")

        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))

        cutOffFrequencyLabel = addLabel("Cut-off Frequency: 10000 Hz")
        addSlider(#selector(setCutOffFrequency), value: 10000, minimum: 10000, maximum: 22050)

        gainLabel = addLabel("Gain: 0 dB")
        addSlider(#selector(setGain), value: 0, minimum: -40, maximum: 40)

    }

    //: Handle UI Events

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

    func stop() {
        player.stop()
    }

    func process() {
        highShelfFilter.start()
    }

    func bypass() {
        highShelfFilter.bypass()
    }
    func setCutOffFrequency(slider: Sl