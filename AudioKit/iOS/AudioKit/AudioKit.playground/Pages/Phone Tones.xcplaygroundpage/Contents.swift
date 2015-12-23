//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phone Tones
//: ### AudioKit is great for sound design. Here, we show you how to create some telephone sounds using the sineWave generator.
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: A dial tone is simply two sine waves at different frequencies
let dialTone1 = sineWave(frequency: 350)
let dialTone2 = sineWave(frequency: 440)
let dialTone = mix(dialTone1, dialTone2, t: 0.5)

//: The ringing sound is also a pair of frequencies that play for 2 seconds, and repeats every 6 seconds
let ringingTone1 = sineWave(frequency: 480)
let ringingTone2 = sineWave(frequency: 440)
let ringingToneMix = mix(ringingTone1, ringingTone2, t: 0.5)

let ringTrigger = metronome(0.1666) // 1 / 6 seconds
let ringing = ringingToneMix.triggeredBy(ringTrigger, attack: 0.01, hold: 2, release: 0.01)


//: The busy signal is similar as well
let busySignalTone1 = sineWave(frequency: 480)
let busySignalTone2 = sineWave(frequency: 620)
let busySignalTone = mix(busySignalTone1, busySignalTone2, t: 0.5)

let busyTrigger = metronome(2)
let busySignal = busySignalTone.triggeredBy(busyTrigger, attack: 0.01, hold: 0.25, release: 0.01)

//: Uncomment out the one you would like to hear
//let generator = AKOperationGenerator(operation: dialTone)
//let generator = AKOperationGenerator(operation: ringing)
//let generator = AKOperationGenerator(operation: busySignal)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
