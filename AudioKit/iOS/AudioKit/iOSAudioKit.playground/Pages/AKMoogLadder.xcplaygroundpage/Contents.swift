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
let lowPassFilter: AKMoogLadder

switch source {
case "mic":
    lowPassFilter = AKMoogLadder(mic)
default:
    lowPassFilter = AKMoogLadder(player)
}
//: Set the parameters of the low pass filter here

lowPassFilter.cutoffFrequency = 300 // Hz
lowPassFilter.resonance = 0.6  // Cents

audiokit.audioOutput = lowPassFilter
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
