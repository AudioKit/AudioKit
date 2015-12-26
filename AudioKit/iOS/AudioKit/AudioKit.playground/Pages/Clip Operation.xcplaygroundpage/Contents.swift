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
var player = AKAudioPlayer(file!)
player.looping = true
let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096), baseFrequency: 100,  amplitude:0.1)
let sinusoid = AKOperation.sineWave(frequency: 0.3)
let limitSine = sinusoid.scale(minimum: 0, maximum: 1)

let clip = AKOperation.input.clip(limitSine)

let effect = AKOperationEffect(player, operation: clip)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
