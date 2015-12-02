//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts
import XCPlayground
import AudioKit

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let delay = AKDelay(player)

//: Set the parameters of the delay here
delay.time = 0.01 // seconds
delay.feedback  = 90 // Percent
delay.dryWetMix = 60 // Percent

audiokit.audioOutput = delay
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
