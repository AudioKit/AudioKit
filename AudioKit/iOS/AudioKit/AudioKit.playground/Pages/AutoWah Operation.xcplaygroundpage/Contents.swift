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
let player = AKAudioPlayer(file!)
player.looping = true

let wahAmount = sineWave(frequency: 0.6.ak).scaledTo(minimum: 1, maximum: 0)

let autowah = AKInput.autoWahed(wah: wahAmount, mix: 100.ak, amplitude: 1.ak)

let effect = AKNode.effect(player, operation: autowah)

audiokit.audioOutput = effect
audiokit.start()
player.play()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
