//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKMoogLadder
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
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
let bandPassFilter: AKMoogLadder

switch source {
case "mic":
    bandPassFilter = AKMoogLadder(mic)
default:
    bandPassFilter = AKMoogLadder(player)
}
//: Set the parameters of the band pass filter here
bandPassFilter.cutoffFrequency = 1000 // Hz
bandPassFilter.resonance = 0.98  // Cents

audiokit.audioOutput = bandPassFilter
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
