//: [Previous](@previous)
//:
//: ---
//:
//: ## AKAUDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

//: Change the source to "mic" to process your voice
let source = "player"

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let mic = AKMicrophone()
let file = NSBundle.mainBundle().pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
let playerWindow: AKAudioPlayerWindow
let delay: AKAUDelay

switch (source) {
case "mic":
    delay = AKAUDelay(mic)
default:
    delay = AKAUDelay(player)
    playerWindow = AKAudioPlayerWindow(player)
}

//: Set the parameters of the delay here
delay.time = 0.1 // seconds
delay.feedback  = 90 // Percent
delay.dryWetMix = 60 // Percent

var delayWindow  = AKDelayWindow(delay)

//: You can also set the bounds of the sliders here
delayWindow.timeSlider.maxValue = 0.1 // seconds

audiokit.audioOutput = delay
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [Next](@next)
