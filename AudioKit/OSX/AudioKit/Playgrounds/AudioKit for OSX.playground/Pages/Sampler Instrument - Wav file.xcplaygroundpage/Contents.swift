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

let delay  = AKDelay(sampler)
delay.time = pulse * 1.5
delay.dryWetMix = 30
delay.feedback = 20

let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeRoom)

let mixer = AKMixer(reverb)
mixer.volume = 5.0

//: Connect the sampler to the main output
audiokit.audioOutput = mixer
audiokit.start()

//: This is a loop to send a random note to the sampler
//: The sampler 'playNote' function is very useful here
AKPlaygroundLoop.start(every: pulse) { timer in
    let scale = [0,2,4,5,7,9,11,12]
    let note = scale.randomElement()
    let octave = randomInt(3...7)  * 12
    let accidental = [1,0,0,0,0,0,0,0,0,0,0].randomElement()
    if accidental != 0 && !scale.contains(accidental % 12) { print("ACCIDENT!") }
    sampler.playNote(note + octave + accidental)
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
