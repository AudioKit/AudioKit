//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## AutoWah Operation
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("guitarloop", ofType: "wav")
var player = AKAudioPlayer(file!)
player.looping = true

let wahAmount = AKOperation.sineWave(frequency: 0.6).scale(minimum: 1, maximum: 0)

let autowah = AKOperation.input.autoWah(wah: wahAmount, mix: 100, amplitude: 1)

let effect = AKOperationEffect(player, operation: autowah)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
