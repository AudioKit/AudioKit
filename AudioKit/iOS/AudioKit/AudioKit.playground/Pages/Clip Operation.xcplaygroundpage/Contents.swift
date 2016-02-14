//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Clip Operation
//:
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let sinusoid = AKOperation.sineWave(frequency: 0.3)
let limitSine = sinusoid.scale(minimum: 0, maximum: 1)

let clip = AKOperation.input.clip(limitSine)

let effect = AKOperationEffect(player, operation: clip)

AudioKit.output = effect
AudioKit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
