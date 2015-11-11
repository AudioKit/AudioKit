//: [Previous](@previous)
//:
//: ---
//:
//: ## AKAUHighShelfFilter
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
let highShelfFilter: AKAUHighShelfFilter

switch (source) {
case "mic":
    highShelfFilter = AKAUHighShelfFilter(mic)
default:
    highShelfFilter = AKAUHighShelfFilter(player)
    playerWindow = AKAudioPlayerWindow(player)
}
//: Set the parameters of the Peak Limiter here
highShelfFilter.cutOffFrequency = 10000 // Hz
highShelfFilter.gain = 0 // dB

var highShelfFilterWindow = AKAUHighShelfFilterWindow(highShelfFilter)

audiokit.audioOutput = highShelfFilter
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
