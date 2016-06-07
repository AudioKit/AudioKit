//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Shelf Filter
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var lowShelfFilter = AKLowShelfFilter(player)

//: Set the parameters here
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

AudioKit.output = lowShelfFilter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    var gainLabel: Label?
    
    override func setup() {
        addTitle("Low Shelf Filter")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Low Shelf Filter Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        cutoffFrequencyLabel = addLabel("Cut-off Frequency: 80 Hz")
        addSlider(#selector(setcutoffFrequency), value: 80, minimum: 10, maximum: 200)
        
        gainLabel = addLabel("Gain: 0 dB")
        addSlider(#selector(setgain), value: 0, minimum: -40, maximum: 40)
        
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
        lowShelfFilter.start()
    }
    
    func bypass() {
        lowShelfFilter.bypass()
    }
    func setcutoffFrequency(slider: Slider) {
        lowShelfFilter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", lowShelfFilter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
    }
    
    func setgain(slider: Slider) {
        lowShelfFilter.gain = Double(slider.value)
        let gain = String(format: "%0.1f", lowShelfFilter.gain)
        gainLabel!.text = "Gain: \(gain) dB"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
