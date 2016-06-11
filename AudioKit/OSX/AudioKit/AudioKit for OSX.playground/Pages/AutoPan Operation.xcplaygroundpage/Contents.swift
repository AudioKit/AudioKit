//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoPan Operation
//:
import XCPlayground
import AudioKit


let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let oscillator = AKOperation.sineWave(frequency: AKOperation.parameters(0), amplitude: AKOperation.parameters(1))

let panner = AKOperation.input.pan(oscillator)

let effect = AKOperationEffect(player, stereoOperation: panner)
effect.parameters = [10, 1]
AudioKit.output = effect
AudioKit.start()

let playgroundWidth = 500

class PlaygroundView: AKPlaygroundView {
    var speedLabel: Label?
    var depthLabel: Label?
    
    override func setup() {
        addTitle("AutoPan")
        
        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))
        
        speedLabel = addLabel("Speed: \(effect.parameters[0])")
        addSlider(#selector(setSpeed), value: effect.parameters[0], minimum: 0.1, maximum: 25)
        
        depthLabel = addLabel("Depth: \(effect.parameters[1])")
        addSlider(#selector(setDepth), value: effect.parameters[1])
    }
    
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
    
    func setSpeed(slider: Slider) {
        effect.parameters[0] = Double(slider.value)
        speedLabel!.text = "Speed: \(String(format: "%0.3f", effect.parameters[0]))"
    }
    
    func setDepth(slider: Slider) {
        effect.parameters[1] = Double(slider.value)
        depthLabel!.text = "Depth: \(String(format: "%0.3f", effect.parameters[1]))"
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: playgroundWidth, height: 650))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
