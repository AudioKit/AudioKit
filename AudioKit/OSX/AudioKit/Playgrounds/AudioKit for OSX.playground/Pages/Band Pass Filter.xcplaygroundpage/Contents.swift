//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKBandPassFilter
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
let playerWindow: AKAudioPlayerWindow
let bandPassFilter: AKBandPassFilter

switch source {
case "mic":
    bandPassFilter = AKBandPassFilter(mic)
default:
    bandPassFilter = AKBandPassFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}

//: Set the parameters of the band pass filter here
bandPassFilter.centerFrequency = 5000 // Hz
bandPassFilter.bandwidth = 600  // Cents

var bandPassFilterWindow = AKBandPassFilterWindow(bandPassFilter)

audiokit.audioOutput = bandPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
