//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## High Pass Filter
//: ### A high-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the higher frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var highPassFilter = AKHighPassFilter(player)

//: Set the parameters here
highPassFilter.cutoffFrequency = 6900 // Hz
highPassFilter.resonance = 0 // dB

AudioKit.output = highPassFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?
    
    override func setup() {
        addTitle("High Pass Filter")
        
        addLabel("Audio Player")
        addButton("Start", action: "start")
        addButton("Stop", action: "stop")
        
        addLabel("High Pass Filter Parameters")
        
        addButton("Process", action: "process")
        addButton("Bypass", action: "bypass")
        
        cutoffFrequencyLabel = addLabel("Cut-off Frequency: 6900 Hz")
        addSlider("setCutoffFrequency:", value: 6900, minimum: 10, maximum: 22050)
        
        resonanceLabel = addLabel("Resonance: 0 dB")
        addSlider("setResonance:", value: 0, minimum: -20, maximum: 40)
        
    }
    
    //: Handle UI Events
    
    func start() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func process() {
        highPassFilter.start()
    }
    
    func bypass() {
        highPassFilter.bypass()
    }
    func setCutoffFrequency(slider: Slider) {
        highPassFilter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", highPassFilter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
    }
    
    func setResonance(slider: Slider) {
        highPassFilter.resonance = Double(slider.value)
        let resonance = String(format: "%0.1f", highPassFilter.resonance)
        resonanceLabel!.text = "resonance: \(resonance) dB"
    }
    
}

let view = PlaygroundView(frame: CGRectMake(0, 0, 500, 550));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
