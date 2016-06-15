//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## Using Functions Part 2
//:
import PlaygroundSupport
import AudioKit

func instrument(noteNumber: Int, rate: Double, amplitude: Double) -> AKOperation {
    let metro = AKOperation.metronome(82.0 / (60.0 * rate))
    let frequency = noteNumber.midiNoteToFrequency()
    return AKOperation.fmOscillator(baseFrequency: frequency, amplitude: amplitude)
        .triggeredWithEnvelope(metro, attack: 0.5, hold: 1, release: 1)
}

let instrument1 = instrument(60, rate: 4, amplitude: 0.5)
let instrument2 = instrument(62, rate: 5, amplitude: 0.4)
let instrument3 = instrument(65, rate: 7, amplitude: 1.3/4.0)
let instrument4 = instrument(67, rate: 7, amplitude: 0.125)

let instruments = (instrument1 + instrument2 + instrument3 + instrument4) * 0.13

let reverb = instruments.reverberateWithCostello(feedback: 0.9, cutoffFrequency: 10000).toMono()

let generator = AKOperationGenerator(operation: mixer(instruments, reverb, balance: 0.4))

AudioKit.output = generator
AudioKit.start()

generator.start()

PlaygroundPage.current.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
