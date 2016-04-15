//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Convolution
//: ### Allows you to create a large variety of effects, usually reverbs or environments, but it could also be for modeling.
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

var mixer = AKDryWetMixer(stairwellConvolution, dishConvolution, balance: 1)
var dryWetMixer = AKDryWetMixer(player, mixer, balance: 1)

AudioKit.output = dryWetMixer
AudioKit.start()

stairwellConvolution.start()
dishConvolution.start()
player.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Convolution")

        addLabel("Audio Playback")
        addButton("Start", action: #selector(start))
        addButton("Stop", action: #selector(stop))

        addLineBreak()

        addLabel("Convolution Parameters")

        addLabel("Mix: Dry Audio to Fully Convolved")
        addSlider(#selector(setDryWet), value: dryWetMixer.balance)

        addLabel("Impulse Response: Stairwell to Dish")
        addSlider(#selector(setIRMix), value: mixer.balance)
    }

    func start() {
        player.play()
    }
    func stop() {
        player.stop()
    }

    func setIRMix(slider: Slider) {
        mixer.balance = Double(slider.value)
    }

    func setDryWet(slider: Slider) {
        dryWetMixer.balance = Double(slider.value)
    }
}

let view = PlaygroundView(frame: CGRect(x: 0, y: 0, width: 500, height:400))
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = view
