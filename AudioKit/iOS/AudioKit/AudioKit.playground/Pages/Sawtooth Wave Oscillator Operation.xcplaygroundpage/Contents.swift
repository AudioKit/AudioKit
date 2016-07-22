//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Wave Oscillator Operation
//: ### Maybe the most annoying sound ever. Sorry.
import XCPlayground
import AudioKit

//: Set up the operations that will be used to make a generator node

let generator = AKOperationGenerator() { _ in
    let freq = AKOperation.jitter(amplitude: 200, minimumFrequency: 1, maximumFrequency: 10) + 200
    let amp  = AKOperation.randomVertexPulse(minimum: 0, maximum: 0.3, updateFrequency: 1)
    return AKOperation.sawtoothWave(frequency: freq, amplitude: amp)
}

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
