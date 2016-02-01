//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Linear and Exponential Segment Operations
//: ### You can create segments that vary parameters in operations over a certain duration.  Here we create an alien apocalypse.
//:
import XCPlayground
import AudioKit


//: Generate a new pew sound twice per second
let updateRate = 2.0

//: Vary the starting frequency and duration randomly
let start = AKOperation.randomNumberPulse() * 2000 + 300
let duration = AKOperation.randomNumberPulse()
let frequency = AKOperation.lineSegment(AKOperation.trigger, start: start, end: 0, duration: duration)

//: Decrease the amplitude exponentially
let amplitude = AKOperation.exponentialSegment(AKOperation.trigger, start: 0.8, end: 0.01, duration: 1.0 / updateRate)
let sine = AKOperation.sineWave(frequency: frequency, amplitude:  amplitude)

let generator = AKOperationGenerator(operation:  sine)

var delay = AKDelay(generator)

//: Add some effects for good fun
delay.time = 0.25 / updateRate
delay.feedback = 0.8
var reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeHall)

AudioKit.output = reverb
AudioKit.start()

generator.start()

AKPlaygroundLoop(frequency: updateRate) {
    generator.trigger()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
