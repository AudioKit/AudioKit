//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Interactive Convolution
//: ### Open the timeline view to use the controls this playground sets up.
//:
import Cocoa
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let stairwell = bundle.URLForResource("Impulse Responses/stairwell", withExtension: "wav")!
let dish = bundle.URLForResource("Impulse Responses/dish", withExtension: "wav")!

var stairwellConvolution = AKConvolution.init(player, impulseResponseFileURL: stairwell, partitionLength: 8192)
var dishConvolution = AKConvolution.init(player, impulseResponseFileURL: dish, partitionLength: 8192)

var mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 0)
var dryWetMixer = AKDryWetMixer(player, mixer, balance: 0)

AudioKit.output = dryWetMixer
AudioKit.start()

stairwellConvolution.start()
dishConvolution.start()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {
    
    internal override func setup() {
        addTitle("Convolution")
        
        addLabel("Audio Playback")
        addButton("Start", action: "start")
        addButton("Stop", action: "stop")

        addLabel("Mix: Dry Audio to Fully Convolved")
        addSlider("setDryWet:")
        
        addLabel("Impulse Response: Stairwell to Dish")
        addSlider("setIRMix:")
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }
    
    func setIRMix(slider: Slider) {
        mixer.balance = Double(slider.floatValue)
    }
    
    func setDryWet(slider: Slider) {
        dryWetMixer.balance = Double(slider.floatValue)
    }
}

let view = PlaygroundView(frame: NSRect(x: 0, y: 0, width: 500, height: 350));
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
