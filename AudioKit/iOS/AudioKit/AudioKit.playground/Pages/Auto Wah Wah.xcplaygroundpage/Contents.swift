//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKAutoWah
//: ### One of the most iconic guitar effects is the wah-pedal. Here, we run an audio loop of a guitar through an AKAutoWah node. 
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
let player = AKAudioPlayer(file!)
let wah = AKAutoWah(player)
player.looping = true

//: Set the parameters of the auto-wah here
wah.wah = 1
wah.amplitude = 1

audiokit.audioOutput = wah
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
