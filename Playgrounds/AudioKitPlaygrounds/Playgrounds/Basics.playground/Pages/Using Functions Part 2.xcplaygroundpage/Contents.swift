//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Using Functions Part 2
//:
import AudioKitPlaygrounds
import AudioKit

func instrument(noteNumber: MIDINoteNumber, rate: Double, amplitude: Double) -> AKOperation {
    let metro = AKOperation.metronome(frequency: 82.0 / (60.0 * rate))
    let frequency = noteNumber.midiNoteToFrequency()
    return AKOperation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)
        .triggeredWithEnvelope(trigger: metro, attack: 0.5, hold: 1, release: 1)
}

let generator = AKOperationGenerator { _ in
    let instrument1 = instrument(noteNumber: 60, rate: 4, amplitude: 0.5)
    let instrument2 = instrument(noteNumber: 62, rate: 5, amplitude: 0.4)
    let instrument3 = instrument(noteNumber: 65, rate: 7, amplitude: 1.3 / 4.0)
    let instrument4 = instrument(noteNumber: 67, rate: 7, amplitude: 0.125)

    let instruments = (instrument1 + instrument2 + instrument3 + instrument4) * 0.13

    let reverb = instruments.reverberateWithCostello(feedback: 0.9, cutoffFrequency: 10_000).toMono()

    return mixer(instruments, reverb, balance: 0.4)
}

AudioKit.output = generator
try AudioKit.start()

generator.start()

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
