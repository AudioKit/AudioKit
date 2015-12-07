//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## fmOscillator
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

//: ```AKP``` is basically shorthand for AKParameter, with type methods that return AKParameters that you can use in other operations
let sine  = AKP.sine(frequency: 1.ak)
let sine2 = AKP.sine(frequency: 1.64.ak)
let freq  = AKP.scale(sine,  minimumOutput: 900.ak, maximumOutput: 400.ak)
let car   = AKP.scale(sine2, minimumOutput: 1.ak,   maximumOutput: 2.ak) * 7 + 3
let mod   = AKP.scale(sine,  minimumOutput: 1.ak,   maximumOutput: 3.ak) * 2
let index = AKP.scale(sine2, minimumOutput: 1.ak,   maximumOutput: 5.ak) / 5 + 3
let oscillator = AKP.fmOscillator(baseFrequency: freq, carrierMultiplier: car, modulatingMultiplier: mod, modulationIndex: index, amplitude: 0.1.ak)

let generator = AKP.generator(oscillator)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
