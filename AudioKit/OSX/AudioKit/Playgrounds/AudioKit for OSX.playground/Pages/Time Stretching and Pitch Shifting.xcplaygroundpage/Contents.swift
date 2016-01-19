//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Time Stretching and Pitch Shifting
//: ### With AKTimePitch you can easily change the pitch and speed of a player-generated sound.  It does not work on live input or generated signals.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: This section prepares the player
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true
let playerWindow = AKAudioPlayerWindow(player)

//: Next, we'll connect the audio source to a time/pitch effect
var timePitch = AKTimePitch(player)

//: Set the parameters of the Time/Pitch stretching here
timePitch.rate = 1.0 // rate
timePitch.pitch = 1.0 // Cents
timePitch.overlap = 8.0 // generic

var timePitchWindow = AKTimePitchWindow(timePitch)
timePitchWindow.rateSlider.maxValue = 4.0
audiokit.audioOutput = timePitch
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
