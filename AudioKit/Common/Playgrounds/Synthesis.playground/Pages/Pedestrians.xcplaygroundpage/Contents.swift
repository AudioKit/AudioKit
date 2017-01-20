//: ## Pedestrians
//: A British crossing signal implemented with AudioKit, an example from
//: Andy Farnell's excellent book "Designing Sound"
import PlaygroundSupport
import AudioKit

let generator = AKOperationGenerator() { _ in

    // Generate a sine wave at the right frequency
    let crossingSignalTone = AKOperation.sineWave(frequency: 2500)

    // Periodically trigger an envelope around that signal
    let crossingSignalTrigger = AKOperation.periodicTrigger(period: 0.2)
    let crossingSignal = crossingSignalTone.triggeredWithEnvelope(
        trigger: crossingSignalTrigger,
        attack: 0.01,
        hold: 0.1,
        release: 0.01)

    // scale the volume
    return crossingSignal * 0.2
}

AudioKit.output = generator
AudioKit.start()
//: Activate the signal
generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true
