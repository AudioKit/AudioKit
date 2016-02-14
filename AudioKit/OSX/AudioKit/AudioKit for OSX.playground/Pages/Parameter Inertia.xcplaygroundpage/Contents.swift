//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Parameter Inertia
//: ### Ramping to values at different rates
import XCPlayground
import AudioKit

var noise = AKWhiteNoise(amplitude: 1)
var filter = AKMoogLadder(noise)

filter.resonance = 0.94
filter.inertia = 0.0002

AudioKit.output = filter
AudioKit.start()

noise.start()

var counter = 0

AKPlaygroundLoop(frequency: 2.66) {
    let frequencyToggle = counter % 2
    let inertiaToggle = counter % 16
    if frequencyToggle > 0 {
        filter.cutoffFrequency = 111
    } else {
        filter.cutoffFrequency = 666
    }
    if inertiaToggle > 8 {
        filter.inertia = 0.2
    } else {
        filter.inertia = 0.0002
    }
    
    counter += 1
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
