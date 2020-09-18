//: ## Phasor Operation
//: Using the phasor to sweep amplitude and frequencies

import AudioKit

let interval: Double = 2
let noteCount: Double = 24
let startingNote: Double = 48 // C

let generator = OperationGenerator {

    let frequency = (floor(Operation.phasor(frequency: 0.5) * noteCount) * interval + startingNote)
        .midiNoteToFrequency()

    var amplitude = (Operation.phasor(frequency: 0.5) - 1).portamento() // prevents the click sound

    var oscillator = Operation.sineWave(frequency: frequency, amplitude: amplitude)
    let reverb = oscillator.reverberateWithChowning()
    return mixer(oscillator, reverb, balance: 0.6)
}

engine.output = generator
try engine.start()
generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
