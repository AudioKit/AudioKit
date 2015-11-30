//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDecimator
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
let decimator: AKDecimator

switch source {
case "mic":
    decimator = AKDecimator(mic)
default:
    decimator = AKDecimator(player)
}
//: Set the parameters of the decimator here
decimator.decimation =  2 // Percent
decimator.rounding = 0 // Percent
decimator.mix = 50 // Percent

audiokit.audioOutput = decimator
audiokit.start()
if source == "player" {
    player.play()
}
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
