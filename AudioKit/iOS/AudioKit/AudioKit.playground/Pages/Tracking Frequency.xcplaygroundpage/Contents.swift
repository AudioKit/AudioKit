//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Frequency
//: ### Tracking frequency is just as easy as tracking amplitude, and even includes amplitude, but it is more CPU intensive, so if you just need amplitude, use the amplitude tracker.
import XCPlayground
import AudioKit

//: Let's set up the volume to be changing in the shape of a sine wave
let volume = AKOperation.sineWave(frequency:0.2).scale(minimum: 0.5, maximum: 1)

//: And let's make the frequency also be a sineWave
let minimum = Double(100)
let maximum = Double(2200)
let frequency = AKOperation.sineWave(frequency: 0.1).scale(minimum: minimum, maximum: maximum)

//: So our oscillator will move around randomly in frequency and have a smoothly varying amplitude
let oscillator = AKOperation.sineWave(frequency: frequency, amplitude: volume)

//: Connect up the the nodes
let oscillatorNode = AKOperationGenerator(operation: oscillator)
let tracker = AKFrequencyTracker(oscillatorNode)
let booster = AKBooster(tracker, gain: 1)
let secondaryOscillator = AKOscillator()

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = AKMixer(booster, secondaryOscillator)
AudioKit.start()

oscillatorNode.start()
secondaryOscillator.start()

//: And here's where we monitor the results of tracking the amplitude.
AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency
    secondaryOscillator.frequency = freq
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
