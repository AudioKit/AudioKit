//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Wave Oscillator Operation
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Set up the operations that will be used to make a generator node

let freq = jitter(amplitude: 200, minimumFrequency: 1, maximumFrequency: 10) + 200
let amp  = randomVertexPulse(minimum: 0, maximum: 1, updateFrequency: 1)
let oscillator = sawtoothWave(frequency: freq, amplitude: amp)

//: Set up the nodes
let generator = AKOperationGenerator(operation: oscillator)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
