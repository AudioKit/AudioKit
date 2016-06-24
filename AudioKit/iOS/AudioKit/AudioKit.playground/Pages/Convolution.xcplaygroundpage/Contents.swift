//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Convolution
//: ### Allows you to create a large variety of effects, usually reverbs or environments, but it could also be for modeling.
import XCPlayground
import AudioKit

let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .Resources)

let player = try AKAudioPlayer(file: file)
player.looping = true


let bundle = NSBundle.mainBundle()
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

class PlaygroundView: AKPlaygroundView {

    override func setup() {
        addTitle("Convolution")

        addLabel("Audio Playback")
        addButton("Drums", action: #selector(startDrumLoop))
        addButton("Bass", action: #selector(startBassLoop))
        addButton("Guitar", action: #selector(startGuitarLoop))
        addButton("Lead", action: #selector(startLeadLoop))
        addButton("Mix", action: #selector(startMixLoop))
        addButton("Stop", action: #selector(stop))

        addLineBreak()

        addLabel("Convolution Parameters")

        addLabel("Mix: Dry Audio to Fully Convolved")
        addSlider(#selector(setDryWet), value: dryWetMixer.balance)

        addLabel("Impulse Response: Stairwell to Dish")
        addSlider(#selector(setIRMix), value: mixer.balance)
    }

    func startLoop(part: String) {
        player.stop()
        let file = try? AKAudioFile(readFileName: "\(part)loop.wav", baseDir: .Resources)
        try? player.replaceFile(file!)
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
