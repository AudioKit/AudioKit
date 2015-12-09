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

let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let highPassFilter: AKHighPassFilter

switch source {
case "mic":
    highPassFilter = AKHighPassFilter(mic)
default:
    playerWindow = AKAudioPlayerWindow(player)
    let playerWithVolumeAndPanControl = AKMixer(player)
    highPassFilter = AKHighPassFilter(playerWithVolumeAndPanControl)
}

//: Set the parameters of the high pass filter here
highPassFilter.cutoffFrequency = 6900 // Hz
highPassFilter.resonance = 0 // dB

var highPassFilterWindow = AKHighPassFilterWindow(highPassFilter)

audiokit.audioOutput = highPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
