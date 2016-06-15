//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parameter Ramp Time
//: ### Ramping to values at different rates
import PlaygroundSupport
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

PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
