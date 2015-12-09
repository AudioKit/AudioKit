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

let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let parametricEQ: AKParametricEQ

switch source {
case "mic":
    parametricEQ = AKParametricEQ(mic)
default:
    playerWindow = AKAudioPlayerWindow(player)
    let playerWithVolumeAndPanControl = AKMixer(player)
    parametricEQ = AKParametricEQ(playerWithVolumeAndPanControl)
}

//: Set the parameters of the parametric equalizer here
parametricEQ.centerFrequency = 2000 // Hz
parametricEQ.q = 1.0 // Hz
parametricEQ.gain = 0 // dB

var parametricEQWindow = AKParametricEQWindow(parametricEQ)

audiokit.audioOutput = parametricEQ
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
