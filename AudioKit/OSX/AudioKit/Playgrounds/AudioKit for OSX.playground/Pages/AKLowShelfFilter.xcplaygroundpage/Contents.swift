//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKLowShelfFilter
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
let playerWindow: AKAudioPlayerWindow
let lowShelfFilter: AKLowShelfFilter

switch source {
case "mic":
    lowShelfFilter = AKLowShelfFilter(mic)
default:
    lowShelfFilter = AKLowShelfFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}

//: Set the parameters of the low-shelf filter here
lowShelfFilter.cutoffFrequency = 80 // Hz
lowShelfFilter.gain = 0 // dB

var lowShelfFilterWindow = AKLowShelfFilterWindow(lowShelfFilter)

audiokit.audioOutput = lowShelfFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
