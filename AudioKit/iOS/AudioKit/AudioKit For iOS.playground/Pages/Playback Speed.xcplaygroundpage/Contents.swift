//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Playback Speed
//: ### Here we'll use the AKVariSpeed node to change the playback speed of a file (which also affects the pitch)
//:
import PlaygroundSupport
import AudioKit

let bundle = Bundle.main()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

var variSpeed = AKVariSpeed(player)

//: Set the parameters here
variSpeed.rate = 2.0

AudioKit.output = variSpeed
AudioKit.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    //: UI Elements we'll need to be able to access
    var rateLabel: Label?
    var pitchLabel: Label?
    var overlapLabel: Label?
    
    override func setup() {
        addTitle("Playback Speed")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        addLabel("VariSpeed Parameters")
        
        addButton("Process", action: #selector(process))
        addButton("Bypass", action: #selector(bypass))
        
        rateLabel = addLabel("Rate: \(variSpeed.rate) rate")
        addSlider(#selector(setRate), value: variSpeed.rate, minimum: 0.03125, maximum: 5.0)
    }
    
    //: Handle UI Events
    
    func startLoop(_ part: String) {
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
        variSpeed.start()
    }
    
    func bypass() {
        variSpeed.bypass()
    }
    func setRate(slider: Slider) {
        variSpeed.rate = Double(slider.value)
        let rate = String(format: "%0.3f", variSpeed.rate)
        rateLabel!.text = "Rate: \(rate) rate"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
