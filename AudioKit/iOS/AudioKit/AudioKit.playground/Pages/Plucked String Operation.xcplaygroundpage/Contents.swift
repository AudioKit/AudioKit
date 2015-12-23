//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Plucked String Operation
//: ### Experimenting with a physical model of a string

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let playRate = 2.0

let randomNoteNumber = floor(randomNumberPulse(minimum: 12, maximum: 96, updateFrequency: 20))
let frequency = randomNoteNumber.midiNoteToFrequency()
let trigger = metronome(playRate)
let pluck = pluckedString(
    frequency: frequency,
    position: 0.2,
    pickupPosition: 0.1,
    reflectionCoefficent: 0.01,
    amplitude: 0.5)

let pluckNode = AKOperationGenerator(operation: pluck, triggered: true)

var distortion = AKDistortion(pluckNode)
distortion.finalMix = 50
distortion.decimationMix = 0
distortion.ringModMix = 0
distortion.softClipGain = 0

var delay  = AKDelay(distortion)
delay.time = 1.5 / playRate
delay.dryWetMix = 30
delay.feedback = 20

let reverb = AKReverb(delay)

//: Connect the sampler to the main output
audiokit.audioOutput = reverb
audiokit.start()

let updater = AKPlaygroundLoop(every: 1.0 / playRate) {
    pluckNode.trigger()
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
