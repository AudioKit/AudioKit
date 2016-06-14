//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Clip
//: ##
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var clipper = AKClipper(player)

//: Set the initial limit of the clipper here
clipper.limit = 0.1

AudioKit.output = clipper
AudioKit.start()

player.play()

class PlaygroundView: AKPlaygroundView {
    
    var limitLabel: Label?
    
    override func setup() {
        addTitle("Clipper")
        
        addLabel("Audio Playback")
        addButton("Start", action: #selector(startLoop))
        addButton("Stop", action: #selector(stop))
        
        limitLabel = addLabel("Limit: \(clipper.limit)")
        addSlider(#selector(setLimit), value: clipper.limit)
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
    
    func setLimit(slider: Slider) {
        clipper.limit = Double(slider.value)
        let limit = String(format: "%0.1f", clipper.limit)
        limitLabel!.text = "Limit: \(limit)"
    }
    
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 350))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
