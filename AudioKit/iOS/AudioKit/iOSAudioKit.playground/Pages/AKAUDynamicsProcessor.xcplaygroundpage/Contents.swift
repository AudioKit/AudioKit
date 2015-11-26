//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUDynamicsProcessor
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
let dynamicsProcessor: AKAUDynamicsProcessor

switch source {
case "mic":
    dynamicsProcessor = AKAUDynamicsProcessor(mic)
default:
    dynamicsProcessor = AKAUDynamicsProcessor(player)
}
//: Set the parameters of the dynamics processor here
dynamicsProcessor.threshold = -20 // dB
dynamicsProcessor.headRoom = 5 // dB
dynamicsProcessor.expansionRatio = 2 // rate
dynamicsProcessor.expansionThreshold = 2 // rate
dynamicsProcessor.attackTime = 0.001 // secs
dynamicsProcessor.releaseTime = 0.05 // secs
dynamicsProcessor.masterGain = 0 // dB
dynamicsProcessor.compressionAmount = 0 // dB
dynamicsProcessor.inputAmplitude = 0 // dB
dynamicsProcessor.outputAmplitude = 0 // dB

audiokit.audioOutput = dynamicsProcessor
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
