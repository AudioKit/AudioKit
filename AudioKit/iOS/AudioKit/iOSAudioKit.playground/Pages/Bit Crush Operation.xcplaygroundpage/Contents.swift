//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## bitCrush
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: ```AKP``` is basically shorthand for AKParameter, with type methods that return AKParameters that you can use in other operations
let sine = AKP.sine(frequency: 1.ak)
let sampleRate = AKP.scale(sine, minimumOutput: 1000.ak, maximumOutput: 5000.ak)
let bitDepth   = AKP.scale(sine, minimumOutput:   16.ak, maximumOutput:    4.ak)
let frequency  = AKP.scale(sine, minimumOutput:  220.ak, maximumOutput:  440.ak)
let oscillator = AKP.sine(frequency: frequency, amplitude:   0.1.ak)

let bitCrush = AKP.bitCrush(oscillator, bitDepth: bitDepth, sampleRate: sampleRate)

let generator = AKP.generator(bitCrush)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
