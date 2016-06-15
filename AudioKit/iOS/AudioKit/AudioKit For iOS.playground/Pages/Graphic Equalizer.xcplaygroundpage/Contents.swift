//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Graphic Equalizer
//: ### Here we'll build a graphic equalizer from a set of equalizer filters
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var lowFilter = AKEqualizerFilter(player, centerFrequency: 50, bandwidth: 100, gain: 1.0)
var midFilter = AKEqualizerFilter(lowFilter, centerFrequency: 350, bandwidth: 300, gain: 1.0)
var highFilter = AKEqualizerFilter(midFilter, centerFrequency: 5000, bandwidth: 1000, gain: 1.0)


AudioKit.output = highFilter
AudioKit.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var lowLabel: Label?
    var midLabel: Label?
    var highLabel: Label?
    
    override func setup() {
        addTitle("Graphic Equalizer")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Equalizer Gains")
        
        lowLabel = addLabel("Low: \(lowFilter.gain)")
        addSlider(#selector(setLowGain), value: lowFilter.gain, minimum: 0, maximum: 10)
        
        midLabel = addLabel("Mid: \(midFilter.gain)")
        addSlider(#selector(setMidGain), value: midFilter.gain, minimum: 0, maximum: 10)
        
        highLabel = addLabel("High: \(highFilter.gain)")
        addSlider(#selector(setHighGain), value: highFilter.gain, minimum: 0, maximum: 10)
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
    
    func setLowGain(slider: Slider) {
        lowFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", lowFilter.gain)
        lowLabel!.text = "Low: \(gain)"
    }

    func setMidGain(slider: Slider) {
        midFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", midFilter.gain)
        midLabel!.text = "Mid: \(gain)"
    }

    func setHighGain(slider: Slider) {
        highFilter.gain = Double(slider.value)
        let gain = String(format: "%0.3f", highFilter.gain)
        highLabel!.text = "High: \(gain)"
    }

}


let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 550))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
