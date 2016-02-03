//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the low-frequency components of the audio signal, allowing for the lower frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var lowPassFilter = AKLowPassFilter(player)

//: Set the parameters here
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

AudioKit.output = lowPassFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    var resonanceLabel: Label?
    
    override func setup() {
        addTitle("Low Pass Filter")
        
        addLabel("Audio Player")
        addButton("Start", action: "start")
        addButton("Stop", action: "stop")
        
        addLabel("Low Pass Filter Parameters")
        
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
        lowPassFilter.start()
    }
    
    func bypass() {
        lowPassFilter.bypass()
    }
    func setCutoffFrequency(slider: Slider) {
        lowPassFilter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", lowPassFilter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
    }
    
    func setResonance(slider: Slider) {
        lowPassFilter.resonance = Double(slider.value)
        let resonance = String(format: "%0.1f", lowPassFilter.resonance)
        resonanceLabel!.text = "Resonance: \(resonance) dB"
    }
    
}

let view = PlaygroundView(frame: CGRectMake(0, 0, 500, 550));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
