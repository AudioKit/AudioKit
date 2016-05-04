//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low Pass Butterworth Filter
//: ### A low-pass filter takes an audio signal as an input, and cuts out the high-frequency components of the audio signal, allowing for the lower frequency components to "pass through" the filter.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var filter = AKLowPassButterworthFilter(player)

//: Set the parameters here
filter.cutoffFrequency = 500 // Hz

AudioKit.output = filter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var cutoffFrequencyLabel: Label?
    
    override func setup() {
        addTitle("Low Pass Butterworth Filter")
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Low Pass Filter Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        cutoffFrequencyLabel = addLabel("Cut-off Frequency: \(filter.cutoffFrequency) Hz")
        addSlider(#selector(setCutoffFrequency), value: filter.cutoffFrequency, minimum: 10, maximum: 22050)
    }
    
    //: Handle UI Events
    
    func start() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func process() {
        filter.start()
    }
    
    func bypass() {
        filter.bypass()
    }
    
    func setCutoffFrequency(slider: Slider) {
        filter.cutoffFrequency = Double(slider.value)
        let cutoffFrequency = String(format: "%0.1f", filter.cutoffFrequency)
        cutoffFrequencyLabel!.text = "Cut-off Frequency: \(cutoffFrequency) Hz"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
