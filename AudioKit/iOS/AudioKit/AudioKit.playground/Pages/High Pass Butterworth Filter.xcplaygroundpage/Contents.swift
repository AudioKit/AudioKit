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
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLabel("High Pass Filter Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        cutoffFrequencyLabel = addLabel("Cut-off Frequency: \(highPassFilter.cutoffFrequency) Hz")
        addSlider(#selector(setCutoffFrequency), value: highPassFilter.cutoffFrequency, minimum: 10, maximum: 22050)
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
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
