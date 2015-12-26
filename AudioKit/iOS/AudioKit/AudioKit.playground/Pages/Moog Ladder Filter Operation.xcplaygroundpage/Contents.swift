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
var player = AKAudioPlayer(file!)
player.looping = true
let fm = AKFMOscillator(table: AKTable(.Sine, size: 4096), baseFrequency: 100,  amplitude:0.1)

let frequency = AKOperation.sineWave(frequency: 10).scale(minimum: 500, maximum: 1000)
let resonance = abs(AKOperation.sineWave(frequency: 0.3)) * 0.95

let filter  = AKOperation.input.moogLadderFilter(cutoffFrequency: frequency, resonance: resonance) * 3

let effect = AKOperationEffect(player, operation: filter)

audiokit.audioOutput = effect
audiokit.start()
player.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
