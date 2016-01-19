//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Dripping Sounds
//: ### Physical model of a water drop letting hitting a pool.  What's this good for?  We don't know, but hey it's cool. :)
import AudioKit
import XCPlayground

let playRate = 2.0

let audiokit = AKManager.sharedInstance

let drip = AKDrip()
drip.intensity = 100

let reverb = AKReverb(drip)


audiokit.audioOutput = reverb
audiokit.start()

AKPlaygroundLoop(frequency: playRate) {
    drip.trigger()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
