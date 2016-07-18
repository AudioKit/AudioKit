//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dripping Sounds
//: ### Physical model of a water drop letting hitting a pool.
//: ### What's this good for?  We don't know, but hey it's cool. :)
import AudioKit
import XCPlayground

let playRate = 2.0

let drip = AKDrip(intensity: 10,
                  dampingFactor: 0.9,
                  energyReturn: 1.5,
                  mainResonantFrequency: 1000.0,
                  firstResonantFrequency: 1500.0,
                  secondResonantFrequency: 2250.0,
                  amplitude: 0.1)

let reverb = AKReverb(drip)


AudioKit.output = reverb
AudioKit.start()

AKPlaygroundLoop(frequency: playRate) {
    drip.trigger()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
