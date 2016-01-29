//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Busy Signal
//: ### The busy signal is similar as well, just a different set of parameters.
import XCPlayground
import AudioKit

let busySignalTone1 = AKOperation.sineWave(frequency: 480)
let busySignalTone2 = AKOperation.sineWave(frequency: 620)
let busySignalTone = mixer(busySignalTone1, busySignalTone2, balance: 0.5)

let busyTrigger = AKOperation.metronome(2)
let busySignal = busySignalTone.triggeredWithEnvelope(busyTrigger,
    attack: 0.01, hold: 0.25, release: 0.01)

let generator = AKOperationGenerator(operation: busySignal * 0.4)

AudioKit.output = generator
AudioKit.start()

generator.play()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
