//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKHighShelfFilter
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
let highShelfFilter: AKHighShelfFilter

switch source {
case "mic":
    highShelfFilter = AKHighShelfFilter(mic)
default:
    highShelfFilter = AKHighShelfFilter(player)
}
//: Set the parameters of the high shelf filter here
highShelfFilter.cutOffFrequency = 1000 // Hz
highShelfFilter.gain = -10 // dB

audiokit.audioOutput = highShelfFilter
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
