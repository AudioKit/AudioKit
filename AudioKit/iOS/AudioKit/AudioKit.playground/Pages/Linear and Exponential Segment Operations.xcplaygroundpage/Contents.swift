//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Linear and Exponential Segment Operations
//: ### Add description
//:
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let updateRate = 2.0
let start = AKOperation.randomNumberPulse() * 2000 + 300
let duration = AKOperation.randomNumberPulse()

let frequency = AKOperation.lineSegment(AKOperation.trigger, start: start, end: 0, duration: duration)
let amplitude = AKOperation.exponentialSegment(AKOperation.trigger, start: 0.8, end: 0.01, duration: 1.0 / updateRate)
let sine = AKOperation.sineWave(frequency: frequency, amplitude:  amplitude)

let generator = AKOperationGenerator(operation:  sine)

var delay = AKDelay(generator)
delay.time = 0.25 / updateRate
delay.feedback = 0.8

var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeHall)
audiokit.audioOutput = reverb
audiokit.start()

generator.start()
generator.trigger()

AKPlaygroundLoop(frequency: updateRate) {
    generator.trigger()
}
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
