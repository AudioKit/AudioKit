//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKRingModulator
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let ringModulator: AKRingModulator

switch source {
case "mic":
    ringModulator = AKRingModulator(mic)
default:
    ringModulator = AKRingModulator(player)
}
//: Set the parameters of the ring modulator here
ringModulator.frequency1 = 200 // Hertz
ringModulator.frequency2 = 700 // Hertz
ringModulator.balance = 50 // Percent
ringModulator.mix = 50 // Percent

audiokit.audioOutput = ringModulator
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
