//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKCostelloReverb
//: ### Add description
import XCPlayground
import AudioKit

//: This is set-up, the next thing to change is in the next section:
let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let reverb = AKCostelloReverb(player)

//: Set the parameters of the reverb here
reverb.cutoffFrequency = 9900 // Hz
reverb.feedback = 0.92

audiokit.audioOutput = reverb
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
