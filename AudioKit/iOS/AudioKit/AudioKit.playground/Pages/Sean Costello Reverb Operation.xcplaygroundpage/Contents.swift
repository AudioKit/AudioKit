//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sean Costello Reverb Operation
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let reverb = AKOperation.input.reverberateWithCostello(
    feedback: AKOperation.sineWave(frequency: 0.1).scale(minimum: 0.5, maximum: 0.97),
    cutoffFrequency: 10000)
let effect = AKOperationEffect(player, stereoOperation: reverb)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
