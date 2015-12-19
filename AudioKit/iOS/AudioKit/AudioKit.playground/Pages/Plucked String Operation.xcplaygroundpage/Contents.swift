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
let frequency = randomNoteNumber.midiNoteToFrequency()
let string = pluckedString(
    frequency: frequency,
    position: 0.2.ak,
    pickupPosition: 0.1.ak,
    reflectionCoefficent: 0.01.ak,
    amplitude: 0.5.ak)
let trigger = metronome(3)
let pluck = AKOperation("\(trigger) \(string)")

let pluckNode = AKNode.generator(pluck)

let delay  = AKDelay(pluckNode)
delay.time = 1.0 / 3.0 * 1.5
delay.dryWetMix = 30
delay.feedback = 20

let reverb = AKReverb(delay)

//: Connect the sampler to the main output
audiokit.audioOutput = reverb
audiokit.start()


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
