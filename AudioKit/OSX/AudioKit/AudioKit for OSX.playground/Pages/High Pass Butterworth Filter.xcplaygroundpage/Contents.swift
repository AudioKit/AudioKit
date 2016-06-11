//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Pass Butterworth Filter
//: ### A high-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var highPassFilter = AKHighPassButterworthFilter(player)

//: Set the parameters here
highPassFilter.cutoffFrequency = 6900 // Hz

AudioKit.output = highPassFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    
    override func setup() {
        addTitle("High Pass Butterworth Filter")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("High Pass Filter Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        cutoffFrequencyLabel = addLabel("Cut-off Frequency: \(highPassFilter.cutoffFrequency) Hz")
        addSlider(#selector(setCutoffFrequency), value: highPassFilter.cutoffFrequency, minimum: 10, maximum: 22050)
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
    
    func