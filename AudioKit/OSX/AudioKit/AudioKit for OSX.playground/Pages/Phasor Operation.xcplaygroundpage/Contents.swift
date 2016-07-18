//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Phasor Operation
//: ### Here we use the phasor to sweep amplitude and frequencies
import XCPlayground
import AudioKit

let interval: Double = 2
let noteCount: Double = 24
let startingNote: Double = 48 // C
let frequency = (floor(AKOperation.phasor(frequency: 0.5) * noteCount) * interval  + startingNote)
    .midiNoteToFrequency()

var amplitude = (AKOperation.phasor(frequency: 0.5) - 1).portamento() // prevents the click sound

var oscillator = AKOperation.sineWave(frequency: frequency, amplitude: amplitude)
let reverb = oscillator.reverberateWithChowning()
let oscillatorReverbMix = mixer(oscillator, reverb, balance: 0.6)
let generator = AKOperationGenerator(operation: oscillatorReverbMix)

AudioKit.output = generator
AudioKit.start()
generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
