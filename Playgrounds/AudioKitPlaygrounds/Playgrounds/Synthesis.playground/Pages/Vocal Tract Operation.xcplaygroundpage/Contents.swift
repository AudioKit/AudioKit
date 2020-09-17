//: ## Vocal Tract Operation
//:
//: Sometimes as audio developers, we just like to have some fun.

import AudioKit

let playRate = 2.0

let generator = OperationGenerator {
    let frequency = Operation.sineWave(frequency: 1).scale(minimum: 100, maximum: 300)
    let jitter = Operation.jitter(amplitude: 300, minimumFrequency: 1, maximumFrequency: 3)
    let position = Operation.sineWave(frequency: 0.1).scale()
    let diameter = Operation.sineWave(frequency: 0.2).scale()
    let tenseness = Operation.sineWave(frequency: 0.3).scale()
    let nasality = Operation.sineWave(frequency: 0.35).scale()
    return Operation.vocalTract(frequency: frequency + jitter,
                                  tonguePosition: position,
                                  tongueDiameter: diameter,
                                  tenseness: tenseness,
                                  nasality: nasality)
}

engine.output = generator
try engine.start()
generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
