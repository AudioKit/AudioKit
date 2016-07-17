//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Microphone Input
//:
import XCPlayground
import AudioKit

let mic = AKMicrophone()
let tracker = AKFrequencyTracker.init(mic, hopSize: 200, peakCount: 2000)
let silence = AKBooster(tracker, gain: 0)

//: The frequency tracker passes its input to the output, so we can insert into the signal chain at the bottom
AudioKit.output = silence
AudioKit.start()


//: And here's where we monitor the results of tracking the amplitude.
AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency
    
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
