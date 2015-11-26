//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUTimePitch
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
let timePitch: AKAUTimePitch

switch source {
case "mic":
    timePitch = AKAUTimePitch(mic)
default:
    timePitch = AKAUTimePitch(player)
}
//: Set the parameters of the Peak Limiter here
timePitch.rate = 2.0 // rate
timePitch.pitch = 0.5 // Cents
timePitch.overlap = 8.0 // generic

audiokit.audioOutput = timePitch
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
