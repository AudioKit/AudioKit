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
        
        addLabel("Audio Player")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        limitLabel = addLabel("Limit: \(clipper.limit)")
        addSlider(#selector(setLimit), value: clipper.limit)
    }
    
    func start() {
        player.play()
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
