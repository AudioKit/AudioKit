//: ## Sampler
//: Loading a sampler with a reference wav file
import AudioKitPlaygrounds
import AudioKit
import AudioKitUI

let pulse = 0.23 // seconds

let sampler = AKAppleSampler()
try sampler.loadWav("Samples/FM Piano")

var delay = AKDelay(sampler)
delay.time = pulse * 1.5
delay.dryWetMix = 0.3
delay.feedback = 0.2

let reverb = AKReverb(delay)
reverb.loadFactoryPreset(.largeRoom)

var mixer = AKMixer(reverb)
mixer.volume = 5.0

engine.output = mixer
try engine.start()

//: This is a loop to send a random note to the sampler
AKPlaygroundLoop(every: pulse) {
    let scale = [0, 2, 4, 5, 7, 9, 11, 12]
    var note = scale.randomElement()!
    let octave = [3, 4, 5, 6, 7].randomElement()! * 12
    if random(in: 0...10) < 1.0 { note += 1 }
    if !scale.contains(note % 12) { AKLog("ACCIDENT!") }
    if random(in: 0...6) > 1.0 { try! sampler.play(noteNumber: MIDINoteNumber(note + octave)) }
}

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
