//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dry Wet Mixer
//: It's very common to mix exactly two inputs, one before
//: processing occurs, and one after, resulting in a combination
//: of the two.  This is so common that many of the AudioKit nodes have a
//: dry/wet mix parameter built in.  But, if you are building your own
//: custom effects, or making a long chain of effects, you can use
//: AKDryWetMixer to blend your signals.

import AudioKit

//: This section prepares the players
let file = try AKAudioFile(readFileName: "drumloop.wav", baseDir: .resources)
var drums = try AKAudioPlayer(file: file)
drums.looping = true

//: Build an effects chain:

var delay = AKDelay(drums)
delay.time = 0.1
delay.feedback = 0.8
let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.largeChamber)

//: Mix the result of those two processors back with the original

let mixture = AKDryWetMixer(drums, reverb, balance: 0.5)

AudioKit.output = mixture
AudioKit.start()
drums.play()

//: User Interface Set up

class PlaygroundView: AKPlaygroundView {

    var balanceLabel: Label?

    override func setup() {
        addTitle("Dry Wet Mix")

        addSubview(AKBypassButton(node: drums))

        addSubview(AKPropertySlider(
            property: "Balance",
            value: mixture.balance,
            color: AKColor.cyan
        ) { sliderValue in
            mixture.balance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = PlaygroundView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
