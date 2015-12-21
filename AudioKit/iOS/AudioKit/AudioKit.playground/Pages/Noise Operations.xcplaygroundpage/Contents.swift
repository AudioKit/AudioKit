//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Noise Operations
//: ### Add description
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let white = whiteNoise()
let pink = pinkNoise()

let balance = sineWave(frequency: 0.3).scaledTo(minimum: 0, maximum: 1)
let noise = mix(white, pink, t: 1)
let pan = sineWave(frequency: 0.3)

let generator = AKNode.generator(noise.panned(pan))

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
