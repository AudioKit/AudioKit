//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKTimePitch
//: ### Add description
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let timePitch: AKTimePitch

switch source {
case "mic":
    timePitch = AKTimePitch(mic)
default:
    playerWindow = AKAudioPlayerWindow(player)
    let playerWithVolumeAndPanControl = AKMixer(player)
    timePitch = AKTimePitch(playerWithVolumeAndPanControl)
}

//: Set the parameters of the Peak Limiter here
timePitch.rate = 1.0 // rate
timePitch.pitch = 1.0 // Cents
timePitch.overlap = 8.0 // generic

var timePitchWindow = AKTimePitchWindow(timePitch)
timePitchWindow.rateSlider.maxValue = 4.0
audiokit.audioOutput = timePitch
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
