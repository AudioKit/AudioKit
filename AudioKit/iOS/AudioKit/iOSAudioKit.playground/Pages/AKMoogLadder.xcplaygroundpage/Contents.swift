//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKMoogLadder
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
let moogLadder: AKMoogLadder

switch source {
case "mic":
    moogLadder = AKMoogLadder(mic)
default:
    moogLadder = AKMoogLadder(player)
}
//: Set the parameters of the low pass filter here

moogLadder.cutoffFrequency = 300 // Hz
moogLadder.resonance = 0.6  // Cents

audiokit.audioOutput = moogLadder
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
