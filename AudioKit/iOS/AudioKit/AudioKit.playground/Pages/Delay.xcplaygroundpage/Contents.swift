//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Delay
//: ### Here we can explore the powerful effect of repeating sounds after varying length delay times and feedback amounts. Our delay has three parameters: "time", which is the amount of time in seconds you want your sound to be delayed, "feedback", which is sets how much the delayed signal should be fed back into itself, and "dryWetMix", which is the amount of "dry" (or non-delayed signal), and "wet" (delayed-signal) audio you want your output signal to consist of.
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

var delay = AKDelay(player)

delay.time      = 0.1 // seconds
delay.feedback  = 0.5 // Normalized Value 0 - 1
delay.dryWetMix = 0.5 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
