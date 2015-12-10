//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## clip
//: ### We tried to give you a large variety of different generators and effects. However, you may come across a situation where we don't have something that you may need. If that's the case, you can build your own! This is an example of building a sound generator from scratch.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("mixloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096), baseFrequency: 100,  amplitude:0.1)
let sine = AKP.sine(frequency: 0.3.ak)
let limitSine = AKP.scale(sine, minimum: 0.ak, maximum: 1.ak)

let clip = AKP.clip(AKP.input, limit: limitSine)
let effect = AKNode.effect(player, operation: clip)

audiokit.audioOutput = effect
audiokit.start()
player.play()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
