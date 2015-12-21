//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Amplitude
//: ### Tracking the amplitude of one node's output using the AKAmplitudeTracker node.

//: Standard imports and AudioKit setup:
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Let's set up the volume to be changing in the shape of a sine wave
let volume = sineWave(frequency:0.2).scaledTo(minimum: 0.3, maximum: 1)

//: And let's make the frequency also be a sineWave
let minimum = Double(200)
let maximum = Double(800)
let frequency = sineWave(frequency: 0.5).scaledTo(minimum: minimum, maximum: maximum)

//: So our oscillator will move around randomly in frequency and have a smoothly varying amplitude
let oscillator = sineWave(frequency: frequency, amplitude: volume)

//: Connect up the the nodes
let oscillatorNode = AKNode.generator(oscillator)
let tracker = AKFrequencyTracker(oscillatorNode, minimumFrequency: minimum, maximumFrequency: maximum)


//: The amplitude tracker's passes its input to the output, so we can insert into the signal chain at the bottom
audiokit.audioOutput = tracker
audiokit.start()

//: And here's where we monitor the results of tracking the amplitude.
let updater = AKPlaygroundLoop(every: 0.1) {
    let amp = tracker.amplitude
    let freq = tracker.frequency

}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: You can experiment with this playground by changing the volume function to a phasor or another well-known function to see how well the amplitude tracker can track.  Also, you could change the sound source from an oscillator to a noise generator, or any constant sound source (some things like a physical model would not work because the output has an envelope to its volume).  Instead of just plotting our results, we could use the value to drive other sounds or update an app's user interface.

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
