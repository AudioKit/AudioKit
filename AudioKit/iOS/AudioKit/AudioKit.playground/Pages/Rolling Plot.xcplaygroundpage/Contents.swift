//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Rolling Output Plot
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

var delay = AKDelay(player)

delay.time = 0.01 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

audiokit.audioOutput = delay
audiokit.start()
player.play()

let plotView = AKRollingOutputPlot.createView()

XCPlaygroundPage.currentPage.liveView = plotView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
