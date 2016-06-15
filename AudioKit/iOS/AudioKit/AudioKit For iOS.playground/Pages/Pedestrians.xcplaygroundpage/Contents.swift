//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Pedestrians
//: ### A British crossing signal implemented with AudioKit, an example from Andy Farnell's excellent book "Designing Sound"
import PlaygroundSupport
import AudioKit

//: Generate a sine wave at the right frequency
let crossingSignalTone = AKOperation.sineWave(frequency: 2500)

//: Periodically trigger an envelope around that signal
let crossingSignalTrigger = AKOperation.periodicTrigger(0.2)
let crossingSignal = crossingSignalTone.triggeredWithEnvelope(crossingSignalTrigger, attack: 0.01, hold: 0.1, release: 0.01)

//: Create the generator node (and scale that volume!)
let generator = AKOperationGenerator(operation: crossingSignal * 0.2)

AudioKit.output = generator
AudioKit.start()

//: Activate the signal
generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
