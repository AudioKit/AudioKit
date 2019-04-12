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
import AudioKitPlaygrounds
import AudioKit
//: This section prepares the players
let file = try AKAudioFile(readFileName: "drumloop.wav")
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
try AudioKit.start()
drums.play()

//: User Interface Set up
import AudioKitUI

class LiveView: AKLiveViewController {

    override func viewDidLoad() {
        addTitle("Dry Wet Mix")

        addView(AKButton(title: "Bypass") { button in
            drums.isPlaying ? drums.stop() : drums.play()
            button.title = drums.isPlaying ? "Stop" : "Start"
        })

        addView(AKSlider(property: "Balance", value: mixture.balance) { sliderValue in
            mixture.balance = sliderValue
        })
    }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = LiveView()

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
