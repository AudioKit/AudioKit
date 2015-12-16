//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKTimePitch
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the player
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio source to a time/pitch effect
let timePitch = AKTimePitch(player)

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
