//: [Previous](@previous)
//:
//: ---
//:
//: ## AKAUTimePitch
import XCPlayground
import AudioKit

//: Change the source to "input" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let file = NSBundle.mainBundle().pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
let playerWindow: AKAudioPlayerWindow
let timePitch: AKAUTimePitch

switch (source) {
case "input":
    timePitch = AKAUTimePitch(mic)
default:
    timePitch = AKAUTimePitch(player)
    playerWindow = AKAudioPlayerWindow(player)
}

//: Set the parameters of the AKAUTimePitch here
timePitch.pitch = -700 // cents (1200 = one octavem can be postive or negative)
timePitch.rate = 4

//: You can also set the bounds of the sliders here
audiokit.audioOutput = timePitch
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
