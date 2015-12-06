//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKVariableDelay
//: ### Exploring the powerful effect of repeating sounds after varying length delay times
import XCPlayground
import AudioKit

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let delay = AKVariableDelay(player)

//: Set the parameters of the delay here delay.time = 0.1 // seconds

audiokit.audioOutput = delay
audiokit.start()
player.play()

var t = 0.0
while true {
    delay.time = Float(1.0 - cos(3 * t)) * 0.02
    delay.feedback = Float(1.0 - sin(2 * t)) * 0.5
    t = t + 0.01
    usleep(1000000 / 100)
}

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
