//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Moog Ladder Filter Operation
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let bundle = NSBundle.mainBundle()
let file = bundle.pathForResource("leadloop", ofType: "wav")
let player = AKAudioPlayer(file!)
player.looping = true
let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096), baseFrequency: 100,  amplitude:0.1)

let frequency = sineWave(frequency: 10.ak).scaledTo(minimum: 500, maximum: 1000)
let resonance = abs(sineWave(frequency: 0.3.ak)) * 0.95

let filter  = AKOperation.input.moogLadderFiltered(cutoffFrequency: frequency, resonance: resonance) * 3

let effect = AKNode.effect(player, operation: filter)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
