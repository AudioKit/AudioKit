//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAUTimePitch
//: ### Add description
import XCPlayground
import AudioKit

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("PianoBassDrumLoop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let timePitch = AKAUTimePitch(player)
playerWindow = AKAudioPlayerWindow(player)

//: Set the parameters of the Peak Limiter here
timePitch.rate = 1.0 // rate
timePitch.pitch = 1.0 // Cents
timePitch.overlap = 8.0 // generic

var timePitchWindow = AKAUTimePitchWindow(timePitch)
timePitchWindow.rateSlider.maxValue = 4.0
audiokit.audioOutput = timePitch
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
