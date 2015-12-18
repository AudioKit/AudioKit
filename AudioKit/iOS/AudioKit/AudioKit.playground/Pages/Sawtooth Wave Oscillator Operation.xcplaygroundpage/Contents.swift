//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sawtooth Wave Oscillator Operation
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Set up the operations that will be used to make a generator node

let freq = jitter(amplitude: 200.ak, minimumFrequency: 1.ak, maximumFrequency: 10.0.ak) + 200
let amp  = jitter(amplitude: 0.5.ak, minimumFrequency: 0.1.ak, maximumFrequency: 1.0.ak)
let oscillator = sawtoothWave(frequency: freq, amplitude: amp)

//: Set up the nodes
let generator = AKNode.generator(oscillator)

audiokit.audioOutput = generator
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
