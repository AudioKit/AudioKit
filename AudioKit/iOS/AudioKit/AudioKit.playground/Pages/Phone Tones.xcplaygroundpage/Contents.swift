//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phone Tones
//: ### An example creating typical telephone sounds with AudioKit
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: A dial tone is simply two sine waves at different frequencies
let dialTone1 = sineWave(frequency: 350.ak)
let dialTone2 = sineWave(frequency: 440.ak)
let dialTone = mix(dialTone1, dialTone2, t: 0.5)

//: The ringing sound is also a pair of frequencies that play for 2 seconds, and repeats every 6 seconds
let ringingTone1 = sineWave(frequency: 480.ak)
let ringingTone2 = sineWave(frequency: 440.ak)
let ringingToneMix = mix(ringingTone1, ringingTone2, t: 0.5)

let ringTrigger = metronome(0.1666.ak) // 1 / 6 seconds
let ringing = ringingToneMix.triggeredBy(ringTrigger, attack: 0.01.ak, hold: 2.ak, release: 0.01.ak)


//: The busy signal is similar as well
let busySignalTone1 = sineWave(frequency: 480.ak)
let busySignalTone2 = sineWave(frequency: 620.ak)
let busySignalTone = mix(busySignalTone1, busySignalTone2, t: 0.5)

let busyTrigger = metronome(2.ak)
let busySignal = busySignalTone.triggeredBy(busyTrigger, attack: 0.01.ak, hold: 0.25.ak, release: 0.01.ak)

//: Uncomment out the one you would like to hear
//let generator = AKNode.generator(dialTone)
let generator = AKNode.generator(ringing)
//let generator = AKNode.generator(busySignal)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
