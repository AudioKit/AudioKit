//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sampler Instrument - Wav File
//: ### Loading a sampler with a reference wav file

import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let pulse = 0.23 // seconds

//: We are going to load an EXS24 instrument and send it random notes

let sampler = AKSampler()

//: Here is where we reference the Wav file as it is in the app bundle
sampler.loadWav("Sounds/fmpia1")

let ampedSampler = AKGain(sampler, gain: 3.0)

var delay  = AKDelay(ampedSampler)
delay.time = pulse * 1.5
delay.dryWetMix = 30
delay.feedback = 20

let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeRoom)

//: Connect the sampler to the main output
audiokit.audioOutput = reverb
audiokit.start()

//: This is a loop to send a random note to the sampler
//: The sampler 'playNote' function is very useful here
let updater = AKPlaygroundLoop(every: pulse) {
    let scale = [0,2,4,5,7,9,11,12]
    var note = scale.randomElement()
    let octave = randomInt(3...6)  * 12
    if random(0, 10) < 1.0 { note++ }
    if !scale.contains(note % 12) { print("ACCIDENT!") }
    if random(0, 6) > 1.0 { sampler.playNote(note + octave) }
}

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
