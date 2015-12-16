//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## FM Oscillator Operation
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: Set up the operations that will be used to make a generator node
let sine = sineWave(frequency: 1.ak)
let square = squareWave(frequency: 1.64.ak)
let square2 = squareWave(frequency: sine, amplitude: sine, pulseWidth: sine)
let freq  = sine.scaledTo(minimum: 900, maximum: 200)
let car   = square.scaledTo(minimum: 1.2, maximum: 1.4)
let mod   = square.scaledTo(minimum: 1,   maximum: 3)
let index = square2 * 3 + 5
let oscillator = AKParameter.fmOscillator(
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
