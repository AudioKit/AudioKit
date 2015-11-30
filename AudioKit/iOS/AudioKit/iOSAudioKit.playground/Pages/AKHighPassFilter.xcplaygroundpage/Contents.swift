//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKHighPassFilter
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
let highPassFilter: AKHighPassFilter

switch source {
case "mic":
    highPassFilter = AKHighPassFilter(mic)
default:
    highPassFilter = AKHighPassFilter(player)
}
//: Set the parameters of the high pass filter here
highPassFilter.cutoffFrequency = 1000 // Hz
highPassFilter.resonance = 0 // dB

audiokit.audioOutput = highPassFilter
audiokit.start()

if source == "player" {
    player.play()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
