//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var pitchshifter = AKPitchShifter(player)

AudioKit.output = pitchshifter
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var pitchLabel: Label?
    
    override func setup() {
        addTitle("Time/Pitch")
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        addLabel("Time/Pitch Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        pitchLabel = addLabel("Pitch: \(pitchshifter.shift) Cents")
        addSlider(#selector(setPitch), value: pitchshifter.shift, minimum: -2400, maximum: 2400)
        
        
    }
    
    //: Handle UI Events
    
    func start() {
        player.play()
    }
    
    func stop() {
        player.stop()
    }
    
    func process() {
        pitchshifter.start()
    }
    
    func bypass() {
        pitchshifter.bypass()
    }

    func setPitch(slider: Slider) {
        pitchshifter.shift = Double(slider.value)
        let pitch = String(format: "%0.1f", pitchshifter.shift)
        pitchLabel!.text = "Pitch: \(pitch) Cents"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
