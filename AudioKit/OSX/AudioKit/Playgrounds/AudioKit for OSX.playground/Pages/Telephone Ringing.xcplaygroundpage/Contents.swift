//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Telephone Ringing
//: ###  The ringing sound is also a pair of frequencies that play for 2 seconds, and repeats every 6 seconds.
import XCPlayground
import AudioKit

let ringingTone1 = AKOperation.sineWave(frequency: 480)
let ringingTone2 = AKOperation.sineWave(frequency: 440)

let ringingToneMix = mixer(ringingTone1, ringingTone2, balance: 0.5)

let ringTrigger = AKOperation.metronome(0.1666) // 1 / 6 seconds

let ringing = ringingToneMix.triggeredWithEnvelope(ringTrigger,
    attack: 0.01, hold: 2, release: 0.01)

let generator = AKOperationGenerator(operation: ringing * 0.4)

AudioKit.output = generator
AudioKit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
