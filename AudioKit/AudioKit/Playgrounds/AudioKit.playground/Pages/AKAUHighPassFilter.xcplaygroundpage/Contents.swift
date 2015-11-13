//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUHighPassFilter
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
let highPassFilter: AKAUHighPassFilter

switch (source) {
case "mic":
    highPassFilter = AKAUHighPassFilter(mic)
default:
    highPassFilter = AKAUHighPassFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}
//: Set the parameters of the Peak Limiter here
highPassFilter.cutoffFrequency = 6900 // Hz
highPassFilter.resonance = 0 // dB

var highPassFilterWindow = AKAUHighPassFilterWindow(highPassFilter)

audiokit.audioOutput = highPassFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
