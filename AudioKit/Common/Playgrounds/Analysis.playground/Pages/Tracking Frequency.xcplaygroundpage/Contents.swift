//: ## Tracking Frequency
//: ### Tracking frequency is just as easy as tracking amplitude, and even
//: ### includes amplitude, but it is more CPU intensive, so if you just need amplitude,
//: ### use the amplitude tracker.
import XCPlayground
import AudioKit

//: First lets set up sound source to track
let oscillatorNode = AKOperationGenerator() { _ in
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency: 0.2).scale(minimum: 0, maximum: 0.5)

    // And let's make the frequency also be a sineWave
    let frequency = AKOperation.sineWave(frequency: 0.1).scale(minimum: 100, maximum: 2200)

    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let tracker = AKFrequencyTracker(oscillatorNode)
let booster = AKBooster(tracker, gain: 1)
let secondaryOscillator = AKOscillator()

//: The frequency tracker passes its input to the output,
//: so we can insert into the signal chain at the bottom
AudioKit.output = AKMixer(booster, secondaryOscillator)
AudioKit.start()

oscillatorNode.start()
secondaryOscillator.start()

AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency
    secondaryOscillator.frequency = freq
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

