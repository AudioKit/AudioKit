//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
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
let reverb: AKFlatFrequencyResponseReverb

switch source {
case "mic":
    reverb = AKFlatFrequencyResponseReverb(mic)
default:
    reverb = AKFlatFrequencyResponseReverb(player, loopDuration: 0.2)
}

//: Set the parameters of the delay here
reverb.reverbDuration = 1

audiokit.audioOutput = reverb
audiokit.start()
if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
