//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Node Output Plot
//: ### What's interesting here is that we're plotting the waveform BEFORE the delay is processed
import XCPlayground
import AudioKit

let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("drumloop", ofType: "wav")

var player = AKAudioPlayer(file!)
player.looping = true

var delay = AKDelay(player)

delay.time = 0.1 // seconds
delay.feedback  = 0.9 // Normalized Value 0 - 1
delay.dryWetMix = 0.6 // Normalized Value 0 - 1

AudioKit.output = delay
AudioKit.start()
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
