//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## fmOscillator
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Set up the operations that will be used to make a generator node
let sine  = AKP.sine(frequency: 1.ak)
let sine2 = AKP.sine(frequency: 1.64.ak)
let scaleFactor = 1.4
let sine3 = floor(sine.scaledBy(scaleFactor)).dividedBy(scaleFactor)
let freq  = AKP.scale(sine3, minimum: 900.ak, maximum: 0.ak)
let car   = AKP.scale(sine2, minimum: 1.ak,   maximum: 1.4.ak)
let mod   = AKP.scale(sine,  minimum: 1.ak,   maximum: 3.ak)
let index = sine3 * 3 + 5
let oscillator = AKP.fmOscillator(
    baseFrequency: freq,
    carrierMultiplier: car,
    modulatingMultiplier: mod,
    modulationIndex: index,
    amplitude: 0.5.ak)

//: Set up the nodes
let generator = AKNode.generator(oscillator)
let delay1 = AKDelay(generator,
    time: 0.01, feedback: 99, lowPassCutoff: 0, dryWetMix: 50)
let delay2 = AKDelay(delay1,
    time: 0.1, feedback: 10, lowPassCutoff: 0, dryWetMix: 50)
let reverb = AKReverb(delay2, dryWetMix: 50)

audiokit.audioOutput = reverb
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
