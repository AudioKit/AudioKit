//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pedestrians
//: ### A British crossing signal implemented with AudioKit
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: The busy signal is similar as well
let crossingSignalTone = sineWave(frequency: 2500)

let crossingSignalTrigger = periodicTrigger(0.2)
let crossingSignal = crossingSignalTone.triggeredBy(crossingSignalTrigger, attack: 0.01, hold: 0.1, release: 0.01)

let generator = AKNode.generator(crossingSignal)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
