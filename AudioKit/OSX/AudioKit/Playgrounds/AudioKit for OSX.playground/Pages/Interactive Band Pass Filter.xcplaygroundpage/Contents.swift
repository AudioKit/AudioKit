//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Band Pass Filter
//: ### Band-pass filters allow audio above a specified frequency range and bandwidth to pass through to an output. The center frequency is the starting point from where the frequency limit is set. Adjusting the bandwidth sets how far out above and below the center frequency the frequency band should be. Anything above that band should pass through.
import XCPlayground
import AudioKit

//: This section prepares the player and the microphone
var mic = AKMicrophone()
mic.volume = 0

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

//: Next, we'll connect the audio sources to a band pass filter
let inputMix = AKMixer(mic, player)
var bandPassFilter = AKBandPassFilter(inputMix)

//: Set the parameters of the band pass filter here
bandPassFilter.centerFrequency = 5000 // Hz
bandPassFilter.bandwidth = 600  // Cents

AudioKit.output = bandPassFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var centerFrequencyLabel: Label?
    var bandwidthLabel: Label?
    
    override func setup() {
        addTitle("Band Pass Filter")
        
        addLabel("Microphone")
        addSlider("setMicrophoneVolume:")
        
        addLabel("Audio Player")
        addButton("Start", action: "start")
        addButton("Stop", action: "stop")
        
        centerFrequencyLabel = addLabel("Center Frequency: 5000 Hz")
        addSlider("setCenterFrequency:", value: 5000, minimum: 20, maximum: 22050)
        
        bandwidthLabel = addLabel("Bandwidth 600 Cents")
        addSlider("setBandwidth:", value: 600, minimum: 100, maximum: 12000)
    }
    
    //: Handle UI Events
    
    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }
    
    func setMicrophoneVolume(slider: Slider) {
        mic.volume = Double(slider.floatValue)
    }
    
    func setCenterFrequency(slider: Slider) {
        bandPassFilter.centerFrequency = Double(slider.floatValue)
        let frequency = String(format: "%0.1f", bandPassFilter.centerFrequency)
        centerFrequencyLabel!.stringValue = "Center Frequency: \(frequency) Hz"
    }
    
    func setBandwidth(slider: Slider) {
        bandPassFilter.bandwidth = Double(slider.floatValue)
        let bandwidth = String(format: "%0.1f", bandPassFilter.bandwidth)
        bandwidthLabel!.stringValue = "Bandwidth: \(bandwidth) Cents"
    }
    
    
}

let view = PlaygroundView(frame: NSRect(x: 0, y: 0, width: 500, height: 550));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
