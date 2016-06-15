//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Low-Frequency Oscillation of Parameters
//: ### Often times we want rhythmic changing of parameters that varying in a standard way.  This is tradition done with Low-Frequency Oscillators, LFOs.
import PlaygroundSupport
import AudioKit

let frequencyLFO = AKOperation.square(frequency: 1).scale(minimum: 440, maximum: 880)
let carrierLFO   = AKOperation.triangle(frequency: 1).scale(minimum: 1, maximum: 2)
let modulatingMultiplierLFO = AKOperation.sawtooth(frequency: 1).scale(minimum: 0.1, maximum: 2)
let modulatingIndexLFO = AKOperation.reverseSawtooth(frequency: 1).scale(minimum: 0.1, maximum: 20)

let fmOscillator = AKOperation.fmOscillator(
    baseFrequency: frequencyLFO,
    carrierMultiplier: carrierLFO,
    modulatingMultiplier: modulatingMultiplierLFO,
    modulationIndex:  modulatingIndexLFO,
    amplitude: 0.2)

let generator = AKOperationGenerator(operation: fmOscillator)

AudioKit.output = generator
AudioKit.start()

generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
