//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Noise Operations
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let white = AKOperation.whiteNoise()
let pink = AKOperation.pinkNoise()

let balance = AKOperation.sineWave(frequency: 0.3).scale(minimum: 0, maximum: 1)
let noise = mix(white, pink, t: 1)
let pan = AKOperation.sineWave(frequency: 0.3)

let generator = AKOperationGenerator(stereoOperation: noise.pan(pan))

audiokit.audioOutput = generator
audiokit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
