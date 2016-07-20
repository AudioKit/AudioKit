//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Tracking Amplitude
//: ### Here, we show how you can determine the amplitude of an audio signal by
//: ### outputting the value of a generator node into the AKAmplitudeTracker.
//: ### This node is great if you want to build an app that does audio monitoring and analysis.
import XCPlayground
import AudioKit

//: First lets set up sound source to track
let oscillatorNode = AKOperationGenerator() {
    // Let's set up the volume to be changing in the shape of a sine wave
    let volume = AKOperation.sineWave(frequency:0.2).scale(minimum: 0, maximum: 0.5)
    
    // And lets make the frequency move around to make sure it doesn't affect the amplitude tracking
    let frequency = AKOperation.jitter(amplitude: 200, minimumFrequency: 10, maximumFrequency: 30) + 200
    
    // So our oscillator will move around randomly in frequency and have a smoothly varying amplitude
    return AKOperation.sineWave(frequency: frequency, amplitude: volume)
}

let trackedAmplitude = AKAmplitudeTracker(oscillatorNode)

//: The amplitude tracker passes its input to the output, so we can insert into the signal chain at the bottom
AudioKit.output = trackedAmplitude
AudioKit.start()
oscillatorNode.start()

//: And here's where we monitor the results of tracking the amplitude.
AKPlaygroundLoop(every: 0.1) {
    let amp = trackedAmplitude.amplitude
}

//: This keeps the playground running so that audio can play for a long time
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true


//: You can experiment with this playground by changing the volume function to a
//: phasor or another well-known function to see how well the amplitude tracker
//: can track.  Also, you could change the sound source from an oscillator to a
//: noise generator, or any constant sound source (some things like a physical
//: model would not work because the output has an envelope to its volume).
//: Instead of just plotting our results, we could use the value to drive other
//: sounds or update an app's user interface.
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
