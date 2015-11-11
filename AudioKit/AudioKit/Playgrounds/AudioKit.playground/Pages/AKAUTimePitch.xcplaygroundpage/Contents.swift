//: [Previous](@previous)
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
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
let playerWindow: AKAudioPlayerWindow
let timePitch: AKAUTimePitch

switch (source) {
case "mic":
    timePitch = AKAUTimePitch(mic)
default:
    timePitch = AKAUTimePitch(player)
    playerWindow = AKAudioPlayerWindow(player)
}
//: Set the parameters of the Peak Limiter here
timePitch.rate = 1.0 // rate
timePitch.pitch = 1.0 // Cents
timePitch.overlap = 8.0 // generic
timePitch.enablePeakLocking = 1 // Boolean

var timePitchWindow = AKAUTimePitchWindow(timePitch)

audiokit.audioOutput = timePitch
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
