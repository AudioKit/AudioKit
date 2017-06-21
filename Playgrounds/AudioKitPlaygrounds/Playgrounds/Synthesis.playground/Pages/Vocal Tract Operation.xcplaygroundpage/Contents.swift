//: ## Vocal Tract Operation
//:
//: Sometimes as audio developers, we just like to have some fun.
import AudioKitPlaygrounds
import AudioKit

let playRate = 2.0

let generator = AKOperationGenerator { _ in
    let frequency = AKOperation.sineWave(frequency: 1).scale(minimum: 100, maximum: 300)
    let jitter = AKOperation.jitter(amplitude: 300, minimumFrequency: 1, maximumFrequency: 3)
    let position = AKOperation.sineWave(frequency: 0.1).scale()
    let diameter = AKOperation.sineWave(frequency: 0.2).scale()
    let tenseness = AKOperation.sineWave(frequency: 0.3).scale()
    let nasality = AKOperation.sineWave(frequency: 0.35).scale()
    return AKOperation.vocalTract(frequency: frequency + jitter,
                                  tonguePosition: position,
                                  tongueDiameter: diameter,
                                  tenseness: tenseness,
                                  nasality: nasality)
}

AudioKit.output = generator
AudioKit.start()
generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
