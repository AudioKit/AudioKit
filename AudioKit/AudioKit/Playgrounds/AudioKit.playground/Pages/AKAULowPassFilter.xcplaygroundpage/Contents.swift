//: [Previous](@previous)
//:
//: ---
//:
//: ## AKAULowPassFilter
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
let playerWindow: AKAudioPlayerWindow
let lowPassFilter: AKAULowPassFilter

switch (source) {
case "mic":
    lowPassFilter = AKAULowPassFilter(mic)
default:
    lowPassFilter = AKAULowPassFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}
//: Set the parameters of the Peak Limiter here
lowPassFilter.cutoffFrequency = 6900 // Hz
lowPassFilter.resonance = 0 // dB

var lowPassFilterWindow = AKAULowPassFilterWindow(lowPassFilter)

audiokit.audioOutput = lowPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
