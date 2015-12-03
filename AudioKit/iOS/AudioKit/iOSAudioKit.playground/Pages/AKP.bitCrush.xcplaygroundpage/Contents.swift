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
let sampleRate = AKP.scale(sine, minimum: 1000.ak, maximum: 5000.ak)
let bitDepth   = AKP.scale(sine, minimum:    2.ak, maximum:   16.ak)
let frequency  = AKP.scale(sine, minimum:  220.ak, maximum:  440.ak)
let oscillator = AKP.sine(frequency: frequency)

let bitCrush = AKP.bitCrush(oscillator, bitDepth: bitDepth, sampleRate: sampleRate)

let generator = AKP.generator(bitCrush)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
