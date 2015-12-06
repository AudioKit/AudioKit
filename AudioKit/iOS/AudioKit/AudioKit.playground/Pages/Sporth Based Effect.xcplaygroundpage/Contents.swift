//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKCustomEffect
//: ### You can also create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth). We'll show you how to do that for an effect node below...
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()

let file = bundle.pathForResource("808loop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let modifier = AKCustomEffect(player, sporth:"0 p 1 p 0.1 1 sine 0.5 0.97 scale 10000 revsc")

audiokit.audioOutput = modifier
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
