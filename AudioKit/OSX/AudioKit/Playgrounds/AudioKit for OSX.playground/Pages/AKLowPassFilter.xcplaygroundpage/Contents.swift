//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKLowPassFilter
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
let lowPassFilter: AKLowPassFilter

switch source {
case "mic":
    lowPassFilter = AKLowPassFilter(mic)
default:
    lowPassFilter = AKLowPassFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}

//: Set the parameters of the low pass filter here
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

var lowPassFilterWindow = AKLowPassFilterWindow(lowPassFilter)

audiokit.audioOutput = lowPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
