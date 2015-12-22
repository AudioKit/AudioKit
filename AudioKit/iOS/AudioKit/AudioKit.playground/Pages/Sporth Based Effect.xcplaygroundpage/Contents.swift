//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AKOperationEffect
//: ### You can also create nodes for AudioKit using [Sporth](https://github.com/PaulBatchelor/Sporth). We'll show you how to do that for an effect node below...
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()

let file = bundle.pathForResource("drumloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true

let input  = AKStereoOperation.input
let zitarev_example = "\(input) 15 200 7.0 8.0 10000 315 0 1500 0 1 0 zitarev"

let effect = AKOperationEffect(player, sporth: zitarev_example)

audiokit.audioOutput = effect
audiokit.start()

player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
