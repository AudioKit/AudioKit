//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phone Tones
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds using the sineWave generator.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: The busy signal is similar as well
let busySignalTone1 = sineWave(frequency: 480)
let busySignalTone2 = sineWave(frequency: 620)
let busySignalTone = mix(busySignalTone1, busySignalTone2, t: 0.5)

let busyTrigger = metronome(2)
let busySignal = busySignalTone.triggeredBy(busyTrigger, attack: 0.01, hold: 0.25, release: 0.01)

let generator = AKOperationGenerator(operation: busySignal)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
