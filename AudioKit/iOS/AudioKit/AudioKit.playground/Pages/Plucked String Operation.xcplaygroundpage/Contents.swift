//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Plucked String Operation
//: ### Experimenting with a physical model of a string

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let playRate = 3.0

let randomNoteNumber = floor(randomNumberPulse(minimum: 12.ak, maximum: 96.ak, updateFrequency: 20.ak))
let frequency = randomNoteNumber.midiNoteToFrequency()
let trigger = metronome(playRate)
let pluck = pluckedStringTriggeredBy(
    trigger,
    frequency: frequency,
    position: 0.2.ak,
    pickupPosition: 0.1.ak,
    reflectionCoefficent: 0.01.ak,
    amplitude: 0.5.ak)

let pluckNode = AKNode.generator(pluck)

let distortion = AKDistortion(pluckNode)
distortion.finalMix = 50
distortion.decimationMix = 0
distortion.ringModMix = 0
distortion.softClipGain = 0

let delay  = AKDelay(distortion)
delay.time = 1.5 / playRate
delay.dryWetMix = 30
delay.feedback = 20

let reverb = AKReverb(delay)

//: Connect the sampler to the main output
audiokit.audioOutput = reverb
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
