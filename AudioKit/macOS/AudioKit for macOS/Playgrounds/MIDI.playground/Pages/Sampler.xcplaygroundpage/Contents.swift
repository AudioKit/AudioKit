//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Sampler
//: ### Loading a sampler with a reference wav file

import XCPlayground
import AudioKit

let pulse = 0.23 // seconds

//: We are going to load an EXS24 instrument and send it random notes

let sampler = AKSampler()

//: Here is where we reference the Wav file as it is in the app bundle
sampler.loadWav("Sounds/fmpia1")

var delay  = AKDelay(sampler)
delay.time = pulse * 1.5
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.LargeRoom)

var mixer = AKMixer(reverb)
mixer.volume = 5.0

//: Connect the sampler to the main output
AudioKit.output = mixer
AudioKit.start()

//: This is a loop to send a random note to the sampler
//: The sampler 'playNote' function is very useful here
AKPlaygroundLoop(every: pulse) { timer in
    let scale = [0, 2, 4, 5, 7, 9, 11, 12]
    var note = scale.randomElement()
    let octave = randomInt(3...7)  * 12
    if random(0, 10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { print("ACCIDENT!") }
    if random(0, 6) > 1.0 { sampler.play(noteNumber: note + octave) }
}


XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
