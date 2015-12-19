//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Delay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times and feedback amounts. Our delay has three parameters: "time", which is the ammount of time in seconds you want your sound to be delayed, "feedback", which is sets how much the delayed signal should be fed back into itself, an "dryWetMix", which is the percentage of "dry" (or non-delayed signal), and "wet" (delayed-signal) audio you want your output signal to consist of. 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

let player = AKAudioPlayer(file!)
player.looping = true

let delay = AKDelay(player)

delay.time = 0.01 // seconds
delay.feedback  = 90 // Percent
delay.dryWetMix = 60 // Percent

audiokit.audioOutput = delay
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
