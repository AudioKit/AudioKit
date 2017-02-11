//: ## FM Oscillator Operation
//:
import PlaygroundSupport
import AudioKit

let generator = AKOperationGenerator { _ in

    // Set up the operations that will be used to make a generator node
    let sine = AKOperation.sineWave(frequency: 1)
    let square = AKOperation.squareWave(frequency: 1.64)
    let square2 = AKOperation.squareWave(frequency: sine, amplitude: sine, pulseWidth: sine)

    let freq = sine.scale(minimum: 900, maximum: 200)
    let car = square.scale(minimum: 1.2, maximum: 1.4)
    let mod = square.scale(minimum: 1, maximum: 3)
    let index = square2 * 3 + 5

    let oscillator = AKOperation.fmOscillator(
        baseFrequency: freq,
        carrierMultiplier: car,
        modulatingMultiplier: mod,
        modulationIndex: index,
        amplitude: 0.5)

    return oscillator.pan(sine)
}

let delay1 = AKDelay(generator,
    time: 0.01, feedback: 0.99, lowPassCutoff: 0, dryWetMix: 0.5)
let delay2 = AKDelay(delay1,
    time: 0.1, feedback: 0.1, lowPassCutoff: 0, dryWetMix: 0.5)
let reverb = AKReverb(delay2, dryWetMix: 0.5)

AudioKit.output = reverb
AudioKit.start()

generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true
