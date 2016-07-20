//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low-Frequency Oscillation of Parameters
//: ### Often times we want rhythmic changing of parameters that varying in a standard way.
//: ### This is tradition done with Low-Frequency Oscillators, LFOs.
import XCPlayground
import AudioKit

let generator = AKOperationGenerator() {
    let frequencyLFO = AKOperation.square(frequency: 1)
        .scale(minimum: 440, maximum: 880)
    let carrierLFO   = AKOperation.triangle(frequency: 1)
        .scale(minimum: 1, maximum: 2)
    let modulatingMultiplierLFO = AKOperation.sawtooth(frequency: 1)
        .scale(minimum: 0.1, maximum: 2)
    let modulatingIndexLFO = AKOperation.reverseSawtooth(frequency: 1)
        .scale(minimum: 0.1, maximum: 20)

    return AKOperation.fmOscillator(
        baseFrequency: frequencyLFO,
        carrierMultiplier: carrierLFO,
        modulatingMultiplier: modulatingMultiplierLFO,
        modulationIndex:  modulatingIndexLFO,
        amplitude: 0.2)
}

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
