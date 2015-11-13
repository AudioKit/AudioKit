//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUParametricEQ
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let parametricEQ: AKAUParametricEQ

switch (source) {
case "mic":
    parametricEQ = AKAUParametricEQ(mic)
default:
    parametricEQ = AKAUParametricEQ(player)
    playerWindow = AKAudioPlayerWindow(player)
}
//: Set the parameters of the Peak Limiter here
parametricEQ.centerFrequency = 2000 // Hz
parametricEQ.q = 1.0 // Hz
parametricEQ.gain = 0 // dB

var parametricEQWindow = AKAUParametricEQWindow(parametricEQ)

audiokit.audioOutput = parametricEQ
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
