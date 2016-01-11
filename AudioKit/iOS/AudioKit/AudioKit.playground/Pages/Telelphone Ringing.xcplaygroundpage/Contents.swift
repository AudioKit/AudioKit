//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phone Tones
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds using the sineWave generator.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: The ringing sound is also a pair of frequencies that play for 2 seconds, and repeats every 6 seconds
let ringingTone1 = AKOperation.sineWave(frequency: 480)
let ringingTone2 = AKOperation.sineWave(frequency: 440)
let ringingToneMix = mixer(ringingTone1, ringingTone2, balance: 0.5)

let ringTrigger = AKOperation.metronome(0.1666) // 1 / 6 seconds
let ringing = ringingToneMix.triggeredWithEnvelope(ringTrigger, attack: 0.01, hold: 2, release: 0.01)

let generator = AKOperationGenerator(operation: ringing)

audiokit.audioOutput = generator
audiokit.start()

generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
