//: ## Phasor Operation
//: Using the phasor to sweep amplitude and frequencies
import XCPlayground
import AudioKit

let interval: Double = 2
let noteCount: Double = 24
let startingNote: Double = 48 // C

let generator = AKOperationGenerator() { _ in

    let frequency = (floor(AKOperation.phasor(frequency: 0.5) * noteCount) * interval  + startingNote)
        .midiNoteToFrequency()

    var amplitude = (AKOperation.phasor(frequency: 0.5) - 1).portamento() // prevents the click sound

    var oscillator = AKOperation.sineWave(frequency: frequency, amplitude: amplitude)
    let reverb = oscillator.reverberateWithChowning()
    return mixer(oscillator, reverb, balance: 0.6)
}

AudioKit.output = generator
AudioKit.start()
generator.start()

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
