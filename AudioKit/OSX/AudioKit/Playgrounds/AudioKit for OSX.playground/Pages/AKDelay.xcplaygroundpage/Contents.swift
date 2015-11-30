//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let playerWindow: AKAudioPlayerWindow
let delay: AKDelay

switch source {
case "mic":
    delay = AKDelay(mic)
default:
    delay = AKDelay(player)
    playerWindow = AKAudioPlayerWindow(player)
}

delay.//: Set the parameters of the delay here
time = 0.01 // seconds
delay.feedback  = 90 // Percent
delay.dryWetMix = 60 // Percent

var delayWindow  = AKDelayWindow(delay)

delayWin//: You can also set the bounds of the sliders here
dow.timeSlider.maxValue = 0.2 // seconds
delayWindow.feedbackSlider.maxValue = 99
audiokit.audioOutput = delay
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
