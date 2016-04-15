//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Auto Wah Wah
//: ### One of the most iconic guitar effects is the wah-pedal. Here, we run an audio loop of a guitar through an AKAutoWah node. 
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
var wah = AKAutoWah(player)

//: Set the parameters of the auto-wah here
wah.wah = 1
wah.amplitude = 1

AudioKit.output = wah
AudioKit.start()

player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    var wahLabel: Label?
    
    override func setup() {
        addTitle("Auto Wah Wah")
        
        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))
        
        wahLabel = addLabel("Wah: \(wah.wah)")
        addSlider(#selector(setWah), value: wah.wah)
    }
    
    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }
    
    func setWah(slider: Slider) {
        wah.wah = Double(slider.value)
        wahLabel!.text = "Wah: \(String(format: "%0.3f", wah.wah))"
    }

}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height: 300))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
