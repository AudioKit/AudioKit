//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Variable Delay Operation
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true


let time = AKOperation.sineWave(frequency: 0.3).scaledTo(minimum: 0.01, maximum: 0.2)
let feedback = AKOperation.sineWave(frequency: 0.21).scaledTo(minimum: 0.5, maximum: 0.9)

let variableDelay = AKOperation.input.variableDelay(time: time, feedback: feedback, maximumDelayTime: 1.0)
let effect = AKOperationEffect(player, operation: variableDelay)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
