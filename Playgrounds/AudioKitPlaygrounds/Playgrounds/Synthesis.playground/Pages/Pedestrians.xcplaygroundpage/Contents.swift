//: ## Pedestrians
//: A British crossing signal implemented with AudioKit, an example from
//: Andy Farnell's excellent book "Designing Sound"

import AudioKit

let generator = OperationGenerator {

    // Generate a sine wave at the right frequency
    let crossingSignalTone = Operation.sineWave(frequency: 2_500)

    // Periodically trigger an envelope around that signal
    let crossingSignalTrigger = Operation.periodicTrigger(period: 0.2)
    let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
        trigger: crossingSignalTrigger,
        attack: 0.01,
        hold: 0.1,
        release: 0.01)

    // scale the volume
    return crossingSignal * 0.2
}

engine.output = generator
try engine.start()
//: Activate the signal
generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
