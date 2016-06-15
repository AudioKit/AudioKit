//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Noise Operations
//: 
import PlaygroundSupport
import AudioKit

let white = AKOperation.whiteNoise()
let pink = AKOperation.pinkNoise()

let balance = AKOperation.sineWave(frequency: 0.3).scale(minimum: 0, maximum: 1)
let noise = mixer(white, pink, balance: 1)
let pan = AKOperation.sineWave(frequency: 0.3)

let generator = AKOperationGenerator(stereoOperation: noise.pan(pan))

AudioKit.output = generator
AudioKit.start()

generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
