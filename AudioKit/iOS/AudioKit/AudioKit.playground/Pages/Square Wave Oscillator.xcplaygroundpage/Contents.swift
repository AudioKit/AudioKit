//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Square Wave Oscillator
//: ### Generating audio
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance
let sawtooth = AKSquareWaveOscillator()
audiokit.audioOutput = sawtooth
audiokit.start()

var t: Float = 0

let updater = AKPlaygroundLoop(every: 0.12) {
    sawtooth.frequency.randomize(100, 220)
    sawtooth.pulseWidth = 0.99 - abs(0.9 * cos(t))
    t = t + 0.01
    sawtooth.amplitude.randomize(0, 0.2)
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
