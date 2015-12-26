//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb Operation
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let reverb = AKOperation.input.reverberateWithCostello(
    feedback: sineWave(frequency: 0.1).scaledTo(minimum: 0.5, maximum: 0.97),
    cutoffFrequency: 10000)
let effect = AKOperationEffect(player, stereoOperation: reverb)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
