//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node Output Plot
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

var delay = AKDelay(player)

delay.time = 0.1 // seconds
delay.feedback  = 90 // Percent
delay.dryWetMix = 60 // Percent

audiokit.audioOutput = delay
audiokit.start()
player.play()


let plot = AKNodeOutputPlot(player)
plot.plot?.plotType = .Rolling
plot.plot?.shouldFill = true
plot.plot?.shouldMirror = true
plot.plot?.color = UIColor.blueColor()
let view = plot.containerView

XCPlaygroundPage.currentPage.liveView = plot.containerView

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
