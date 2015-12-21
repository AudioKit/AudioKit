//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## bitCrush
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let sinusoid = sineWave(frequency: 1)
let sampleRate = sinusoid.scaledTo(minimum: 300, maximum: 900)
let bitDepth   = sinusoid.scaledTo(minimum:   8, maximum:   2)
let oscillator = sineWave(frequency: 440)
let bitCrush = oscillator.bitCrushed(bitDepth: bitDepth, sampleRate: sampleRate)

let generator = AKNode.generator(bitCrush * 0.2)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
