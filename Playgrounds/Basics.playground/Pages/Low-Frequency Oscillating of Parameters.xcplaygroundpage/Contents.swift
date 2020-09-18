//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low-Frequency Oscillation of Parameters
//: ### Oftentimes we want rhythmic changing of parameters that varying in a standard way.
//: ### This is traditionally done with Low-Frequency Oscillators, LFOs.
import AudioKit

let generator = OperationGenerator {
    let frequencyLFO = Operation.square(frequency: 1)
        .scale(minimum: 440, maximum: 880)
    let carrierLFO = Operation.triangle(frequency: 1)
        .scale(minimum: 1, maximum: 2)
    let modulatingMultiplierLFO = Operation.sawtooth(frequency: 1)
        .scale(minimum: 0.1, maximum: 2)
    let modulatingIndexLFO = Operation.reverseSawtooth(frequency: 1)
        .scale(minimum: 0.1, maximum: 20)

    return Operation.fmOscillator(
        baseFrequency: frequencyLFO,
        carrierMultiplier: carrierLFO,
        modulatingMultiplier: modulatingMultiplierLFO,
        modulationIndex: modulatingIndexLFO,
        amplitude: 0.2)
}

engine.output = generator
try engine.start()

generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
