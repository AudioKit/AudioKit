//: ## FM Oscillator Operation
//:


import AudioKit

let generator = OperationGenerator {

    // Set up the operations that will be used to make a generator node
    let sine = Operation.sineWave(frequency: 1)
    let square = Operation.squareWave(frequency: 1.64)
    let square2 = Operation.squareWave(frequency: sine, amplitude: sine, pulseWidth: sine)

    let freq = sine.scale(minimum: 900, maximum: 200)
    let car = square.scale(minimum: 1.2, maximum: 1.4)
    let mod = square.scale(minimum: 1, maximum: 3)
    let index = square2 * 3 + 5

    let oscillator = Operation.fmOscillator(baseFrequency: freq,
                                              carrierMultiplier: car,
                                              modulatingMultiplier: mod,
                                              modulationIndex: index,
                                              amplitude: 0.5)

    return oscillator.pan(sine)
}

let delay1 = Delay(generator, time: 0.01, feedback: 0.99, lowPassCutoff: 0, dryWetMix: 0.5)
let delay2 = Delay(delay1, time: 0.1, feedback: 0.1, lowPassCutoff: 0, dryWetMix: 0.5)
let reverb = Reverb(delay2, dryWetMix: 0.5)

engine.output = reverb
try engine.start()

generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
