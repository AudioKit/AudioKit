//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Plucked String Operation
//: ### Experimenting with a physical model of a string

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let randomNoteNumber = floor(randomNumberPulse(minimum: 12.ak, maximum: 96.ak, updateFrequency: 20.ak))
let frequency = randomNoteNumber.midiNoteNumberToFrequency()
let string = pluckedString(
    frequency: frequency,
    position: 0.2.ak,
    pickupPosition: 0.1.ak,
    reflectionCoefficent: 0.01.ak,
    amplitude: 0.5.ak)
let trigger = metronome(3.ak)
let pluck = AKOperation("\(trigger) \(string)")
let generator = AKNode.generator(pluck)
//: Connect the sampler to the main output
audiokit.audioOutput = generator
audiokit.start()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
