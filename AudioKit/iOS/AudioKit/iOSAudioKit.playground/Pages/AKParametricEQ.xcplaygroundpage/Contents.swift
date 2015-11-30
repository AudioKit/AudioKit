//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKParametricEQ
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let parametricEQ: AKParametricEQ

switch source {
case "mic":
    parametricEQ = AKParametricEQ(mic)
default:
    parametricEQ = AKParametricEQ(player)
}
//: Set the parameters of the parametric equalizer here
parametricEQ.centerFrequency = 1000 // Hz
parametricEQ.q = 1 // Hz
parametricEQ.gain = 10 // dB

audiokit.audioOutput = parametricEQ
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
