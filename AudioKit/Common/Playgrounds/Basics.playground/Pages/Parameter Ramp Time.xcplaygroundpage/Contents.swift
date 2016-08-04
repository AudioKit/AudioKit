//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parameter Ramp Time
//: ### Most AudioKit nodes have parameters that you can change.
//: ### Its very common need to change these parameters in a smooth way
//: ### to avoid pops and clicks, so you can set a ramp time to slow the 
//: ### variation of a property from its current value to its next.
import XCPlayground
import AudioKit

var noise = AKWhiteNoise(amplitude: 1)
var filter = AKMoogLadder(noise)

filter.resonance = 0.94

AudioKit.output = filter
AudioKit.start()

noise.start()

var counter = 0

AKPlaygroundLoop(frequency: 2.66) {
    let frequencyToggle = counter % 2
    let rampTimeToggle = counter % 16
    if frequencyToggle > 0 {
        filter.cutoffFrequency = 111
    } else {
        filter.cutoffFrequency = 666
    }
    if rampTimeToggle > 8 {
        filter.rampTime = 0.2
    } else {
        filter.rampTime = 0.0002
    }
    counter += 1
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
