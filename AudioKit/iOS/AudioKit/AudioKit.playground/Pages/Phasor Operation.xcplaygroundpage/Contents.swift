//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phasor Operation
//: ### Here we use the phasor to sweep amplitude and frequencies
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let interval: Double = 2
let numberOfNotes: Double = 24
let startingNote: Double = 48 // C
let frequency = (floor(phasor(frequency: 0.5.ak) * numberOfNotes) * interval  + startingNote).midiNoteToFrequency()

var amplitude = phasor(frequency: 0.5.ak) - 1
amplitude.applyPortamento() // prevents the click sound

var oscillator = sineWave(frequency: frequency, amplitude: amplitude)
let reverb = oscillator.reverberatedWithChowning()
let oscillatorReverbMix = mix(oscillator, reverb, t: 0.6)
let generator = AKNode.generator(oscillatorReverbMix)

audiokit.audioOutput = generator
audiokit.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
