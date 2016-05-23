//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tremolo
//: ### 
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var tremolo = AKTremolo(player, waveform: AKTable(.PositiveSquare))

//: Set the parameters of the tremolo here
tremolo.frequency = 8

AudioKit.output = tremolo
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    var tremoloLabel: Label?
    
    override func setup() {
        addTitle("Tremolo")
        
        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        tremoloLabel = addLabel("Frequency: \(tremolo.frequency)")
        addSlider(#selector(setFrequency), value: tremolo.frequency, minimum: 0, maximum: 20)
    }
    
    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }
    
    func setFrequency(slider: Slider) {
        tremolo.frequency = Double(slider.value)
        tremoloLabel!.text = "Frequency: \(String(format: "%0.3f", tremolo.frequency))"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
