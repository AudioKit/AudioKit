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
let sampleRate = AKP.scale(sine, minimum: 300.ak, maximum: 900.ak)
let bitDepth   = AKP.scale(sine, minimum:   8.ak, maximum:   2.ak)
let oscillator = AKP.sine(frequency: 440.ak)

let bitCrush = AKP.bitCrush(oscillator, bitDepth: bitDepth, sampleRate: sampleRate)

let generator = AKNode.generator(bitCrush * 0.2)

audiokit.audioOutput = generator
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
